import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final Connectivity connectivity;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  @override
  Future<({List<ProductEntity> products, bool isFromCache, String? error})> getProducts({
    bool forceRefresh = false,
    String? category,
  }) async {
    // 1. Read from local Hive cache
    final cachedModels = await localDataSource.getCachedProducts();
    var cachedEntities = cachedModels.map((m) => m.toEntity()).toList();

    if (category != null && category.isNotEmpty) {
      cachedEntities = cachedEntities.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
    }

    // 2. Check network connectivity
    final connectivityResult = await connectivity.checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    // Offline mode: serve cache immediately
    if (!isOnline) {
      AppLogger.w('🌐 Offline: Returning ${cachedEntities.length} cached products.');
      return (
        products: cachedEntities,
        isFromCache: true,
        error: cachedEntities.isEmpty
            ? 'No internet connection and no offline cached products found.'
            : 'You are currently offline. Displaying cached products.',
      );
    }

    // 3. Online: Fetch from FakeStore API if forceRefresh or cache is empty
    try {
      AppLogger.i('🌐 Fetching products from FakeStore API (Category: ${category ?? 'All'})...');
      final remoteModels = category != null && category.isNotEmpty
          ? await remoteDataSource.getProductsByCategory(category)
          : await remoteDataSource.getProducts();

      // Update Hive local cache
      final hiveModels = remoteModels.map((m) => m.toHiveModel()).toList();
      await localDataSource.cacheProducts(hiveModels);

      final freshEntities = remoteModels.map((m) => m.toEntity()).toList();
      return (products: freshEntities, isFromCache: false, error: null);
    } on AppException catch (e) {
      AppLogger.e('⚠️ Remote fetch failed: ${e.message}. Using cache fallback.');
      if (cachedEntities.isNotEmpty) {
        return (
          products: cachedEntities,
          isFromCache: true,
          error: 'Could not refresh from API (${e.message}). Showing cached products.',
        );
      }
      return (products: <ProductEntity>[], isFromCache: false, error: e.message);
    } catch (e) {
      AppLogger.e('⚠️ Unexpected error: $e');
      if (cachedEntities.isNotEmpty) {
        return (
          products: cachedEntities,
          isFromCache: true,
          error: 'Unexpected error. Showing cached products.',
        );
      }
      return (products: <ProductEntity>[], isFromCache: false, error: e.toString());
    }
  }

  @override
  Future<({ProductEntity? product, bool isFromCache, String? error})> getProductDetails(
    int id, {
    bool forceRefresh = false,
  }) async {
    final cached = await localDataSource.getCachedProductDetails(id);
    final cachedEntity = cached?.toEntity();

    final connectivityResult = await connectivity.checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (!isOnline) {
      if (cachedEntity != null) {
        return (product: cachedEntity, isFromCache: true, error: 'Offline mode: Showing cached product.');
      }
      return (product: null, isFromCache: true, error: 'No connection and product is not cached.');
    }

    try {
      final remoteModel = await remoteDataSource.getProductDetails(id);
      await localDataSource.cacheProduct(remoteModel.toHiveModel());
      return (product: remoteModel.toEntity(), isFromCache: false, error: null);
    } on AppException catch (e) {
      if (cachedEntity != null) {
        return (product: cachedEntity, isFromCache: true, error: 'API error. Showing cached product.');
      }
      return (product: null, isFromCache: false, error: e.message);
    }
  }

  @override
  Future<List<String>> getCategories({bool forceRefresh = false}) async {
    final cachedCategories = await localDataSource.getCachedCategories();

    final connectivityResult = await connectivity.checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    if (!isOnline || (!forceRefresh && cachedCategories.isNotEmpty)) {
      if (cachedCategories.isNotEmpty) return cachedCategories;
    }

    try {
      final remoteCategories = await remoteDataSource.getCategories();
      await localDataSource.cacheCategories(remoteCategories);
      return remoteCategories;
    } catch (e) {
      AppLogger.w('Failed to fetch fresh categories: $e');
      return cachedCategories;
    }
  }

  @override
  Future<void> clearCache() async {
    await localDataSource.clearCache();
  }
}

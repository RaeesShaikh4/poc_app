import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/product_hive_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductHiveModel>> getCachedProducts();
  Future<ProductHiveModel?> getCachedProductDetails(int id);
  Future<void> cacheProducts(List<ProductHiveModel> products);
  Future<void> cacheProduct(ProductHiveModel product);
  Future<List<String>> getCachedCategories();
  Future<void> cacheCategories(List<String> categories);
  Future<void> clearCache();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final HiveService hiveService;

  ProductLocalDataSourceImpl({required this.hiveService});

  @override
  Future<List<ProductHiveModel>> getCachedProducts() async {
    try {
      final box = hiveService.productsBox;
      final products = box.values.toList();
      AppLogger.i('💾 Read ${products.length} products from Hive cache.');
      return products;
    } catch (e) {
      throw CacheException('Failed to read products from Hive storage: $e');
    }
  }

  @override
  Future<ProductHiveModel?> getCachedProductDetails(int id) async {
    try {
      final box = hiveService.productsBox;
      return box.get(id);
    } catch (e) {
      throw CacheException('Failed to read product #$id from Hive: $e');
    }
  }

  @override
  Future<void> cacheProducts(List<ProductHiveModel> products) async {
    try {
      final box = hiveService.productsBox;
      final Map<dynamic, ProductHiveModel> entries = {
        for (var product in products) product.id: product,
      };
      await box.putAll(entries);
      AppLogger.i('💾 Saved ${products.length} products to Hive cache.');
    } catch (e) {
      throw CacheException('Failed to save products to Hive: $e');
    }
  }

  @override
  Future<void> cacheProduct(ProductHiveModel product) async {
    try {
      final box = hiveService.productsBox;
      await box.put(product.id, product);
    } catch (e) {
      throw CacheException('Failed to save product to Hive: $e');
    }
  }

  @override
  Future<List<String>> getCachedCategories() async {
    try {
      final box = hiveService.categoriesBox;
      return box.values.toList();
    } catch (e) {
      throw CacheException('Failed to read categories from Hive: $e');
    }
  }

  @override
  Future<void> cacheCategories(List<String> categories) async {
    try {
      final box = hiveService.categoriesBox;
      await box.clear();
      await box.addAll(categories);
    } catch (e) {
      throw CacheException('Failed to cache categories into Hive: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await hiveService.clearAll();
      AppLogger.w('🗑️ Cleared all Hive storage.');
    } catch (e) {
      throw CacheException('Failed to clear Hive storage: $e');
    }
  }
}

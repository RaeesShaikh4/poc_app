import '../entities/product_entity.dart';

/// Contract for Product operations following offline-first principles.
abstract class ProductRepository {
  /// Fetches products using an offline-first strategy:
  /// 1. Reads local Hive cache.
  /// 2. If [forceRefresh] is true or cache is empty, fetches from FakeStore API.
  /// 3. Saves fresh data to Hive.
  /// 4. Gracefully falls back to cache on offline / network error.
  Future<({List<ProductEntity> products, bool isFromCache, String? error})> getProducts({
    bool forceRefresh = false,
    String? category,
  });

  /// Fetches a single product by ID.
  Future<({ProductEntity? product, bool isFromCache, String? error})> getProductDetails(
    int id, {
    bool forceRefresh = false,
  });

  /// Fetches available categories.
  Future<List<String>> getCategories({bool forceRefresh = false});

  /// Clears offline Hive storage.
  Future<void> clearCache();
}

import 'package:hive_flutter/hive_flutter.dart';
import '../../features/products/data/models/product_hive_model.dart';
import '../constants/storage_keys.dart';
import '../utils/app_logger.dart';

/// Centralized service for initializing Hive, registering TypeAdapters,
/// and accessing storage boxes.
class HiveService {
  static Future<void> init() async {
    AppLogger.i('📦 Initializing Hive storage...');
    await Hive.initFlutter();

    // Register Type Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductHiveModelAdapter());
    }

    // Open boxes ahead of time
    await Hive.openBox<ProductHiveModel>(StorageKeys.productsBox);
    await Hive.openBox<String>(StorageKeys.categoriesBox);
    AppLogger.i('📦 Hive initialized and boxes opened successfully.');
  }

  Box<ProductHiveModel> get productsBox => Hive.box<ProductHiveModel>(StorageKeys.productsBox);
  Box<String> get categoriesBox => Hive.box<String>(StorageKeys.categoriesBox);

  Future<void> clearAll() async {
    await productsBox.clear();
    await categoriesBox.clear();
    AppLogger.w('📦 Cleared all data from Hive boxes.');
  }
}

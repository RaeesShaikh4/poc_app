import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../network/dio_logging_interceptor.dart';
import '../storage/hive_service.dart';
import '../../features/products/data/datasources/product_local_datasource.dart';
import '../../features/products/data/datasources/product_remote_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/presentation/providers/product_provider.dart';

final sl = GetIt.instance;

/// Initialize all core dependencies, clients, data sources, repositories, and providers.
Future<void> initDependencies(AppConfig config) async {
  // 1. Config
  if (sl.isRegistered<AppConfig>()) {
    await sl.unregister<AppConfig>();
  }
  sl.registerSingleton<AppConfig>(config);

  // 2. Storage & Connectivity
  if (!sl.isRegistered<HiveService>()) {
    sl.registerLazySingleton<HiveService>(() => HiveService());
  }
  if (!sl.isRegistered<Connectivity>()) {
    sl.registerLazySingleton<Connectivity>(() => Connectivity());
  }

  // 3. Network & Dio with Custom Logger Interceptor
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(() {
      final dio = Dio(
        BaseOptions(
          baseUrl: config.apiBaseUrl,
          connectTimeout: Duration(milliseconds: config.connectTimeoutMs),
          receiveTimeout: Duration(milliseconds: config.receiveTimeoutMs),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // Add custom logger interceptor
      dio.interceptors.add(
        DioLoggingInterceptor(isEnabled: config.enableNetworkLogs),
      );

      return dio;
    });
  }

  // 4. Retrofit REST API Client for FakeStore
  if (!sl.isRegistered<ApiClient>()) {
    sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<Dio>(), baseUrl: config.apiBaseUrl));
  }

  // 5. Data Sources
  if (!sl.isRegistered<ProductRemoteDataSource>()) {
    sl.registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
    );
  }
  if (!sl.isRegistered<ProductLocalDataSource>()) {
    sl.registerLazySingleton<ProductLocalDataSource>(
      () => ProductLocalDataSourceImpl(hiveService: sl<HiveService>()),
    );
  }

  // 6. Repositories
  if (!sl.isRegistered<ProductRepository>()) {
    sl.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(
        remoteDataSource: sl<ProductRemoteDataSource>(),
        localDataSource: sl<ProductLocalDataSource>(),
        connectivity: sl<Connectivity>(),
      ),
    );
  }

  // 7. Presentation Providers
  if (!sl.isRegistered<ProductProvider>()) {
    sl.registerFactory<ProductProvider>(
      () => ProductProvider(
        productRepository: sl<ProductRepository>(),
        connectivity: sl<Connectivity>(),
      ),
    );
  }
}

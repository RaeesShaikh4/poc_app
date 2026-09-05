import 'package:flutter/material.dart';
import 'app.dart';
import 'core/config/app_config.dart';
import 'core/config/environment.dart';
import 'core/di/injection_container.dart';
import 'core/storage/hive_service.dart';
import 'core/utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load Dev configuration (from compile-time constants or defaults)
  final config = AppConfig.fromEnvironment(env: Environment.dev);
  AppLogger.i('🚀 Launching ${config.appName} in [DEV] mode...');

  // Initialize offline Hive storage
  await HiveService.init();

  // Initialize GetIt dependency injection
  await initDependencies(config);

  runApp(const MainApp());
}

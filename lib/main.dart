import 'package:flutter/material.dart';
import 'app.dart';
import 'core/config/app_config.dart';
import 'core/di/injection_container.dart';
import 'core/storage/hive_service.dart';
import 'core/utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load configuration from environment defines
  final config = AppConfig.fromEnvironment();
  AppLogger.i('🚀 Launching ${config.appName} in [${config.environment.name.toUpperCase()}] mode...');

  // Initialize offline Hive storage
  await HiveService.init();

  // Initialize GetIt dependency injection
  await initDependencies(config);

  runApp(const MainApp());
}

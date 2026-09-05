import 'package:flutter/material.dart';
import 'app.dart';
import 'core/config/app_config.dart';
import 'core/config/environment.dart';
import 'core/di/injection_container.dart';
import 'core/storage/hive_service.dart';
import 'core/utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load Live / Production configuration
  final config = AppConfig.fromEnvironment(env: Environment.live);
  AppLogger.i('🚀 Launching ${config.appName} in [LIVE] mode...');

  // Initialize offline Hive storage
  await HiveService.init();

  // Initialize GetIt dependency injection
  await initDependencies(config);

  runApp(const MainApp());
}

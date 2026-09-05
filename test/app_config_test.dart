import 'package:flutter_test/flutter_test.dart';
import 'package:poc_mcp_app/core/config/app_config.dart';
import 'package:poc_mcp_app/core/config/environment.dart';

void main() {
  group('AppConfig Environment Tests', () {
    test('Environment.dev returns proper defaults and flags', () {
      final config = AppConfig.fromEnvironment(env: Environment.dev);
      expect(config.environment, Environment.dev);
      expect(config.environment.isDev, isTrue);
      expect(config.environment.isLive, isFalse);
      expect(config.apiBaseUrl, 'https://fakestoreapi.com');
      expect(config.enableNetworkLogs, isTrue);
    });

    test('Environment.live returns proper production config', () {
      final config = AppConfig.fromEnvironment(env: Environment.live);
      expect(config.environment, Environment.live);
      expect(config.environment.isDev, isFalse);
      expect(config.environment.isLive, isTrue);
      expect(config.apiBaseUrl, 'https://fakestoreapi.com');
      expect(config.enableNetworkLogs, isFalse);
    });
  });
}

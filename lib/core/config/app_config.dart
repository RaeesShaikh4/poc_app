import 'environment.dart';

/// Immutable configuration class for managing environment-specific settings.
/// Uses compile-time `--dart-define` / `--dart-define-from-file` constants
/// for security (keys are not hardcoded or leaked into git).
class AppConfig {
  final Environment environment;
  final String appName;
  final String apiBaseUrl;
  final int connectTimeoutMs;
  final int receiveTimeoutMs;
  final bool enableNetworkLogs;
  final bool isOfflineFirstEnabled;

  const AppConfig({
    required this.environment,
    required this.appName,
    required this.apiBaseUrl,
    this.connectTimeoutMs = 15000,
    this.receiveTimeoutMs = 15000,
    this.enableNetworkLogs = true,
    this.isOfflineFirstEnabled = true,
  });

  /// Factory constructor to securely construct [AppConfig] from compile-time defines
  /// or explicit entry-point definitions.
  factory AppConfig.fromEnvironment({Environment? env}) {
    final activeEnv = env ??
        Environment.fromString(
          const String.fromEnvironment('APP_ENV', defaultValue: 'dev'),
        );

    return switch (activeEnv) {
      Environment.dev => const AppConfig(
          environment: Environment.dev,
          appName: String.fromEnvironment(
            'APP_NAME',
            defaultValue: 'Shopify (Dev)',
          ),
          apiBaseUrl: String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'https://fakestoreapi.com',
          ),
          connectTimeoutMs: 15000,
          receiveTimeoutMs: 15000,
          enableNetworkLogs: true,
          isOfflineFirstEnabled: true,
        ),
      Environment.live => const AppConfig(
          environment: Environment.live,
          appName: String.fromEnvironment(
            'APP_NAME',
            defaultValue: 'Shopify',
          ),
          apiBaseUrl: String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'https://fakestoreapi.com',
          ),
          connectTimeoutMs: 10000,
          receiveTimeoutMs: 10000,
          enableNetworkLogs: false,
          isOfflineFirstEnabled: true,
        ),
    };
  }
}

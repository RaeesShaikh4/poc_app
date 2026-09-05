/// Environment types supported by the application.
enum Environment {
  dev,
  live;

  bool get isDev => this == Environment.dev;
  bool get isLive => this == Environment.live;

  static Environment fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'live':
      case 'prod':
      case 'production':
        return Environment.live;
      case 'dev':
      case 'development':
      default:
        return Environment.dev;
    }
  }
}

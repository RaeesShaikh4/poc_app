/// Base exception class for data layer errors.
class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, [this.statusCode]);

  @override
  String toString() => 'AppException(message: $message, statusCode: $statusCode)';
}

class ServerException extends AppException {
  ServerException(super.message, [super.statusCode]);
}

class CacheException extends AppException {
  CacheException(super.message);
}

class NetworkException extends AppException {
  NetworkException(super.message);
}

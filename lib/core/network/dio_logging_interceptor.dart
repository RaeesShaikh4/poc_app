import 'dart:convert';
import 'package:dio/dio.dart';
import '../utils/app_logger.dart';

/// Interceptor that uses [AppLogger] to log network requests, responses, and errors.
class DioLoggingInterceptor extends Interceptor {
  final bool isEnabled;

  DioLoggingInterceptor({this.isEnabled = true});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (isEnabled) {
      final buffer = StringBuffer();
      buffer.writeln('➡️ [REQUEST] ${options.method} ${options.uri}');
      if (options.headers.isNotEmpty) {
        buffer.writeln('Headers: ${jsonEncode(options.headers)}');
      }
      if (options.queryParameters.isNotEmpty) {
        buffer.writeln('QueryParams: ${jsonEncode(options.queryParameters)}');
      }
      if (options.data != null) {
        buffer.writeln('Body: ${_formatData(options.data)}');
      }
      AppLogger.i(buffer.toString());
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (isEnabled) {
      final buffer = StringBuffer();
      buffer.writeln(
        '⬅️ [RESPONSE] [${response.statusCode}] ${response.requestOptions.method} ${response.requestOptions.uri}',
      );
      if (response.data != null) {
        buffer.writeln('Data: ${_formatData(response.data)}');
      }
      AppLogger.i(buffer.toString());
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (isEnabled) {
      final buffer = StringBuffer();
      buffer.writeln(
        '❌ [ERROR] [${err.response?.statusCode ?? 'NO_CODE'}] ${err.requestOptions.method} ${err.requestOptions.uri}',
      );
      buffer.writeln('Message: ${err.message}');
      buffer.writeln('Type: ${err.type}');
      if (err.response?.data != null) {
        buffer.writeln('Response: ${_formatData(err.response?.data)}');
      }
      AppLogger.e(buffer.toString(), err.error, err.stackTrace);
    }
    super.onError(err, handler);
  }

  String _formatData(dynamic data) {
    if (data is Map || data is List) {
      try {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(data);
      } catch (_) {
        return data.toString();
      }
    }
    return data.toString();
  }
}

import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProductDetails(int id);
  Future<List<String>> getCategories();
  Future<List<ProductModel>> getProductsByCategory(String category);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      return await apiClient.getProducts();
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to fetch products from FakeStore API');
    } catch (e) {
      throw ServerException('Unexpected error during API call: $e');
    }
  }

  @override
  Future<ProductModel> getProductDetails(int id) async {
    try {
      return await apiClient.getProductDetails(id);
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to fetch product #$id details');
    } catch (e) {
      throw ServerException('Unexpected error during API call: $e');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      return await apiClient.getCategories();
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to fetch categories');
    } catch (e) {
      throw ServerException('Unexpected error during API call: $e');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      return await apiClient.getProductsByCategory(category);
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to fetch products for category $category');
    } catch (e) {
      throw ServerException('Unexpected error during API call: $e');
    }
  }

  ServerException _handleDioException(DioException e, String defaultMessage) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ServerException('Connection timed out. Please check your internet connection.', e.response?.statusCode);
    } else if (e.type == DioExceptionType.connectionError) {
      return ServerException(
        'Unable to connect to FakeStore API (Host lookup failed). Please verify your internet connection.',
        e.response?.statusCode,
      );
    } else if (e.response != null) {
      return ServerException('Server error (${e.response?.statusCode})', e.response?.statusCode);
    }
    return ServerException(e.message ?? defaultMessage, e.response?.statusCode);
  }
}

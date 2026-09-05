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
      throw ServerException(
        e.message ?? 'Failed to fetch products from FakeStore API',
        e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException('Unexpected error during API call: $e');
    }
  }

  @override
  Future<ProductModel> getProductDetails(int id) async {
    try {
      return await apiClient.getProductDetails(id);
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Failed to fetch product #$id details',
        e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException('Unexpected error during API call: $e');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      return await apiClient.getCategories();
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Failed to fetch categories',
        e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException('Unexpected error during API call: $e');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      return await apiClient.getProductsByCategory(category);
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Failed to fetch products for category $category',
        e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException('Unexpected error during API call: $e');
    }
  }
}

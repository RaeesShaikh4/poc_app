import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../features/products/data/models/product_model.dart';
import '../constants/api_constants.dart';

part 'api_client.g.dart';

/// Typed REST API Client generated with Retrofit for FakeStore API.
@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @GET(ApiConstants.productsEndpoint)
  Future<List<ProductModel>> getProducts();

  @GET(ApiConstants.productDetailsEndpoint)
  Future<ProductModel> getProductDetails(@Path('id') int id);

  @GET(ApiConstants.categoriesEndpoint)
  Future<List<String>> getCategories();

  @GET(ApiConstants.categoryProductsEndpoint)
  Future<List<ProductModel>> getProductsByCategory(@Path('category') String category);
}

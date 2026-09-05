import 'package:flutter_test/flutter_test.dart';
import 'package:poc_mcp_app/features/products/data/models/product_model.dart';
import 'package:poc_mcp_app/features/products/domain/entities/product_entity.dart';

void main() {
  group('ProductModel Tests', () {
    const sampleJson = {
      'id': 1,
      'title': 'Fjallraven - Foldsack No. 1 Backpack',
      'price': 109.95,
      'description': 'Your perfect pack for everyday use and walks in the forest.',
      'category': "men's clothing",
      'image': 'https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg',
      'rating': {
        'rate': 3.9,
        'count': 120,
      }
    };

    test('fromJson parses correctly from FakeStore API format', () {
      final model = ProductModel.fromJson(sampleJson);
      expect(model.id, 1);
      expect(model.title, 'Fjallraven - Foldsack No. 1 Backpack');
      expect(model.price, 109.95);
      expect(model.rating?.rate, 3.9);
      expect(model.rating?.count, 120);
    });

    test('toEntity converts correctly to ProductEntity', () {
      final model = ProductModel.fromJson(sampleJson);
      final entity = model.toEntity();

      expect(entity, isA<ProductEntity>());
      expect(entity.id, 1);
      expect(entity.ratingRate, 3.9);
      expect(entity.ratingCount, 120);
    });

    test('toHiveModel converts correctly for local storage', () {
      final model = ProductModel.fromJson(sampleJson);
      final hiveModel = model.toHiveModel();

      expect(hiveModel.id, 1);
      expect(hiveModel.price, 109.95);
      expect(hiveModel.cachedAtMillis, isNonZero);
    });
  });
}

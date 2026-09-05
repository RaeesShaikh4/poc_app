import 'package:hive/hive.dart';
import '../../domain/entities/product_entity.dart';

part 'product_hive_model.g.dart';

/// Hive database model for local offline persistence of Products.
@HiveType(typeId: 0)
class ProductHiveModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String image;

  @HiveField(6)
  final double ratingRate;

  @HiveField(7)
  final int ratingCount;

  @HiveField(8)
  final int cachedAtMillis;

  ProductHiveModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.ratingRate,
    required this.ratingCount,
    required this.cachedAtMillis,
  });

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      title: title,
      price: price,
      description: description,
      category: category,
      image: image,
      ratingRate: ratingRate,
      ratingCount: ratingCount,
    );
  }

  factory ProductHiveModel.fromEntity(ProductEntity entity) {
    return ProductHiveModel(
      id: entity.id,
      title: entity.title,
      price: entity.price,
      description: entity.description,
      category: entity.category,
      image: entity.image,
      ratingRate: entity.ratingRate,
      ratingCount: entity.ratingCount,
      cachedAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
  }
}

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/product_entity.dart';
import 'product_hive_model.dart';

part 'product_model.g.dart';

@JsonSerializable()
class RatingModel {
  final double rate;
  final int count;

  const RatingModel({
    required this.rate,
    required this.count,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) => _$RatingModelFromJson(json);

  Map<String, dynamic> toJson() => _$RatingModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ProductModel {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final RatingModel? rating;

  const ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    this.rating,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      title: title,
      price: price,
      description: description,
      category: category,
      image: image,
      ratingRate: rating?.rate ?? 0.0,
      ratingCount: rating?.count ?? 0,
    );
  }

  ProductHiveModel toHiveModel() {
    return ProductHiveModel(
      id: id,
      title: title,
      price: price,
      description: description,
      category: category,
      image: image,
      ratingRate: rating?.rate ?? 0.0,
      ratingCount: rating?.count ?? 0,
      cachedAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
  }
}

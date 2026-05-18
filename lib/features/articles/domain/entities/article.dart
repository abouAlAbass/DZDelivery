import 'package:freezed_annotation/freezed_annotation.dart';

part 'article.freezed.dart';
part 'article.g.dart';

@freezed
class Article with _$Article {
  const factory Article({
    int? id,
    required String name,
    String? code,
    String? barcode,
    required double price,
    @Default(0.0) double salePrice,
    @Default(0.0) double purchasePrice,
    @Default(0.0) double minStock,
    @Default(true) bool isActive,
    required String unit, // kg, m2, m3, pieces
    @Default('physical') String type, // physical, service
    @Default('materials') String category,
    @Default(0.0) double taxRate,
    @Default(0.0) double marginRate,
    String? quickTemplate,
    @Default(1.0) double defaultQuantity,
    @Default(0) int quickTemplateOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) = _Article;

  factory Article.fromJson(Map<String, dynamic> json) =>
      _$ArticleFromJson(json);
}

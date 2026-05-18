// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ArticleImpl _$$ArticleImplFromJson(Map<String, dynamic> json) =>
    _$ArticleImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      code: json['code'] as String?,
      barcode: json['barcode'] as String?,
      price: (json['price'] as num).toDouble(),
      salePrice: (json['salePrice'] as num?)?.toDouble() ?? 0.0,
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      minStock: (json['minStock'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? true,
      unit: json['unit'] as String,
      type: json['type'] as String? ?? 'physical',
      category: json['category'] as String? ?? 'materials',
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.0,
      marginRate: (json['marginRate'] as num?)?.toDouble() ?? 0.0,
      quickTemplate: json['quickTemplate'] as String?,
      defaultQuantity: (json['defaultQuantity'] as num?)?.toDouble() ?? 1.0,
      quickTemplateOrder: (json['quickTemplateOrder'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$$ArticleImplToJson(_$ArticleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'barcode': instance.barcode,
      'price': instance.price,
      'salePrice': instance.salePrice,
      'purchasePrice': instance.purchasePrice,
      'minStock': instance.minStock,
      'isActive': instance.isActive,
      'unit': instance.unit,
      'type': instance.type,
      'category': instance.category,
      'taxRate': instance.taxRate,
      'marginRate': instance.marginRate,
      'quickTemplate': instance.quickTemplate,
      'defaultQuantity': instance.defaultQuantity,
      'quickTemplateOrder': instance.quickTemplateOrder,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

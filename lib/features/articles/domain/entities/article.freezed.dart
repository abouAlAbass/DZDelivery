// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'article.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Article _$ArticleFromJson(Map<String, dynamic> json) {
  return _Article.fromJson(json);
}

/// @nodoc
mixin _$Article {
  int? get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get code => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  String get unit => throw _privateConstructorUsedError; // kg, m2, m3, pieces
  String get type => throw _privateConstructorUsedError; // physical, service
  String get category => throw _privateConstructorUsedError;
  double get taxRate => throw _privateConstructorUsedError;
  double get marginRate => throw _privateConstructorUsedError;
  String? get quickTemplate => throw _privateConstructorUsedError;
  double get defaultQuantity => throw _privateConstructorUsedError;
  int get quickTemplateOrder => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Article to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ArticleCopyWith<Article> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArticleCopyWith<$Res> {
  factory $ArticleCopyWith(Article value, $Res Function(Article) then) =
      _$ArticleCopyWithImpl<$Res, Article>;
  @useResult
  $Res call({
    int? id,
    String name,
    String? code,
    double price,
    String unit,
    String type,
    String category,
    double taxRate,
    double marginRate,
    String? quickTemplate,
    double defaultQuantity,
    int quickTemplateOrder,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$ArticleCopyWithImpl<$Res, $Val extends Article>
    implements $ArticleCopyWith<$Res> {
  _$ArticleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? code = freezed,
    Object? price = null,
    Object? unit = null,
    Object? type = null,
    Object? category = null,
    Object? taxRate = null,
    Object? marginRate = null,
    Object? quickTemplate = freezed,
    Object? defaultQuantity = null,
    Object? quickTemplateOrder = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            code: freezed == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String?,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            unit: null == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            taxRate: null == taxRate
                ? _value.taxRate
                : taxRate // ignore: cast_nullable_to_non_nullable
                      as double,
            marginRate: null == marginRate
                ? _value.marginRate
                : marginRate // ignore: cast_nullable_to_non_nullable
                      as double,
            quickTemplate: freezed == quickTemplate
                ? _value.quickTemplate
                : quickTemplate // ignore: cast_nullable_to_non_nullable
                      as String?,
            defaultQuantity: null == defaultQuantity
                ? _value.defaultQuantity
                : defaultQuantity // ignore: cast_nullable_to_non_nullable
                      as double,
            quickTemplateOrder: null == quickTemplateOrder
                ? _value.quickTemplateOrder
                : quickTemplateOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ArticleImplCopyWith<$Res> implements $ArticleCopyWith<$Res> {
  factory _$$ArticleImplCopyWith(
    _$ArticleImpl value,
    $Res Function(_$ArticleImpl) then,
  ) = __$$ArticleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    String name,
    String? code,
    double price,
    String unit,
    String type,
    String category,
    double taxRate,
    double marginRate,
    String? quickTemplate,
    double defaultQuantity,
    int quickTemplateOrder,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$ArticleImplCopyWithImpl<$Res>
    extends _$ArticleCopyWithImpl<$Res, _$ArticleImpl>
    implements _$$ArticleImplCopyWith<$Res> {
  __$$ArticleImplCopyWithImpl(
    _$ArticleImpl _value,
    $Res Function(_$ArticleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? code = freezed,
    Object? price = null,
    Object? unit = null,
    Object? type = null,
    Object? category = null,
    Object? taxRate = null,
    Object? marginRate = null,
    Object? quickTemplate = freezed,
    Object? defaultQuantity = null,
    Object? quickTemplateOrder = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$ArticleImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        unit: null == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        taxRate: null == taxRate
            ? _value.taxRate
            : taxRate // ignore: cast_nullable_to_non_nullable
                  as double,
        marginRate: null == marginRate
            ? _value.marginRate
            : marginRate // ignore: cast_nullable_to_non_nullable
                  as double,
        quickTemplate: freezed == quickTemplate
            ? _value.quickTemplate
            : quickTemplate // ignore: cast_nullable_to_non_nullable
                  as String?,
        defaultQuantity: null == defaultQuantity
            ? _value.defaultQuantity
            : defaultQuantity // ignore: cast_nullable_to_non_nullable
                  as double,
        quickTemplateOrder: null == quickTemplateOrder
            ? _value.quickTemplateOrder
            : quickTemplateOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ArticleImpl implements _Article {
  const _$ArticleImpl({
    this.id,
    required this.name,
    this.code,
    required this.price,
    required this.unit,
    this.type = 'physical',
    this.category = 'materials',
    this.taxRate = 0.0,
    this.marginRate = 0.0,
    this.quickTemplate,
    this.defaultQuantity = 1.0,
    this.quickTemplateOrder = 0,
    this.createdAt,
  });

  factory _$ArticleImpl.fromJson(Map<String, dynamic> json) =>
      _$$ArticleImplFromJson(json);

  @override
  final int? id;
  @override
  final String name;
  @override
  final String? code;
  @override
  final double price;
  @override
  final String unit;
  // kg, m2, m3, pieces
  @override
  @JsonKey()
  final String type;
  // physical, service
  @override
  @JsonKey()
  final String category;
  @override
  @JsonKey()
  final double taxRate;
  @override
  @JsonKey()
  final double marginRate;
  @override
  final String? quickTemplate;
  @override
  @JsonKey()
  final double defaultQuantity;
  @override
  @JsonKey()
  final int quickTemplateOrder;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Article(id: $id, name: $name, code: $code, price: $price, unit: $unit, type: $type, category: $category, taxRate: $taxRate, marginRate: $marginRate, quickTemplate: $quickTemplate, defaultQuantity: $defaultQuantity, quickTemplateOrder: $quickTemplateOrder, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArticleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.taxRate, taxRate) || other.taxRate == taxRate) &&
            (identical(other.marginRate, marginRate) ||
                other.marginRate == marginRate) &&
            (identical(other.quickTemplate, quickTemplate) ||
                other.quickTemplate == quickTemplate) &&
            (identical(other.defaultQuantity, defaultQuantity) ||
                other.defaultQuantity == defaultQuantity) &&
            (identical(other.quickTemplateOrder, quickTemplateOrder) ||
                other.quickTemplateOrder == quickTemplateOrder) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    code,
    price,
    unit,
    type,
    category,
    taxRate,
    marginRate,
    quickTemplate,
    defaultQuantity,
    quickTemplateOrder,
    createdAt,
  );

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ArticleImplCopyWith<_$ArticleImpl> get copyWith =>
      __$$ArticleImplCopyWithImpl<_$ArticleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ArticleImplToJson(this);
  }
}

abstract class _Article implements Article {
  const factory _Article({
    final int? id,
    required final String name,
    final String? code,
    required final double price,
    required final String unit,
    final String type,
    final String category,
    final double taxRate,
    final double marginRate,
    final String? quickTemplate,
    final double defaultQuantity,
    final int quickTemplateOrder,
    final DateTime? createdAt,
  }) = _$ArticleImpl;

  factory _Article.fromJson(Map<String, dynamic> json) = _$ArticleImpl.fromJson;

  @override
  int? get id;
  @override
  String get name;
  @override
  String? get code;
  @override
  double get price;
  @override
  String get unit; // kg, m2, m3, pieces
  @override
  String get type; // physical, service
  @override
  String get category;
  @override
  double get taxRate;
  @override
  double get marginRate;
  @override
  String? get quickTemplate;
  @override
  double get defaultQuantity;
  @override
  int get quickTemplateOrder;
  @override
  DateTime? get createdAt;

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ArticleImplCopyWith<_$ArticleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

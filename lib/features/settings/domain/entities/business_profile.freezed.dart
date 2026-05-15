// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'business_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BusinessProfile _$BusinessProfileFromJson(Map<String, dynamic> json) {
  return _BusinessProfile.fromJson(json);
}

/// @nodoc
mixin _$BusinessProfile {
  int? get id => throw _privateConstructorUsedError;
  String get companyName => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get website => throw _privateConstructorUsedError;
  String? get logoPath => throw _privateConstructorUsedError;

  /// Serializes this BusinessProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BusinessProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BusinessProfileCopyWith<BusinessProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusinessProfileCopyWith<$Res> {
  factory $BusinessProfileCopyWith(
    BusinessProfile value,
    $Res Function(BusinessProfile) then,
  ) = _$BusinessProfileCopyWithImpl<$Res, BusinessProfile>;
  @useResult
  $Res call({
    int? id,
    String companyName,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? logoPath,
  });
}

/// @nodoc
class _$BusinessProfileCopyWithImpl<$Res, $Val extends BusinessProfile>
    implements $BusinessProfileCopyWith<$Res> {
  _$BusinessProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BusinessProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? companyName = null,
    Object? address = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? website = freezed,
    Object? logoPath = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            companyName: null == companyName
                ? _value.companyName
                : companyName // ignore: cast_nullable_to_non_nullable
                      as String,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            website: freezed == website
                ? _value.website
                : website // ignore: cast_nullable_to_non_nullable
                      as String?,
            logoPath: freezed == logoPath
                ? _value.logoPath
                : logoPath // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BusinessProfileImplCopyWith<$Res>
    implements $BusinessProfileCopyWith<$Res> {
  factory _$$BusinessProfileImplCopyWith(
    _$BusinessProfileImpl value,
    $Res Function(_$BusinessProfileImpl) then,
  ) = __$$BusinessProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    String companyName,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? logoPath,
  });
}

/// @nodoc
class __$$BusinessProfileImplCopyWithImpl<$Res>
    extends _$BusinessProfileCopyWithImpl<$Res, _$BusinessProfileImpl>
    implements _$$BusinessProfileImplCopyWith<$Res> {
  __$$BusinessProfileImplCopyWithImpl(
    _$BusinessProfileImpl _value,
    $Res Function(_$BusinessProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BusinessProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? companyName = null,
    Object? address = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? website = freezed,
    Object? logoPath = freezed,
  }) {
    return _then(
      _$BusinessProfileImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        companyName: null == companyName
            ? _value.companyName
            : companyName // ignore: cast_nullable_to_non_nullable
                  as String,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        website: freezed == website
            ? _value.website
            : website // ignore: cast_nullable_to_non_nullable
                  as String?,
        logoPath: freezed == logoPath
            ? _value.logoPath
            : logoPath // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BusinessProfileImpl implements _BusinessProfile {
  const _$BusinessProfileImpl({
    this.id,
    required this.companyName,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.logoPath,
  });

  factory _$BusinessProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$BusinessProfileImplFromJson(json);

  @override
  final int? id;
  @override
  final String companyName;
  @override
  final String? address;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  final String? website;
  @override
  final String? logoPath;

  @override
  String toString() {
    return 'BusinessProfile(id: $id, companyName: $companyName, address: $address, phone: $phone, email: $email, website: $website, logoPath: $logoPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusinessProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyName, companyName) ||
                other.companyName == companyName) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.logoPath, logoPath) ||
                other.logoPath == logoPath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    companyName,
    address,
    phone,
    email,
    website,
    logoPath,
  );

  /// Create a copy of BusinessProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BusinessProfileImplCopyWith<_$BusinessProfileImpl> get copyWith =>
      __$$BusinessProfileImplCopyWithImpl<_$BusinessProfileImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BusinessProfileImplToJson(this);
  }
}

abstract class _BusinessProfile implements BusinessProfile {
  const factory _BusinessProfile({
    final int? id,
    required final String companyName,
    final String? address,
    final String? phone,
    final String? email,
    final String? website,
    final String? logoPath,
  }) = _$BusinessProfileImpl;

  factory _BusinessProfile.fromJson(Map<String, dynamic> json) =
      _$BusinessProfileImpl.fromJson;

  @override
  int? get id;
  @override
  String get companyName;
  @override
  String? get address;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  String? get website;
  @override
  String? get logoPath;

  /// Create a copy of BusinessProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BusinessProfileImplCopyWith<_$BusinessProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

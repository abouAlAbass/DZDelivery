// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClientImpl _$$ClientImplFromJson(Map<String, dynamic> json) => _$ClientImpl(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  address: json['address'] as String?,
  addressName: json['addressName'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$ClientImplToJson(_$ClientImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address,
      'addressName': instance.addressName,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BusinessProfileImpl _$$BusinessProfileImplFromJson(
  Map<String, dynamic> json,
) => _$BusinessProfileImpl(
  id: (json['id'] as num?)?.toInt(),
  companyName: json['companyName'] as String,
  address: json['address'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  website: json['website'] as String?,
  logoPath: json['logoPath'] as String?,
);

Map<String, dynamic> _$$BusinessProfileImplToJson(
  _$BusinessProfileImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'companyName': instance.companyName,
  'address': instance.address,
  'phone': instance.phone,
  'email': instance.email,
  'website': instance.website,
  'logoPath': instance.logoPath,
};

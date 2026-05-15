import 'package:freezed_annotation/freezed_annotation.dart';

part 'business_profile.freezed.dart';
part 'business_profile.g.dart';

@freezed
class BusinessProfile with _$BusinessProfile {
  const factory BusinessProfile({
    int? id,
    required String companyName,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? logoPath,
  }) = _BusinessProfile;

  factory BusinessProfile.fromJson(Map<String, dynamic> json) => _$BusinessProfileFromJson(json);
}

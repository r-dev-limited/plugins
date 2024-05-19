// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      name: json['name'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']),
      createdAt: (json['createdAt'] as num?)?.toDouble(),
      updatedAt: (json['updatedAt'] as num?)?.toDouble(),
      lastUpdatedClaims: (json['lastUpdatedClaims'] as num?)?.toDouble(),
      onboardingFinished: json['onboardingFinished'] as bool?,
      userAffinity: (json['userAffinity'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  writeNotNull('email', instance.email);
  writeNotNull('avatarUrl', instance.avatarUrl);
  writeNotNull('role', _$UserRoleEnumMap[instance.role]);
  writeNotNull('createdAt', instance.createdAt);
  writeNotNull('updatedAt', instance.updatedAt);
  writeNotNull('lastUpdatedClaims', instance.lastUpdatedClaims);
  writeNotNull('onboardingFinished', instance.onboardingFinished);
  writeNotNull('userAffinity', instance.userAffinity);
  return val;
}

const _$UserRoleEnumMap = {
  UserRole.Admin: 'Admin',
  UserRole.User: 'User',
};

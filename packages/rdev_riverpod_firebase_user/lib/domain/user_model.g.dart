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

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      if (instance.name case final value?) 'name': value,
      if (instance.email case final value?) 'email': value,
      if (instance.avatarUrl case final value?) 'avatarUrl': value,
      if (_$UserRoleEnumMap[instance.role] case final value?) 'role': value,
      if (instance.createdAt case final value?) 'createdAt': value,
      if (instance.updatedAt case final value?) 'updatedAt': value,
      if (instance.lastUpdatedClaims case final value?)
        'lastUpdatedClaims': value,
      if (instance.onboardingFinished case final value?)
        'onboardingFinished': value,
      if (instance.userAffinity case final value?) 'userAffinity': value,
    };

const _$UserRoleEnumMap = {
  UserRole.Admin: 'Admin',
  UserRole.User: 'User',
};

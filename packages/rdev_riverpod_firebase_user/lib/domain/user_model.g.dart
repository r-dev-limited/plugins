// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      uid: json['uid'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']),
      createdAt: (json['createdAt'] as num).toDouble(),
      updatedAt: (json['updatedAt'] as num?)?.toDouble(),
      lastUpdatedClaims: (json['lastUpdatedClaims'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'email': instance.email,
      'avatarUrl': instance.avatarUrl,
      'role': _$UserRoleEnumMap[instance.role],
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'lastUpdatedClaims': instance.lastUpdatedClaims,
    };

const _$UserRoleEnumMap = {
  UserRole.Admin: 'Admin',
  UserRole.User: 'User',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FCMToken _$FCMTokenFromJson(Map<String, dynamic> json) => FCMToken(
      token: json['token'] as String?,
      createdAt: (json['createdAt'] as num?)?.toDouble(),
      type: $enumDecodeNullable(_$FCMTokenTypeEnumMap, json['type']),
      id: json['id'] as String?,
    );

Map<String, dynamic> _$FCMTokenToJson(FCMToken instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('token', instance.token);
  writeNotNull('createdAt', instance.createdAt);
  writeNotNull('type', _$FCMTokenTypeEnumMap[instance.type]);
  writeNotNull('id', instance.id);
  return val;
}

const _$FCMTokenTypeEnumMap = {
  FCMTokenType.Android: 'Android',
  FCMTokenType.Ios: 'Ios',
  FCMTokenType.Web: 'Web',
};

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      name: json['name'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']),
      createdAt: (json['createdAt'] as num).toDouble(),
      updatedAt: (json['updatedAt'] as num?)?.toDouble(),
      lastUpdatedClaims: (json['lastUpdatedClaims'] as num?)?.toDouble(),
      fcmTokens: (json['fcmTokens'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, FCMToken.fromJson(e as Map<String, dynamic>)),
      ),
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
  val['createdAt'] = instance.createdAt;
  writeNotNull('updatedAt', instance.updatedAt);
  writeNotNull('lastUpdatedClaims', instance.lastUpdatedClaims);
  writeNotNull(
      'fcmTokens', instance.fcmTokens?.map((k, e) => MapEntry(k, e.toJson())));
  writeNotNull('onboardingFinished', instance.onboardingFinished);
  writeNotNull('userAffinity', instance.userAffinity);
  return val;
}

const _$UserRoleEnumMap = {
  UserRole.Admin: 'Admin',
  UserRole.User: 'User',
};

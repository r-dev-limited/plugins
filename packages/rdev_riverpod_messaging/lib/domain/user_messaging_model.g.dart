// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_messaging_model.dart';

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

UserMessagingModel _$UserMessagingModelFromJson(Map<String, dynamic> json) =>
    UserMessagingModel(
      userId: json['userId'] as String?,
      createdAt: (json['createdAt'] as num?)?.toDouble(),
      updatedAt: (json['updatedAt'] as num?)?.toDouble(),
      fcmTokens: (json['fcmTokens'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, FCMToken.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$UserMessagingModelToJson(UserMessagingModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('userId', instance.userId);
  writeNotNull('createdAt', instance.createdAt);
  writeNotNull('updatedAt', instance.updatedAt);
  writeNotNull(
      'fcmTokens', instance.fcmTokens?.map((k, e) => MapEntry(k, e.toJson())));
  return val;
}

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

Map<String, dynamic> _$FCMTokenToJson(FCMToken instance) => <String, dynamic>{
      if (instance.token case final value?) 'token': value,
      if (instance.createdAt case final value?) 'createdAt': value,
      if (_$FCMTokenTypeEnumMap[instance.type] case final value?) 'type': value,
      if (instance.id case final value?) 'id': value,
    };

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

Map<String, dynamic> _$UserMessagingModelToJson(UserMessagingModel instance) =>
    <String, dynamic>{
      if (instance.userId case final value?) 'userId': value,
      if (instance.createdAt case final value?) 'createdAt': value,
      if (instance.updatedAt case final value?) 'updatedAt': value,
      if (instance.fcmTokens?.map((k, e) => MapEntry(k, e.toJson()))
          case final value?)
        'fcmTokens': value,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelData _$ChannelDataFromJson(Map<String, dynamic> json) => ChannelData(
      fcmData: json['fcmData'] as Map<String, dynamic>?,
      emailData: json['emailData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ChannelDataToJson(ChannelData instance) =>
    <String, dynamic>{
      if (instance.fcmData case final value?) 'fcmData': value,
      if (instance.emailData case final value?) 'emailData': value,
    };

UserNotificationModel _$UserNotificationModelFromJson(
        Map<String, dynamic> json) =>
    UserNotificationModel(
      message: json['message'] as String?,
      userId: json['userId'] as String?,
      from: json['from'] as String?,
      channelData: json['channelData'] == null
          ? null
          : ChannelData.fromJson(json['channelData'] as Map<String, dynamic>),
      state: $enumDecodeNullable(_$NotificationStateEnumMap, json['state']),
      channelTypes: (json['channelTypes'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$NotificationChannelTypeEnumMap, e))
          .toList(),
      createdAt: (json['createdAt'] as num).toDouble(),
      updatedAt: (json['updatedAt'] as num?)?.toDouble(),
      deliveredAt: (json['deliveredAt'] as num?)?.toDouble(),
      readAt: (json['readAt'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UserNotificationModelToJson(
        UserNotificationModel instance) =>
    <String, dynamic>{
      if (instance.message case final value?) 'message': value,
      if (instance.userId case final value?) 'userId': value,
      if (instance.from case final value?) 'from': value,
      if (instance.channelData?.toJson() case final value?)
        'channelData': value,
      if (_$NotificationStateEnumMap[instance.state] case final value?)
        'state': value,
      if (instance.channelTypes
              ?.map((e) => _$NotificationChannelTypeEnumMap[e]!)
              .toList()
          case final value?)
        'channelTypes': value,
      'createdAt': instance.createdAt,
      if (instance.updatedAt case final value?) 'updatedAt': value,
      if (instance.deliveredAt case final value?) 'deliveredAt': value,
      if (instance.readAt case final value?) 'readAt': value,
      if (instance.metadata case final value?) 'metadata': value,
    };

const _$NotificationStateEnumMap = {
  NotificationState.Sent: 'Sent',
  NotificationState.Delivered: 'Delivered',
  NotificationState.Read: 'Read',
};

const _$NotificationChannelTypeEnumMap = {
  NotificationChannelType.Email: 'Email',
  NotificationChannelType.Fcm: 'Fcm',
  NotificationChannelType.Internal: 'Internal',
};

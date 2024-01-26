// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelData _$ChannelDataFromJson(Map<String, dynamic> json) => ChannelData(
      fcmData: json['fcmData'] as Map<String, dynamic>?,
      emailData: json['emailData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ChannelDataToJson(ChannelData instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('fcmData', instance.fcmData);
  writeNotNull('emailData', instance.emailData);
  return val;
}

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
      types: (json['types'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$NotificationChannelTypeEnumMap, e))
          .toList(),
      createdAt: (json['createdAt'] as num).toDouble(),
      updatedAt: (json['updatedAt'] as num?)?.toDouble(),
      deliveredAt: (json['deliveredAt'] as num?)?.toDouble(),
      readAt: (json['readAt'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UserNotificationModelToJson(
    UserNotificationModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('message', instance.message);
  writeNotNull('userId', instance.userId);
  writeNotNull('from', instance.from);
  writeNotNull('channelData', instance.channelData?.toJson());
  writeNotNull('state', _$NotificationStateEnumMap[instance.state]);
  writeNotNull(
      'types',
      instance.types
          ?.map((e) => _$NotificationChannelTypeEnumMap[e]!)
          .toList());
  val['createdAt'] = instance.createdAt;
  writeNotNull('updatedAt', instance.updatedAt);
  writeNotNull('deliveredAt', instance.deliveredAt);
  writeNotNull('readAt', instance.readAt);
  writeNotNull('metadata', instance.metadata);
  return val;
}

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

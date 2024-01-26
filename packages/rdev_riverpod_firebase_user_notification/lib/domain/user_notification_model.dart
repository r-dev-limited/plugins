import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_notification_model.g.dart';

enum NotificationChannelType {
  Email,
  Fcm,
  Internal,
}

enum NotificationState {
  Sent,
  Delivered,
  Read,
}

@JsonSerializable(ignoreUnannotated: true)
class ChannelData {
  @JsonKey()
  final Map<String, dynamic>? fcmData;
  @JsonKey()
  final Map<String, dynamic>? emailData;

  ChannelData({
    this.fcmData,
    this.emailData,
  });

  copyWith({
    Map<String, dynamic>? fcmData,
    Map<String, dynamic>? emailData,
  }) {
    return ChannelData(
      fcmData: fcmData ?? this.fcmData,
      emailData: emailData ?? this.emailData,
    );
  }

  factory ChannelData.fromJson(Map<String, dynamic> json) =>
      _$ChannelDataFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelDataToJson(this);
}

@JsonSerializable(ignoreUnannotated: true)
class UserNotificationModel {
  String? uid;
  DocumentSnapshot? snapshot;

  ///
  @JsonKey()
  final String? message;

  @JsonKey()
  final String? userId;

  @JsonKey()
  final String? from;

  @JsonKey()
  final ChannelData? channelData;

  @JsonKey()
  final NotificationState? state;

  @JsonKey()
  final List<NotificationChannelType>? channelTypes;

  @JsonKey()
  final double createdAt;

  @JsonKey()
  final double? updatedAt;

  @JsonKey()
  final double? deliveredAt;

  @JsonKey()
  final double? readAt;

  @JsonKey()
  final Map<String, dynamic>? metadata;

  UserNotificationModel({
    this.uid,
    this.snapshot,
    this.message,
    this.userId,
    this.from,
    this.channelData,
    this.state,
    this.channelTypes,
    required this.createdAt,
    this.updatedAt,
    this.deliveredAt,
    this.readAt,
    this.metadata,
  });

  copyWith({
    String? uid,
    DocumentSnapshot? snapshot,
    String? message,
    String? userId,
    String? from,
    ChannelData? channelData,
    NotificationState? state,
    List<NotificationChannelType>? channelTypes,
    Map<String, dynamic>? metadata,
    double? deliveredAt,
    double? readAt,
    double? createdAt,
    double? updatedAt,
    double? lastUpdatedClaims,
  }) {
    return UserNotificationModel(
      uid: uid ?? this.uid,
      snapshot: snapshot ?? this.snapshot,
      message: message ?? this.message,
      userId: userId ?? this.userId,
      from: from ?? this.from,
      channelData: channelData ?? this.channelData,
      state: state ?? this.state,
      channelTypes: channelTypes ?? this.channelTypes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Connect the generated [_$UserNotificationModelFromJson] function to the `fromJson`
  /// factory.
  factory UserNotificationModel.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final vo = _$UserNotificationModelFromJson(snapshot.data()!);
    vo.snapshot = snapshot;
    vo.uid = snapshot.id;
    return vo;
  }

  /// Connect the generated [_$UserNotificationModelFromJson] function to the `fromJson`
  /// factory.
  factory UserNotificationModel.fromJson(Map<String, dynamic> json) =>
      _$UserNotificationModelFromJson(json);

  /// Connect the generated [_$UserNotificationModelToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$UserNotificationModelToJson(this);
}

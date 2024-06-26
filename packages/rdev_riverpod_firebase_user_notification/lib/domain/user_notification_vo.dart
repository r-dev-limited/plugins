import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_notification_model.dart';

class UserNotificationVO extends Equatable {
  final String? uid;
  final DocumentSnapshot? snapshot;

  final String? message;
  final String? userId;
  final String? from;
  final ChannelData? channelData;
  final NotificationState? state;
  final List<NotificationChannelType>? channelTypes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final Map<String, dynamic>? metadata;

  const UserNotificationVO({
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

  @override
  List<Object?> get props => [
        uid,
        createdAt,
        updatedAt,
        deliveredAt,
        readAt,
        message,
        userId,
        from,
        channelData,
        state,
        channelTypes,
        metadata,
      ];

  UserNotificationVO copyWith({
    String? uid,
    DocumentSnapshot? snapshot,
    String? message,
    String? userId,
    String? from,
    ChannelData? channelData,
    NotificationState? state,
    List<NotificationChannelType>? channelTypes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserNotificationVO(
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

  factory UserNotificationVO.fromModel(UserNotificationModel model) {
    return UserNotificationVO(
      uid: model.uid!,
      snapshot: model.snapshot,
      message: model.message,
      userId: model.userId,
      from: model.from,
      channelData: model.channelData,
      state: model.state,
      channelTypes: model.channelTypes,
      createdAt: DateTime.fromMillisecondsSinceEpoch(model.createdAt.toInt()),
      updatedAt: model.updatedAt is double
          ? DateTime.fromMillisecondsSinceEpoch(model.updatedAt!.toInt())
          : null,
      deliveredAt: model.deliveredAt is double
          ? DateTime.fromMillisecondsSinceEpoch(model.deliveredAt!.toInt())
          : null,
      readAt: model.readAt is double
          ? DateTime.fromMillisecondsSinceEpoch(model.readAt!.toInt())
          : null,
      metadata: model.metadata,
    );
  }

  UserNotificationModel toModel() {
    final model = UserNotificationModel(
      uid: uid,
      snapshot: snapshot,
      message: message,
      userId: userId,
      from: from,
      channelData: channelData,
      state: state,
      channelTypes: channelTypes,
      createdAt: createdAt.millisecondsSinceEpoch.toDouble(),
      updatedAt: updatedAt is DateTime
          ? updatedAt!.millisecondsSinceEpoch.toDouble()
          : null,
      deliveredAt: deliveredAt is DateTime
          ? deliveredAt!.millisecondsSinceEpoch.toDouble()
          : null,
      readAt:
          readAt is DateTime ? readAt!.millisecondsSinceEpoch.toDouble() : null,
      metadata: metadata,
    );

    return model;
  }
}

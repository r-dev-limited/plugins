import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rdev_riverpod_messaging/domain/user_messaging_model.dart';

class UserMessagingVO extends Equatable {
  final String? uid;
  final DocumentSnapshot? snapshot;
  final Map<String, FCMToken>? fcmTokens;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserMessagingVO({
    this.uid,
    this.snapshot,
    this.fcmTokens,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        uid,
        snapshot,
        fcmTokens,
        userId,
        createdAt,
        updatedAt,
      ];

  UserMessagingVO copyWith({
    String? uid,
    DocumentSnapshot? snapshot,
    String? userId,
    Map<String, FCMToken>? fcmTokens,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserMessagingVO(
      uid: uid ?? this.uid,
      snapshot: snapshot ?? this.snapshot,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserMessagingVO.fromModel(UserMessagingModel model) {
    return UserMessagingVO(
      uid: model.uid!,
      snapshot: model.snapshot,
      fcmTokens: model.fcmTokens,
      userId: model.userId,
      createdAt: model.createdAt is double
          ? DateTime.fromMillisecondsSinceEpoch(model.createdAt!.toInt())
          : null,
      updatedAt: model.updatedAt is double
          ? DateTime.fromMillisecondsSinceEpoch(model.updatedAt!.toInt())
          : null,
    );
  }

  UserMessagingModel toModel() {
    final model = UserMessagingModel(
      uid: uid,
      snapshot: snapshot,
      createdAt: createdAt?.millisecondsSinceEpoch.toDouble(),
      userId: userId!,
      fcmTokens: fcmTokens,
      updatedAt: updatedAt is DateTime
          ? updatedAt!.millisecondsSinceEpoch.toDouble()
          : null,
    );

    return model;
  }
}

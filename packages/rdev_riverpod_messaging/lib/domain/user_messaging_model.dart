import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_messaging_model.g.dart';

enum FCMTokenType {
  Android,
  Ios,
  Web,
}

@JsonSerializable(ignoreUnannotated: true)
class FCMToken {
  @JsonKey()
  final String? token;
  @JsonKey()
  final double? createdAt;
  @JsonKey()
  final FCMTokenType? type;
  @JsonKey()
  final String? id;

  FCMToken({
    this.token,
    this.createdAt,
    this.type,
    this.id,
  });

  copyWith({
    String? token,
    double? createdAt,
    FCMTokenType? type,
    String? id,
  }) {
    return FCMToken(
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      id: id ?? this.id,
    );
  }

  factory FCMToken.fromJson(Map<String, dynamic> json) =>
      _$FCMTokenFromJson(json);

  Map<String, dynamic> toJson() => _$FCMTokenToJson(this);
}

@JsonSerializable(ignoreUnannotated: true)
class UserMessagingModel {
  String? uid;
  DocumentSnapshot? snapshot;

  @JsonKey()
  final String? userId;

  @JsonKey()
  final double? createdAt;

  @JsonKey()
  final double? updatedAt;

  @JsonKey()
  final Map<String, FCMToken>? fcmTokens;

  UserMessagingModel({
    this.uid,
    this.snapshot,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.fcmTokens,
  });

  copyWith({
    String? uid,
    DocumentSnapshot? snapshot,
    String? userId,
    Map<String, FCMToken>? fcmTokens,
    double? createdAt,
    double? updatedAt,
  }) {
    return UserMessagingModel(
      uid: uid ?? this.uid,
      snapshot: snapshot ?? this.snapshot,
      userId: userId ?? this.userId,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserMessagingModel.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final vo = _$UserMessagingModelFromJson(snapshot.data()!);
    vo.snapshot = snapshot;
    vo.uid = snapshot.id;
    return vo;
  }

  factory UserMessagingModel.fromJson(Map<String, dynamic> json) =>
      _$UserMessagingModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserMessagingModelToJson(this);
}

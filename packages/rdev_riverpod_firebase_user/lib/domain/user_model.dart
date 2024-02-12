import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_model.g.dart';

enum UserRole {
  Admin,
  User,
}

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
class UserModel {
  String? uid;
  DocumentSnapshot? snapshot;

  ///
  @JsonKey()
  final String? name;

  @JsonKey()
  final String? email;

  @JsonKey()
  final String? avatarUrl;

  @JsonKey()
  final UserRole? role;

  @JsonKey()
  final double createdAt;

  @JsonKey()
  final double? updatedAt;

  @JsonKey()
  final double? lastUpdatedClaims;

  @JsonKey()
  final Map<String, FCMToken>? fcmTokens;

  @JsonKey()
  final bool? onboardingFinished;

  @JsonKey()
  final double? userAffinity;

  UserModel({
    this.uid,
    this.snapshot,
    this.name,
    this.email,
    this.avatarUrl,
    this.role,
    required this.createdAt,
    this.updatedAt,
    this.lastUpdatedClaims,
    this.fcmTokens,
    this.onboardingFinished,
    this.userAffinity,
  });

  copyWith({
    String? uid,
    DocumentSnapshot? snapshot,
    String? name,
    String? email,
    String? avatarUrl,
    UserRole? role,
    double? createdAt,
    double? updatedAt,
    double? lastUpdatedClaims,
    Map<String, FCMToken>? fcmTokens,
    bool? onboardingFinished,
    double? userAffinity,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      snapshot: snapshot ?? this.snapshot,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastUpdatedClaims: lastUpdatedClaims ?? this.lastUpdatedClaims,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      onboardingFinished: onboardingFinished ?? this.onboardingFinished,
      userAffinity: userAffinity ?? this.userAffinity,
    );
  }

  /// Connect the generated [_$UserModelFromJson] function to the `fromJson`
  /// factory.
  factory UserModel.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final vo = _$UserModelFromJson(snapshot.data()!);
    vo.snapshot = snapshot;
    vo.uid = snapshot.id;
    return vo;
  }

  /// Connect the generated [_$UserModelFromJson] function to the `fromJson`
  /// factory.
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Connect the generated [_$UserModelToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

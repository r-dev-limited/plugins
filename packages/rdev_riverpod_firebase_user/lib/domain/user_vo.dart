import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

class UserVO extends Equatable {
  final String? uid;
  final DocumentSnapshot? snapshot;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final UserRole? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastUpdatedClaims;
  final Map<String, FCMToken>? fcmTokens;

  const UserVO({
    this.uid,
    this.snapshot,
    this.name,
    this.email,
    this.avatarUrl,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.lastUpdatedClaims,
    this.fcmTokens,
  });

  @override
  List<Object?> get props => [
        uid,
        name,
        email,
        avatarUrl,
        role,
        createdAt,
        updatedAt,
        lastUpdatedClaims,
        fcmTokens,
      ];

  UserVO copyWith({
    String? uid,
    DocumentSnapshot? snapshot,
    String? name,
    String? email,
    String? avatarUrl,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastUpdatedClaims,
    Map<String, FCMToken>? fcmTokens,
  }) {
    return UserVO(
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
    );
  }

  factory UserVO.fromUserModel(UserModel user) {
    return UserVO(
      uid: user.uid!,
      snapshot: user.snapshot,
      name: user.name,
      email: user.email,
      role: user.role,
      createdAt: DateTime.fromMillisecondsSinceEpoch(user.createdAt.toInt()),
      updatedAt: user.updatedAt is double
          ? DateTime.fromMillisecondsSinceEpoch(user.updatedAt!.toInt())
          : null,
      lastUpdatedClaims: user.lastUpdatedClaims is double
          ? DateTime.fromMillisecondsSinceEpoch(user.lastUpdatedClaims!.toInt())
          : null,
      fcmTokens: user.fcmTokens,
    );
  }

  UserModel toUserModel() {
    final userModel = UserModel(
      uid: uid,
      snapshot: snapshot,
      createdAt: createdAt!.millisecondsSinceEpoch.toDouble(),
      name: name is String ? name : null,
      email: email is String ? email : null,
      role: role is UserRole ? role : null,
      updatedAt: updatedAt is DateTime
          ? updatedAt!.millisecondsSinceEpoch.toDouble()
          : null,
      lastUpdatedClaims: lastUpdatedClaims is DateTime
          ? lastUpdatedClaims!.millisecondsSinceEpoch.toDouble()
          : null,
    );

    return userModel;
  }
}

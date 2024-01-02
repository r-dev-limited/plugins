import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_model.g.dart';

enum UserRole {
  Admin,
  User,
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
  });

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

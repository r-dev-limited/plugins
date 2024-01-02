import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthAdditionalUserInfoVO extends Equatable {
  final String? authorizationCode;
  final String? providerId;
  final String? username;
  final bool? isNewUser;
  final Map<String, dynamic>? profile;

  const AuthAdditionalUserInfoVO({
    this.authorizationCode,
    this.providerId,
    this.username,
    this.isNewUser,
    this.profile,
  });

  @override
  List<Object?> get props => [
        authorizationCode,
        providerId,
        username,
        isNewUser,
        profile,
      ];

  factory AuthAdditionalUserInfoVO.fromAuthAdditionalUserInfo(
      AdditionalUserInfo userInfo) {
    return AuthAdditionalUserInfoVO(
      authorizationCode: userInfo.authorizationCode,
      providerId: userInfo.providerId,
      username: userInfo.username,
      isNewUser: userInfo.isNewUser,
      profile: userInfo.profile,
    );
  }
}

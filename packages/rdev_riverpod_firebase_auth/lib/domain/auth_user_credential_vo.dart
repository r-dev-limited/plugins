import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_additional_user_info_vo.dart';
import 'auth_credential_vo.dart';
import 'auth_user_vo.dart';

class AuthUserCredentialVO extends Equatable {
  final AuthUserVO? userVO;
  final AuthCredentialVO? credentialVO;
  final AuthAdditionalUserInfoVO? additionalUserInfo;

  const AuthUserCredentialVO({
    this.userVO,
    this.credentialVO,
    this.additionalUserInfo,
  });

  @override
  List<Object?> get props => [
        userVO.hashCode,
        credentialVO.hashCode,
        additionalUserInfo.hashCode,
      ];

  factory AuthUserCredentialVO.fromAuthUserCredential(
      UserCredential credential) {
    return AuthUserCredentialVO(
      userVO: credential.user is User
          ? AuthUserVO.fromAuthUser(credential.user!)
          : null,
      credentialVO: credential.credential is AuthCredential
          ? AuthCredentialVO.fromAuthCredential(credential.credential!)
          : null,
      additionalUserInfo: credential.additionalUserInfo is AdditionalUserInfo
          ? AuthAdditionalUserInfoVO.fromAuthAdditionalUserInfo(
              credential.additionalUserInfo!)
          : null,
    );
  }
}

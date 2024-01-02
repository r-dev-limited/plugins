import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthCredentialVO extends Equatable {
  final String? accessToken;
  final String? providerId;
  final String? signInMethod;
  final int? token;

  const AuthCredentialVO({
    this.accessToken,
    this.providerId,
    this.signInMethod,
    this.token,
  });

  @override
  List<Object?> get props => [
        accessToken,
        providerId,
        signInMethod,
        token,
      ];

  factory AuthCredentialVO.fromAuthCredential(AuthCredential credential) {
    return AuthCredentialVO(
      accessToken: credential.accessToken,
      providerId: credential.providerId,
      signInMethod: credential.signInMethod,
      token: credential.token,
    );
  }
}

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthIDTokenResultVO extends Equatable {
  final String? signInProvider;
  final String? token;
  final Map<String, dynamic>? claims;
  final DateTime? expirationTime;

  const AuthIDTokenResultVO({
    this.signInProvider,
    this.token,
    this.claims,
    this.expirationTime,
  });

  @override
  List<Object?> get props => [
        signInProvider,
        token,
        claims,
        expirationTime,
      ];

  factory AuthIDTokenResultVO.fromIDTokenResult(IdTokenResult idTokenResult) {
    return AuthIDTokenResultVO(
      signInProvider: idTokenResult.signInProvider,
      token: idTokenResult.token,
      claims: idTokenResult.claims,
      expirationTime: idTokenResult.expirationTime,
    );
  }
}

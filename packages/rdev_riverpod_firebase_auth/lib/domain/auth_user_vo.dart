import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthUserVO extends Equatable {
  final String? uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final bool isEmailVerified;
  final bool isAnonymous;

  const AuthUserVO({
    this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    this.isEmailVerified = false,
    this.isAnonymous = false,
  });

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoUrl,
        isEmailVerified,
        isAnonymous,
      ];

  factory AuthUserVO.fromAuthUser(User user) {
    return AuthUserVO(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
      isAnonymous: user.isAnonymous,
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';

import '../domain/auth_idtoken_result_vo.dart';
import '../domain/auth_user_credential_vo.dart';
import '../domain/auth_user_vo.dart';
import 'auth_data_service.dart';

/// Exception class for AuthService.
class AuthServiceException extends RdevException {
  AuthServiceException({
    String? message,
    RdevCode? code,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          stackTrace: stackTrace,
        );
}

/// This file contains the implementation of the `AuthService` class.
///
/// The `AuthService` class provides authentication services using Firebase Auth.
/// It interacts with the `AuthDataService` to perform authentication operations.
class AuthService {
  final AuthDataService _authDataService;

  AuthService(this._authDataService);

  /// Returns a stream of `AuthUserVO` objects representing the authenticated user.
  Stream<AuthUserVO?> authStateChanges() {
    return _authDataService
        .authStateChanges()
        .map((event) => event is User ? AuthUserVO.fromAuthUser(event) : null);
  }

  /// Returns the currently authenticated user as an `AuthUserVO` object.
  AuthUserVO? get currentUser => _authDataService.currentUser is User
      ? AuthUserVO.fromAuthUser(_authDataService.currentUser!)
      : null;

  /// Signs in the user anonymously and returns an `AuthUserCredentialVO` object.
  Future<AuthUserCredentialVO> signInAnonymously() async {
    try {
      final authCredential = await _authDataService.signInAnonymously();
      final vo = AuthUserCredentialVO.fromAuthUserCredential(authCredential);
      return vo;
    } catch (e) {
      if (e is RdevException) {
        throw AuthServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw AuthServiceException(
          stackTrace: StackTrace.current, message: e.toString());
    }
  }

  /// Signs in the user using Google authentication and returns an `AuthUserCredentialVO` object.
  Future<AuthUserCredentialVO> signInWithGoogle() async {
    try {
      final authCredential = await _authDataService.signInWithGoogle();
      final vo = AuthUserCredentialVO.fromAuthUserCredential(authCredential);
      return vo;
    } catch (e) {
      if (e is RdevException) {
        throw AuthServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw AuthServiceException(
          stackTrace: StackTrace.current, message: e.toString());
    }
  }

  /// Signs in the user using Facebook authentication and returns an `AuthUserCredentialVO` object.
  Future<AuthUserCredentialVO> signInWithFacebook() async {
    try {
      final authCredential = await _authDataService.signInWithFacebook();
      final vo = AuthUserCredentialVO.fromAuthUserCredential(authCredential);
      return vo;
    } catch (e) {
      if (e is RdevException) {
        throw AuthServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw AuthServiceException(
          stackTrace: StackTrace.current, message: e.toString());
    }
  }

  /// Signs in the user with the provided email and password, and returns an `AuthUserCredentialVO` object.
  Future<AuthUserCredentialVO> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final authCredential =
          await _authDataService.signInWithEmailAndPassword(email, password);
      final vo = AuthUserCredentialVO.fromAuthUserCredential(authCredential);
      return vo;
    } catch (e) {
      if (e is RdevException) {
        throw AuthServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw AuthServiceException(
          stackTrace: StackTrace.current, message: e.toString());
    }
  }

  /// Signs in the user using Apple authentication and returns an `AuthUserCredentialVO` object.
  Future<AuthUserCredentialVO> signInWithApple() async {
    try {
      final authCredential = await _authDataService.signInWithApple();
      final vo = AuthUserCredentialVO.fromAuthUserCredential(authCredential);
      return vo;
    } catch (e) {
      if (e is RdevException) {
        throw AuthServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw AuthServiceException(
          stackTrace: StackTrace.current, message: e.toString());
    }
  }

  /// Signs in the user using Microsoft authentication and returns an `AuthUserCredentialVO` object.
  Future<AuthUserCredentialVO> signInWithMicrosoft() async {
    try {
      final authCredential = await _authDataService.signInWithMicrosoft();
      final vo = AuthUserCredentialVO.fromAuthUserCredential(authCredential);
      return vo;
    } catch (e) {
      if (e is RdevException) {
        throw AuthServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw AuthServiceException(
          stackTrace: StackTrace.current, message: e.toString());
    }
  }

  /// Creates a new user with the provided email and password, and returns an `AuthUserCredentialVO` object.
  Future<AuthUserCredentialVO> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final authCredential =
          await _authDataService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final vo = AuthUserCredentialVO.fromAuthUserCredential(authCredential);
      return vo;
    } catch (e) {
      if (e is RdevException) {
        throw AuthServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw AuthServiceException(
          stackTrace: StackTrace.current, message: e.toString());
    }
  }

  /// Logs out the currently authenticated user.
  Future<void> logout() async {
    try {
      await _authDataService.logout();
    } catch (e) {
      if (e is RdevException) {
        throw AuthServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw AuthServiceException(
          stackTrace: StackTrace.current, message: e.toString());
    }
  }

  /// Resends the email verification for the provided email.
  Future<void> resendEmailVerification(String email) async {
    try {
      await _authDataService.resendEmailVerification(email);
    } catch (e) {
      if (e is RdevException) {
        throw AuthServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw AuthServiceException(
          stackTrace: StackTrace.current, message: e.toString());
    }
  }

  /// Fetches the sign-in methods available for the provided email.
  Future<List<String>> fetchSignInMethodsForEmail(String email) async {
    try {
      return await _authDataService.fetchSignInMethodsForEmail(email);
    } catch (e) {
      if (e is RdevException) {
        throw AuthServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw AuthServiceException(
          stackTrace: StackTrace.current, message: e.toString());
    }
  }

  /// Sends a password reset email to the provided email.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authDataService.sendPasswordResetEmail(email);
    } catch (e) {
      if (e is RdevException) {
        throw AuthServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw AuthServiceException(
          stackTrace: StackTrace.current, message: e.toString());
    }
  }

  Future<AuthIDTokenResultVO?> refreshCurrentUserToken(
      {bool force = false}) async {
    try {
      final idTokenResult =
          await _authDataService.refreshCurrentUserToken(force: force);
      final vo = idTokenResult is IdTokenResult
          ? AuthIDTokenResultVO.fromIDTokenResult(idTokenResult)
          : null;
      return vo;
    } catch (e) {
      if (e is RdevException) {
        throw AuthServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw AuthServiceException(
          stackTrace: StackTrace.current, message: e.toString());
    }
  }

  Future<AuthUserVO> reloadCurrentUser() async {
    try {
      final authUser = await _authDataService.reloadCurrentUser();
      final vo = AuthUserVO.fromAuthUser(authUser);
      return vo;
    } catch (e) {
      if (e is RdevException) {
        throw AuthServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw AuthServiceException(
          stackTrace: StackTrace.current, message: e.toString());
    }
  }

  /// Provider for the `AuthService` class.
  static Provider<AuthService> provider = Provider<AuthService>((ref) {
    final authService = AuthService(ref.watch(AuthDataService.provider));
    return authService;
  });
}

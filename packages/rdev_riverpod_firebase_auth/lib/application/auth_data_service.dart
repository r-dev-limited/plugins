import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';
import 'package:rdev_riverpod_firebase/firebase_providers.dart';

/// Exception class for AuthService.
class AuthDataServiceException extends RdevException {
  AuthDataServiceException({
    String? message,
    RdevCode? code,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          stackTrace: stackTrace,
        );
}

/// This class provides data services for authentication.
class AuthDataService {
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;
  final GoogleSignIn _googleSignIn;

  /// Constructor for AuthDataService.
  AuthDataService(
    this._auth,
    this._functions, [
    GoogleSignIn? googleSignIn,
  ]) : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email', 'profile'],
              signInOption: SignInOption.standard,
              clientId: kIsWeb
                  ? const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID')
                  : null,
            );

  /// Returns a stream of the current user's authentication state.
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  /// Returns the currently authenticated user.
  User? get currentUser => _auth.currentUser;

  // This is assigned to isWeb so that we can mock kIsWeb, this variable is only available to auth_service and tests.
  @visibleForTesting
  bool isWeb = kIsWeb;

  /// Signs in the user anonymously and returns the user credential.
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (err) {
      if (err is FirebaseAuthException) {
        throw AuthDataServiceException(
          stackTrace: err.stackTrace,
          message: err.message,
          code: RdevCode.Internal,
        );
      } else {
        throw AuthDataServiceException(
          message: err.toString(),
        );
      }
    }
  }

  /// Signs in the user using Google authentication and returns the user credential.
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final googleUser = await _googleSignIn.signIn();
      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      if (googleAuth is GoogleSignInAuthentication &&
          (googleAuth.accessToken is String || googleAuth.idToken is String)) {
        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        return await _auth.signInWithCredential(credential);
      } else {
        throw AuthDataServiceException(
          message: 'Google Sign In Failed',
        );
      }
    } catch (err) {
      if (err is FirebaseAuthException) {
        throw AuthDataServiceException(
          stackTrace: err.stackTrace,
          message: err.message,
          code: RdevCode.Internal,
        );
      }
      if (err is AuthDataServiceException) {
        rethrow;
      }
      throw AuthDataServiceException(
        message: err.toString(),
      );
    }
  }

  /// Signs in the user using Facebook authentication and returns the user credential.
  Future<UserCredential> signInWithFacebook() async {
    try {
      if (kIsWeb) {
        // Create a new provider
        FacebookAuthProvider facebookProvider = FacebookAuthProvider();
        facebookProvider.addScope('email');
        facebookProvider.setCustomParameters({
          'display': 'popup',
        });
        // Once signed in, return the UserCredential
        final credential =
            await FirebaseAuth.instance.signInWithPopup(facebookProvider);
        return credential;
      } else {
        // Trigger the sign-in flow
        final LoginResult loginResult = await FacebookAuth.instance.login();
        switch (loginResult.status) {
          case LoginStatus.success:
            {
              // Create a credential from the access token
              final OAuthCredential facebookAuthCredential =
                  FacebookAuthProvider.credential(
                      loginResult.accessToken!.token);
              // Once signed in, return the UserCredential
              final credential = await FirebaseAuth.instance
                  .signInWithCredential(facebookAuthCredential);
              return credential;
            }
          case LoginStatus.cancelled:
            throw AuthDataServiceException(
                message: 'Facebook Sign In Cancelled', code: RdevCode.Aborted);

          default:
            throw AuthDataServiceException(
              message: 'Facebook Sign In Failed',
            );
        }
      }
    } catch (err) {
      if (err is FirebaseAuthException) {
        throw AuthDataServiceException(
            message: err.message,
            code: RdevCode.Internal,
            stackTrace: err.stackTrace);
      }
      throw AuthDataServiceException(
        message: err.toString(),
      );
    }
  }

  /// Signs in the user using Apple authentication and returns the user credential.
  Future<UserCredential> signInWithApple() async {
    try {
      final appleProvider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');
      if (isWeb) {
        return await _auth.signInWithPopup(appleProvider);
      } else {
        return await _auth.signInWithProvider(appleProvider);
      }
    } catch (err) {
      if (err is FirebaseAuthException) {
        throw AuthDataServiceException(
            message: err.message,
            code: RdevCode.Internal,
            stackTrace: err.stackTrace);
      }
      throw AuthDataServiceException(
        message: err.toString(),
      );
    }
  }

  /// Signs in the user using Microsoft authentication and returns the user credential.
  Future<UserCredential> signInWithMicrosoft() async {
    try {
      final microsoftProvider = MicrosoftAuthProvider();
      if (isWeb) {
        return await _auth.signInWithPopup(microsoftProvider);
      } else {
        return await _auth.signInWithProvider(microsoftProvider);
      }
    } catch (err) {
      if (err is FirebaseAuthException) {
        throw AuthDataServiceException(
            message: err.message,
            code: RdevCode.Internal,
            stackTrace: err.stackTrace);
      }
      throw AuthDataServiceException(
        message: err.toString(),
      );
    }
  }

  /// Signs in the user with the provided email and password, and returns the user credential.
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential;
    } catch (err) {
      if (err is FirebaseAuthException) {
        throw AuthDataServiceException(
            message: err.message,
            code: RdevCode.Internal,
            stackTrace: err.stackTrace);
      }
      throw AuthDataServiceException(
        message: err.toString(),
      );
    }
  }

  /// Creates a new user with the provided email, password, and optional display name, and returns the user credential.
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (displayName is String && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
      }
      return credential;
    } catch (err) {
      if (err is FirebaseAuthException) {
        throw AuthDataServiceException(
            message: err.message,
            code: RdevCode.Internal,
            stackTrace: err.stackTrace);
      }
      throw AuthDataServiceException(
        message: err.toString(),
      );
    }
  }

  /// Logs out the currently authenticated user.
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (err) {
      throw AuthDataServiceException(
        message: err.toString(),
      );
    }
    try {
      await _googleSignIn.signOut();
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  /// Resends the email verification for the provided email.
  Future<void> resendEmailVerification(String email) {
    try {
      return _functions
          .httpsCallable('callables-sendEmailVerification')
          .call({'email': email});
    } catch (err) {
      throw AuthDataServiceException(
        message: err.toString(),
      );
    }
  }

  /// Fetches the sign-in methods available for the provided email.
  Future<List<String>> fetchSignInMethodsForEmail(String email) async {
    try {
      final providers = await _auth.fetchSignInMethodsForEmail(email);
      return providers;
    } catch (err) {
      if (err is FirebaseAuthException) {
        /// When email is not found (iOS?)
        if (err.code == 'null-error') {
          return [];
        }
        throw AuthDataServiceException(
            message: err.message,
            code: RdevCode.Internal,
            stackTrace: err.stackTrace);
      }
      throw AuthDataServiceException(
        message: err.toString(),
      );
    }
  }

  /// Sends a password reset email to the provided email.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (err) {
      if (err is FirebaseAuthException) {
        throw AuthDataServiceException(
            message: err.message,
            code: RdevCode.Internal,
            stackTrace: err.stackTrace);
      }
      throw AuthDataServiceException(
        message: err.toString(),
      );
    }
  }

  Future<IdTokenResult?> refreshCurrentUserToken({bool force = false}) async {
    try {
      return _auth.currentUser?.getIdTokenResult(force);
    } catch (err) {
      if (err is AuthDataServiceException) {
        rethrow;
      }
      throw AuthDataServiceException(
        message: err.toString(),
      );
    }
  }

  Future<User> reloadCurrentUser() async {
    try {
      if (_auth.currentUser is User) {
        await _auth.currentUser!.reload();
        return _auth.currentUser!;
      } else {
        throw AuthDataServiceException(
          message: 'No current user',
          code: RdevCode.NotFound,
        );
      }
    } catch (err) {
      if (err is AuthDataServiceException) {
        rethrow;
      }
      throw AuthDataServiceException(
        message: err.toString(),
      );
    }
  }

  /// Provider for the `AuthDataService` class.
  static Provider<AuthDataService> provider = Provider<AuthDataService>((ref) {
    final authService = AuthDataService(
      ref.watch(fbAuthProvider),
      ref.watch(fbFunctionsProvider),
    );
    return authService;
  });
}

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';
import 'package:rdev_riverpod_firebase/firebase_providers.dart';
import 'package:rdev_riverpod_firebase/firestore_helpers.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';

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

  AuthDataServiceException.fromRdevException(
    RdevException rdevException,
  ) : super(
          message: rdevException.message,
          code: rdevException.code,
          stackTrace: rdevException.stackTrace,
        );
}

/// This class provides data services for authentication.
class AuthDataService {
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;
  final GoogleSignIn _googleSignIn;
  bool _googleSignInInitialized = false;

  /// Constructor for AuthDataService.
  AuthDataService(
    this._auth,
    this._functions, [
    GoogleSignIn? googleSignIn,
  ]) : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) {
      return;
    }
    await _googleSignIn.initialize(
      clientId: kIsWeb
          ? const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID')
          : null,
    );
    _googleSignInInitialized = true;
  }

  /// Returns a stream of the current user's authentication state.
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  /// Returns a stream of the current user's authentication state.
  Stream<User?> authIdTokenChanges() {
    return _auth.idTokenChanges();
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
        throw AuthDataServiceException.fromRdevException(err.toRdevException());
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
      await _ensureGoogleSignInInitialized();
      const scopeHint = ['email', 'profile'];
      // Sign out current user if not anonymous
      if (_auth.currentUser != null && _auth.currentUser!.isAnonymous != true) {
        await _auth.signOut();
      }

      if (_auth.currentUser != null && _auth.currentUser!.isAnonymous == true) {
        // Trigger the authentication flow
        final googleUser = await _googleSignIn.authenticate(
          scopeHint: scopeHint,
        );
        // Obtain the auth details from the request
        final googleAuth = googleUser.authentication;
        final authz = await googleUser.authorizationClient
            .authorizationForScopes(scopeHint);
        final accessToken = authz?.accessToken ??
            (await googleUser.authorizationClient.authorizeScopes(scopeHint))
                .accessToken;
        if (googleAuth.idToken is String || accessToken.isNotEmpty) {
          // Create a new credential
          final googleCredential = GoogleAuthProvider.credential(
            accessToken: accessToken,
            idToken: googleAuth.idToken,
          );

          final credential =
              await _auth.currentUser!.linkWithCredential(googleCredential);

          await _auth.currentUser!.reload();
          if (_auth.currentUser!.email is String &&
              _auth.currentUser!.email!.isNotEmpty) {
            await resendEmailVerification(_auth.currentUser!.email!);
          }
          return credential;
        } else {
          throw AuthDataServiceException(
            message: 'Google Sign In Failed',
          );
        }
      }

      // Trigger the authentication flow
      final googleUser = await _googleSignIn.authenticate(
        scopeHint: scopeHint,
      );
      // Obtain the auth details from the request
      final googleAuth = googleUser.authentication;
      final authz =
          await googleUser.authorizationClient.authorizationForScopes(
        scopeHint,
      );
      final accessToken = authz?.accessToken ??
          (await googleUser.authorizationClient.authorizeScopes(scopeHint))
              .accessToken;
      if (googleAuth.idToken is String || accessToken.isNotEmpty) {
        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: accessToken,
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
        throw AuthDataServiceException.fromRdevException(err.toRdevException());
      }
      if (err is AuthDataServiceException) {
        rethrow;
      }
      throw AuthDataServiceException(
        message: err.toString(),
      );
    }
  }

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Signs in the user using Facebook authentication and returns the user credential.
  Future<UserCredential> signInWithFacebook() async {
    try {
      if (_auth.currentUser != null && _auth.currentUser!.isAnonymous != true) {
        await _auth.signOut();
      }
      if (kIsWeb) {
        // Create a new provider
        FacebookAuthProvider facebookProvider = FacebookAuthProvider();
        facebookProvider.addScope('email');
        facebookProvider.setCustomParameters({
          'display': 'popup',
        });

        // Once signed in, return the UserCredential
        final credential = await _auth.signInWithPopup(facebookProvider);
        return credential;
      } else {
        final rawNonce = generateNonce();
        final nonce = sha256ofString(rawNonce);

        // Trigger the sign-in flow
        final LoginResult loginResult = await FacebookAuth.instance
            .login(loginTracking: LoginTracking.limited, nonce: nonce);
        switch (loginResult.status) {
          case LoginStatus.success:
            {
              final AuthCredential facebookAuthCredential;

              switch (loginResult.accessToken!.type) {
                case AccessTokenType.classic:
                  final token = loginResult.accessToken! as ClassicToken;
                  facebookAuthCredential = FacebookAuthProvider.credential(
                    token.authenticationToken!,
                  );
                  break;
                case AccessTokenType.limited:
                  final token = loginResult.accessToken! as LimitedToken;
                  facebookAuthCredential = OAuthCredential(
                    providerId: 'facebook.com',
                    signInMethod: 'oauth',
                    idToken: token.tokenString,
                    rawNonce: rawNonce,
                  );
                  break;
              }

              if (_auth.currentUser != null &&
                  _auth.currentUser!.isAnonymous == true) {
                final credential = _auth.currentUser!
                    .linkWithCredential(facebookAuthCredential);
                await _auth.currentUser!.reload();
                if (_auth.currentUser!.email is String &&
                    _auth.currentUser!.email!.isNotEmpty) {
                  await resendEmailVerification(_auth.currentUser!.email!);
                }
                return credential;
              }
              // Once signed in, return the UserCredential
              final credential =
                  await _auth.signInWithCredential(facebookAuthCredential);
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
        throw AuthDataServiceException.fromRdevException(err.toRdevException());
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
        if (_auth.currentUser != null &&
            _auth.currentUser!.isAnonymous == true) {
          final appleIdCredential =
              await SignInWithApple.getAppleIDCredential(scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ]);
          final credential = _auth.currentUser!.linkWithCredential(
            OAuthProvider('apple.com').credential(
              idToken: appleIdCredential.identityToken,
              accessToken: appleIdCredential.authorizationCode,
            ),
          );
          await _auth.currentUser!.reload();
          if (_auth.currentUser!.email is String &&
              _auth.currentUser!.email!.isNotEmpty) {
            await resendEmailVerification(_auth.currentUser!.email!);
          }
          return credential;
        }
        return await _auth.signInWithProvider(appleProvider);
      }
    } catch (err) {
      if (err is FirebaseAuthException) {
        throw AuthDataServiceException.fromRdevException(err.toRdevException());
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
        throw AuthDataServiceException.fromRdevException(err.toRdevException());
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
        throw AuthDataServiceException.fromRdevException(err.toRdevException());
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
      // Sign out current user if not anonymous
      if (_auth.currentUser != null && _auth.currentUser!.isAnonymous != true) {
        await _auth.signOut();
      } else if (_auth.currentUser != null &&
          _auth.currentUser!.isAnonymous == true) {
        /// create email provider
        final emailProvider =
            EmailAuthProvider.credential(email: email, password: password);
        final credential =
            await _auth.currentUser!.linkWithCredential(emailProvider);
        if (displayName is String && displayName.isNotEmpty) {
          await credential.user?.updateDisplayName(displayName);
        }
        //This should update claims too
        await resendEmailVerification(email);
        await _auth.currentUser!.reload();
        return credential;
      }

      final credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (displayName is String && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
      }

      return credential;
    } catch (err) {
      if (err is FirebaseAuthException) {
        throw AuthDataServiceException.fromRdevException(err.toRdevException());
      }
      throw AuthDataServiceException(
        message: err.toString(),
      );
    }
  }

  /// Links an email/password credential to the current user.
  Future<UserCredential> linkEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthDataServiceException(message: 'No current user');
      }
      final emailProvider =
          EmailAuthProvider.credential(email: email, password: password);
      final credential = await user.linkWithCredential(emailProvider);
      await user.getIdToken(true);
      await resendEmailVerification(email);
      await user.reload();
      return credential;
    } catch (err) {
      if (err is FirebaseAuthException) {
        throw AuthDataServiceException.fromRdevException(err.toRdevException());
      }
      if (err is AuthDataServiceException) {
        throw err;
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
      final authPlatform = FirebaseAuthPlatform.instanceFor(
        app: _auth.app,
        pluginConstants: _auth.pluginConstants,
      );
      final providers = await authPlatform.fetchSignInMethodsForEmail(email);
      return providers;
    } catch (err) {
      if (err is FirebaseAuthException) {
        /// When email is not found (iOS?)
        if (err.code == 'null-error') {
          return [];
        }
        throw AuthDataServiceException.fromRdevException(err.toRdevException());
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
        throw AuthDataServiceException.fromRdevException(err.toRdevException());
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

  Future<void> deleteCurrentUser() async {
    try {
      if (_auth.currentUser is User) {
        await _auth.currentUser!.delete();
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

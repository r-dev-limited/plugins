import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

import '../application/auth_service.dart';
import '../domain/auth_idtoken_result_vo.dart';
import '../domain/auth_user_vo.dart';

@immutable
class AuthRepositoryState extends Equatable {
  final AuthIDTokenResultVO? tokenResult;
  final AuthUserVO? authUser;

  bool get isDeveloper {
    if (tokenResult?.claims != null) {
      return tokenResult!.claims!['d'] == 1;
    }

    return false;
  }

  String get role {
    if (tokenResult?.claims != null) {
      return tokenResult!.claims!['role'] ?? 'User';
    }

    return 'User';
  }

  bool get hasVerifiedEmail {
    return authUser?.isEmailVerified ?? false;
  }

  bool get isReady {
    return authUser is AuthUserVO &&
        (authUser!.isAnonymous ||
            tokenResult is AuthIDTokenResultVO && hasVerifiedEmail);
  }

  const AuthRepositoryState({
    this.authUser,
    this.tokenResult,
  });

  AuthRepositoryState copyWith({
    AuthIDTokenResultVO? tokenResult,
    AuthUserVO? authUser,
    DateTime? lastUpdatedClaims,
  }) {
    return AuthRepositoryState(
      authUser: authUser ?? this.authUser,
      tokenResult: tokenResult ?? this.tokenResult,
    );
  }

  @override
  List<Object?> get props => [
        authUser.hashCode,
        tokenResult.hashCode,
      ];

  Map<String, dynamic> toMap() {
    return {
      'authUser': authUser,
      'tokenResult': tokenResult,
      'isDeveloper': isDeveloper,
      'isReady': isReady,
    };
  }
}

class AuthRepository extends AsyncNotifier<AuthRepositoryState> {
  final log = Logger('AuthRepository');
  late AuthService _authService;

  ///
  StreamSubscription? _authStateChangesSubscription;

  /// Build (Init)
  @override
  FutureOr<AuthRepositoryState> build() async {
    log.info('build()');
    _authService = ref.watch(AuthService.provider);

    var result = const AuthRepositoryState();

    /// Cancel all subscriptions
    await _authStateChangesSubscription?.cancel();

    /// Give it a bit of time to cancel
    await Future.delayed(const Duration(seconds: 1));

    /// Check current user
    final currentUser = _authService.currentUser;
    if (currentUser is AuthUserVO) {
      try {
        result = await _fetchUserData(currentUser);
      } catch (err) {
        log.severe('build() _fetchUserData()', err);
        await _authService.logout();
      }
    }

    /// Stream Changes
    _authStateChangesSubscription = _authService.authStateChanges().listen(
      (user) async {
        if (user?.uid != result.authUser?.uid) {
          log.info('build authStateChanges()', user);
          final tmpState = await _fetchUserData(user);
          state = AsyncValue.data(tmpState);
        }
      },
    );

    return result;
  }

  Future<AuthRepositoryState> _fetchUserData(AuthUserVO? user) async {
    log.info('_fetchUserData()', user);
    if (user is AuthUserVO) {
      var result = AuthRepositoryState(authUser: user);

      /// TODO: Isolate analytics away
      /// Update analytics
      // try {
      //   await AnalyticsDataSource.instance.setAnalyticsUserId(user.uid);
      //   await AnalyticsDataSource.instance.analytics
      //       .setAnalyticsCollectionEnabled(true);

      //   /// Set analytics values for RemoteConfig usage.
      //   final organisation = user.email?.split('@').last;
      //   if (organisation is String) {
      //     await AnalyticsDataSource.instance.setUserProperty(
      //         ConfigurationAnalyticsUserPropertyKeys.organisation,
      //         organisation);

      //     await AnalyticsDataSource.instance.setUserProperty(
      //         ConfigurationAnalyticsUserPropertyKeys.isInternalUser,
      //         organisation == 'placebo.life' ? 'true' : 'false');
      //   }
      // } catch (err) {
      //   log.warning('_newUserDetected() - setAnalyticsUserId failed', err);
      // }

      /// Refresh Token
      try {
        final token = await refreshToken();
        result = result.copyWith(
          tokenResult: token,
          lastUpdatedClaims: DateTime.now(),
        );
      } catch (err) {
        log.warning('_newUserDetected() - getIdTokenResult failed', err);
      }

      // await _startFirestoreUserStream(user);
      return result;
    } else {
      /// Update analytics
      // try {
      //   await AnalyticsDataSource.instance.setAnalyticsUserId(null);
      // } catch (err) {
      //   log.warning('_newUserDetected() - setAnalyticsUserId failed', err);
      // }
      return const AuthRepositoryState();
    }
  }

  /// Private Methods
  Future<AuthIDTokenResultVO?> refreshToken() async {
    try {
      final tokenResult =
          await _authService.refreshCurrentUserToken(force: true);

      if (state.value?.tokenResult != null && state.value?.authUser != null) {
        final currentUser = await _authService.reloadCurrentUser();
        state = AsyncValue.data(state.value!.copyWith(
          tokenResult: tokenResult,
          authUser: currentUser,
        ));
      }

      return tokenResult;
    } catch (err) {
      log.warning('_newUserDetected() - getIdTokenResult failed', err);
    }
    return null;
  }

  Future<void> signInAnonymously() async {
    log.info('signInAnonymously()');
    try {
      await _authService.signInAnonymously();
    } catch (err) {
      if (err is AuthServiceException) {
        log.severe(
          'signInAnonymously() - failed',
          err.message,
        );
        rethrow;
      }
    }
  }

  Future<void> logout() async {
    log.info('logout()');
    // Set the state to loading
    state = const AsyncValue.loading();
    try {
      await _authService.logout();
    } catch (err) {
      state = const AsyncValue.data(AuthRepositoryState());
      throw err;
    }
  }

  static AsyncNotifierProvider<AuthRepository, AuthRepositoryState> provider =
      AsyncNotifierProvider<AuthRepository, AuthRepositoryState>(() {
    return AuthRepository();
  });
}

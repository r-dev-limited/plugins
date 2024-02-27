import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

import '../application/auth_service.dart';
import '../domain/auth_user_vo.dart';

@immutable
class AuthRepositoryState extends Equatable {
  final AuthUserVO? authUser;

  bool get hasVerifiedEmail {
    return authUser?.isEmailVerified ?? false;
  }

  const AuthRepositoryState({
    this.authUser,
  });

  AuthRepositoryState copyWith({
    AuthUserVO? authUser,
    DateTime? lastUpdatedClaims,
  }) {
    return AuthRepositoryState(
      authUser: authUser ?? this.authUser,
    );
  }

  @override
  List<Object?> get props => [
        authUser.hashCode,
      ];
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

    var resultCompleter = Completer<AuthRepositoryState>();

    /// Cancel all subscriptions
    await _authStateChangesSubscription?.cancel();

    /// Give it a bit of time to cancel
    await Future.delayed(const Duration(seconds: 1));

    /// Check current user
    final currentUser = _authService.currentUser;
    if (currentUser is AuthUserVO) {
      try {
        resultCompleter.complete(AuthRepositoryState(authUser: currentUser));
      } catch (err) {
        log.severe('build() _fetchUserData()', err);
        await _authService.logout();
        resultCompleter.complete(const AuthRepositoryState());
      }
    }

    /// Stream Changes
    _authStateChangesSubscription = _authService.authStateChanges().listen(
      (user) async {
        log.info('build authStateChanges()', user);
        final tmpState = AuthRepositoryState(authUser: user);
        if (!resultCompleter.isCompleted) {
          resultCompleter.complete(tmpState);
        } else {
          state = AsyncValue.data(tmpState);
        }
      },
    );

    return resultCompleter.future;
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

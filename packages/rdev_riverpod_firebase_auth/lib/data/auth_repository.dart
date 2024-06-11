import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rdev_errors_logging/talker_provider.dart';
import 'package:talker/talker.dart';

import '../application/auth_service.dart';
import '../domain/auth_user_vo.dart';

class AuthRepositoryLog extends TalkerLog {
  AuthRepositoryLog(
    String message, [
    dynamic args,
    StackTrace? stackTrace,
  ]) : super(
          message,
          exception: args,
          stackTrace: stackTrace,
        );

  /// Your custom log title
  @override
  String get title => 'AuthRepository';

  /// Your custom log color
  @override
  AnsiPen get pen => AnsiPen()..cyan();
}

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
  late Talker _log;
  late AuthService _authService;

  ///
  StreamSubscription? _authStateChangesSubscription;

  /// Build (Init)
  @override
  FutureOr<AuthRepositoryState> build() async {
    _log = ref.watch(appTalkerProvider);
    _log.logTyped(AuthRepositoryLog('build()'));

    _authService = ref.read(AuthService.provider);

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
        _log.logTyped(AuthRepositoryLog(
            'build() _fetchUserData()', err, StackTrace.current));
        await _authService.logout();
        resultCompleter.complete(const AuthRepositoryState());
      }
    }

    /// Stream Changes
    _authStateChangesSubscription = _authService.authStateChanges().listen(
      (user) async {
        _log.logTyped(AuthRepositoryLog('build authStateChanges()', user));
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
    _log.logTyped(AuthRepositoryLog('signInAnonymously()'));
    try {
      await _authService.signInAnonymously();
    } catch (err) {
      if (err is AuthServiceException) {
        _log.logTyped(AuthRepositoryLog(
            'signInAnonymously() - failed', err.message, StackTrace.current));
        rethrow;
      }
    }
  }

  Future<void> deleteCurrentUser() async {
    _log.logTyped(AuthRepositoryLog('deleteCurrentUser()'));
    try {
      await _authService.deleteCurrentUser();
    } catch (err) {
      if (err is AuthServiceException) {
        _log.logTyped(AuthRepositoryLog(
            'deleteCurrentUser() - failed', err.message, StackTrace.current));
        rethrow;
      }
    }
  }

  Future<void> logout() async {
    _log.logTyped(AuthRepositoryLog('logout()'));
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

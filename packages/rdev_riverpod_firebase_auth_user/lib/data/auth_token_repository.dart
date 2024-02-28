import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:rdev_riverpod_firebase_auth/application/auth_service.dart';
import 'package:rdev_riverpod_firebase_auth/domain/auth_idtoken_result_vo.dart';
import 'package:rdev_riverpod_firebase_user/data/user_repository.dart';

@immutable
class AuthTokenRepositoryState extends Equatable {
  final AuthIDTokenResultVO? tokenResult;

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

  bool get isEmailVerified {
    if (tokenResult?.claims != null) {
      return tokenResult!.claims!['email_verified'] == true;
    }

    return false;
  }

  const AuthTokenRepositoryState({
    this.tokenResult,
  });

  AuthTokenRepositoryState copyWith({
    AuthIDTokenResultVO? tokenResult,
    DateTime? lastUpdatedClaims,
  }) {
    return AuthTokenRepositoryState(
      tokenResult: tokenResult ?? this.tokenResult,
    );
  }

  @override
  List<Object?> get props => [
        tokenResult.hashCode,
      ];
}

class AuthTokenRepository
    extends FamilyAsyncNotifier<AuthTokenRepositoryState, String?> {
  final log = Logger('AuthRepository');
  late AuthService _authService;
  String? _currentUserId;

  /// Build (Init)
  /// This method will be called every time lastUpdatedClaims changes
  /// Which will hapen on actual claim change OR user switch OR user init
  @override
  FutureOr<AuthTokenRepositoryState> build(arg) async {
    _authService = ref.read(AuthService.provider);
    _currentUserId = arg;

    final claims = ref.watch(UserRepository.provider
        .call(_currentUserId)
        .select((data) => data.value?.user?.lastUpdatedClaims));

    // ref.listen(UserRepository.provider.call(_currentUserId),
    //     (previous, next) async {
    //   if (previous?.value?.user?.lastUpdatedClaims !=
    //       next.value?.user?.lastUpdatedClaims) {
    //     final tokenResult =
    //         await _authService.refreshCurrentUserToken(force: claims != null);
    //     state = AsyncValue.data(AuthTokenRepositoryState(
    //       tokenResult: tokenResult,
    //     ));
    //   }
    // });
    try {
      await Future.delayed(Duration(seconds: 1));
      final tokenResult =
          await _authService.refreshCurrentUserToken(force: claims != null);
      log.fine(tokenResult?.claims);
      return AuthTokenRepositoryState(
        tokenResult: tokenResult,
      );
    } catch (e) {
      return AuthTokenRepositoryState();
    }
  }

  Future<AuthTokenRepositoryState> refreshToken({bool force = true}) async {
    final oldState = state;
    state = AsyncLoading();
    AuthTokenRepositoryState result = state.value ?? AuthTokenRepositoryState();
    try {
      final tokenResult =
          await _authService.refreshCurrentUserToken(force: force);
      result = AuthTokenRepositoryState(tokenResult: tokenResult);
      state = AsyncData(result);
    } catch (e) {
      log.warning(e);
      state = oldState;
    }
    return result;
  }

  static AsyncNotifierProviderFamily<AuthTokenRepository,
          AuthTokenRepositoryState, String?> provider =
      AsyncNotifierProvider.family<AuthTokenRepository,
          AuthTokenRepositoryState, String?>(() {
    return AuthTokenRepository();
  });
}

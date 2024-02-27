import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:rdev_riverpod_firebase_auth/application/auth_service.dart';
import 'package:rdev_riverpod_firebase_auth/domain/auth_idtoken_result_vo.dart';
import 'package:rdev_riverpod_firebase_auth_user/data/current_user_repository.dart';

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

class AuthTokenRepository extends AsyncNotifier<AuthTokenRepositoryState> {
  final log = Logger('AuthRepository');
  late AuthService _authService;

  /// Build (Init)
  /// This method will be called every time lastUpdatedClaims changes
  /// Which will hapen on actual claim change OR user switch OR user init
  @override
  FutureOr<AuthTokenRepositoryState> build() async {
    _authService = ref.read(AuthService.provider);
    ref.watch(CurrentUserRepository.provider
        .select((data) => data.value?.userVO?.lastUpdatedClaims));

    final tokenResult = await _authService.refreshCurrentUserToken(force: true);
    return AuthTokenRepositoryState(
      tokenResult: tokenResult,
    );
  }

  static AsyncNotifierProvider<AuthTokenRepository, AuthTokenRepositoryState>
      provider =
      AsyncNotifierProvider<AuthTokenRepository, AuthTokenRepositoryState>(() {
    return AuthTokenRepository();
  });
}

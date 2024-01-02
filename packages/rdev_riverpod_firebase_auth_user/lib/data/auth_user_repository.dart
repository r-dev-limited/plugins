/// This file contains the implementation of the AuthUserRepository class, which is responsible for managing the authentication state and user data.
///
/// The [AuthUserRepository] class extends the [AsyncNotifier] class and holds the state of the authentication repository and the last updated claims.
///
/// The [AuthUserRepositoryState] class is an immutable class that represents the state of the [AuthUserRepository]. It contains the [AuthRepositoryState] and [DateTime] of the last updated claims.
///
/// The [copyWith] method in the [AuthUserRepositoryState] class is used to create a new instance of the state with updated values.
///
/// The [props] method in the [AuthUserRepositoryState] class returns a list of properties that are used to determine if two instances of the state are equal.
///
/// The [AuthUserRepository] class also contains a logger instance named 'log' from the [Logger] class for logging purposes.
///
/// The [build] method in the [AuthUserRepository] class is an overridden method from the [AsyncNotifier] class. It is responsible for building the state of the repository by reading the [AuthRepository] provider and listening to changes in the [CurrentUserRepository] provider.
///
/// The [provider] static member in the [AuthUserRepository] class is an instance of the [AsyncNotifierProvider] that provides the [AuthUserRepository] and [AuthUserRepositoryState] to other parts of the application.
///

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:rdev_riverpod_firebase_auth/data/auth_repository.dart';
import 'package:rdev_riverpod_firebase_user/data/user_repository.dart';

@immutable
class AuthUserRepositoryState extends Equatable {
  final AuthRepositoryState? authRepositoryState;
  final DateTime? lastUpdatedClaims;

  /// Constructs an instance of [AuthUserRepositoryState] with the given parameters.
  const AuthUserRepositoryState({
    this.authRepositoryState,
    this.lastUpdatedClaims,
  });

  /// Creates a new instance of the state with updated values.
  AuthUserRepositoryState copyWith({
    AuthRepositoryState? authRepositoryState,
    UserRepositoryState? currentUserRepositoryState,
    DateTime? lastUpdatedClaims,
  }) {
    return AuthUserRepositoryState(
      authRepositoryState: authRepositoryState ?? this.authRepositoryState,
      lastUpdatedClaims: lastUpdatedClaims ?? this.lastUpdatedClaims,
    );
  }

  @override
  List<Object?> get props => [
        authRepositoryState.hashCode,
        lastUpdatedClaims,
      ];
}

/// The [AuthUserRepository] class extends the [AsyncNotifier] class and manages the authentication state and user data.
class AuthUserRepository extends AsyncNotifier<AuthUserRepositoryState> {
  final log = Logger('AuthUserRepository');
  late AuthRepository _authRepository;

  @override
  FutureOr<AuthUserRepositoryState> build() async {
    _authRepository = ref.read(AuthRepository.provider.notifier);
    final authState = await ref.watch(AuthRepository.provider.future);
    final currentUserRepositoryProvider =
        UserRepository.provider.call(authState.authUser?.uid);

    /// Listens to changes in the [CurrentUserRepository] provider and updates the state accordingly.
    ref.listen(
      currentUserRepositoryProvider.selectAsync(
        (value) => value.user?.lastUpdatedClaims,
      ),
      (prev, next) async {
        var nextLastUpdatedClaims = await next as DateTime?;
        if (state.value != null && state.value?.lastUpdatedClaims == null) {
          state = AsyncValue.data(
            (state.value ?? const AuthUserRepositoryState())
                .copyWith(lastUpdatedClaims: nextLastUpdatedClaims),
          );
        } else {
          if (nextLastUpdatedClaims != state.value?.lastUpdatedClaims) {
            unawaited(_authRepository.refreshToken());
          }
        }
      },
    );

    return AuthUserRepositoryState(
      authRepositoryState: authState,
    );
  }

  /// The [provider] is a static member of the [AuthUserRepository] class that provides the [AuthUserRepository] and [AuthUserRepositoryState] to other parts of the application.
  static AsyncNotifierProvider<AuthUserRepository, AuthUserRepositoryState>
      provider =
      AsyncNotifierProvider<AuthUserRepository, AuthUserRepositoryState>(() {
    return AuthUserRepository();
  });
}

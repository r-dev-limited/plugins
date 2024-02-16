// This file contains the implementation of the CurrentUserRepository class
// which is responsible for managing the current user state.

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:rdev_riverpod_firebase/firebase_providers.dart';
import 'package:rdev_riverpod_firebase_auth/data/auth_repository.dart';
import 'package:rdev_riverpod_firebase_user/data/user_repository.dart';
import 'package:rdev_riverpod_firebase_user/domain/user_vo.dart';

final fbMessagingTokenRefreshProvider = StreamProvider<String>((ref) {
  final messagingInstance = ref.watch(fbMessagingProvider);

  return messagingInstance.onTokenRefresh;
});

final currentFbMessagingTokenProvider = StateProvider<String?>((ref) {
  final messagingInstance =
      ref.watch(fbMessagingTokenRefreshProvider.select((value) => value));

  return messagingInstance.value;
});

// Abstract class representing the state of the CurrentUserRepository
@immutable
class CurrentUserRepositoryState extends Equatable {
  final UserVO? user;
  final AuthRepositoryState authRepositoryState;

  ///
  const CurrentUserRepositoryState({
    this.user,
    required this.authRepositoryState,
  });

  @override
  List<Object?> get props => [
        user,
        authRepositoryState,
      ];
}

// CurrentUserRepository class responsible for managing the current user state
class CurrentUserRepository extends AsyncNotifier<CurrentUserRepositoryState> {
  final log = Logger('CurrentUserRepository');
  String? _currentUserId;

  late UserRepository _userRepository;
  late AuthRepository _authRepository;

  @override
  FutureOr<CurrentUserRepositoryState> build() async {
    log.info('build()');
    _authRepository = ref.watch(AuthRepository.provider.notifier);

    final authState = await ref.watch(AuthRepository.provider.future);
    _currentUserId = authState.authUser?.uid;
    _userRepository =
        ref.watch(UserRepository.provider.call(_currentUserId).notifier);

    if (_currentUserId is String) {
      final userVO = await ref.watch(UserRepository.provider
          .call(_currentUserId)
          .selectAsync((data) => data.user));

      /// Monitor Future Changes

      ref.listen(currentFbMessagingTokenProvider, (previous, next) {
        if (next is String && _currentUserId is String) {
          log.info('Token Changed: ${next}');
          ref
              .read(UserRepository.provider.call(_currentUserId).notifier)
              .updateUserFCMToken(next);
        }
      });

      try {
        final settings = await ref.read(fbMessagingProvider).requestPermission(
            alert: true,
            badge: true,
            provisional: true,
            sound: true,
            announcement: true);

        this
            .log
            .info('User granted permission: ${settings.authorizationStatus}');
        const vapidKey = const String.fromEnvironment('VAPID_KEY');
        final currentToken =
            await ref.read(fbMessagingProvider).getToken(vapidKey: vapidKey);
        log.info('Current Token: $currentToken');
        if (currentToken is String && _currentUserId is String) {
          ref.read(currentFbMessagingTokenProvider.notifier).state =
              currentToken;
        }
      } catch (err) {
        /// This might fail, and we should leave it to the user to fix it.
        this.log.warning(err);
      }
      return CurrentUserRepositoryState(
        user: userVO,
        authRepositoryState: authState,
      );
    } else {
      return CurrentUserRepositoryState(authRepositoryState: authState);
    }
  }

  Future<void> updateUser(UserVO vo) async {
    if (_currentUserId is String &&
        (vo.uid is String && vo.uid == _currentUserId || vo.uid == null)) {
      final updatedVO = vo.copyWith(uid: _currentUserId);
      final oldState = state.value;
      state = AsyncValue.loading();
      try {
        await _userRepository.updateUser(updatedVO);
      } catch (err) {
        state = AsyncValue.data(oldState!);
        throw err;
      }
    }
  }

  Future<void> onboardingFinished(Map<String, dynamic> payload) async {
    if (_currentUserId is String) {
      try {
        await _userRepository.onboardingFinished(payload);
      } catch (err) {
        throw err;
      }
    }
  }

  Future<void> logout() async {
    final lastToken = ref.read(currentFbMessagingTokenProvider);
    if (lastToken is String) {
      try {
        await _userRepository.removeUserFCMToken(lastToken);
      } catch (err) {
        log.warning(err);
      }
    }
    try {
      await _authRepository.logout();
    } catch (err) {
      log.warning(err);
    }

    _currentUserId = null;
  }

  // Provider for the CurrentUserRepository class
  static AsyncNotifierProvider<CurrentUserRepository,
          CurrentUserRepositoryState> provider =
      AsyncNotifierProvider<CurrentUserRepository, CurrentUserRepositoryState>(
          () {
    return CurrentUserRepository();
  });
}

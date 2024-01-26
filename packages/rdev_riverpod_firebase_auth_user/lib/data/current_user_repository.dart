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
  const CurrentUserRepositoryState({this.user});

  @override
  List<Object?> get props => [
        user,
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
    _currentUserId = await ref.watch(
        AuthRepository.provider.selectAsync((data) => data.authUser?.uid));
    _userRepository =
        ref.watch(UserRepository.provider.call(_currentUserId).notifier);
    _authRepository = ref.watch(AuthRepository.provider.notifier);
    if (_currentUserId is String) {
      await ref.read(fbMessagingProvider).requestPermission(
          alert: true,
          badge: true,
          provisional: true,
          sound: true,
          announcement: true);
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

      final currentToken = await ref
          .read(fbMessagingProvider)
          .getToken(vapidKey: String.fromEnvironment('VapidKey'));
      log.info('Current Token: $currentToken');
      if (currentToken is String && _currentUserId is String) {
        ref.read(currentFbMessagingTokenProvider.notifier).state = currentToken;
      }
      return CurrentUserRepositoryState(user: userVO);
    } else {
      return const CurrentUserRepositoryState();
    }
  }

  Future<void> updateUser(UserVO vo) async {
    if (_currentUserId is String &&
        (vo.uid is String && vo.uid == _currentUserId || vo.uid == null)) {
      final updatedVO = vo.copyWith(uid: _currentUserId);
      state = AsyncValue.loading();
      try {
        await ref
            .read(UserRepository.provider.call(_currentUserId).notifier)
            .updateUser(updatedVO);
      } catch (err) {
        throw err;
      }
    }
  }

  Future<void> logout() async {
    final lastToken = ref.read(currentFbMessagingTokenProvider);
    if (lastToken is String) {
      await ref
          .read(UserRepository.provider.call(_currentUserId).notifier)
          .removeUserFCMToken(lastToken);
    }

    await _authRepository.logout();
    _currentUserId = null;
    state = AsyncValue.data(CurrentUserRepositoryState());
  }

  // Provider for the CurrentUserRepository class
  static AsyncNotifierProvider<CurrentUserRepository,
          CurrentUserRepositoryState> provider =
      AsyncNotifierProvider<CurrentUserRepository, CurrentUserRepositoryState>(
          () {
    return CurrentUserRepository();
  });
}

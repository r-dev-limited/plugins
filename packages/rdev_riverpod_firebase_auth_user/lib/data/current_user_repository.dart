// This file contains the implementation of the CurrentUserRepository class
// which is responsible for managing the current user state.

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:rdev_riverpod_firebase_auth/data/auth_repository.dart';
import 'package:rdev_riverpod_firebase_user/data/user_repository.dart';
import 'package:rdev_riverpod_firebase_user/domain/user_vo.dart';

// Abstract class representing the state of the CurrentUserRepository
@immutable
class CurrentUserRepositoryState extends Equatable {
  final UserVO? user;

  ///
  const CurrentUserRepositoryState({
    this.user,
  });

  @override
  List<Object?> get props => [
        user,
      ];
}

// CurrentUserRepository class responsible for managing the current user state
class CurrentUserRepository
    extends FamilyAsyncNotifier<CurrentUserRepositoryState, String?> {
  final log = Logger('CurrentUserRepository');
  String? _currentUserId;

  late UserRepository _userRepository;

  @override
  FutureOr<CurrentUserRepositoryState> build(arg) async {
    log.info('build()');
    _currentUserId = arg;
    _userRepository =
        ref.read(UserRepository.provider.call(_currentUserId).notifier);

    if (_currentUserId is String) {
      final userVO = ref.watch(UserRepository.provider
          .call(_currentUserId)
          .select((data) => data.value?.user));

      return CurrentUserRepositoryState(
        user: userVO,
      );
    } else {
      return CurrentUserRepositoryState();
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
    try {
      await ref.read(AuthRepository.provider.notifier).logout();
    } catch (err) {
      log.warning(err);
    }

    _currentUserId = null;
  }

  // Provider for the CurrentUserRepository class
  static AsyncNotifierProviderFamily<CurrentUserRepository,
          CurrentUserRepositoryState, String?> provider =
      AsyncNotifierProvider.family<CurrentUserRepository,
          CurrentUserRepositoryState, String?>(() {
    return CurrentUserRepository();
  });
}

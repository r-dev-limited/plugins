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

@immutable
class CurrentUserRepositoryState extends Equatable {
  final UserVO? userVO;

  const CurrentUserRepositoryState({
    this.userVO,
  });

  @override
  List<Object?> get props => [
        userVO,
      ];
}

// CurrentUserRepository class responsible for managing the current user state
class CurrentUserRepository extends AsyncNotifier<CurrentUserRepositoryState> {
  final log = Logger('CurrentUserRepository');
  String? _currentUserId;

  late UserRepository _userRepository;

  /// This method is called when user switches (or logout)
  /// then obtain userVO from UserRepo and then updates
  /// when user changes (firestore stream)
  @override
  FutureOr<CurrentUserRepositoryState> build() async {
    log.info('build()');
    _currentUserId = await ref.watch(
        AuthRepository.provider.selectAsync((data) => data.authUser?.uid));
    if (_currentUserId is String) {
      final userVO = await ref.watch(UserRepository.provider
          .call(_currentUserId)
          .selectAsync((data) => data.user));
      return CurrentUserRepositoryState(userVO: userVO);
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

  // Provider for the CurrentUserRepository class
  static AsyncNotifierProvider<CurrentUserRepository,
          CurrentUserRepositoryState> provider =
      AsyncNotifierProvider<CurrentUserRepository, CurrentUserRepositoryState>(
          () {
    return CurrentUserRepository();
  });
}

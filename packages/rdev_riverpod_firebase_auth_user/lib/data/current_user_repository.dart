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
  @override
  FutureOr<CurrentUserRepositoryState> build() async {
    log.info('build()');
    _currentUserId = await ref.watch(
        AuthRepository.provider.selectAsync((data) => data.authUser?.uid));
    await ref.watch(UserRepository.provider.call(_currentUserId));
    return _fetch();
  }

  Future<CurrentUserRepositoryState> _fetch() async {
    final userVO = await ref.watch(UserRepository.provider
        .call(_currentUserId)
        .selectAsync((data) => data.user));

    return CurrentUserRepositoryState(user: userVO);
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
        state = await AsyncValue.data(await _fetch());
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

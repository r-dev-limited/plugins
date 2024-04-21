// This file contains the implementation of the CurrentUserRepository class
// which is responsible for managing the current user state.

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

import '../application/user_service.dart';
import '../domain/user_vo.dart';

// Abstract class representing the state of the CurrentUserRepository
@immutable
class UserRepositoryState extends Equatable {
  final UserVO? user;
  const UserRepositoryState({this.user});

  @override
  List<Object?> get props => [
        user,
      ];
}

// CurrentUserRepository class responsible for managing the current user state
class UserRepository extends FamilyAsyncNotifier<UserRepositoryState, String?> {
  final log = Logger('UserRepository');
  late UserService _userService;

  ///
  String? _userId;
  UserVO? _lastUser;
  StreamSubscription? _currentUserSubscription;

  @override
  FutureOr<UserRepositoryState> build(arg) async {
    log.info('build()');
    _userId = arg;
    // Get the UserService instance from the provider
    _userService = ref.read(UserService.provider);

    // Fetch user data and start the user stream
    final result = await _fetchUserData();
    unawaited(_startFirestoreUserStream());

    return result;
  }

  // Fetch user data based on the current user ID
  Future<UserRepositoryState> _fetchUserData() async {
    log.info('_fetchUserData()');

    if (_userId is String) {
      try {
        _lastUser = await _userService.getUser(_userId!);
        return UserRepositoryState(user: _lastUser!);
      } catch (err) {
        log.warning('_fetchUserData() - getUser failed', err);
      }
    }

    return const UserRepositoryState();
  }

  // Private method to start listening to changes in the user stream
  Future<void> _startFirestoreUserStream() async {
    await _currentUserSubscription?.cancel();

    if (_userId is String) {
      _currentUserSubscription =
          _userService.streamUserChanges(_userId!).listen((event) async {
        if (event is UserVO &&
            (event.updatedAt != _lastUser?.updatedAt || _lastUser == null)) {
          _lastUser = event;

          state = AsyncValue.data(UserRepositoryState(user: _lastUser));
        }
      });
    }
  }

  Future<void> updateUser(UserVO vo) async {
    if (vo.uid is String) {
      state = AsyncValue.loading();
      try {
        await this._userService.updateUser(vo);
      } catch (err) {
        /// Restore data
        state = AsyncValue.data(await _fetchUserData());
        throw err;
      }
    }
  }

  Future<void> onboardingFinished(Map<String, dynamic> payload) async {
    if (_userId is String) {
      state = AsyncValue.loading();
      try {
        await _userService.onboardingFinished(_userId!, payload);
      } catch (err) {
        /// Restore data
        state = AsyncValue.data(await _fetchUserData());
        throw err;
      }
    }
  }

  Future<void> deleteAccount() async {
    if (_userId is String) {
      state = AsyncValue.loading();
      try {
        await _userService.deleteAccount(_userId!);
      } catch (err) {
        /// Restore data
        state = AsyncValue.data(await _fetchUserData());
        throw err;
      }
    }
  }

  // Provider for the CurrentUserRepository class
  static AsyncNotifierProviderFamily<UserRepository, UserRepositoryState,
          String?> provider =
      AsyncNotifierProvider.family<UserRepository, UserRepositoryState,
          String?>(() {
    return UserRepository();
  });
}

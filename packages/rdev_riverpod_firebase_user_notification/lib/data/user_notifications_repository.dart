import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../application/user_notifications_service.dart';
import '../domain/user_notification_vo.dart';

@immutable
class UsersRepositoryState {
  final List<UserVO> users;
  final bool isLastPage;

  ///
  const UsersRepositoryState({
    this.users = const [],
    this.isLastPage = false,
  });

  UsersRepositoryState copyWith({
    List<UserVO>? users,
    bool? isLastPage,
  }) {
    return UsersRepositoryState(
      users: users ?? this.users,
      isLastPage: isLastPage ?? this.isLastPage,
    );
  }
}

class UsersRepository extends AsyncNotifier<UsersRepositoryState> {
  late UsersService _usersService;
  DocumentSnapshot<Object?>? _lastDocument;

  /// Build (Init)
  @override
  FutureOr<UsersRepositoryState> build() async {
    _usersService = ref.watch(UsersService.provider);
    _lastDocument = null;
    final tmpState = await _fetchUsers();

    return tmpState;
  }

  /// Get Users
  Future<UsersRepositoryState> _fetchUsers() async {
    try {
      final userVOs = await _usersService.getUsers(startAt: _lastDocument);
      var isLastPage = false;
      if (_lastDocument != null && _lastDocument!.id == userVOs.last.uid) {
        isLastPage = true;
      }
      _lastDocument = userVOs.lastOrNull?.snapshot;
      return UsersRepositoryState(isLastPage: isLastPage, users: userVOs);
    } catch (err) {
      rethrow;
    }
  }

  Future<void> nextPage(bool shouldReload) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      if (shouldReload) {
        _lastDocument = null;
      }
      return _fetchUsers();
    });
  }

  static AsyncNotifierProvider<UsersRepository, UsersRepositoryState> provider =
      AsyncNotifierProvider<UsersRepository, UsersRepositoryState>(() {
    return UsersRepository();
  });
}

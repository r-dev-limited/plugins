import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../application/users_service.dart';
import '../domain/user_vo.dart';

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
      final oldUsers =
          _lastDocument == null ? <UserVO>[] : state.value?.users ?? <UserVO>[];

      var isLastPage = false;
      if (_lastDocument != null &&
          _lastDocument!.id == userVOs.lastOrNull?.uid) {
        isLastPage = true;
      }
      _lastDocument = userVOs.lastOrNull?.snapshot;
      oldUsers.addAll(userVOs);

      /// Remove all duplicate elements based on the uid
      final newHunts = oldUsers.toSet().toList();
      return UsersRepositoryState(isLastPage: isLastPage, users: newHunts);
    } catch (err) {
      rethrow;
    }
  }

  Future<UsersRepositoryState> nextPage(bool shouldReload) async {
    if (shouldReload) {
      _lastDocument = null;
    }
    final tmpState = await _fetchUsers();
    state = AsyncValue.data(tmpState);
    return tmpState;
  }

  static AsyncNotifierProvider<UsersRepository, UsersRepositoryState> provider =
      AsyncNotifierProvider<UsersRepository, UsersRepositoryState>(() {
    return UsersRepository();
  });
}

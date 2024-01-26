import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../application/user_notifications_service.dart';
import '../domain/user_notification_vo.dart';

@immutable
class UserNotificationsRepositoryState {
  final List<UserNotificationVO> notifications;
  final bool isLastPage;

  ///
  const UserNotificationsRepositoryState({
    this.notifications = const [],
    this.isLastPage = false,
  });

  UserNotificationsRepositoryState copyWith({
    List<UserNotificationVO>? notifications,
    bool? isLastPage,
  }) {
    return UserNotificationsRepositoryState(
      notifications: notifications ?? this.notifications,
      isLastPage: isLastPage ?? this.isLastPage,
    );
  }
}

class UserNotificationsRepository
    extends FamilyAsyncNotifier<UserNotificationsRepositoryState, String> {
  late UserNotificationsService _userNotificationsService;
  DocumentSnapshot<Object?>? _lastDocument;
  String? _userId;

  /// Build (Init)
  @override
  FutureOr<UserNotificationsRepositoryState> build(arg) async {
    _userId = arg;
    _userNotificationsService = ref.watch(UserNotificationsService.provider);
    _lastDocument = null;
    final tmpState = await _fetchNotifications();

    return tmpState;
  }

  /// Get Users
  Future<UserNotificationsRepositoryState> _fetchNotifications() async {
    try {
      final notificationVOs = await _userNotificationsService.getNotifications(
        startAt: _lastDocument,
        userId: _userId!,
        orderBy: 'createdAt',
        descending: true,
      );
      var isLastPage = false;
      if (_lastDocument != null &&
          _lastDocument!.id == notificationVOs.last.uid) {
        isLastPage = true;
      }
      _lastDocument = notificationVOs.lastOrNull?.snapshot;
      return UserNotificationsRepositoryState(
          isLastPage: isLastPage, notifications: notificationVOs);
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
      return _fetchNotifications();
    });
  }

  static AsyncNotifierProviderFamily<UserNotificationsRepository,
          UserNotificationsRepositoryState, String> provider =
      AsyncNotifierProvider.family<UserNotificationsRepository,
          UserNotificationsRepositoryState, String>(() {
    return UserNotificationsRepository();
  });
}

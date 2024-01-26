// This file contains the implementation of the UserService class
// which is responsible for interacting with user data.

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/user_notification_vo.dart';
import 'user_notifications_data_service.dart';

// Exception class for UserService
class UserNotificationsServiceException extends RdevException {
  UserNotificationsServiceException({
    String? message,
    RdevCode? code,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          stackTrace: stackTrace,
        );
}

// UserService class for managing user-related operations
class UserNotificationsService {
  final UserNotificationsDataService _userNotificationsDataService;

  UserNotificationsService(this._userNotificationsDataService);

  // Fetches user data based on the provided userId
  Future<List<UserNotificationVO>> getNotifications({
    int limit = 50,
    DocumentSnapshot? startAt,
    required String userId,
  }) async {
    try {
      final models = await _userNotificationsDataService.getNotifications(
        limit: limit,
        startAt: startAt,
        userId: userId,
      );
      final vos = models.map((e) {
        final vo = UserNotificationVO.fromModel(e);
        return vo;
      }).toList();

      return vos;
    } catch (e) {
      if (e is RdevException) {
        throw UserNotificationsServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw UserNotificationsServiceException(message: e.toString());
    }
  }

  // Provider for the UserNotificationsService class
  static Provider<UserNotificationsService> provider =
      Provider<UserNotificationsService>((ref) {
    final userService = UserNotificationsService(
        ref.watch(UserNotificationsDataService.provider));
    return userService;
  });
}

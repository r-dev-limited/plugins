import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';
import 'package:rdev_riverpod_messaging/application/user_messaging_data_service.dart';
import 'package:rdev_riverpod_messaging/domain/user_messaging_model.dart';
import 'package:rdev_riverpod_messaging/domain/user_messaging_vo.dart';

// Exception class for UserMessagingService
class UserMessagingServiceException extends RdevException {
  UserMessagingServiceException({
    String? message,
    RdevCode? code,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          stackTrace: stackTrace,
        );
}

// UserMessagingService class for managing user-related operations
class UserMessagingService {
  final UserMessagingDataService _userMessagingDataService;

  UserMessagingService(this._userMessagingDataService);

  // Fetches user data based on the provided userId
  Future<UserMessagingVO> getMessaging(String userId) async {
    try {
      final userModel = await _userMessagingDataService.getMessaging(userId);
      final vo = UserMessagingVO.fromModel(userModel);
      return vo;
    } catch (e) {
      if (e is RdevException) {
        UserMessagingServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw UserMessagingServiceException();
    }
  }

  // Streams user changes based on the provided userId
  Stream<UserMessagingVO?> streamUserChanges(String userId) {
    return _userMessagingDataService
        .streamUserMessagingChanges(userId)
        .map((event) {
      if (event == null) {
        return null;
      }
      final vo = UserMessagingVO.fromModel(event);
      return vo;
    });
  }

  Future<UserMessagingVO> updateUserFCMToken(
      String userId, FCMToken token) async {
    try {
      final userModel =
          await _userMessagingDataService.updateUserFCMToken(userId, token);
      return UserMessagingVO.fromModel(userModel);
    } catch (e) {
      if (e is RdevException) {
        UserMessagingServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw UserMessagingServiceException();
    }
  }

  Future<void> removeUserFCMToken(String userId, String token) async {
    try {
      await _userMessagingDataService.removeUserFCMToken(userId, token);
    } catch (e) {
      if (e is RdevException) {
        UserMessagingServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw UserMessagingServiceException();
    }
  }

  // Provider for the UserMessagingService class
  static Provider<UserMessagingService> provider =
      Provider<UserMessagingService>((ref) {
    final userMessagingService =
        UserMessagingService(ref.watch(UserMessagingDataService.provider));
    return userMessagingService;
  });
}

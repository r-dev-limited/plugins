// This file contains the implementation of the UserService class
// which is responsible for interacting with user data.

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';

import '../domain/user_vo.dart';
import 'user_data_service.dart';

// Exception class for UserService
class UserServiceException extends RdevException {
  UserServiceException({
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
class UserService {
  final UserDataService _userDataService;

  UserService(this._userDataService);

  // Fetches user data based on the provided userId
  Future<UserVO> getUser(String userId) async {
    try {
      final userModel = await _userDataService.getUser(userId);
      final vo = UserVO.fromUserModel(userModel);
      return vo;
    } catch (e) {
      if (e is RdevException) {
        throw UserServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw UserServiceException();
    }
  }

  // Streams user changes based on the provided userId
  Stream<UserVO?> streamUserChanges(String userId) {
    return _userDataService.streamUserChanges(userId).map((event) {
      if (event == null) {
        return null;
      }
      final vo = UserVO.fromUserModel(event);
      return vo;
    });
  }

  // Updates the user data with the provided UserVO
  Future<UserVO> updateUser(UserVO data) async {
    try {
      // Parse UserVO to UserModel
      data = data.copyWith(updatedAt: DateTime.now());
      var userModel = data.toUserModel();
      userModel = await _userDataService.updateUser(data: userModel);
      return UserVO.fromUserModel(userModel);
    } catch (e) {
      if (e is RdevException) {
        throw UserServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw UserServiceException();
    }
  }

  Future<void> onboardingFinished(
      String userId, Map<String, dynamic> payload) async {
    try {
      await _userDataService.onboardingFinished(userId, payload);
    } catch (e) {
      if (e is RdevException) {
        throw UserServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw UserServiceException();
    }
  }

  // Provider for the UserService class
  static Provider<UserService> provider = Provider<UserService>((ref) {
    final userService = UserService(ref.watch(UserDataService.provider));
    return userService;
  });
}

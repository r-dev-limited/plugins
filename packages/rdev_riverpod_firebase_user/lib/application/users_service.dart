// This file contains the implementation of the UserService class
// which is responsible for interacting with user data.

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/user_vo.dart';
import 'users_data_service.dart';

// Exception class for UserService
class UsersServiceException extends RdevException {
  UsersServiceException({
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
class UsersService {
  final UsersDataService _usersDataService;

  UsersService(this._usersDataService);

  // Fetches user data based on the provided userId
  Future<List<UserVO>> getUsers({
    int limit = 50,
    DocumentSnapshot? startAt,
  }) async {
    try {
      final userModels = await _usersDataService.getUsers(
        limit: limit,
        startAt: startAt,
      );
      final vos = userModels.map((e) {
        final vo = UserVO.fromUserModel(e);
        return vo;
      }).toList();

      return vos;
    } catch (e) {
      if (e is RdevException) {
        throw UsersServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw UsersServiceException(message: e.toString());
    }
  }

  // Provider for the UsersService class
  static Provider<UsersService> provider = Provider<UsersService>((ref) {
    final userService = UsersService(ref.watch(UsersDataService.provider));
    return userService;
  });
}

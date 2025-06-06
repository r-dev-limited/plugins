// This file contains the implementation of the UserDataService class
// which is responsible for interacting with user data in Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';
import 'package:rdev_errors_logging/talker_provider.dart';
import 'package:rdev_riverpod_firebase/firebase_providers.dart';
import 'package:rdev_riverpod_firebase/firestore_helpers.dart';
import 'package:talker/talker.dart';

import '../domain/user_model.dart';

class UserDataServiceLog extends TalkerLog {
  UserDataServiceLog(
    String message, [
    dynamic args,
    StackTrace? stackTrace,
  ]) : super(
          message,
          exception: args,
          stackTrace: stackTrace,
        );

  /// Your custom log title
  @override
  String get title => 'UserDataService';

  /// Your custom log color
  @override
  AnsiPen get pen => AnsiPen()..cyan();
}

// Exception class for UserDataService
class UserDataServiceException extends RdevException {
  UserDataServiceException({
    String? message,
    RdevCode? code,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          stackTrace: stackTrace,
        );

  UserDataServiceException.fromRdevException(
    RdevException rdevException,
  ) : super(
          message: rdevException.message,
          code: rdevException.code,
          stackTrace: rdevException.stackTrace,
        );
}

// UserDataService class for managing user data in Firestore
class UserDataService {
  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;
  final Talker _log;

  UserDataService(
    this._db,
    this._functions,
    this._log,
  );

  // Fetches user data based on the provided userId
  Future<UserModel> getUser(String userId) async {
    try {
      final snapshot = await _db.collection('Users').doc(userId).get();

      if (snapshot.data() != null) {
        final model = await UserModel.fromDocumentSnapshot(snapshot);

        return model;
      }

      throw UserDataServiceException(
          code: RdevCode.NotFound,
          message: 'User with id:${userId} was not found');
    } catch (err) {
      if (err is UserDataServiceException) {
        rethrow;
      }

      if (err is FirebaseException) {
        throw UserDataServiceException.fromRdevException(err.toRdevException());
      }

      throw UserDataServiceException(message: err.toString());
    }
  }

  // Streams user changes based on the provided userId
  Stream<UserModel?> streamUserChanges(String userId) {
    final userRef = _db.collection('Users').doc(userId);

    return userRef.snapshots().asyncMap((event) async {
      if (event.data() == null) {
        return null;
      }

      try {
        final user = await UserModel.fromDocumentSnapshot(event);

        return user;
      } catch (err) {
        _log.logCustom(UserDataServiceLog(
            'streamUserChanges failed', err, StackTrace.current));
        return null;
      }
    });
  }

  // Updates the user data with the provided UserModel
  Future<UserModel> updateUser({
    required UserModel data,
  }) async {
    if (data.uid == null) {
      throw UserDataServiceException(
          code: RdevCode.InvalidArgument, message: 'User uid is required');
    }

    final userRef = _db.collection('Users').doc(data.uid);

    try {
      await _db.runTransaction((tx) async {
        final userSnapshot = await tx.get(userRef);

        if (userSnapshot.exists) {
          final userJson = await data.toJson();
          tx.set(userRef, userJson, SetOptions(merge: true));
        } else {
          throw UserDataServiceException(
              code: RdevCode.NotFound,
              message: 'User with id:${data.uid} was not found');
        }
      });

      final snapshot = await userRef.get();
      final updatedModel = await UserModel.fromDocumentSnapshot(snapshot);
      return updatedModel;
    } catch (err) {
      if (err is UserDataServiceException) {
        rethrow;
      }
      throw UserDataServiceException(message: err.toString());
    }
  }

  /// Invites a new user into the workspace and returns [Map<String,dynamic>] if successful
  /// Throws [UsersServiceException] if failed
  Future<Map<String, dynamic>> updateUserClaims(
      String userId, Map<String, dynamic> claims) async {
    try {
      final callable = _functions.httpsCallable('callables-updateUserClaims');
      final result = await callable.call({'uid': userId, 'claims': claims});
      final updatedClaims = result.data as Map<String, dynamic>;
      return updatedClaims;
    } on FirebaseFunctionsException catch (e) {
      // Handle FirebaseFunctionsException
      throw UserDataServiceException.fromRdevException(e.toRdevException());
    } on Exception catch (e) {
      // Handle other exceptions
      throw UserDataServiceException(message: e.toString());
    }
  }

  /// get user's claims data
  /// Throws [UsersServiceException] if failed
  /// Returns [Map<String, dynamic>] if successful
  Future<Map<String, dynamic>> getUserClaims(String userId) async {
    try {
      final callable = _functions.httpsCallable('callables-getUserClaims');
      final result = await callable.call({'uid': userId});
      final claims = result.data as Map<String, dynamic>;
      return claims;
    } on FirebaseFunctionsException catch (e) {
      // Handling FirebaseFunctionsException
      throw UserDataServiceException.fromRdevException(e.toRdevException());
    } on Exception catch (e) {
      // Handling other exceptions
      throw UserDataServiceException(message: e.toString());
    }
  }

  Future<void> regenerateAuthClaims(String userId) {
    try {
      final callable =
          _functions.httpsCallable('callables-regenerateAuthClaims');
      return callable.call({
        'uid': userId,
      });
    } on FirebaseFunctionsException catch (e) {
      // Handling FirebaseFunctionsException
      throw UserDataServiceException.fromRdevException(e.toRdevException());
    } catch (e) {
      throw UserDataServiceException(message: e.toString());
    }
  }

  Future<void> onboardingFinished(
      String userId, Map<String, dynamic> payload) async {
    try {
      final callable = _functions.httpsCallable('callables-onboardingFinished');
      payload['userId'] = userId;
      await callable.call(payload);
    } on FirebaseFunctionsException catch (e) {
      // Handling FirebaseFunctionsException
      throw UserDataServiceException.fromRdevException(e.toRdevException());
    } catch (e) {
      throw UserDataServiceException(message: e.toString());
    }
  }

  Future<void> deleteAccount(
    String userId,
  ) async {
    try {
      final callable = _functions.httpsCallable('callables-deleteAccount');
      await callable.call({"userId": userId});
    } on FirebaseFunctionsException catch (e) {
      // Handling FirebaseFunctionsException
      throw UserDataServiceException.fromRdevException(e.toRdevException());
    } catch (e) {
      throw UserDataServiceException(message: e.toString());
    }
  }

  // Provider for the UserDataService class
  static Provider<UserDataService> provider = Provider<UserDataService>((ref) {
    final userService = UserDataService(
      ref.watch(fbFirestoreProvider),
      ref.watch(fbFunctionsProvider),
      ref.watch(appTalkerProvider),
    );
    return userService;
  });
}

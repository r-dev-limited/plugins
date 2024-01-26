// This file contains the implementation of the UserDataService class
// which is responsible for interacting with user data in Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';
import 'package:rdev_riverpod_firebase/firebase_providers.dart';

import '../domain/user_model.dart';

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
}

// UserDataService class for managing user data in Firestore
class UserDataService {
  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;
  final _log = Logger('UserDataService');

  UserDataService(
    this._db,
    this._functions,
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
        throw UserDataServiceException(message: err.toString());
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
        _log.severe('streamUserChanges failed', err);
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

  Future<UserModel> updateUserFCMToken(String userId, FCMToken token) async {
    final usersRef = _db.collection('Users');

    final userRef = usersRef.doc(userId);
    final userTokensRef = userRef.collection('Tokens');
    try {
      await _db.runTransaction((tx) async {
        final userSnapshot = await tx.get(userRef);

        if (userSnapshot.exists) {
          var model = await UserModel.fromDocumentSnapshot(userSnapshot);
          if (token.id == null) {
            token = token.copyWith(id: userTokensRef.doc().id); // Virtual ID
          }
          final fcmTokens = model.fcmTokens ?? <String, FCMToken>{};

          /// Check if token already exists in fcmTokens.token
          final sameToken =
              fcmTokens.values.where((element) => element.token == token.token);
          if (sameToken.length > 0) {
            return model;
          }

          fcmTokens[token.id!] = token;
          model = model.copyWith(
            fcmTokens: fcmTokens,
            updatedAt: DateTime.now().millisecondsSinceEpoch.toDouble(),
          );
          tx.set(userRef, model.toJson());
        } else {
          throw UserDataServiceException(
              code: RdevCode.NotFound,
              message: 'User with id:${userId} was not found');
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

  Future<UserModel> removeUserFCMToken(String userId, String token) async {
    final usersRef = _db.collection('Users');

    final userRef = usersRef.doc(userId);
    try {
      await _db.runTransaction((tx) async {
        final userSnapshot = await tx.get(userRef);

        if (userSnapshot.exists) {
          var model = await UserModel.fromDocumentSnapshot(userSnapshot);

          final fcmTokens = <String, FCMToken>{};

          /// Check if token already exists in fcmTokens.token
          final removedToken =
              fcmTokens.values.where((element) => element.token != token);

          removedToken.forEach((element) {
            fcmTokens[element.id!] = element;
          });

          print(removedToken);

          model = model.copyWith(
            fcmTokens: fcmTokens,
            updatedAt: DateTime.now().millisecondsSinceEpoch.toDouble(),
          );
          tx.set(userRef, model.toJson());
        } else {
          throw UserDataServiceException(
              code: RdevCode.NotFound,
              message: 'User with id:${userId} was not found');
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
      throw UserDataServiceException(
        message: e.message ?? '',
        stackTrace: e.stackTrace,
        code: RdevCode.Internal,
      );
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
      throw UserDataServiceException(
        message: e.message ?? '',
        stackTrace: e.stackTrace,
        code: RdevCode.Internal,
      );
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
      throw UserDataServiceException(
        message: e.message ?? '',
        stackTrace: e.stackTrace,
        code: RdevCode.Internal,
      );
    } catch (e) {
      throw UserDataServiceException(message: e.toString());
    }
  }

  // Provider for the UserDataService class
  static Provider<UserDataService> provider = Provider<UserDataService>((ref) {
    final userService = UserDataService(
      ref.watch(fbFirestoreProvider),
      ref.watch(fbFunctionsProvider),
    );
    return userService;
  });
}

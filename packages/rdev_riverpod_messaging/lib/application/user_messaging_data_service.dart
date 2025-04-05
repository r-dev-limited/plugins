import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';
import 'package:rdev_errors_logging/talker_provider.dart';
import 'package:rdev_riverpod_firebase/firebase_providers.dart';
import 'package:rdev_riverpod_messaging/domain/user_messaging_model.dart';
import 'package:talker/talker.dart';

class UserMessagingDataServiceLog extends TalkerLog {
  UserMessagingDataServiceLog(
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
  String get title => 'UserMessagingDataService';

  /// Your custom log color
  @override
  AnsiPen get pen => AnsiPen()..cyan();
}

final fbMessagingTokenRefreshProvider = StreamProvider<String>((ref) {
  final messagingInstance = ref.watch(fbMessagingProvider);

  return messagingInstance.onTokenRefresh;
});

// Exception class for UserMessagingDataService
class UserMessagingDataServiceException extends RdevException {
  UserMessagingDataServiceException({
    String? message,
    RdevCode? code,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          stackTrace: stackTrace,
        );
}

// UserMessagingDataService class for managing user data in Firestore
class UserMessagingDataService {
  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;
  final Talker _log;

  UserMessagingDataService(
    this._db,
    this._functions,
    this._log,
  );

  // Fetches user data based on the provided userId
  Future<UserMessagingModel> getMessaging(String userId) async {
    try {
      final snapshot = await _db
          .collection('Users')
          .doc(userId)
          .collection('Private')
          .doc('messaging')
          .get();

      if (snapshot.data() != null) {
        final model = await UserMessagingModel.fromDocumentSnapshot(snapshot);

        return model;
      }

      throw UserMessagingDataServiceException(
          code: RdevCode.NotFound,
          message: 'UserMessaging with for user:${userId} was not found');
    } catch (err) {
      if (err is UserMessagingDataServiceException) {
        rethrow;
      }

      if (err is FirebaseException) {
        throw UserMessagingDataServiceException(message: err.toString());
      }

      throw UserMessagingDataServiceException(message: err.toString());
    }
  }

  // Streams user changes based on the provided userId
  Stream<UserMessagingModel?> streamUserMessagingChanges(String userId) {
    final userRef = _db
        .collection('Users')
        .doc(userId)
        .collection('Private')
        .doc('messaging');

    return userRef.snapshots().asyncMap((event) async {
      if (event.data() == null) {
        return null;
      }

      try {
        final user = await UserMessagingModel.fromDocumentSnapshot(event);

        return user;
      } catch (err) {
        _log.logCustom(UserMessagingDataServiceLog(
            'streamUserMessagingChanges failed', err, StackTrace.current));
        return null;
      }
    });
  }

  Future<UserMessagingModel> updateUserFCMToken(
      String userId, FCMToken token) async {
    final usersRef = _db.collection('Users');

    final userRef = usersRef.doc(userId);
    final userTokensRef = userRef.collection('Tokens');
    try {
      await _db.runTransaction((tx) async {
        final userSnapshot = await tx.get(userRef);

        if (userSnapshot.exists) {
          var model =
              await UserMessagingModel.fromDocumentSnapshot(userSnapshot);
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
          throw UserMessagingDataServiceException(
              code: RdevCode.NotFound,
              message: 'User with id:${userId} was not found');
        }
      });

      final snapshot = await userRef.get();
      final updatedModel =
          await UserMessagingModel.fromDocumentSnapshot(snapshot);
      return updatedModel;
    } catch (err) {
      if (err is UserMessagingDataServiceException) {
        rethrow;
      }
      throw UserMessagingDataServiceException(message: err.toString());
    }
  }

  Future<void> removeUserFCMToken(String userId, String fcmToken) async {
    try {
      await _functions
          .httpsCallable('callables-removeFCMToken')
          .call({'userId': userId, 'fcmToken': fcmToken});
    } catch (err) {
      if (err is UserMessagingDataServiceException) {
        rethrow;
      }
      throw UserMessagingDataServiceException(message: err.toString());
    }
  }

  // Provider for the UserMessagingDataService class
  static Provider<UserMessagingDataService> provider =
      Provider<UserMessagingDataService>((ref) {
    final userService = UserMessagingDataService(
      ref.watch(fbFirestoreProvider),
      ref.watch(fbFunctionsProvider),
      ref.watch(appTalkerProvider),
    );
    return userService;
  });
}

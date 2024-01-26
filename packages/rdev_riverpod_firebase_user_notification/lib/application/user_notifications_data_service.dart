import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:cloud_functions/cloud_functions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';
import 'package:rdev_riverpod_firebase/firebase_providers.dart';
import 'package:rdev_riverpod_firebase_user_notification/domain/user_notification_model.dart';

class UserNotificationsDataServiceException extends RdevException {
  UserNotificationsDataServiceException({
    String? message,
    RdevCode? code,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          stackTrace: stackTrace,
        );
}

class UserNotificationsDataService {
  final FirebaseFirestore _db;
  // final FirebaseFunctions _functions;

  UserNotificationsDataService(
    this._db,
    //  this._functions,
  );

  Future<List<UserNotificationModel>> getNotifications({
    int limit = 50,
    DocumentSnapshot? startAt,
    required String userId,
  }) async {
    try {
      final usersRef = _db.collection('Users');
      final userDocRef = usersRef.doc(userId);
      final userNotificationsRef = userDocRef.collection('UserNotifications');
      var query = userNotificationsRef.limit(limit);
      if (startAt is DocumentSnapshot) {
        query = query.startAtDocument(startAt);
      }
      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        return [];
      }
      final toParse = snapshot.docs.map((e) async {
        final user = await UserNotificationModel.fromDocumentSnapshot(e);

        return user;
      }).toList();

      final parsed = await Future.wait(toParse);
      return parsed;
    } catch (err) {
      if (err is FirebaseException) {
        throw UserNotificationsDataServiceException(
          message: err.message,
          code: RdevCode.Internal,
          stackTrace: err.stackTrace,
        );
      }
      throw UserNotificationsDataServiceException(message: err.toString());
    }
  }

  static Provider<UserNotificationsDataService> provider =
      Provider<UserNotificationsDataService>((ref) {
    final workspaceService = UserNotificationsDataService(
      ref.watch(fbFirestoreProvider),
      //   ref.watch(fbFunctionsProvider),
    );
    return workspaceService;
  });
}

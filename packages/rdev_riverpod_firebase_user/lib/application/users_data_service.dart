import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';
import 'package:rdev_riverpod_firebase/firebase_providers.dart';
import 'package:rdev_riverpod_firebase_user/domain/user_model.dart';

class UsersDataServiceException extends RdevException {
  UsersDataServiceException({
    String? message,
    RdevCode? code,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          stackTrace: stackTrace,
        );
}

class UsersDataService {
  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  UsersDataService(
    this._db,
    this._functions,
  );

  Future<List<UserModel>> getUsers({
    int limit = 50,
    DocumentSnapshot? startAt,
  }) async {
    try {
      final usersRef = _db.collection('Users');
      var query = usersRef.limit(limit);
      if (startAt is DocumentSnapshot) {
        query = query.startAtDocument(startAt);
      }
      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        return [];
      }
      final toParse = snapshot.docs.map((e) async {
        final user = await UserModel.fromDocumentSnapshot(e);

        return user;
      }).toList();

      final parsed = await Future.wait(toParse);
      return parsed;
    } catch (err) {
      if (err is FirebaseException) {
        throw UsersDataServiceException(
          message: err.message,
          code: RdevCode.Internal,
          stackTrace: err.stackTrace,
        );
      }
      throw UsersDataServiceException(message: err.toString());
    }
  }

  /// Creates a new admin user and
  /// assign a typesense key to that user's claims
  // Future<void> createAdminUser(CreateAdminVO admin) {
  //   try {
  //     final callable = _functions.httpsCallable('callables-createAdminUser');
  //     return callable.call(admin.toJson());
  //   } on FirebaseFunctionsException catch (e) {
  //     // Handling FirebaseFunctionsException
  //     throw UsersServiceException(
  //       model: CarvError()
  //         ..message = e.message ?? ''
  //         ..details = e.stackTrace?.toString() ?? ''
  //         ..code = CarvError_CarvCode.Internal,
  //     );
  //   } catch (e) {
  //     throw UsersServiceException(
  //       model: CarvError()
  //         ..message = e.toString()
  //         ..code = CarvError_CarvCode.Internal,
  //     );
  //   }
  // }

  static Provider<UsersDataService> provider =
      Provider<UsersDataService>((ref) {
    final workspaceService = UsersDataService(
      ref.watch(fbFirestoreProvider),
      ref.watch(fbFunctionsProvider),
    );
    return workspaceService;
  });
}

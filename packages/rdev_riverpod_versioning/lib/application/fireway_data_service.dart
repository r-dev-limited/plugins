/// This file contains the implementation of the FirewayDataService class,
/// which is responsible for fetching the latest backend version from Firestore.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rdev_riverpod_firebase/firebase_providers.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';
import '../domain/fireway_model.dart';

/// Custom exception class for FirewayDataService.
/// It extends RdevException.
class FirewayDataServiceException extends RdevException {
  FirewayDataServiceException({
    String? message,
    RdevCode? code,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          stackTrace: stackTrace,
        );
}

/// The FirewayDataService class handles data operations related to Fireway.
class FirewayDataService {
  final FirebaseFirestore _db;

  FirewayDataService(this._db);

  /// Retrieves the latest backend version from Firestore.
  /// Returns a Future of FirewayModel.
  Future<FirewayModel> getLatestBackendVersion() async {
    try {
      final query = _db
          .collection('fireway')
          .orderBy('installed_on', descending: true)
          .limit(1);
      final snapshot = await query.get();
      final list = snapshot.docs.map<Future<FirewayModel>>((document) async {
        final model = await FirewayModel.fromJson(document.data());
        model.uid = document.id;
        return model;
      }).toList();

      if (list.isNotEmpty) {
        return list.first;
      }

      throw FirewayDataServiceException(
          code: RdevCode.NotFound, message: 'Fireway Version data not found');
    } catch (err) {
      if (err is FirewayDataServiceException) {
        rethrow;
      }
      throw FirewayDataServiceException(
        message: err.toString(),
      );
    }
  }

  /// Provider for the FirewayDataService class.
  /// It is used to provide instances of FirewayDataService using Riverpod.
  static Provider<FirewayDataService> provider = Provider<FirewayDataService>(
    (ref) => FirewayDataService(
      ref.watch(fbFirestoreProvider),
    ),
  );
}

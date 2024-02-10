import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';
import 'package:rdev_riverpod_firebase/firebase_providers.dart';

import '../domain/in_app_product_model.dart';

class InAppProductDataServicexception extends RdevException {
  InAppProductDataServicexception({
    String? message,
    RdevCode? code,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          stackTrace: stackTrace,
        );
}

class InAppProductDataService {
  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  final _log = Logger('InAppProductDataService');

  InAppProductDataService(
    this._db,
    this._functions,
  );

  Future<List<InAppProductModel>> getProducts({
    int limit = 50,
    DocumentSnapshot? startAt,
    String? ownerPath,
  }) async {
    try {
      final productsRef = _db.collection('InAppProducts');
      var query = productsRef.limit(limit);
      if (startAt is DocumentSnapshot) {
        query = query.startAtDocument(startAt);
      }

      if (ownerPath is String) {
        query = query.where('ownerPath', isEqualTo: ownerPath);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        return [];
      }
      final toParse = snapshot.docs.map((e) async {
        final product = await InAppProductModel.fromDocumentSnapshot(e);

        return product;
      }).toList();

      final parsed = await Future.wait(toParse);
      return parsed;
    } catch (err) {
      if (err is FirebaseException) {
        throw InAppProductDataServicexception(
          message: err.message,
          code: RdevCode.Internal,
          stackTrace: err.stackTrace,
        );
      }
      throw InAppProductDataServicexception(message: err.toString());
    }
  }

  Future<InAppProductModel> getProduct(String productId) async {
    try {
      final snapshot =
          await _db.collection('InAppProducts').doc(productId).get();
      if (snapshot.exists) {
        final data = snapshot.data()!;
        final model = await InAppProductModel.fromJson(data);
        model.uid = snapshot.id;
        return model;
      }
      _log.severe(
          'getProduct', 'InAppProduct with id:$productId was not found');

      throw InAppProductDataServicexception(
        message: 'InAppProduct $productId was not found',
        code: RdevCode.NotFound,
      );
    } catch (err) {
      _log.severe('getProduct', err);
      if (err is InAppProductDataServicexception) {
        rethrow;
      }
      throw InAppProductDataServicexception(
        message: err.toString(),
      );
    }
  }

  // Provider for the InAppProductDataService class
  static Provider<InAppProductDataService> provider =
      Provider<InAppProductDataService>((ref) {
    final stored_fileService = InAppProductDataService(
      ref.watch(fbFirestoreProvider),
      ref.watch(fbFunctionsProvider),
    );
    return stored_fileService;
  });
}

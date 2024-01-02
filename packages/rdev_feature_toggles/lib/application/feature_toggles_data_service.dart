import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:rdev_feature_toggles/domain/feature_toggle_model.dart';
import 'package:rdev_riverpod_firebase/firebase_providers.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';

class FeatureTogglesDataServiceException extends RdevException {
  FeatureTogglesDataServiceException({
    String? message,
    RdevCode? code,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          stackTrace: stackTrace,
        );
}

class FeatureTogglesDataService {
  final log = Logger('FeatureTogglesDataService');
  final FirebaseFirestore _firestore;

  FeatureTogglesDataService(this._firestore);

  Future<List<FeatureToggleModel>> getFeatureToggles({
    Map<String, String>? parent,
  }) async {
    if (parent is Map<String, String> && parent.isNotEmpty) {
      final keys = parent.keys.toList();

      if (keys.length > 1) {
        throw FeatureTogglesDataServiceException(
            code: RdevCode.InvalidArgument,
            message: 'Parent can only have one key');
      }

      final key = keys.first;
      final value = parent[key];

      final collectionPath = key.split(RegExp(r'(?=[A-Z])'));

      final parentRef =
          _firestore.collection(collectionPath.join('/')).doc(value);

      final parentFeatureToggleRef = parentRef.collection('FeatureToggles');
      try {
        final parentFeatureToggleDoc = await parentFeatureToggleRef.get();
        final models = parentFeatureToggleDoc.docs.map((e) {
          final featureToggleModel = FeatureToggleModel.fromJson(e.data());

          featureToggleModel.uid = e.id;
          return featureToggleModel;
        }).toList();

        return models;
      } catch (err) {
        log.warning('Error getting workspace feature toggle: $err');
      }
    }
    // Use root level
    final featureToggleRef = _firestore.collection('FeatureToggles');
    try {
      final featureToggleDoc = await featureToggleRef.get();
      final models = featureToggleDoc.docs.map((e) {
        final featureToggleModel = FeatureToggleModel.fromJson(e.data());

        featureToggleModel.uid = e.id;
        return featureToggleModel;
      }).toList();

      return models;
    } catch (err) {
      throw FeatureTogglesDataServiceException(message: err.toString());
    }
  }

  Future<FeatureToggleModel> getFeatureToggle({
    required String version,
    Map<String, String>? parent,
  }) async {
    if (parent is Map<String, String> && parent.isNotEmpty) {
      final keys = parent.keys.toList();

      if (keys.length > 1) {
        throw FeatureTogglesDataServiceException(
            code: RdevCode.InvalidArgument,
            message: 'Parent can only have one key');
      }

      final key = keys.first;
      final value = parent[key];

      final collectionPath = key.split(RegExp(r'(?=[A-Z])'));

      final parentRef =
          _firestore.collection(collectionPath.join('/')).doc(value);

      final parentFeatureToggleRef = parentRef.collection('FeatureToggles');
      try {
        final parentFeatureToggleDoc =
            await parentFeatureToggleRef.doc(version).get();

        if (parentFeatureToggleDoc.exists == false) {
          throw FeatureTogglesDataServiceException(
              code: RdevCode.NotFound,
              message: 'Feature toggle with version: $version was not found');
        }
        final featureToggleModel =
            FeatureToggleModel.fromJson(parentFeatureToggleDoc.data()!);

        featureToggleModel.uid = parentFeatureToggleDoc.id;
        return featureToggleModel;
      } catch (err) {
        log.warning('Error getting workspace feature toggle: $err');
      }
    }
    // Use root level
    final featureToggleRef = _firestore.collection('FeatureToggles');
    try {
      final featureToggleDoc = await featureToggleRef.doc(version).get();
      if (featureToggleDoc.exists == false) {
        throw FeatureTogglesDataServiceException(
            code: RdevCode.NotFound,
            message: 'Feature toggle with version: $version was not found');
      }
      final featureToggleModel =
          FeatureToggleModel.fromJson(featureToggleDoc.data()!);

      featureToggleModel.uid = featureToggleDoc.id;
      return featureToggleModel;
    } catch (err) {
      if (err is FeatureTogglesDataServiceException) {
        rethrow;
      }
      throw FeatureTogglesDataServiceException(message: err.toString());
    }
  }

  Stream<List<FeatureToggleModel>> streamUserFeatureToggles({
    Map<String, String>? parent,
  }) {
    if (parent is Map<String, String> && parent.isNotEmpty) {
      final keys = parent.keys.toList();

      if (keys.length > 1) {
        throw FeatureTogglesDataServiceException(
            code: RdevCode.InvalidArgument,
            message: 'Parent can only have one key');
      }

      final key = keys.first;
      final value = parent[key];

      final collectionPath = key.split(RegExp(r'(?=[A-Z])'));

      final parentRef =
          _firestore.collection(collectionPath.join('/')).doc(value);

      final parentFeatureToggleRef = parentRef.collection('FeatureToggles');
      try {
        final parentFeatureToggleStream = parentFeatureToggleRef.snapshots();
        final models = parentFeatureToggleStream.map((e) {
          final models = e.docs.map((e) {
            final featureToggleModel = FeatureToggleModel.fromJson(e.data());

            featureToggleModel.uid = e.id;
            return featureToggleModel;
          }).toList();
          return models;
        });

        return models;
      } catch (err) {
        log.warning('Error getting workspace feature toggle: $err');
      }
    }
    // Use root level
    final featureToggleRef = _firestore.collection('FeatureToggles');
    try {
      final parentFeatureToggleStream = featureToggleRef.snapshots();
      final models = parentFeatureToggleStream.map((e) {
        final models = e.docs.map((e) {
          final featureToggleModel = FeatureToggleModel.fromJson(e.data());

          featureToggleModel.uid = e.id;
          return featureToggleModel;
        }).toList();
        return models;
      });

      return models;
    } catch (err) {
      throw FeatureTogglesDataServiceException(message: err.toString());
    }
  }

  Future<void> updateFeatureToggle(FeatureToggleModel model) async {
    try {
      if (model.uid is String) {
        var ref = this._firestore.collection('FeatureToggles');
        if (model.parent is Map<String, String>) {
          final keys = model.parent!.keys.toList();

          if (keys.length > 1) {
            throw FeatureTogglesDataServiceException(
                code: RdevCode.InvalidArgument,
                message: 'Parent can only have one key');
          }

          final key = keys.first;
          final value = model.parent![key];

          final collectionPath = key.split(RegExp(r'(?=[A-Z])'));

          final parentRef =
              _firestore.collection(collectionPath.join('/')).doc(value);

          ref = parentRef.collection('FeatureToggles');
        }

        var doc = ref.doc(model.uid);
        await doc.set(model.toJson(), SetOptions(merge: true));
      } else {
        throw FeatureTogglesDataServiceException(
            code: RdevCode.InvalidArgument,
            message: 'Feature toggle uid is required');
      }
    } catch (err) {
      throw FeatureTogglesDataServiceException(message: err.toString());
    }
  }

  Future<void> createFeatureToggle(FeatureToggleModel model) async {
    try {
      var ref = this._firestore.collection('FeatureToggles');
      if (model.parent is Map<String, String>) {
        final keys = model.parent!.keys.toList();

        if (keys.length > 1) {
          throw FeatureTogglesDataServiceException(
              code: RdevCode.InvalidArgument,
              message: 'Parent can only have one key');
        }

        final key = keys.first;
        final value = model.parent![key];

        final collectionPath = key.split(RegExp(r'(?=[A-Z])'));

        final parentRef =
            _firestore.collection(collectionPath.join('/')).doc(value);

        ref = parentRef.collection('FeatureToggles');
      }

      var doc = model.uid is String ? ref.doc(model.uid) : ref.doc();

      await doc.set(model.toJson());
    } catch (err) {
      throw FeatureTogglesDataServiceException(message: err.toString());
    }
  }

  Future<void> deleteFeatureToggle(
    String path,
    String toggleId,
  ) async {
    try {
      final userRef = _firestore.doc(path);

      final userFeatureToggleRef = userRef.collection('FeatureToggles');

      return userFeatureToggleRef.doc(toggleId).delete();
    } catch (err) {
      log.warning('Error deleting feature toggle: $err and path: $path');
    }
  }

  static Provider<FeatureTogglesDataService> provider =
      Provider<FeatureTogglesDataService>(
    (ref) => FeatureTogglesDataService(
      ref.watch(fbFirestoreProvider),
    ),
  );
}

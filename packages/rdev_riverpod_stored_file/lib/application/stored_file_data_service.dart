import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:rdev_errors_logging/rdev_exception.dart';
import 'package:rdev_errors_logging/talker_provider.dart';
import 'package:rdev_riverpod_firebase/firebase_providers.dart';
import 'package:talker/talker.dart';

import '../domain/stored_file_model.dart';

class StoredFileDataServiceLog extends TalkerLog {
  StoredFileDataServiceLog(
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
  String get title => 'StoredFileDataService';

  /// Your custom log color
  @override
  AnsiPen get pen => AnsiPen()..cyan();
}

class StoredFileDataServiceException extends RdevException {
  StoredFileDataServiceException({
    String? message,
    RdevCode? code,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          stackTrace: stackTrace,
        );
}

class StoredFileDataService {
  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;
  final FirebaseStorage _storage;

  final Talker _log;

  StoredFileDataService(
    this._db,
    this._functions,
    this._storage,
    this._log,
  );

  Future<Uint8List> getFileData(String gcsPath) async {
    try {
      final fileRef = _storage.refFromURL(gcsPath);
      final res = await fileRef.getData();

      if (res != null) {
        return res;
      }
      _log.logTyped(StoredFileDataServiceLog(
          'getFileData', 'File $gcsPath was not found'));

      throw StoredFileDataServiceException(
        message: 'File $gcsPath was not found',
        code: RdevCode.NotFound,
      );
    } catch (err) {
      _log.logTyped(
          StoredFileDataServiceLog('getFileData', err, StackTrace.current));
      if (err is StoredFileDataServiceException) {
        rethrow;
      }
      throw StoredFileDataServiceException(
        message: err.toString(),
      );
    }
  }

  Future<List<StoredFileModel>> getStoredFiles({
    int limit = 50,
    DocumentSnapshot? startAt,
    String? ownerPath,
  }) async {
    try {
      final productsRef = _db.collection('StoredFiles');
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
        final product = await StoredFileModel.fromDocumentSnapshot(e);

        return product;
      }).toList();

      final parsed = await Future.wait(toParse);
      return parsed;
    } catch (err) {
      if (err is FirebaseException) {
        throw StoredFileDataServiceException(
          message: err.message,
          code: RdevCode.Internal,
          stackTrace: err.stackTrace,
        );
      }
      throw StoredFileDataServiceException(message: err.toString());
    }
  }

  Future<StoredFileModel> getStoredFile(String storedFileId) async {
    try {
      final snapshot =
          await _db.collection('StoredFiles').doc(storedFileId).get();
      if (snapshot.exists) {
        final data = snapshot.data()!;
        final model = await StoredFileModel.fromJson(data);
        model.uid = snapshot.id;
        return model;
      }
      _log.logTyped(StoredFileDataServiceLog(
          'getStoredFile', 'StoredFile with id:$storedFileId was not found'));

      throw StoredFileDataServiceException(
        message: 'StoredFile $storedFileId was not found',
        code: RdevCode.NotFound,
      );
    } catch (err) {
      _log.logTyped(
          StoredFileDataServiceLog('getStoredFile', err, StackTrace.current));
      if (err is StoredFileDataServiceException) {
        rethrow;
      }
      throw StoredFileDataServiceException(
        message: err.toString(),
      );
    }
  }

  UploadTask uploadFile(
    String gcsPath,
    Uint8List fileData,
    String contentType,
  ) {
    final fileRef = _storage.refFromURL(gcsPath);
    final res = fileRef.putData(
        fileData,
        SettableMetadata(
          contentType: contentType,
        ));
    //final result = await res;
    return res;
  }

  Future<StoredFileModel> createStoredFile({
    String? storedFileId,
    required String ownerPath,
    Map<String, StoredFileSubscriber>? stateSubscribers,
    String? fileExtension,
    String? contentType,
  }) async {
    final storedFilesRef = _db.collection('StoredFiles');
    final storedFileRef = storedFilesRef.doc(storedFileId);

    final model = StoredFileModel(
        createdAt: DateTime.now().millisecondsSinceEpoch.toDouble(),
        uid: storedFileRef.id,
        metaData: {},
        ownerPath: ownerPath,
        stateSubscribers: stateSubscribers ?? {},
        state: StoredFile_StoredFileState.Uploading,
        contentType: contentType ?? '',
        fileExtension: fileExtension ?? '',
        filePath:
            'gs://${_storage.bucket}/StoredFiles/${storedFileRef.id}.${fileExtension}');

    try {
      await storedFileRef.set(await model.toJson());
      model.uid = storedFileRef.id;
      return model;
    } catch (err) {
      _log.logTyped(StoredFileDataServiceLog(
          'createStoredFile', err, StackTrace.current));
      throw StoredFileDataServiceException(
        message: err.toString(),
      );
    }
  }

  Future<String> getPublicVideoUrl(String storedFileId) async {
    try {
      final getVideoUrl =
          _functions.httpsCallable('callables-getPublicVideoUrl');

      final res = await getVideoUrl.call({'storedFileId': storedFileId});

      if (res.data is String) {
        return res.data;
      }
      _log.logTyped(StoredFileDataServiceLog(
          'getPublicVideoUrl', 'Invalid response from getPublicVideoUrl'));
      throw Exception('Invalid response from getPublicVideoUrl');
    } catch (err) {
      _log.logTyped(StoredFileDataServiceLog(
          'getPublicVideoUrl', err, StackTrace.current));
      throw StoredFileDataServiceException(
        message: err.toString(),
      );
    }
  }

  // Provider for the StoredFileDataService class
  static Provider<StoredFileDataService> provider =
      Provider<StoredFileDataService>((ref) {
    final stored_fileService = StoredFileDataService(
      ref.watch(fbFirestoreProvider),
      ref.watch(fbFunctionsProvider),
      ref.watch(fbStorageProvider),
      ref.watch(appTalkerProvider),
    );
    return stored_fileService;
  });
}

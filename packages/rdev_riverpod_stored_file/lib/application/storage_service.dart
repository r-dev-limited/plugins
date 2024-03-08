import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:logging/logging.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';

class StorageServiceException extends RdevException {
  StorageServiceException({
    String? message,
    RdevCode? code,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          stackTrace: stackTrace,
        );
}

class StorageService {
  final FirebaseStorage _storage;

  final log = Logger('StorageService');

  StorageService(this._storage);

  Future<Uint8List> getFileData(String gcsPath) async {
    try {
      final fileRef = _storage.refFromURL(gcsPath);
      final res = await fileRef.getData();

      if (res != null) {
        return res;
      }
      log.warning('getFileData', 'File $gcsPath was not found');

      throw StorageServiceException(
        message: 'File $gcsPath was not found',
        code: RdevCode.NotFound,
      );
    } catch (err) {
      log.severe('getFileData', err);
      if (err is StorageServiceException) {
        rethrow;
      }
      throw StorageServiceException(
        message: err.toString(),
      );
    }
  }
}

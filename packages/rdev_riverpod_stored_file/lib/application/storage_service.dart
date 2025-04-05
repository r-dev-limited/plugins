import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';
import 'package:talker/talker.dart';

class StorageServiceLog extends TalkerLog {
  StorageServiceLog(
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
  String get title => 'StorageService';

  /// Your custom log color
  @override
  AnsiPen get pen => AnsiPen()..cyan();
}

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

  final Talker _log;

  StorageService(
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
      _log.logCustom(
          StorageServiceLog('getFileData', 'File $gcsPath was not found'));

      throw StorageServiceException(
        message: 'File $gcsPath was not found',
        code: RdevCode.NotFound,
      );
    } catch (err) {
      _log.logCustom(StorageServiceLog('getFileData', err, StackTrace.current));
      if (err is StorageServiceException) {
        rethrow;
      }
      throw StorageServiceException(
        message: err.toString(),
      );
    }
  }
}

import 'dart:typed_data';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';
import 'package:rdev_errors_logging/talker_provider.dart';
import 'package:rdev_riverpod_stored_file/domain/stored_file_model.dart';
import 'package:rdev_riverpod_stored_file/domain/stored_file_vo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talker/talker.dart';

import 'stored_file_data_service.dart';
import '../domain/uploding_file_vo.dart';

class StoredFileServiceLog extends TalkerLog {
  StoredFileServiceLog(
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
  String get title => 'StoredFileService';

  /// Your custom log color
  @override
  AnsiPen get pen => AnsiPen()..cyan();
}

class StoredFileServiceException extends RdevException {
  StoredFileServiceException({
    String? message,
    RdevCode? code,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          stackTrace: stackTrace,
        );
}

class StoredFileService {
  final StoredFileDataService _storedFileDataService;
  final Talker _log;

  StoredFileService(
    this._storedFileDataService,
    this._log,
  );

  Future<List<StoredFileVO>> getStoredFiles({
    int limit = 50,
    DocumentSnapshot? startAt,
    String? ownerPath,
  }) async {
    try {
      final productModels = await _storedFileDataService.getStoredFiles(
        limit: limit,
        startAt: startAt,
        ownerPath: ownerPath,
      );
      final vos = productModels.map((e) {
        final vo = StoredFileVO.fromStoredFileModel(e);
        return vo;
      }).toList();

      return vos;
    } catch (e) {
      if (e is RdevException) {
        throw StoredFileServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw StoredFileServiceException(message: e.toString());
    }
  }

  Future<UploadingFile> uploadFile({
    required String ownerPath,
    Map<String, StoredFileSubscriber>? stateSubscribers,
    required Uint8List fileData,
    required String fileExtension,
  }) async {
    try {
      final contentType = lookupMimeType('file.$fileExtension');
      final tmpStoredFile = await _storedFileDataService.createStoredFile(
        ownerPath: ownerPath,
        stateSubscribers: stateSubscribers,
        fileExtension: fileExtension,
        contentType: contentType,
      );
      if (tmpStoredFile.contentType is String &&
          tmpStoredFile.filePath is String) {
        final uploadTask = _storedFileDataService.uploadFile(
            tmpStoredFile.filePath!, fileData, tmpStoredFile.contentType!);
        return UploadingFile(
          storedFileVO: StoredFileVO.fromStoredFileModel(tmpStoredFile),
          uploadTask: uploadTask,
        );
      } else {
        throw StoredFileServiceException(
          message: 'File extension $fileExtension is not supported',
          code: RdevCode.Unimplemented,
        );
      }
    } catch (err) {
      _log.logTyped(
          StoredFileServiceLog('uploadFile', err, StackTrace.current));
      if (err is StoredFileServiceException) {
        rethrow;
      }
      throw StoredFileServiceException(
        message: err.toString(),
      );
    }
  }

  // Provider for the StoredFileService class
  static Provider<StoredFileService> provider =
      Provider<StoredFileService>((ref) {
    final stored_fileService = StoredFileService(
      ref.watch(StoredFileDataService.provider),
      ref.watch(appTalkerProvider),
    );
    return stored_fileService;
  });
}

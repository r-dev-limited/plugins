import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rdev_riverpod_stored_file/application/stored_file_service.dart';
import 'package:rdev_riverpod_stored_file/domain/stored_file_vo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rdev_riverpod_stored_file/domain/uploding_file_vo.dart';

import '../domain/stored_file_model.dart';

@immutable
class StoredFilesRepositoryState {
  final List<StoredFileVO> storedFiles;
  final List<UploadingFile> uploadingFiles;
  final bool isLastPage;

  ///
  const StoredFilesRepositoryState({
    this.storedFiles = const [],
    this.uploadingFiles = const [],
    this.isLastPage = false,
  });

  StoredFilesRepositoryState copyWith({
    List<StoredFileVO>? storedFiles,
    List<UploadingFile>? uploadingFiles,
    bool? isLastPage,
  }) {
    return StoredFilesRepositoryState(
      storedFiles: storedFiles ?? this.storedFiles,
      uploadingFiles: uploadingFiles ?? this.uploadingFiles,
      isLastPage: isLastPage ?? this.isLastPage,
    );
  }
}

class StoredFilesRepository
    extends FamilyAsyncNotifier<StoredFilesRepositoryState, String?> {
  late String? ownerPath;
  late StoredFileService _storedFileService;
  final List<UploadingFile> _uploadingFiles = [];
  DocumentSnapshot<Object?>? _lastDocument;

  /// Build (Init)
  @override
  FutureOr<StoredFilesRepositoryState> build(arg) async {
    ownerPath = arg;
    _storedFileService = ref.watch(StoredFileService.provider);

    final tmpState = await _fetchStoredFiles();

    return tmpState;
  }

  Future<StoredFilesRepositoryState> _fetchStoredFiles() async {
    try {
      final storedFileVOs = await _storedFileService.getStoredFiles(
        startAt: _lastDocument,
        ownerPath: ownerPath,
      );
      var isLastPage = false;
      if (_lastDocument != null &&
          _lastDocument!.id == storedFileVOs.last.uid) {
        isLastPage = true;
      }
      _lastDocument = storedFileVOs.lastOrNull?.snapshot;
      return StoredFilesRepositoryState(
        isLastPage: isLastPage,
        storedFiles: storedFileVOs,
        uploadingFiles: _uploadingFiles,
      );
    } catch (err) {
      rethrow;
    }
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      _lastDocument = null;
      return _fetchStoredFiles();
    });
  }

  Future<void> loadMore() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      return _fetchStoredFiles();
    });
  }

  Future<void> uploadFile({
    String? ownerPath,
    required Uint8List fileData,
    required String fileExtension,
    Map<String, StoredFileSubscriber>? stateSubscribers,
  }) async {
    if (ownerPath == null && this.ownerPath == null) {
      throw Exception('ownerPath is required');
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final uploadingFile = await _storedFileService.uploadFile(
        ownerPath: ownerPath ?? this.ownerPath!,
        fileData: fileData,
        fileExtension: fileExtension,
        stateSubscribers: stateSubscribers,
      );
      _uploadingFiles.add(uploadingFile);

      /// Remove on complete
      uploadingFile.uploadTask.whenComplete(() async {
        _uploadingFiles.remove(uploadingFile);
        state = await AsyncValue.guard(() async {
          _lastDocument = null;
          return _fetchStoredFiles();
        });
      });
      _lastDocument = null;
      return _fetchStoredFiles();
    });
  }

  static AsyncNotifierProviderFamily<StoredFilesRepository,
          StoredFilesRepositoryState, String?> provider =
      AsyncNotifierProvider.family<StoredFilesRepository,
          StoredFilesRepositoryState, String?>(() {
    return StoredFilesRepository();
  });
}

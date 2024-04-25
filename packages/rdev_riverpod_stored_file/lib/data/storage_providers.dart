import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rdev_errors_logging/talker_provider.dart';
import 'package:rdev_riverpod_firebase/firebase_providers.dart';
import 'package:rdev_riverpod_stored_file/application/storage_service.dart';

final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(
    ref.watch(fbStorageProvider),
    ref.watch(appTalkerProvider),
  ),
);

final fileDataProvider = FutureProvider.family<Uint8List, String>(
  name: 'fileDataProvider',
  (ref, gcsPath) async {
    final storedFileData =
        await ref.read(storageServiceProvider).getFileData(gcsPath);

    return storedFileData;
  },
);

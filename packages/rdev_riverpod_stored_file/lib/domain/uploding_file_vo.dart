import 'package:rdev_riverpod_stored_file/domain/stored_file_vo.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadingFile {
  final StoredFileVO storedFileVO;
  final UploadTask uploadTask;

  UploadingFile({required this.storedFileVO, required this.uploadTask});
}

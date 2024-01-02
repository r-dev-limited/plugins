import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'stored_file_model.dart';

class StoredFileVO extends Equatable {
  final String? uid;

  final DocumentSnapshot? snapshot;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final StoredFile_StoredFileState state;
  final String ownerPath;
  final Map<String, StoredFileSubscriber> stateSubscribers;
  final String? filePath;
  final String? fileExtension;
  final String? contentType;
  final Map<String, dynamic> metaData;

  StoredFileVO({
    required this.state,
    required this.ownerPath,
    required this.stateSubscribers,
    required this.metaData,
    this.uid,
    this.snapshot,
    this.createdAt,
    this.updatedAt,
    this.filePath,
    this.fileExtension,
    this.contentType,
  });

  @override
  List<Object?> get props => [
        uid,
        createdAt,
        updatedAt,
      ];

  StoredFileVO copyWith({
    String? uid,
    DocumentSnapshot? snapshot,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metaData,
    StoredFile_StoredFileState? state,
    String? ownerPath,
    Map<String, StoredFileSubscriber>? stateSubscribers,
    String? filePath,
    String? fileExtension,
    String? contentType,
  }) {
    return StoredFileVO(
      uid: uid ?? this.uid,
      snapshot: snapshot ?? this.snapshot,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metaData: metaData ?? this.metaData,
      state: state ?? this.state,
      ownerPath: ownerPath ?? this.ownerPath,
      stateSubscribers: stateSubscribers ?? this.stateSubscribers,
      filePath: filePath ?? this.filePath,
      fileExtension: fileExtension ?? this.fileExtension,
      contentType: contentType ?? this.contentType,
    );
  }

  factory StoredFileVO.fromStoredFileModel(StoredFileModel model) {
    return StoredFileVO(
      uid: model.uid!,
      snapshot: model.snapshot,
      createdAt: DateTime.fromMillisecondsSinceEpoch(model.createdAt.toInt()),
      updatedAt: model.updatedAt is double
          ? DateTime.fromMillisecondsSinceEpoch(model.updatedAt!.toInt())
          : null,
      metaData: model.metaData,
      state: model.state,
      ownerPath: model.ownerPath,
      stateSubscribers: model.stateSubscribers,
      filePath: model.filePath,
      fileExtension: model.fileExtension,
      contentType: model.contentType,
    );
  }

  StoredFileModel toStoredFileModel() {
    final model = StoredFileModel(
      uid: uid,
      snapshot: snapshot,
      createdAt: createdAt!.millisecondsSinceEpoch.toDouble(),
      updatedAt: updatedAt is DateTime
          ? updatedAt!.millisecondsSinceEpoch.toDouble()
          : null,
      metaData: metaData,
      state: state,
      ownerPath: ownerPath,
      stateSubscribers: stateSubscribers,
      filePath: filePath,
      fileExtension: fileExtension,
      contentType: contentType,
    );

    return model;
  }
}

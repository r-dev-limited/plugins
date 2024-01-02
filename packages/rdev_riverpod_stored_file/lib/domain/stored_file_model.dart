import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'stored_file_model.g.dart';

enum StoredFile_StoredFileState {
  Uploading,
  Done,
  Error,
}

@JsonSerializable(ignoreUnannotated: true)
class StoredFileSubscriber {
  @JsonKey()
  String ownerPath;

  @JsonKey()
  String? fieldPath;

  StoredFileSubscriber({
    required this.ownerPath,
    this.fieldPath,
  });

  /// Connect the generated [_$StoredFileSubscriberFromJson] function to the `fromJson`
  /// factory.
  factory StoredFileSubscriber.fromJson(Map<String, dynamic> json) =>
      _$StoredFileSubscriberFromJson(json);

  /// Connect the generated [_$StoredFileSubscriberToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$StoredFileSubscriberToJson(this);
}

@JsonSerializable(ignoreUnannotated: true)
class StoredFileModel {
  String? uid;

  DocumentSnapshot? snapshot;

  @JsonKey()
  final double createdAt;

  @JsonKey()
  final double? updatedAt;

  @JsonKey()
  final StoredFile_StoredFileState state;

  @JsonKey()
  final String ownerPath;

  @JsonKey()
  final Map<String, StoredFileSubscriber> stateSubscribers;

  @JsonKey()
  final String? filePath;

  @JsonKey()
  final String? fileExtension;

  @JsonKey()
  final String? contentType;

  @JsonKey()
  final Map<String, dynamic> metaData;

  StoredFileModel({
    required this.createdAt,
    required this.state,
    required this.ownerPath,
    required this.stateSubscribers,
    required this.metaData,
    this.uid,
    this.snapshot,
    this.updatedAt,
    this.filePath,
    this.fileExtension,
    this.contentType,
  });

  /// Connect the generated [_$StoredFileModelFromJson] function to the `fromJson`
  /// factory.
  factory StoredFileModel.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final vo = _$StoredFileModelFromJson(snapshot.data()!);
    vo.snapshot = snapshot;
    vo.uid = snapshot.id;
    return vo;
  }

  /// Connect the generated [_$StoredFileModelFromJson] function to the `fromJson`
  /// factory.
  factory StoredFileModel.fromJson(Map<String, dynamic> json) =>
      _$StoredFileModelFromJson(json);

  /// Connect the generated [_$StoredFileModelToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$StoredFileModelToJson(this);
}

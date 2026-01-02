// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stored_file_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoredFileSubscriber _$StoredFileSubscriberFromJson(
  Map<String, dynamic> json,
) => StoredFileSubscriber(
  ownerPath: json['ownerPath'] as String,
  fieldPath: json['fieldPath'] as String?,
);

Map<String, dynamic> _$StoredFileSubscriberToJson(
  StoredFileSubscriber instance,
) => <String, dynamic>{
  'ownerPath': instance.ownerPath,
  'fieldPath': ?instance.fieldPath,
};

StoredFileModel _$StoredFileModelFromJson(
  Map<String, dynamic> json,
) => StoredFileModel(
  createdAt: (json['createdAt'] as num?)?.toDouble(),
  state: $enumDecodeNullable(
    _$StoredFile_StoredFileStateEnumMap,
    json['state'],
  ),
  ownerPath: json['ownerPath'] as String?,
  stateSubscribers: (json['stateSubscribers'] as Map<String, dynamic>?)?.map(
    (k, e) =>
        MapEntry(k, StoredFileSubscriber.fromJson(e as Map<String, dynamic>)),
  ),
  metaData: json['metaData'] as Map<String, dynamic>?,
  updatedAt: (json['updatedAt'] as num?)?.toDouble(),
  filePath: json['filePath'] as String?,
  fileExtension: json['fileExtension'] as String?,
  contentType: json['contentType'] as String?,
);

Map<String, dynamic> _$StoredFileModelToJson(StoredFileModel instance) =>
    <String, dynamic>{
      'createdAt': ?instance.createdAt,
      'updatedAt': ?instance.updatedAt,
      'state': ?_$StoredFile_StoredFileStateEnumMap[instance.state],
      'ownerPath': ?instance.ownerPath,
      'stateSubscribers': ?instance.stateSubscribers?.map(
        (k, e) => MapEntry(k, e.toJson()),
      ),
      'filePath': ?instance.filePath,
      'fileExtension': ?instance.fileExtension,
      'contentType': ?instance.contentType,
      'metaData': ?instance.metaData,
    };

const _$StoredFile_StoredFileStateEnumMap = {
  StoredFile_StoredFileState.Uploading: 'Uploading',
  StoredFile_StoredFileState.Done: 'Done',
  StoredFile_StoredFileState.Error: 'Error',
};

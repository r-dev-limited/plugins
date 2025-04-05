// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stored_file_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoredFileSubscriber _$StoredFileSubscriberFromJson(
        Map<String, dynamic> json) =>
    StoredFileSubscriber(
      ownerPath: json['ownerPath'] as String,
      fieldPath: json['fieldPath'] as String?,
    );

Map<String, dynamic> _$StoredFileSubscriberToJson(
        StoredFileSubscriber instance) =>
    <String, dynamic>{
      'ownerPath': instance.ownerPath,
      if (instance.fieldPath case final value?) 'fieldPath': value,
    };

StoredFileModel _$StoredFileModelFromJson(Map<String, dynamic> json) =>
    StoredFileModel(
      createdAt: (json['createdAt'] as num?)?.toDouble(),
      state: $enumDecodeNullable(
          _$StoredFile_StoredFileStateEnumMap, json['state']),
      ownerPath: json['ownerPath'] as String?,
      stateSubscribers:
          (json['stateSubscribers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k, StoredFileSubscriber.fromJson(e as Map<String, dynamic>)),
      ),
      metaData: json['metaData'] as Map<String, dynamic>?,
      updatedAt: (json['updatedAt'] as num?)?.toDouble(),
      filePath: json['filePath'] as String?,
      fileExtension: json['fileExtension'] as String?,
      contentType: json['contentType'] as String?,
    );

Map<String, dynamic> _$StoredFileModelToJson(StoredFileModel instance) =>
    <String, dynamic>{
      if (instance.createdAt case final value?) 'createdAt': value,
      if (instance.updatedAt case final value?) 'updatedAt': value,
      if (_$StoredFile_StoredFileStateEnumMap[instance.state] case final value?)
        'state': value,
      if (instance.ownerPath case final value?) 'ownerPath': value,
      if (instance.stateSubscribers?.map((k, e) => MapEntry(k, e.toJson()))
          case final value?)
        'stateSubscribers': value,
      if (instance.filePath case final value?) 'filePath': value,
      if (instance.fileExtension case final value?) 'fileExtension': value,
      if (instance.contentType case final value?) 'contentType': value,
      if (instance.metaData case final value?) 'metaData': value,
    };

const _$StoredFile_StoredFileStateEnumMap = {
  StoredFile_StoredFileState.Uploading: 'Uploading',
  StoredFile_StoredFileState.Done: 'Done',
  StoredFile_StoredFileState.Error: 'Error',
};

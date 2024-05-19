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
    StoredFileSubscriber instance) {
  final val = <String, dynamic>{
    'ownerPath': instance.ownerPath,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('fieldPath', instance.fieldPath);
  return val;
}

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

Map<String, dynamic> _$StoredFileModelToJson(StoredFileModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('createdAt', instance.createdAt);
  writeNotNull('updatedAt', instance.updatedAt);
  writeNotNull('state', _$StoredFile_StoredFileStateEnumMap[instance.state]);
  writeNotNull('ownerPath', instance.ownerPath);
  writeNotNull('stateSubscribers',
      instance.stateSubscribers?.map((k, e) => MapEntry(k, e.toJson())));
  writeNotNull('filePath', instance.filePath);
  writeNotNull('fileExtension', instance.fileExtension);
  writeNotNull('contentType', instance.contentType);
  writeNotNull('metaData', instance.metaData);
  return val;
}

const _$StoredFile_StoredFileStateEnumMap = {
  StoredFile_StoredFileState.Uploading: 'Uploading',
  StoredFile_StoredFileState.Done: 'Done',
  StoredFile_StoredFileState.Error: 'Error',
};

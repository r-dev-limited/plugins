// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fireway_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FirewayModel _$FirewayModelFromJson(Map<String, dynamic> json) => FirewayModel(
  uid: json['uid'] as String?,
  description: json['description'] as String,
  version: json['version'] as String,
  success: json['success'] as bool,
  script: json['script'] as String,
  installedOn: const TimestampConverter().fromJson(
    json['installed_on'] as Timestamp,
  ),
  executionTime: (json['execution_time'] as num).toInt(),
);

Map<String, dynamic> _$FirewayModelToJson(FirewayModel instance) =>
    <String, dynamic>{
      'uid': ?instance.uid,
      'description': instance.description,
      'version': instance.version,
      'success': instance.success,
      'script': instance.script,
      'installed_on': const TimestampConverter().toJson(instance.installedOn),
      'execution_time': instance.executionTime,
    };

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
      installedOn: DateTime.parse(json['installedOn'] as String),
      executionTime: json['executionTime'] as int,
    );

Map<String, dynamic> _$FirewayModelToJson(FirewayModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'description': instance.description,
      'version': instance.version,
      'success': instance.success,
      'script': instance.script,
      'installedOn': instance.installedOn.toIso8601String(),
      'executionTime': instance.executionTime,
    };

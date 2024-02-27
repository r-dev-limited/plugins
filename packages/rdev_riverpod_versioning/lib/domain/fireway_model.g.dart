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

Map<String, dynamic> _$FirewayModelToJson(FirewayModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('uid', instance.uid);
  val['description'] = instance.description;
  val['version'] = instance.version;
  val['success'] = instance.success;
  val['script'] = instance.script;
  val['installedOn'] = instance.installedOn.toIso8601String();
  val['executionTime'] = instance.executionTime;
  return val;
}

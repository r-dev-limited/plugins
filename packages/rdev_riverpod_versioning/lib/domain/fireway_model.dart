import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rdev_riverpod_firebase/firestore_helpers.dart';
part 'fireway_model.g.dart';

@JsonSerializable()
class FirewayModel {
  String? uid;

  @JsonKey()
  final String description;

  @JsonKey()
  final String version;

  @JsonKey()
  final bool success;

  @JsonKey()
  final String script;

  @JsonKey(name: 'installed_on')
  @TimestampConverter()
  final DateTime installedOn;

  @JsonKey(name: 'execution_time')
  final int executionTime;

  FirewayModel({
    this.uid,
    required this.description,
    required this.version,
    required this.success,
    required this.script,
    required this.installedOn,
    required this.executionTime,
  });

  /// Connect the generated [_$FirewayModelFromJson] function to the `fromJson`
  /// factory.
  factory FirewayModel.fromJson(Map<String, dynamic> json) =>
      _$FirewayModelFromJson(json);

  /// Connect the generated [_$FirewayModelToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$FirewayModelToJson(this);
}

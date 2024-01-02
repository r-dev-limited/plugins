import 'package:json_annotation/json_annotation.dart';
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
  @JsonKey()
  final DateTime installedOn;
  @JsonKey()
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

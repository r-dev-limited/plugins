import 'package:json_annotation/json_annotation.dart';

part 'feature_toggle_entry_model.g.dart';

@JsonSerializable()
class FeatureToggleEntryModel {
  ///
  @JsonKey()
  final bool value;

  @JsonKey()
  final String name;

  FeatureToggleEntryModel({
    required this.value,
    required this.name,
  });

  /// Connect the generated [_$FeatureToggleEntryModelFromJson] function to the `fromJson`
  /// factory.
  factory FeatureToggleEntryModel.fromJson(Map<String, dynamic> json) =>
      _$FeatureToggleEntryModelFromJson(json);

  /// Connect the generated [_$FeatureToggleEntryModelToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$FeatureToggleEntryModelToJson(this);
}

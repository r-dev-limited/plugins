import 'package:json_annotation/json_annotation.dart';
import 'feature_toggle_entry_model.dart';

part 'feature_toggle_model.g.dart';

@JsonSerializable()
class FeatureToggleModel {
  String? uid;

  ///
  @JsonKey()
  final Map<String, String>? parent;
  // {
  //   Users:'1234',
  //   // OR
  //   UsersWorkspaces:'1234/5678',
  // }

  @JsonKey()
  final List<FeatureToggleEntryModel>? toggles;

  FeatureToggleModel({
    this.uid,
    this.parent,
    this.toggles,
  });

  /// Connect the generated [_$FeatureToggleModelFromJson] function to the `fromJson`
  /// factory.
  factory FeatureToggleModel.fromJson(Map<String, dynamic> json) =>
      _$FeatureToggleModelFromJson(json);

  /// Connect the generated [_$FeatureToggleModelToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$FeatureToggleModelToJson(this);
}

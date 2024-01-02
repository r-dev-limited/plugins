// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_toggle_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeatureToggleEntryModel _$FeatureToggleEntryModelFromJson(
        Map<String, dynamic> json) =>
    FeatureToggleEntryModel(
      value: json['value'] as bool,
      name: json['name'] as String,
    );

Map<String, dynamic> _$FeatureToggleEntryModelToJson(
        FeatureToggleEntryModel instance) =>
    <String, dynamic>{
      'value': instance.value,
      'name': instance.name,
    };

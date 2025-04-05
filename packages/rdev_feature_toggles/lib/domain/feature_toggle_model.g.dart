// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_toggle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeatureToggleModel _$FeatureToggleModelFromJson(Map<String, dynamic> json) =>
    FeatureToggleModel(
      uid: json['uid'] as String?,
      parent: (json['parent'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      toggles: (json['toggles'] as List<dynamic>?)
          ?.map((e) =>
              FeatureToggleEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FeatureToggleModelToJson(FeatureToggleModel instance) =>
    <String, dynamic>{
      if (instance.uid case final value?) 'uid': value,
      if (instance.parent case final value?) 'parent': value,
      if (instance.toggles?.map((e) => e.toJson()).toList() case final value?)
        'toggles': value,
    };

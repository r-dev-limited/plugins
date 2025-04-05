// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_app_product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InAppProductModel _$InAppProductModelFromJson(Map<String, dynamic> json) =>
    InAppProductModel(
      createdAt: (json['createdAt'] as num?)?.toDouble(),
      updatedAt: (json['updatedAt'] as num?)?.toDouble(),
      type: $enumDecode(_$InAppProductTypeEnumMap, json['type']),
      productIdentifier: json['productIdentifier'] as String?,
      referencePrice: (json['referencePrice'] as num?)?.toDouble(),
      pDollars: (json['pDollars'] as num?)?.toDouble(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      metaData: json['metaData'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$InAppProductModelToJson(InAppProductModel instance) =>
    <String, dynamic>{
      if (instance.createdAt case final value?) 'createdAt': value,
      if (instance.updatedAt case final value?) 'updatedAt': value,
      'type': _$InAppProductTypeEnumMap[instance.type]!,
      if (instance.productIdentifier case final value?)
        'productIdentifier': value,
      if (instance.referencePrice case final value?) 'referencePrice': value,
      if (instance.pDollars case final value?) 'pDollars': value,
      if (instance.name case final value?) 'name': value,
      if (instance.description case final value?) 'description': value,
      'metaData': instance.metaData,
    };

const _$InAppProductTypeEnumMap = {
  InAppProductType.AppStore: 'AppStore',
  InAppProductType.PlayStore: 'PlayStore',
  InAppProductType.Other: 'Other',
};

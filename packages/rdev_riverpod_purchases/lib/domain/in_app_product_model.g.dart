// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_app_product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InAppProductModel _$InAppProductModelFromJson(Map<String, dynamic> json) =>
    InAppProductModel(
      createdAt: (json['createdAt'] as num).toDouble(),
      updatedAt: (json['updatedAt'] as num?)?.toDouble(),
      type: $enumDecode(_$InAppProductTypeEnumMap, json['type']),
      productIdentifier: json['productIdentifier'] as String?,
      referencePrice: (json['referencePrice'] as num?)?.toDouble(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      metaData: json['metaData'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$InAppProductModelToJson(InAppProductModel instance) {
  final val = <String, dynamic>{
    'createdAt': instance.createdAt,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('updatedAt', instance.updatedAt);
  val['type'] = _$InAppProductTypeEnumMap[instance.type]!;
  writeNotNull('productIdentifier', instance.productIdentifier);
  writeNotNull('referencePrice', instance.referencePrice);
  writeNotNull('name', instance.name);
  writeNotNull('description', instance.description);
  val['metaData'] = instance.metaData;
  return val;
}

const _$InAppProductTypeEnumMap = {
  InAppProductType.AppStore: 'AppStore',
  InAppProductType.PlayStore: 'PlayStore',
  InAppProductType.Other: 'Other',
};

import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'in_app_product_model.g.dart';

enum InAppProductType {
  AppStore,
  PlayStore,
  Other,
}

@JsonSerializable(ignoreUnannotated: true)
class InAppProductModel {
  String? uid;

  DocumentSnapshot? snapshot;

  @JsonKey()
  final double createdAt;

  @JsonKey()
  final double? updatedAt;

  @JsonKey()
  final InAppProductType type;

  @JsonKey()
  final String? productIdentifier;

  @JsonKey()
  final double? referencePrice;

  @JsonKey()
  final String? name;

  @JsonKey()
  final String? description;

  @JsonKey()
  final Map<String, dynamic> metaData;

  InAppProductModel({
    this.uid,
    this.snapshot,
    required this.createdAt,
    this.updatedAt,
    required this.type,
    required this.productIdentifier,
    required this.referencePrice,
    required this.name,
    required this.description,
    required this.metaData,
  });

  /// Connect the generated [_$InAppProductModelFromJson] function to the `fromJson`
  /// factory.
  factory InAppProductModel.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final vo = _$InAppProductModelFromJson(snapshot.data()!);
    vo.snapshot = snapshot;
    vo.uid = snapshot.id;
    return vo;
  }

  /// Connect the generated [_$InAppProductModelFromJson] function to the `fromJson`
  /// factory.
  factory InAppProductModel.fromJson(Map<String, dynamic> json) =>
      _$InAppProductModelFromJson(json);

  /// Connect the generated [_$InAppProductModelToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$InAppProductModelToJson(this);
}

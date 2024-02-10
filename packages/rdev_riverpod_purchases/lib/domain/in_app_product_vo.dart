import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'in_app_product_model.dart';

class InAppProductVO extends Equatable {
  final String? uid;
  final DocumentSnapshot? snapshot;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ///
  final InAppProductType type;
  final String? productIdentifier;
  final double? referencePrice;
  final String? name;
  final String? description;
  final Map<String, dynamic> metaData;

  InAppProductVO({
    this.uid,
    this.snapshot,
    this.createdAt,
    this.updatedAt,
    required this.type,
    required this.productIdentifier,
    required this.referencePrice,
    required this.name,
    required this.description,
    required this.metaData,
  });

  @override
  List<Object?> get props => [
        uid,
        createdAt,
        updatedAt,
        type,
        productIdentifier,
        referencePrice,
        name,
        description,
        metaData,
      ];

  InAppProductVO copyWith({
    String? uid,
    DocumentSnapshot? snapshot,
    DateTime? createdAt,
    DateTime? updatedAt,
    InAppProductType? type,
    String? productIdentifier,
    double? referencePrice,
    String? name,
    String? description,
    Map<String, dynamic>? metaData,
  }) {
    return InAppProductVO(
      uid: uid ?? this.uid,
      snapshot: snapshot ?? this.snapshot,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      productIdentifier: productIdentifier ?? this.productIdentifier,
      referencePrice: referencePrice ?? this.referencePrice,
      name: name ?? this.name,
      description: description ?? this.description,
      metaData: metaData ?? this.metaData,
    );
  }

  factory InAppProductVO.fromModel(InAppProductModel model) {
    return InAppProductVO(
      uid: model.uid!,
      snapshot: model.snapshot,
      createdAt: DateTime.fromMillisecondsSinceEpoch(model.createdAt.toInt()),
      updatedAt: model.updatedAt is double
          ? DateTime.fromMillisecondsSinceEpoch(model.updatedAt!.toInt())
          : null,
      type: model.type,
      productIdentifier: model.productIdentifier,
      referencePrice: model.referencePrice,
      name: model.name,
      description: model.description,
      metaData: model.metaData,
    );
  }

  InAppProductModel toModel() {
    final model = InAppProductModel(
      uid: uid,
      snapshot: snapshot,
      createdAt: createdAt!.millisecondsSinceEpoch.toDouble(),
      updatedAt: updatedAt is DateTime
          ? updatedAt!.millisecondsSinceEpoch.toDouble()
          : null,
      type: type,
      productIdentifier: productIdentifier,
      referencePrice: referencePrice,
      name: name,
      description: description,
      metaData: metaData,
    );

    return model;
  }
}

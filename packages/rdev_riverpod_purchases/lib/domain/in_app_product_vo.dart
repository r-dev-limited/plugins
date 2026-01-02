import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

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
  final double? pDollars;
  final String? name;
  final String? description;
  final Map<String, dynamic> metaData;

  final Product? productDetails;

  /// get price
  String get price {
    return productDetails?.displayPrice ??
        (referencePrice is double
            ? '\$${referencePrice!.toStringAsFixed(2)}'
            : 'Free');
  }

  InAppProductVO({
    this.uid,
    this.snapshot,
    this.createdAt,
    this.updatedAt,
    required this.type,
    required this.productIdentifier,
    required this.referencePrice,
    required this.pDollars,
    required this.name,
    required this.description,
    required this.metaData,
    this.productDetails,
  });

  @override
  List<Object?> get props => [
        uid,
        createdAt,
        updatedAt,
        type,
        productIdentifier,
        referencePrice,
        pDollars,
        name,
        description,
        metaData,
        productDetails,
      ];

  InAppProductVO copyWith({
    String? uid,
    DocumentSnapshot? snapshot,
    DateTime? createdAt,
    DateTime? updatedAt,
    InAppProductType? type,
    String? productIdentifier,
    double? referencePrice,
    double? pDollars,
    String? name,
    String? description,
    Map<String, dynamic>? metaData,
    Product? productDetails,
  }) {
    return InAppProductVO(
      uid: uid ?? this.uid,
      snapshot: snapshot ?? this.snapshot,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      productIdentifier: productIdentifier ?? this.productIdentifier,
      referencePrice: referencePrice ?? this.referencePrice,
      pDollars: pDollars ?? this.pDollars,
      name: name ?? this.name,
      description: description ?? this.description,
      metaData: metaData ?? this.metaData,
      productDetails: productDetails ?? this.productDetails,
    );
  }

  factory InAppProductVO.fromModel(InAppProductModel model) {
    return InAppProductVO(
      uid: model.uid!,
      snapshot: model.snapshot,
      createdAt: model.createdAt is double
          ? DateTime.fromMillisecondsSinceEpoch(model.createdAt!.toInt())
          : null,
      updatedAt: model.updatedAt is double
          ? DateTime.fromMillisecondsSinceEpoch(model.updatedAt!.toInt())
          : null,
      type: model.type,
      productIdentifier: model.productIdentifier,
      referencePrice: model.referencePrice,
      pDollars: model.pDollars,
      name: model.name,
      description: model.description,
      metaData: model.metaData,
    );
  }

  InAppProductModel toModel() {
    final model = InAppProductModel(
      uid: uid,
      snapshot: snapshot,
      createdAt: createdAt?.millisecondsSinceEpoch.toDouble(),
      updatedAt: updatedAt is DateTime
          ? updatedAt!.millisecondsSinceEpoch.toDouble()
          : null,
      type: type,
      productIdentifier: productIdentifier,
      referencePrice: referencePrice,
      pDollars: pDollars,
      name: name,
      description: description,
      metaData: metaData,
    );

    return model;
  }
}

import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter_inapp_purchase/helpers.dart' as iap_helpers;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:rdev_errors_logging/rdev_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rdev_riverpod_purchases/domain/in_app_product_model.dart';
import 'package:rdev_riverpod_purchases/domain/in_app_product_vo.dart';

import 'in_app_product_data_service.dart';

class InAppProductServiceException extends RdevException {
  InAppProductServiceException({
    String? message,
    RdevCode? code,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          stackTrace: stackTrace,
        );
}

class InAppProductService {
  final InAppProductDataService _InAppProductDataService;

  InAppProductService(
    this._InAppProductDataService,
  );

  Future<List<InAppProductVO>> getInAppProducts({
    int limit = 50,
    DocumentSnapshot? startAt,
    InAppProductType? type,
  }) async {
    try {
      final inAppproductModels =
          await _InAppProductDataService.getInAppProducts(
        limit: limit,
        startAt: startAt,
        type: type,
      );

      final productDetails =
          await _InAppProductDataService.retrieveProductsDetailsFromStore(
              inAppproductModels
                  .where((element) => element.productIdentifier is String)
                  .map((e) => e.productIdentifier!)
                  .toList());

      final vos = inAppproductModels.map((e) {
        final vo = InAppProductVO.fromModel(e);

        /// Try to find product detail for VO
        try {
          final productDetail = productDetails.firstWhere((element) {
            return element.id == vo.productIdentifier;
          });

          return vo.copyWith(
            productDetails: productDetail,
          );
        } catch (err) {
          ///
        }
        return vo;
      }).toList();

      return vos;
    } catch (e) {
      if (e is RdevException) {
        throw InAppProductServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw InAppProductServiceException(message: e.toString());
    }
  }

  Future<void> purchaseInAppProduct(
    Product item,
    String userId,
  ) async {
    try {
      await _InAppProductDataService.purchaseInAppProduct(
        item,
        userId,
      );
    } catch (e) {
      if (e is RdevException) {
        throw InAppProductServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw InAppProductServiceException(message: e.toString());
    }
  }

  Stream<Purchase?> get purchaseUpdatedStream =>
      _InAppProductDataService.purchaseUpdatedStream;

  Stream<iap_helpers.PurchaseResult?> get purchaseErrorStream =>
      _InAppProductDataService.purchaseErrorStream;

  Future<void> restorePurchases() async {
    try {
      return _InAppProductDataService.restorePurchases();
    } catch (e) {
      if (e is RdevException) {
        throw InAppProductServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw InAppProductServiceException(message: e.toString());
    }
  }

  Future<void> verifyPurchase(Purchase purchasedItem, Product item) async {
    try {
      return _InAppProductDataService.verifyPurchase(purchasedItem, item);
    } catch (e) {
      if (e is RdevException) {
        throw InAppProductServiceException(
            code: e.code, message: e.message, stackTrace: e.stackTrace);
      }
      throw InAppProductServiceException(message: e.toString());
    }
  }

  // Provider for the InAppProductService class
  static Provider<InAppProductService> provider =
      Provider<InAppProductService>((ref) {
    final stored_fileService = InAppProductService(
      ref.watch(InAppProductDataService.provider),
    );
    return stored_fileService;
  });
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_inapp_purchase/enums.dart' show PurchaseState;
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart'
    hide PurchaseState;
import 'package:flutter_inapp_purchase/helpers.dart' as iap_helpers;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:rdev_errors_logging/rdev_exception.dart';
import 'package:rdev_errors_logging/talker_provider.dart';
import 'package:rdev_riverpod_firebase/firebase_providers.dart';
import 'package:talker/talker.dart';

import '../domain/in_app_product_model.dart';

class InAppProductDataServiceLog extends TalkerLog {
  InAppProductDataServiceLog(
    String message, [
    dynamic args,
    StackTrace? stackTrace,
  ]) : super(
          message,
          exception: args,
          stackTrace: stackTrace,
        );

  /// Your custom log title
  @override
  String get title => 'InAppProductDataService';

  /// Your custom log color
  @override
  AnsiPen get pen => AnsiPen()..cyan();
}

class InAppProductDataServicexception extends RdevException {
  InAppProductDataServicexception({
    String? message,
    RdevCode? code,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          stackTrace: stackTrace,
        );
}

class InAppProductDataService {
  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;
  final FlutterInappPurchase _inAppPurchase;
  final Stream<Purchase?> _purchaseUpdatedStream;
  final Stream<iap_helpers.PurchaseResult?> _purchaseErrorStream;

  final Talker _log;

  InAppProductDataService(
    this._db,
    this._functions,
    this._inAppPurchase,
    this._purchaseUpdatedStream,
    this._purchaseErrorStream,
    this._log,
  );

  /// Stream getters
  Stream<Purchase?> get purchaseUpdatedStream => _purchaseUpdatedStream;
  Stream<iap_helpers.PurchaseResult?> get purchaseErrorStream =>
      _purchaseErrorStream;

  Future<List<InAppProductModel>> getInAppProducts({
    int limit = 50,
    DocumentSnapshot? startAt,
    InAppProductType? type,
  }) async {
    try {
      final productsRef = _db.collection('InAppProducts');
      var query = productsRef.limit(limit);
      if (startAt is DocumentSnapshot) {
        query = query.startAtDocument(startAt);
      }

      if (type is InAppProductType) {
        query = query.where('type', isEqualTo: type.name);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        return [];
      }
      final toParse = snapshot.docs.map((e) async {
        final product = await InAppProductModel.fromDocumentSnapshot(e);

        return product;
      }).toList();

      final parsed = await Future.wait(toParse);
      return parsed;
    } catch (err) {
      if (err is FirebaseException) {
        throw InAppProductDataServicexception(
          message: err.message,
          code: RdevCode.Internal,
          stackTrace: err.stackTrace,
        );
      }
      throw InAppProductDataServicexception(message: err.toString());
    }
  }

  Future<InAppProductModel> getInAppProduct(String inAppProductId) async {
    try {
      final snapshot =
          await _db.collection('InAppProducts').doc(inAppProductId).get();
      if (snapshot.exists) {
        final data = snapshot.data()!;
        final model = await InAppProductModel.fromJson(data);
        model.uid = snapshot.id;
        return model;
      }
      _log.logCustom(InAppProductDataServiceLog(
          'getProduct', 'InAppProduct with id:$inAppProductId was not found'));

      throw InAppProductDataServicexception(
        message: 'InAppProduct $inAppProductId was not found',
        code: RdevCode.NotFound,
      );
    } catch (err) {
      _log.logCustom(
          InAppProductDataServiceLog('getProduct', err, StackTrace.current));
      if (err is InAppProductDataServicexception) {
        rethrow;
      }
      throw InAppProductDataServicexception(
        message: err.toString(),
      );
    }
  }

  Future<List<Product>> retrieveProductsDetailsFromStore(
    List<String> productIds,
  ) async {
    final productSkus = Set<String>.from(productIds).toList();
    final products = await _inAppPurchase.fetchProducts<Product>(
      skus: productSkus,
      type: ProductQueryType.InApp,
    );

    return products;
  }

  Future<void> purchaseInAppProduct(
    Product item,
    String userId,
  ) async {
    try {
      await _inAppPurchase.initConnection();
      if (item.id.isNotEmpty) {
        await _inAppPurchase.requestPurchase(
          RequestPurchaseProps.inApp((
            apple: RequestPurchaseIosProps(sku: item.id),
            google: RequestPurchaseAndroidProps(skus: [item.id]),
            useAlternativeBilling: null,
          )),
        );
      } else {
        throw InAppProductDataServicexception(
          message: 'Product id is not available',
          code: RdevCode.FailedPrecondition,
        );
      }
    } catch (err) {
      _log.logCustom(InAppProductDataServiceLog(
          'purchaseInAppProduct', err, StackTrace.current));
      if (err is InAppProductDataServicexception) {
        rethrow;
      }
      throw InAppProductDataServicexception(
        message: err.toString(),
      );
    }
  }

  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      await _inAppPurchase.getAvailablePurchases();
      await _inAppPurchase.clearTransactionIOS();
    } catch (err) {
      print(err);
    }
  }

  Future<void> verifyPurchase(Purchase purchasedItem, Product item) async {
    try {
      if (purchasedItem.purchaseState == PurchaseState.purchased) {
        final verifyPurchaseCallable =
            _functions.httpsCallable('callables-verifyPurchase');
        final verificationData =
            purchasedItem.purchaseToken ?? purchasedItem.id;
        final result = await verifyPurchaseCallable.call({
          'productId': purchasedItem.productId,
          'verificationData': verificationData,
          'source': purchasedItem.platform == IapPlatform.Android
              ? 'play_store'
              : 'app_store',
          'purchaseId': purchasedItem.id,
          'price': 1,
        });
        this._log.info('verifyPurchase', result.data);
        if (result.data is Map && result.data["valid"] == true) {
          _inAppPurchase.finishTransaction(
            purchase: purchasedItem,
            isConsumable: true,
          );
        } else {
          throw InAppProductDataServicexception(
            message: 'Purchase verification failed',
            code: RdevCode.FailedPrecondition,
          );
        }
      }
    } catch (err) {
      _log.logCustom(InAppProductDataServiceLog(
          'verifyPurchase', err, StackTrace.current));
      if (err is InAppProductDataServicexception) {
        rethrow;
      }
      throw InAppProductDataServicexception(
        message: err.toString(),
      );
    }
  }

  // Provider for the InAppProductDataService class
  static Provider<InAppProductDataService> provider =
      Provider<InAppProductDataService>((ref) {
    final instance = FlutterInappPurchase.instance;
    unawaited(instance.initConnection());
    final stored_fileService = InAppProductDataService(
      ref.watch(fbFirestoreProvider),
      ref.watch(fbFunctionsProvider),
      instance,
      instance.purchaseUpdated,
      instance.purchaseError,
      ref.watch(appTalkerProvider),
    );
    return stored_fileService;
  });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:logging/logging.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';
import 'package:rdev_riverpod_firebase/firebase_providers.dart';

import '../domain/in_app_product_model.dart';

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
  final Stream<PurchasedItem?> _purchaseUpdatedStream;
  final Stream<PurchaseResult?> _purchaseErrorStream;

  final _log = Logger('InAppProductDataService');

  InAppProductDataService(
    this._db,
    this._functions,
    this._inAppPurchase,
    this._purchaseUpdatedStream,
    this._purchaseErrorStream,
  );

  /// Stream getters
  Stream<PurchasedItem?> get purchaseUpdatedStream => _purchaseUpdatedStream;
  Stream<PurchaseResult?> get purchaseErrorStream => _purchaseErrorStream;

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
      _log.severe(
          'getProduct', 'InAppProduct with id:$inAppProductId was not found');

      throw InAppProductDataServicexception(
        message: 'InAppProduct $inAppProductId was not found',
        code: RdevCode.NotFound,
      );
    } catch (err) {
      _log.severe('getProduct', err);
      if (err is InAppProductDataServicexception) {
        rethrow;
      }
      throw InAppProductDataServicexception(
        message: err.toString(),
      );
    }
  }

  Future<List<IAPItem>> retrieveProductsDetailsFromStore(
    List<String> productIds,
  ) async {
    Set<String> _kIds = Set<String>.from(productIds);
    final products = await _inAppPurchase.getProducts(_kIds.toList());

    return products;
  }

  Future<void> purchaseInAppProduct(
    IAPItem item,
    String userId,
  ) async {
    try {
      final bool available = await _inAppPurchase.isReady();
      if (available) {
        if (item.productId is String) {
          await _inAppPurchase.requestPurchase(item.productId!);
        } else {
          throw InAppProductDataServicexception(
            message: 'Product id is not available',
            code: RdevCode.FailedPrecondition,
          );
        }
      } else {
        throw InAppProductDataServicexception(
          message: 'InAppPurchase instance is not available',
          code: RdevCode.FailedPrecondition,
        );
      }
    } catch (err) {
      _log.severe('purchaseInAppProduct', err);
      if (err is InAppProductDataServicexception) {
        rethrow;
      }
      throw InAppProductDataServicexception(
        message: err.toString(),
      );
    }
  }

  Future<void> verifyPurchase(PurchasedItem purchasedItem, IAPItem item) async {
    try {
      if (purchasedItem.transactionStateIOS == TransactionState.purchased ||
          purchasedItem.transactionStateIOS == TransactionState.restored) {
        final verifyPurchaseCallable =
            _functions.httpsCallable('callables-verifyPurchase');
        final result = await verifyPurchaseCallable.call({
          'productId': purchasedItem.productId,
          'verificationData': purchasedItem.transactionReceipt,
          'source': 'app_store',
          'purchaseId': purchasedItem.transactionId,
          'price': 1,
        });
        this._log.info('verifyPurchase', result.data);
        if (result.data is Map && result.data["valid"] == true) {
          _inAppPurchase.finishTransaction(purchasedItem, isConsumable: true);
        } else {
          throw InAppProductDataServicexception(
            message: 'Purchase verification failed',
            code: RdevCode.FailedPrecondition,
          );
        }
      }
    } catch (err) {
      _log.severe('verifyPurchase', err);
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
    instance.initialize();
    final stored_fileService = InAppProductDataService(
        ref.watch(fbFirestoreProvider),
        ref.watch(fbFunctionsProvider),
        instance,
        FlutterInappPurchase.purchaseUpdated,
        FlutterInappPurchase.purchaseError);
    return stored_fileService;
  });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logging/logging.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';
import 'package:rdev_riverpod_firebase/firebase_providers.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

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
  final InAppPurchase _inAppPurchase;
  final _log = Logger('InAppProductDataService');

  InAppProductDataService(
    this._db,
    this._functions,
    this._inAppPurchase,
  );

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

  Future<List<ProductDetails>> retrieveProductsDetailsFromStore(
      List<String> productIds) async {
    Set<String> _kIds = Set<String>.from(productIds);
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(_kIds);

    List<ProductDetails> products = response.productDetails;
    return products;
  }

  Future<void> purchaseInAppProduct(String inAppProductId) async {
    try {
      final bool available = await InAppPurchase.instance.isAvailable();
      if (!available) {
        // The store cannot be reached or accessed. Update the UI accordingly.
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

  Future<bool> purchaseProduct(
    ProductDetails productDetails,
    String userId,
  ) async {
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
      applicationUserName: userId,
    );

    return _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
  }

  Stream<List<PurchaseDetails>> purchaseUpdatedStream() {
    return _inAppPurchase.purchaseStream;
  }

  Future<void> verifyExistingPurchase(String productId, String userId) async {
    await _inAppPurchase.restorePurchases(applicationUserName: userId);

    // var iosPlatformAddition = _inAppPurchase
    //     .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
    // final restore = await iosPlatformAddition.refreshPurchaseVerificationData();
    // if (restore is PurchaseVerificationData) {
    //   final verifyPurchaseCallable =
    //       _functions.httpsCallable('callables-verifyPurchase');
    //   final result = await verifyPurchaseCallable.call({
    //     'productId': productId,
    //     'verificationData': restore.serverVerificationData,
    //     'source': restore.source,
    //   });
    //   this._log.info('verifyPurchase', result.data);
    //   if (result.data == true) {

    //     await _inAppPurchase.completePurchase(AppStorePurchaseDetails(
    //         productID: productId,
    //         verificationData: restore,
    //         skPaymentTransaction: ,
    //         transactionDate: DateTime.now().microsecondsSinceEpoch.toString(),
    //         status: PurchaseStatus.purchased));
    //   } else {
    //     throw InAppProductDataServicexception(
    //       message: 'Purchase verification failed',
    //       code: RdevCode.FailedPrecondition,
    //     );
    //   }
    // }
  }

  Future<void> verifyPurchase(PurchaseDetails details) async {
    try {
      if (details.pendingCompletePurchase) {
        final verifyPurchaseCallable =
            _functions.httpsCallable('callables-verifyPurchase');
        final result = await verifyPurchaseCallable.call({
          'productId': details.productID,
          'verificationData': details.verificationData.serverVerificationData,
          'source': details.verificationData.source,
          'purchaseId': details.purchaseID,
        });
        this._log.info('verifyPurchase', result.data);
        if (result.data == true) {
          await _inAppPurchase.completePurchase(details);
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
    final stored_fileService = InAppProductDataService(
      ref.watch(fbFirestoreProvider),
      ref.watch(fbFunctionsProvider),
      InAppPurchase.instance,
    );
    return stored_fileService;
  });
}

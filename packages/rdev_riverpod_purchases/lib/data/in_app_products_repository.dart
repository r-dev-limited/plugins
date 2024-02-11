import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:rdev_riverpod_purchases/application/in_app_product_service.dart';
import 'package:rdev_riverpod_purchases/domain/in_app_product_model.dart';
import 'package:rdev_riverpod_purchases/domain/in_app_product_vo.dart';
import 'package:universal_platform/universal_platform.dart';

@immutable
class InAppProductsRepositoryState {
  final List<InAppProductVO> products;
  final bool isLastPage;

  ///
  const InAppProductsRepositoryState({
    this.products = const [],
    this.isLastPage = false,
  });

  InAppProductsRepositoryState copyWith({
    List<InAppProductVO>? products,
    bool? isLastPage,
  }) {
    return InAppProductsRepositoryState(
      products: products ?? this.products,
      isLastPage: isLastPage ?? this.isLastPage,
    );
  }
}

class InAppProductsRepository
    extends AsyncNotifier<InAppProductsRepositoryState> {
  late InAppProductService _inAppProductService;
  DocumentSnapshot<Object?>? _lastDocument;
  StreamSubscription? _streamSubscription;

  /// Build (Init)
  @override
  FutureOr<InAppProductsRepositoryState> build() async {
    _inAppProductService = ref.watch(InAppProductService.provider);
    await _streamSubscription?.cancel();
    _streamSubscription =
        _inAppProductService.purchaseUpdatedStream().listen((event) async {
      final errors = <Object>[];

      for (final element in event) {
        debugPrint(element.toString());
        if (element.pendingCompletePurchase &&
                element.status == PurchaseStatus.purchased ||
            element.status == PurchaseStatus.restored) {
          try {
            await _inAppProductService.verifyPurchase(element);
          } catch (err) {
            debugPrint(err.toString());
            errors.add(err);
          }
        }
      }
      ;
      if (errors.isNotEmpty) {
        // state = AsyncError(errors.first, StackTrace.current);
      } else {
        state = AsyncValue.data(await _fetchStoredFiles());
      }
    });
    final tmpState = await _fetchStoredFiles();

    return tmpState;
  }

  Future<InAppProductsRepositoryState> _fetchStoredFiles() async {
    try {
      final productVOs = await _inAppProductService.getInAppProducts(
        startAt: _lastDocument,

        /// Use target platform to find out type
        type: UniversalPlatform.isIOS
            ? InAppProductType.AppStore
            : UniversalPlatform.isAndroid
                ? InAppProductType.PlayStore
                : InAppProductType.Other,
      );
      var isLastPage = false;
      if (_lastDocument != null && _lastDocument!.id == productVOs.last.uid) {
        isLastPage = true;
      }
      _lastDocument = productVOs.lastOrNull?.snapshot;
      return InAppProductsRepositoryState(
        isLastPage: isLastPage,
        products: productVOs,
      );
    } catch (err) {
      rethrow;
    }
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      _lastDocument = null;
      return _fetchStoredFiles();
    });
  }

  Future<void> loadMore() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      return _fetchStoredFiles();
    });
  }

  Future<void> purchaseProduct(
    ProductDetails productDetails,
    String userId,
  ) async {
    try {
      state = const AsyncValue.loading();
      await _inAppProductService.purchaseProduct(
        productDetails,
        userId,
      );
    } catch (err) {
      if (err is PlatformException) {
        if (err.code == 'storekit_duplicate_product_object' &&
            err.details is Map) {
          try {
            await _inAppProductService.verifyExistingPurchase(
              err.details["productIdentifier"],
              userId,
            );
            state = AsyncData(await _fetchStoredFiles());
          } catch (err) {
            state = AsyncError(err, StackTrace.current);
          }

          return;
        }
      }
      state = AsyncError(err, StackTrace.current);
    }
  }

  static AsyncNotifierProvider<InAppProductsRepository,
          InAppProductsRepositoryState> provider =
      AsyncNotifierProvider<InAppProductsRepository,
          InAppProductsRepositoryState>(() {
    return InAppProductsRepository();
  });
}

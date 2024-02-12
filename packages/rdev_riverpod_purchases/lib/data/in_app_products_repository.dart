import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  IAPItem? puchaseItem;

  /// Build (Init)
  @override
  FutureOr<InAppProductsRepositoryState> build() async {
    _inAppProductService = ref.watch(InAppProductService.provider);
    await _streamSubscription?.cancel();
    _streamSubscription =
        _inAppProductService.purchaseUpdatedStream.listen((event) async {
      if (event is PurchasedItem && puchaseItem is IAPItem) {
        await _inAppProductService.verifyPurchase(event, puchaseItem!);
      } else {
        /// Reset ?
      }

      state = AsyncValue.data(await _fetchStoredFiles());
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
    IAPItem productDetails,
    String userId,
  ) async {
    try {
      state = const AsyncValue.loading();
      puchaseItem = productDetails;
      await _inAppProductService.purchaseInAppProduct(
        productDetails,
        userId,
      );
    } catch (err) {
      print(err);
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

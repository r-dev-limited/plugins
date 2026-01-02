import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';
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
  StreamSubscription? _errorStreamSubscription;
  Product? puchaseItem;
  Completer<Purchase>? completer;

  /// Build (Init)
  @override
  FutureOr<InAppProductsRepositoryState> build() async {
    _inAppProductService = ref.watch(InAppProductService.provider);
    await _streamSubscription?.cancel();
    unawaited(_restorePurchases());
    ref.onDispose(() {
      unawaited(_streamSubscription?.cancel());
      unawaited(_errorStreamSubscription?.cancel());
    });
    final tmpState = await _fetchStoredFiles();
    _streamSubscription =
        _inAppProductService.purchaseUpdatedStream.listen((event) async {
      print(event);
      if (event is Purchase && puchaseItem is Product) {
        try {
          await _inAppProductService.verifyPurchase(event, puchaseItem!);
          completer?.complete(event);
        } catch (err) {
          print(err);
        }
      }
    });

    _errorStreamSubscription =
        _inAppProductService.purchaseErrorStream.listen((event) {
      print(event);
      completer?.completeError(RdevException(
        message:
            event?.message ?? event?.debugMessage ?? event?.code ?? 'unknown',
        code: RdevCode.Internal,
      ));
    });
    return tmpState;
  }

  Future<void> _restorePurchases() async {
    try {
      await _inAppProductService.restorePurchases();
    } catch (err) {
      /// swallow error
      print(err);
    }
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
    Product productDetails,
    String userId,
  ) async {
    final getOriginalState = state.value!;
    state = const AsyncLoading();
    if (completer != null && !completer!.isCompleted) {
      completer!.completeError(
        Exception('Another purchase is in progress'),
      );
    }
    puchaseItem = productDetails;
    completer = Completer<Purchase>();
    var future =
        completer!.future.timeout(Duration(seconds: 60), onTimeout: () {
      throw TimeoutException('Operation timed out');
    });
    _inAppProductService.purchaseInAppProduct(
      productDetails,
      userId,
    );

    try {
      await future;
      state = AsyncValue.data(getOriginalState);
    } catch (err) {
      state = AsyncError(err, StackTrace.current);
      throw err;
    }
  }

  static AsyncNotifierProvider<InAppProductsRepository,
          InAppProductsRepositoryState> provider =
      AsyncNotifierProvider<InAppProductsRepository,
          InAppProductsRepositoryState>(() {
    return InAppProductsRepository();
  });
}

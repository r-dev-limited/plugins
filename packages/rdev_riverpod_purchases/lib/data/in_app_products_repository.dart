import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rdev_riverpod_purchases/application/in_app_product_service.dart';
import 'package:rdev_riverpod_purchases/domain/in_app_product_vo.dart';

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
    extends FamilyAsyncNotifier<InAppProductsRepositoryState, String?> {
  late String? ownerPath;
  late InAppProductService _inAppProductService;
  DocumentSnapshot<Object?>? _lastDocument;

  /// Build (Init)
  @override
  FutureOr<InAppProductsRepositoryState> build(arg) async {
    ownerPath = arg;
    _inAppProductService = ref.watch(InAppProductService.provider);

    final tmpState = await _fetchStoredFiles();

    return tmpState;
  }

  Future<InAppProductsRepositoryState> _fetchStoredFiles() async {
    try {
      final productVOs = await _inAppProductService.getProducts(
        startAt: _lastDocument,
        ownerPath: ownerPath,
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

  static AsyncNotifierProviderFamily<InAppProductsRepository,
          InAppProductsRepositoryState, String?> provider =
      AsyncNotifierProvider.family<InAppProductsRepository,
          InAppProductsRepositoryState, String?>(() {
    return InAppProductsRepository();
  });
}

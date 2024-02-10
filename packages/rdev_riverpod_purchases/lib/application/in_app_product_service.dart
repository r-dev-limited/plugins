import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rdev_riverpod_purchases/domain/in_app_product_vo.dart';

import 'in_app_product_data_service.dart.dart';

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
  final _log = Logger('InAppProductService');

  InAppProductService(this._InAppProductDataService);

  Future<List<InAppProductVO>> getProducts({
    int limit = 50,
    DocumentSnapshot? startAt,
    String? ownerPath,
  }) async {
    try {
      final productModels = await _InAppProductDataService.getProducts(
        limit: limit,
        startAt: startAt,
        ownerPath: ownerPath,
      );
      final vos = productModels.map((e) {
        final vo = InAppProductVO.fromModel(e);
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

  // Provider for the InAppProductService class
  static Provider<InAppProductService> provider =
      Provider<InAppProductService>((ref) {
    final stored_fileService =
        InAppProductService(ref.watch(InAppProductDataService.provider));
    return stored_fileService;
  });
}

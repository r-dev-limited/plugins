/// This file contains the implementation of the FirewayService class,
/// which acts as a bridge between the UI and the FirewayDataService.

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';
import 'package:rdev_riverpod_versioning/application/fireway_data_service.dart';
import 'package:rdev_riverpod_versioning/domain/fireway_vo.dart';

/// Custom exception class for FirewayService.
/// It extends RdevException.
class FirewayServiceException extends RdevException {
  FirewayServiceException({
    String? message,
    RdevCode? code,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          stackTrace: stackTrace,
        );
}

/// The FirewayService class is responsible for providing the latest backend version to the UI.
class FirewayService {
  final FirewayDataService _firewayDataService;

  FirewayService(this._firewayDataService);

  /// Retrieves the latest backend version by calling the getLatestBackendVersion() method of FirewayDataService.
  /// Returns a Future of FirewayVO.
  Future<FirewayVO> getLatestBackendVersion() async {
    try {
      final model = await _firewayDataService.getLatestBackendVersion();
      return FirewayVO.fromFirewayModel(model);
    } catch (err) {
      if (err is RdevException) {
        throw FirewayServiceException(
          code: err.code,
          message: err.message,
          stackTrace: err.stackTrace,
        );
      }
      throw FirewayServiceException(
        message: err.toString(),
      );
    }
  }

  /// Provider for the FirewayService class.
  /// It is used to provide instances of FirewayService using Riverpod.
  static Provider<FirewayService> provider = Provider<FirewayService>(
    (ref) => FirewayService(
      ref.watch(FirewayDataService.provider),
    ),
  );
}

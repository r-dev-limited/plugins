import 'package:flutter/services.dart';

enum RdevCode {
  Internal,
  Cancelled,
  Unknown,
  InvalidArgument,
  DeadlineExceeded,
  NotFound,
  AlreadyExists,
  PermissionDenied,
  ResourceExhausted,
  FailedPrecondition,
  Aborted,
  OutOfRange,
  Unimplemented,
  Ok,
  Unavailable,
  DataLoss,
  Unauthenticated,
}

class RdevException implements Error {
  final String? message;
  final RdevCode? code;
  final StackTrace? _stackTrace;

  ///
  RdevException({
    this.message = 'Unknown error',
    this.code = RdevCode.Unknown,
    StackTrace? stackTrace,
  }) : _stackTrace = stackTrace;

  RdevException.fromRdevException(
    RdevException rdevException,
  )   : message = rdevException.message,
        code = rdevException.code,
        _stackTrace = rdevException.stackTrace;

  @override
  StackTrace? get stackTrace => _stackTrace;

  @override
  String toString() {
    return 'RdevException: ${message ?? 'unknown error = $code'}';
  }
}

extension FirebaseRdevExceptions on PlatformException {
  RdevCode get rdevCode {
    switch (code) {
      case 'cancelled':
        return RdevCode.Cancelled;
      case 'unknown':
        return RdevCode.Unknown;
      case 'invalid-argument':
        return RdevCode.InvalidArgument;
      case 'deadline-exceeded':
        return RdevCode.DeadlineExceeded;
      case 'not-found':
        return RdevCode.NotFound;
      case 'already-exists':
        return RdevCode.AlreadyExists;
      case 'permission-denied':
        return RdevCode.PermissionDenied;
      case 'resource-exhausted':
        return RdevCode.ResourceExhausted;
      case 'failed-precondition':
        return RdevCode.FailedPrecondition;
      case 'aborted':
        return RdevCode.Aborted;
      case 'out-of-range':
        return RdevCode.OutOfRange;
      case 'unimplemented':
        return RdevCode.Unimplemented;
      case 'internal':
        return RdevCode.Internal;
      case 'unavailable':
        return RdevCode.Unavailable;
      case 'data-loss':
        return RdevCode.DataLoss;
      case 'unauthenticated':
        return RdevCode.Unauthenticated;
      default:
        return RdevCode.Unknown;
    }
  }

  RdevException toRdevException() {
    return RdevException(
      message: message,
      code: rdevCode,
      stackTrace: StackTrace.fromString(this.stacktrace ?? ''),
    );
  }
}

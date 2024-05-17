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

  @override
  StackTrace? get stackTrace => _stackTrace;

  @override
  String toString() {
    return 'RdevException: ${message ?? 'unknown error = $code'}';
  }
}

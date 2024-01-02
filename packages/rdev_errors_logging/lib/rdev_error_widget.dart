import 'package:flutter/material.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';

class RdevErrorWidget extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  const RdevErrorWidget({Key? key, required this.error, this.stackTrace})
      : super(key: key);

  Icon _getIcon(RdevCode? code) {
    switch (code) {
      case RdevCode.NotFound:
        return Icon(Icons.not_interested);
      case RdevCode.Aborted:
        return Icon(Icons.cancel);
      case RdevCode.AlreadyExists:
        return Icon(Icons.copy);
      case RdevCode.DataLoss:
        return Icon(Icons.data_usage);
      case RdevCode.DeadlineExceeded:
        return Icon(Icons.timer_off);
      case RdevCode.FailedPrecondition:
        return Icon(Icons.data_array);
      case RdevCode.Internal:
        return Icon(Icons.error);
      case RdevCode.InvalidArgument:
        return Icon(Icons.data_object);
      case RdevCode.OutOfRange:
        return Icon(Icons.numbers);
      case RdevCode.PermissionDenied:
        return Icon(Icons.lock);
      case RdevCode.ResourceExhausted:
        return Icon(Icons.no_transfer);
      case RdevCode.Unauthenticated:
        return Icon(Icons.no_accounts);
      case RdevCode.Unavailable:
        return Icon(Icons.call_missed_outlined);
      case RdevCode.Unimplemented:
        return Icon(Icons.hourglass_empty);
      case RdevCode.Unknown:
        return Icon(Icons.error);

      default:
        return Icon(Icons.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error is RdevException) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _getIcon((error as RdevException).code),
              Text(error.runtimeType.toString())
            ],
          ),
          Text((error as RdevException).message ?? 'Unknown Error')
        ],
      );
    } else {
      return Text(error.toString());
    }
  }
}

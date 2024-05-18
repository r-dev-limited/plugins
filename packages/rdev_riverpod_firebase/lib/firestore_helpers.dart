import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';

class FirestoreHelpers {
  static Map<String, dynamic> convertFirestoreMapToJSON(
      Map<String, dynamic> firestoreJson) {
    return jsonDecode(
      jsonEncode(
        firestoreJson,
        toEncodable: (nonEncodable) {
          if (nonEncodable is Timestamp) {
            return "${nonEncodable.seconds}.${nonEncodable.nanoseconds}";
          }
          // We dont know what type, try to return empty string for now
          debugPrint(nonEncodable.toString());
          // Empty string
          return '';
        },
      ),
    );
  }
}

class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp json) => json.toDate();

  @override
  Timestamp toJson(DateTime object) => Timestamp.fromDate(object);
}

class TimestampNullableConverter
    implements JsonConverter<DateTime?, Timestamp?> {
  const TimestampNullableConverter();

  @override
  DateTime? fromJson(Timestamp? json) => json?.toDate();

  @override
  Timestamp? toJson(DateTime? object) =>
      object == null ? null : Timestamp.fromDate(object);
}

extension FirebaseRdevExceptions on FirebaseException {
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
      stackTrace: this.stackTrace,
    );
  }
}

extension FirebaseAuthRdevExceptions on FirebaseAuthException {
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
      stackTrace: this.stackTrace,
    );
  }
}

extension FirebaseFunctionRdevExceptions on FirebaseFunctionsException {
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
      stackTrace: this.stackTrace,
    );
  }
}

extension FirebaseMultifactorRdevExceptions
    on FirebaseAuthMultiFactorException {
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
    );
  }
}

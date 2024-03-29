import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

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

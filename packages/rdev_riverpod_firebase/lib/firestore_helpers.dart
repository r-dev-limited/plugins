import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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

import 'package:flutter/foundation.dart';

class ListenableWrapper extends ValueNotifier {
  ListenableWrapper(value) : super(value);

  void changeValue(newValue) {
    value = newValue;
  }
}

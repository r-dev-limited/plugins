import 'dart:async';

import 'package:flutter/material.dart';

/// A debouncer that will omit multiple unnessary calls to the action
class UIDebouncer {
  final Duration duration;
  Timer? _timer;

  UIDebouncer({this.duration = const Duration(milliseconds: 600)});

  /// Run the action after the duration
  run(VoidCallback action) {
    if (_timer != null && (_timer?.isActive ?? false)) {
      _timer?.cancel();
    }
    _timer = Timer(duration, action);
  }

  cancel() {
    _timer?.cancel();
  }
}

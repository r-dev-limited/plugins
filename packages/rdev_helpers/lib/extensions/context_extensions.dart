import 'package:flutter/material.dart';

/// Extension to reduce amount of code needed to call context related context.
extension ContextExtensions on BuildContext {
  /// Extension to access [ Theme ].
  ThemeData get theme => Theme.of(this);

  /// Extension to access [ TextTheme ]
  TextTheme get textTheme => theme.textTheme;

  /// Extension  to access [ ColorScheme ]
  ColorScheme get colorScheme => theme.colorScheme;

  /// Extension to access [ MediaQuery ]
  MediaQueryData get mediaQuery => MediaQuery.of(this);
}

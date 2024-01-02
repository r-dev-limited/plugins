import 'package:flutter/material.dart';

extension TextStyleExtension on TextStyle {
  /// Copies values from a different textStyle while it has values
  /// It will only copy from limited parameters
  ///
  /// Parameters: fontSize, height, letterSpacing, fontFamily, fontStyle,
  /// fontWeight, and color
  ///
  TextStyle copyFromTextStyle(TextStyle textStyle) {
    return TextStyle(
      fontSize: textStyle.fontSize ?? fontSize,
      height: textStyle.height ?? height,
      letterSpacing: textStyle.letterSpacing ?? letterSpacing,
      fontFamily: textStyle.fontFamily ?? fontFamily,
      fontStyle: textStyle.fontStyle ?? fontStyle,
      fontWeight: textStyle.fontWeight ?? fontWeight,
      color: textStyle.color ?? color,
    );
  }
}

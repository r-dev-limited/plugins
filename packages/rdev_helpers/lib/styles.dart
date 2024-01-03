// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

/// Spacing, Margins, Gutters, and Paddings.
///
@immutable
class Insets {
  /// value: 4;
  static const double xxsmall = 4;

  /// value: 8;
  static const double xsmall = 8;

  /// value: 12;
  static const double midSmall = 12;

  /// value: 16;
  static const double small = 16;

  /// value: 24;
  static const double medium = 24;

  /// value: 32
  static const double large = 32;

  /// value: 38;
  static const double midLarge = 38;

  /// value: 40;
  static const double xMidLarge = 40;

  /// value: 48;
  static const double xlarge = 48;

  /// value: 56;
  static const double xxlarge = 54;

  /// value: 80;
  static const double offset = 80;
}

/// Borders.
@immutable
class Corners {
  static const double nano = 2;
  static const double micro = 4;
  static const double small = 8;
  static const double midSmall = 12;
  static const double medium = 16;
  static const double large = 32;
  static const double midLarge = 40;
  static const double xlarge = 48;
  static const double xxlarge = 54;
}

/// Animations and movement.
@immutable
class Speed {
  /// got to go...
  static const Duration immediate = Duration(milliseconds: 10);

  /// got to go...
  static const Duration faster = Duration(milliseconds: 100);

  /// got to go...
  static const Duration fast = Duration(milliseconds: 250);

  /// got to go...
  static const Duration normal = Duration(milliseconds: 500);

  /// got to go...
  static const Duration slow = Duration(milliseconds: 900);

  static const Duration notification = Duration(milliseconds: 2500);

  static const Duration toast = Duration(milliseconds: 5000);
}

/// Breakpoints used for page responsivness
@immutable
class Breakpoints {
  static const double mobile = 480;
//   static const double tablet = 800;
//   static const double desktop = 1000;
//   static const double desktop4k = 2560;
//   static const double desktop8k = 4920; // To be confirmed

  //static const double maxWidth = desktop8k;
  static const double minWidth = mobile;
  static const double maxWidthContent = 1440; // Value from Figma
}

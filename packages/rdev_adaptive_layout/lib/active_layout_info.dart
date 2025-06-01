import 'package:flutter/material.dart';
import './adaptive_breakpoint_definitions.dart'; // Assuming it's in the same directory
import 'adaptive_platform.dart'; // Import AdaptivePlatform
import 'device_form_factor.dart'; // Added import

/// Holds information about the current layout state, passed to slot builders.
@immutable
class ActiveLayoutInfo {
  /// The current build context.
  final BuildContext context;

  /// The current target platform (e.g., Android, iOS).
  final TargetPlatform platform;

  /// The current adaptive platform (e.g., Android, iOS, Web).
  final AdaptivePlatform adaptivePlatform;

  /// The current screen orientation (e.g., portrait, landscape).
  final Orientation orientation;

  /// The identifier of the currently active breakpoint.
  final BreakpointId activeBreakpointId;

  /// The current screen size.
  final Size screenSize;

  /// The determined device form factor (e.g., phone, tablet, desktop).
  final DeviceFormFactor formFactor; // Added property

  /// Callbacks for drawer/pane control
  final VoidCallback? openLeftDrawer;
  final VoidCallback? closeLeftDrawer;
  final VoidCallback? toggleLeftDrawer;
  final VoidCallback? openRightDrawer;
  final VoidCallback? closeRightDrawer;
  final VoidCallback? toggleRightDrawer;

  /// For Cupertino, we might use specific terms like "Pane" if the behavior is distinct
  final VoidCallback?
  openLeftPane; // Could be the same as openLeftDrawer internally
  final VoidCallback? closeLeftPane;
  final VoidCallback? toggleLeftPane;
  final VoidCallback? openRightPane;
  final VoidCallback? closeRightPane;
  final VoidCallback? toggleRightPane;

  const ActiveLayoutInfo({
    required this.context,
    required this.platform,
    required this.adaptivePlatform,
    required this.orientation,
    required this.activeBreakpointId,
    required this.screenSize,
    required this.formFactor, // Added to constructor
    // Drawer control callbacks
    this.openLeftDrawer,
    this.closeLeftDrawer,
    this.toggleLeftDrawer,
    this.openRightDrawer,
    this.closeRightDrawer,
    this.toggleRightDrawer,
    // Pane control callbacks (can alias to drawer methods if behavior is identical)
    this.openLeftPane,
    this.closeLeftPane,
    this.toggleLeftPane,
    this.openRightPane,
    this.closeRightPane,
    this.toggleRightPane,
  });

  /// Checks if the current active breakpoint is smaller than or equal to the [other] breakpoint.
  bool isSmallerOrEqualTo(BreakpointId other) {
    return activeBreakpointId.isSmallerOrEqualTo(other);
  }

  /// Checks if the current active breakpoint is larger than or equal to the [other] breakpoint.
  bool isLargerOrEqualTo(BreakpointId other) {
    return activeBreakpointId.isLargerOrEqualTo(other);
  }

  /// Checks if the current active breakpoint is smaller than the [other] breakpoint.
  bool isSmallerThan(BreakpointId other) {
    return activeBreakpointId.isSmallerThan(other);
  }

  /// Checks if the current active breakpoint is larger than the [other] breakpoint.
  bool isLargerThan(BreakpointId other) {
    return activeBreakpointId.isLargerThan(other);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActiveLayoutInfo &&
          runtimeType == other.runtimeType &&
          platform == other.platform &&
          adaptivePlatform == other.adaptivePlatform &&
          orientation == other.orientation &&
          activeBreakpointId == other.activeBreakpointId &&
          screenSize == other.screenSize &&
          formFactor == other.formFactor &&
          openLeftDrawer == other.openLeftDrawer &&
          closeLeftDrawer == other.closeLeftDrawer &&
          toggleLeftDrawer == other.toggleLeftDrawer &&
          openRightDrawer == other.openRightDrawer &&
          closeRightDrawer == other.closeRightDrawer &&
          toggleRightDrawer == other.toggleRightDrawer &&
          openLeftPane == other.openLeftPane &&
          closeLeftPane == other.closeLeftPane &&
          toggleLeftPane == other.toggleLeftPane &&
          openRightPane == other.openRightPane &&
          closeRightPane == other.closeRightPane &&
          toggleRightPane == other.toggleRightPane;

  @override
  int get hashCode =>
      platform.hashCode ^
      adaptivePlatform.hashCode ^
      orientation.hashCode ^
      activeBreakpointId.hashCode ^
      screenSize.hashCode ^
      formFactor.hashCode ^
      openLeftDrawer.hashCode ^
      closeLeftDrawer.hashCode ^
      toggleLeftDrawer.hashCode ^
      openRightDrawer.hashCode ^
      closeRightDrawer.hashCode ^
      toggleRightDrawer.hashCode ^
      openLeftPane.hashCode ^
      closeLeftPane.hashCode ^
      toggleLeftPane.hashCode ^
      openRightPane.hashCode ^
      closeRightPane.hashCode ^
      toggleRightPane.hashCode;
}

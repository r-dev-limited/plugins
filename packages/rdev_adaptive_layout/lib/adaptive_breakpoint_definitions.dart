import 'package:flutter/material.dart';
import 'adaptive_platform.dart'; // Import AdaptivePlatform

/// Represents distinct breakpoint identifiers.
enum BreakpointId {
  xxs, // Extra Extra Small (e.g., small phone portrait)
  xs, // Extra Small (e.g., small phone portrait)
  s, // Small (e.g., phone portrait, small tablet portrait)
  m, // Medium (e.g., phone landscape, tablet portrait)
  l, // Large (e.g., tablet landscape, small desktop)
  xl, // Extra Large (e.g., large desktop)
  xxl, // Extra Extra Large (e.g., extra large desktop)
  xxxl, // Extra Extra Extra Large (e.g., extra extra large desktop)
  xxxxl, // Extra Extra Extra Extra Large (e.g., extra extra extra large desktop)
}

extension BreakpointIdComparison on BreakpointId {
  // Helper to get minWidth for a specific BreakpointId
  // This assumes DefaultBreakpoints.commonBreakpoints is the source of truth for widths.
  static double _getMinWidthFor(BreakpointId id) {
    final breakpointData = DefaultBreakpoints.commonBreakpoints.firstWhere(
      (data) => data.id == id,
      orElse: () {
        // This should not happen if all BreakpointId enum values are defined in commonBreakpoints
        throw ArgumentError(
          'BreakpointId $id not found in DefaultBreakpoints.commonBreakpoints. '
          'Cannot determine its width-based order.',
        );
      },
    );
    return breakpointData.settings.minWidth;
  }

  /// Checks if this breakpoint represents a width category smaller than or equal to
  /// the [other] breakpoint, based on their `minWidth` from `DefaultBreakpoints`.
  bool isSmallerOrEqualTo(BreakpointId other) {
    return _getMinWidthFor(this) <= _getMinWidthFor(other);
  }

  /// Checks if this breakpoint represents a width category larger than or equal to
  /// the [other] breakpoint, based on their `minWidth` from `DefaultBreakpoints`.
  bool isLargerOrEqualTo(BreakpointId other) {
    return _getMinWidthFor(this) >= _getMinWidthFor(other);
  }

  /// Checks if this breakpoint represents a width category smaller than
  /// the [other] breakpoint, based on their `minWidth` from `DefaultBreakpoints`.
  bool isSmallerThan(BreakpointId other) {
    return _getMinWidthFor(this) < _getMinWidthFor(other);
  }

  /// Checks if this breakpoint represents a width category larger than
  /// the [other] breakpoint, based on their `minWidth` from `DefaultBreakpoints`.
  bool isLargerThan(BreakpointId other) {
    return _getMinWidthFor(this) > _getMinWidthFor(other);
  }
}

/// Defines the width constraints for a specific breakpoint.
@immutable
class BreakpointSettings {
  final double minWidth;
  final double? maxWidth; // Null for the largest breakpoint (andUp)

  const BreakpointSettings({required this.minWidth, this.maxWidth});

  /// Checks if a given width falls within this breakpoint's range.
  bool isActive(double width) {
    if (maxWidth == null) {
      return width >= minWidth;
    }
    return width >= minWidth && width < maxWidth!;
  }
}

/// Configuration for breakpoints for a specific platform.
/// Allows defining different breakpoint values for different platforms.
@immutable
class PlatformBreakpointConfig {
  /// The platform this configuration applies to.
  final AdaptivePlatform platform; // Changed to AdaptivePlatform
  // Using a list of records for named breakpoints.
  final List<({BreakpointId id, BreakpointSettings settings})> breakpoints;

  const PlatformBreakpointConfig({
    required this.platform,
    required this.breakpoints,
  });

  /// Finds the active [BreakpointId] for a given screen width.
  /// Assumes breakpoints are ordered from smallest to largest for correct matching.
  BreakpointId getActiveBreakpointId(double screenWidth) {
    // Iterate from largest to smallest to ensure correct matching for overlapping (if any) or unbounded largest breakpoint
    for (final bpConfig in breakpoints.reversed) {
      if (bpConfig.settings.isActive(screenWidth)) {
        return bpConfig.id;
      }
    }
    // Fallback to the smallest if screenWidth is below the smallest defined minWidth.
    // This assumes breakpoints are sorted by minWidth or this is the desired behavior.
    return breakpoints.first.id;
  }
}

/// Default breakpoint configurations for different platforms.
class DefaultBreakpoints {
  // This was previously _defaultBreakpoints, then renamed to commonBreakpoints.
  // Ensuring consistency.
  static final List<({BreakpointId id, BreakpointSettings settings})>
  commonBreakpoints = [
    (id: BreakpointId.xxs, settings: BreakpointSettings(minWidth: 0)),
    (id: BreakpointId.xs, settings: BreakpointSettings(minWidth: 360)),
    (id: BreakpointId.s, settings: BreakpointSettings(minWidth: 600)),
    (id: BreakpointId.m, settings: BreakpointSettings(minWidth: 800)),
    (id: BreakpointId.l, settings: BreakpointSettings(minWidth: 1024)),
    (id: BreakpointId.xl, settings: BreakpointSettings(minWidth: 1280)),
    (id: BreakpointId.xxl, settings: BreakpointSettings(minWidth: 1440)),
    (id: BreakpointId.xxxl, settings: BreakpointSettings(minWidth: 1600)),
    (id: BreakpointId.xxxxl, settings: BreakpointSettings(minWidth: 1920)),
  ];

  /// Default configurations for each platform.
  static List<PlatformBreakpointConfig> get defaultConfigs => [
    PlatformBreakpointConfig(
      platform: AdaptivePlatform.ANDROID,
      breakpoints: commonBreakpoints,
    ),
    PlatformBreakpointConfig(
      platform: AdaptivePlatform.IOS,
      breakpoints: commonBreakpoints,
    ),
    PlatformBreakpointConfig(
      platform: AdaptivePlatform.WEB,
      breakpoints: commonBreakpoints,
    ),
    PlatformBreakpointConfig(
      platform: AdaptivePlatform.MACOS,
      breakpoints: commonBreakpoints,
    ),
    PlatformBreakpointConfig(
      platform: AdaptivePlatform.WINDOWS,
      breakpoints: commonBreakpoints,
    ),
    PlatformBreakpointConfig(
      platform: AdaptivePlatform.LINUX,
      breakpoints: commonBreakpoints,
    ),
    PlatformBreakpointConfig(
      platform: AdaptivePlatform.FUCHSIA,
      breakpoints: commonBreakpoints,
    ),
  ];

  /// Retrieves the [PlatformBreakpointConfig] for the given [platform].
  ///
  /// If [customConfigs] is provided, it searches there first.
  /// Otherwise, it falls back to [defaultConfigs].
  /// If no specific config is found for the platform, it defaults to Material (Android) config.
  static PlatformBreakpointConfig getConfigForPlatform(
    AdaptivePlatform platform, {
    List<PlatformBreakpointConfig>? customConfigs,
  }) {
    final configsToSearch = customConfigs ?? defaultConfigs;
    try {
      return configsToSearch.firstWhere(
        (config) => config.platform == platform,
      );
    } catch (e) {
      return configsToSearch.firstWhere(
        (config) => config.platform == AdaptivePlatform.ANDROID,
        orElse: () => PlatformBreakpointConfig(
          platform: platform,
          breakpoints: commonBreakpoints,
        ),
      );
    }
  }
}

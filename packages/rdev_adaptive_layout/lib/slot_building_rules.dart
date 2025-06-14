import 'package:flutter/material.dart';
import './active_layout_info.dart';
import './adaptive_breakpoint_definitions.dart'; // Required for BreakpointId
import 'adaptive_platform.dart'; // Import the new enum
import 'device_form_factor.dart'; // Added import

/// Defines a specific rule for building a slot, consisting of a condition and a builder.
@immutable
class SlotRule {
  /// The condition under which this rule's builder should be used.
  final bool Function(ActiveLayoutInfo) condition;

  /// The function that builds the widget for this slot if the condition is met.
  final Widget? Function(ActiveLayoutInfo) builder;

  const SlotRule({required this.condition, required this.builder});
}

/// Configuration for matching layout conditions.
///
/// This class defines the criteria (platform, breakpoint, orientation)
/// under which a specific layout or widget variant should be used.
class LayoutMatchConfig {
  /// A set of target platforms (e.g., {AdaptivePlatform.ANDROID, AdaptivePlatform.WEB}).
  /// If null, the config matches any platform.
  final Set<AdaptivePlatform>? platforms;

  /// A function to match breakpoints (e.g., (id) => id.isSmall()).
  /// If null, the config matches any breakpoint.
  final bool Function(BreakpointId activeId)? breakpointMatcher;

  /// The target orientation (e.g., Orientation.portrait).
  /// If null, the config matches any orientation.
  final Orientation? orientationMatcher; // Renamed for clarity

  /// A function to match device form factors (e.g., (factor) => factor == DeviceFormFactor.tablet).
  /// If null, the config matches any form factor.
  final bool Function(DeviceFormFactor formFactor)?
      formFactorMatcher; // Added property

  /// The builder function that constructs the widget when this config matches.
  final Widget? Function(ActiveLayoutInfo layoutInfo) builder;

  /// Indicates if this configuration, when matched for a drawer/pane slot,
  /// should result in a persistent (inline) display rather than a modal/overlay one.
  /// Defaults to false.
  final bool isPersistent;

  /// Internal property to calculate the specificity of this configuration.
  /// More specific configurations (more conditions set) take precedence.
  final int _specificity;

  /// Creates a [LayoutMatchConfig].
  ///
  /// At least one condition (platforms, breakpointMatcher, or orientationMatcher)
  /// should typically be provided, along with the [builder].
  LayoutMatchConfig({
    this.platforms,
    this.breakpointMatcher,
    this.orientationMatcher,
    this.formFactorMatcher, // Added to constructor
    required this.builder,
    this.isPersistent = false, // Default to false
  }) : _specificity = (platforms?.isNotEmpty == true ? 1 : 0) +
            (breakpointMatcher != null ? 1 : 0) +
            (orientationMatcher != null ? 1 : 0) +
            (formFactorMatcher != null
                ? 1
                : 0); // Added to specificity calculation

  /// Returns the specificity of this configuration.
  /// Used to resolve conflicts if multiple configurations match.
  int get specificity => _specificity;

  /// Checks if this configuration matches the given layout parameters.
  ///
  /// [activeBreakpointId]: The current active breakpoint.
  /// [currentOrientation]: The current screen orientation.
  /// [currentPlatform]: The current platform (AdaptivePlatform).
  /// [currentFormFactor]: The current device form factor (DeviceFormFactor).
  bool matches({
    required BreakpointId activeBreakpointId,
    required Orientation currentOrientation,
    required AdaptivePlatform currentPlatform,
    required DeviceFormFactor currentFormFactor, // Added parameter
  }) {
    bool platformMatch = platforms == null ||
        platforms!.isEmpty ||
        platforms!.contains(currentPlatform);
    bool breakpointMatch =
        breakpointMatcher == null || breakpointMatcher!(activeBreakpointId);
    bool orientationMatch =
        orientationMatcher == null || orientationMatcher == currentOrientation;
    bool formFactorMatch = // Added check
        formFactorMatcher == null || formFactorMatcher!(currentFormFactor);

    return platformMatch &&
        breakpointMatch &&
        orientationMatch &&
        formFactorMatch; // Added to return
  }
}

/// Abstract base class for different types of slot builders.
/// This allows `AdaptiveLayoutWidget` to handle both simple function-based builders
/// and more complex rule-based builders.
@immutable
abstract class SlotBuilderType {
  const SlotBuilderType();

  /// Builds the widget for a slot based on the current [ActiveLayoutInfo].
  Widget? build(ActiveLayoutInfo info);
}

/// A slot builder that uses a single function to build the widget.
/// This is for simple slots without complex conditional logic.
@immutable
class SimpleSlotBuilder extends SlotBuilderType {
  final Widget? Function(ActiveLayoutInfo) _builder;

  const SimpleSlotBuilder(this._builder);

  @override
  Widget? build(ActiveLayoutInfo info) => _builder(info);
}

/// A declarative slot builder that uses a list of [LayoutMatchConfig]s.
///
/// It iterates through the [configs] and uses the first one that matches
/// the current layout conditions. If no config matches, it uses the
/// [defaultBuilder].
class DeclarativeSlotBuilder extends SlotBuilderType {
  /// A list of layout match configurations.
  final List<LayoutMatchConfig> configs;

  /// A default builder to use if no [configs] match.
  /// If null and no configs match, no widget is built.
  final Widget? Function(ActiveLayoutInfo layoutInfo)? defaultBuilder;

  /// Creates a [DeclarativeSlotBuilder].
  DeclarativeSlotBuilder({required this.configs, this.defaultBuilder});

  @override
  Widget? build(ActiveLayoutInfo layoutInfo) {
    LayoutMatchConfig? bestMatch;
    for (final config in configs) {
      if (config.matches(
        activeBreakpointId: layoutInfo.activeBreakpointId,
        currentOrientation: layoutInfo.orientation,
        currentPlatform: layoutInfo.adaptivePlatform,
        currentFormFactor: layoutInfo.formFactor, // Pass formFactor
      )) {
        if (bestMatch == null || config.specificity > bestMatch.specificity) {
          bestMatch = config;
        }
      }
    }

    if (bestMatch != null) {
      return bestMatch.builder(layoutInfo);
    }
    return defaultBuilder?.call(layoutInfo);
  }

  /// Finds the best matching [LayoutMatchConfig] for the given [layoutInfo].
  /// Returns null if no configuration matches and no default builder is specified.
  LayoutMatchConfig? getMatchedConfig(ActiveLayoutInfo layoutInfo) {
    LayoutMatchConfig? bestMatch;
    for (final config in configs) {
      if (config.matches(
        activeBreakpointId: layoutInfo.activeBreakpointId,
        currentOrientation: layoutInfo.orientation,
        currentPlatform: layoutInfo.adaptivePlatform,
        currentFormFactor: layoutInfo.formFactor, // Pass formFactor
      )) {
        if (bestMatch == null || config.specificity > bestMatch.specificity) {
          bestMatch = config;
        }
      }
    }
    return bestMatch;
  }
}

/// A simple slot builder that always returns the same widget.
/// This is useful for static content that doesn't change based on layout conditions.
class StaticSlotBuilder extends SlotBuilderType {
  /// The widget to be built.
  final Widget? widget;

  /// Creates a [StaticSlotBuilder].
  StaticSlotBuilder(this.widget);

  @override
  Widget? build(ActiveLayoutInfo layoutInfo) => widget;
}

/// A slot builder that conditionally returns one of two builders based on a predicate.
///
/// The [condition] predicate takes [ActiveLayoutInfo] and returns true or false.
/// If true, [trueBuilder] is used; otherwise, [falseBuilder] is used.
class ConditionalSlotBuilder extends SlotBuilderType {
  /// The condition to evaluate.
  final bool Function(ActiveLayoutInfo layoutInfo) condition;

  /// The builder to use if the condition is true.
  final SlotBuilderType trueBuilder;

  /// The builder to use if the condition is false.
  final SlotBuilderType falseBuilder;

  /// Creates a [ConditionalSlotBuilder].
  ConditionalSlotBuilder({
    required this.condition,
    required this.trueBuilder,
    required this.falseBuilder,
  });

  @override
  Widget? build(ActiveLayoutInfo layoutInfo) {
    return condition(layoutInfo)
        ? trueBuilder.build(layoutInfo)
        : falseBuilder.build(layoutInfo);
  }
}

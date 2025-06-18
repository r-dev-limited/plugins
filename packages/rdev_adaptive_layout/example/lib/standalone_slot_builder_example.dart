import 'package:flutter/material.dart';
import 'package:rdev_adaptive_layout/active_layout_info.dart';
import 'package:rdev_adaptive_layout/adaptive_breakpoint_definitions.dart';
import 'package:rdev_adaptive_layout/adaptive_platform.dart';
import 'package:rdev_adaptive_layout/device_form_factor.dart';
import 'package:rdev_adaptive_layout/slot_building_rules.dart';

class StandaloneSlotBuilderExample extends StatelessWidget {
  const StandaloneSlotBuilderExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Manually create ActiveLayoutInfo (normally done by AdaptiveLayoutWidget)
    final mediaQuery = MediaQuery.of(context);
    final platform = Theme.of(context).platform;

    // Determine adaptive platform
    final adaptivePlatform = platform == TargetPlatform.android
        ? AdaptivePlatform.ANDROID
        : AdaptivePlatform.IOS;

    // Determine breakpoint (simplified logic)
    final screenWidth = mediaQuery.size.width;
    final activeBreakpointId = screenWidth < 600
        ? BreakpointId.s
        : screenWidth < 1024
            ? BreakpointId.m
            : BreakpointId.l;

    // Determine form factor
    final formFactor = screenWidth < 600
        ? DeviceFormFactor.phone
        : screenWidth < 1000
            ? DeviceFormFactor.tablet
            : DeviceFormFactor.desktop;

    final layoutInfo = ActiveLayoutInfo(
      context: context,
      platform: platform,
      adaptivePlatform: adaptivePlatform,
      orientation: mediaQuery.orientation,
      activeBreakpointId: activeBreakpointId,
      screenSize: mediaQuery.size,
      formFactor: formFactor,
    );

    // Create a DeclarativeSlotBuilder for a custom widget
    final customWidgetBuilder = DeclarativeSlotBuilder(
      configs: [
        LayoutMatchConfig(
          platforms: const {AdaptivePlatform.ANDROID},
          breakpointMatcher: (id) => id.isSmallerThan(BreakpointId.m),
          builder: (layoutInfo) => Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue,
            child: Text(
              'Android Small Screen\nBreakpoint: ${layoutInfo.activeBreakpointId}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        LayoutMatchConfig(
          platforms: const {AdaptivePlatform.IOS},
          builder: (layoutInfo) => Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey,
            child: Text(
              'iOS Layout\nBreakpoint: ${layoutInfo.activeBreakpointId}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
      defaultBuilder: (layoutInfo) => Container(
        padding: const EdgeInsets.all(16),
        color: Colors.green,
        child: Text(
          'Default Layout\nBreakpoint: ${layoutInfo.activeBreakpointId}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );

    // Create a ConditionalSlotBuilder
    final conditionalBuilder = ConditionalSlotBuilder(
      condition: (layoutInfo) =>
          layoutInfo.formFactor == DeviceFormFactor.phone,
      trueBuilder: SimpleSlotBuilder(
          (layoutInfo) => const Icon(Icons.phone_android, size: 48)),
      falseBuilder: SimpleSlotBuilder(
          (layoutInfo) => const Icon(Icons.tablet_mac, size: 48)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Standalone Slot Builders')),
      body: Column(
        children: [
          // Use the declarative slot builder
          customWidgetBuilder.build(layoutInfo) ?? const SizedBox.shrink(),
          const SizedBox(height: 20),
          // Use the conditional slot builder
          conditionalBuilder.build(layoutInfo) ?? const SizedBox.shrink(),
          const SizedBox(height: 20),
          Text(
              'Screen: ${mediaQuery.size.width.toInt()}x${mediaQuery.size.height.toInt()}'),
          Text('Platform: $adaptivePlatform'),
          Text('Breakpoint: $activeBreakpointId'),
          Text('Form Factor: $formFactor'),
        ],
      ),
    );
  }
}

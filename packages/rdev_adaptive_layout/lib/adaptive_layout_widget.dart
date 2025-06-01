import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'adaptive_breakpoint_definitions.dart';
import 'active_layout_info.dart';
import 'layout_slot.dart';
import 'slot_building_rules.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'adaptive_platform.dart';
import 'device_form_factor.dart';

/// A widget that adapts its layout based on screen size, platform, and orientation.
///
/// It uses a system of breakpoints and slots to build responsive UIs.
/// The [AdaptiveLayoutWidget] determines the active breakpoint based on the
/// current screen width and platform, then builds the UI by invoking the
/// appropriate [SlotBuilderType] for each defined [LayoutSlot].
///
/// It supports animations during layout transitions and provides mechanisms
/// for handling platform-specific navigation patterns like Material drawers
/// and Cupertino panes.
class AdaptiveLayoutWidget extends StatefulWidget {
  /// Defines breakpoint configurations for various platforms (e.g., iOS, Android, Web).
  ///
  /// If `null`, [DefaultBreakpoints.defaultConfigs] are used. This allows for
  /// customization of how screen widths map to different layout breakpoints
  /// (e.g., small, medium, large) for each platform.
  final List<PlatformBreakpointConfig>? platformBreakpointConfigs;

  /// A map of slot builders. Keys are [LayoutSlot] enums, and values are
  /// [SlotBuilderType] instances which define how to build a widget for that slot.
  ///
  /// Slots not provided in this map will not be rendered, unless a specific
  /// default is handled internally (e.g., [defaultBody]).
  final Map<LayoutSlot, SlotBuilderType> slotBuilders;

  /// The duration for animations when switching between layouts due to
  /// breakpoint changes (e.g., screen resize, orientation change).
  final Duration animationDuration;

  /// The curve for animations when switching between layouts.
  final Curve animationCurve;

  /// A default widget to display in the [LayoutSlot.body] if no builder for
  /// [LayoutSlot.body] is provided in [slotBuilders].
  final Widget? defaultBody;

  /// Creates an [AdaptiveLayoutWidget].
  ///
  /// Requires [slotBuilders] to define the content for different layout areas.
  const AdaptiveLayoutWidget({
    super.key,
    required this.slotBuilders,
    this.platformBreakpointConfigs,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.defaultBody,
  });

  @override
  State<AdaptiveLayoutWidget> createState() => _AdaptiveLayoutWidgetState();
}

class _AdaptiveLayoutWidgetState extends State<AdaptiveLayoutWidget> {
  /// Stores the layout information from the previous build cycle.
  /// Used to determine if an animation should occur when the layout changes.
  ActiveLayoutInfo? _previousLayoutInfo;

  /// A global key to control the [Scaffold] state, primarily for managing drawers.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // --- State for Cupertino Panes (simulating drawers) ---
  /// Tracks whether the left Cupertino pane is open or closed.
  bool _isCupertinoLeftPaneOpen = false;

  /// Tracks whether the right Cupertino pane is open or closed.
  bool _isCupertinoRightPaneOpen = false;

  // --- Drawer/Pane Control Methods ---
  // These methods provide a unified API for controlling drawers/panes,
  // which are then passed to slot builders via [ActiveLayoutInfo].

  // Material Design Drawer Control
  void _openMaterialLeftDrawer() => _scaffoldKey.currentState?.openDrawer();
  void _closeMaterialLeftDrawer() =>
      Navigator.pop(context); // Assumes drawer is a route, common pattern
  void _toggleMaterialLeftDrawer() {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _closeMaterialLeftDrawer();
    } else {
      _openMaterialLeftDrawer();
    }
  }

  void _openMaterialRightDrawer() => _scaffoldKey.currentState?.openEndDrawer();
  void _closeMaterialRightDrawer() => Navigator.pop(context);
  void _toggleMaterialRightDrawer() {
    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      _closeMaterialRightDrawer();
    } else {
      _openMaterialRightDrawer();
    }
  }

  // Cupertino Pane Control (simulates drawer behavior)
  void _openCupertinoLeftPane() =>
      setState(() => _isCupertinoLeftPaneOpen = true);
  void _closeCupertinoLeftPane() =>
      setState(() => _isCupertinoLeftPaneOpen = false);
  void _toggleCupertinoLeftPane() =>
      setState(() => _isCupertinoLeftPaneOpen = !_isCupertinoLeftPaneOpen);

  void _openCupertinoRightPane() =>
      setState(() => _isCupertinoRightPaneOpen = true);
  void _closeCupertinoRightPane() =>
      setState(() => _isCupertinoRightPaneOpen = false);
  void _toggleCupertinoRightPane() =>
      setState(() => _isCupertinoRightPaneOpen = !_isCupertinoRightPaneOpen);
  // --- End Drawer/Pane Control Methods ---

  /// Builds a widget for a given [LayoutSlot].
  ///
  /// It retrieves the corresponding [SlotBuilderType] from [widget.slotBuilders]
  /// and invokes its `build` method. If no builder is found, it uses the
  /// [defaultWidget] if provided.
  ///
  /// The widget is wrapped in an [AnimatedSwitcher] if the layout conditions
  /// (breakpoint or orientation) have changed since the last build, allowing
  /// for smooth transitions.
  Widget? _buildSlot(
    ActiveLayoutInfo layoutInfo,
    LayoutSlot slot, {
    Widget? defaultWidget,
  }) {
    final slotBuilder = widget.slotBuilders[slot];
    Widget? content;

    if (slotBuilder != null) {
      content = slotBuilder.build(layoutInfo);
    } else if (defaultWidget != null) {
      content = defaultWidget;
    }
    // If no builder and no default, content remains null.

    // Determine if an animation should occur.
    // This happens if the active breakpoint or orientation has changed.
    bool shouldAnimate =
        _previousLayoutInfo != null &&
        (_previousLayoutInfo!.activeBreakpointId !=
                layoutInfo.activeBreakpointId ||
            _previousLayoutInfo!.orientation != layoutInfo.orientation);

    if (shouldAnimate) {
      return AnimatedSwitcher(
        duration: widget.animationDuration,
        switchInCurve: widget.animationCurve,
        switchOutCurve: widget.animationCurve,
        child: KeyedSubtree(
          // Using a ValueKey helps AnimatedSwitcher differentiate between widgets
          // and manage their state correctly during transitions.
          // It includes slot name, breakpoint, orientation, and the content's key (if any)
          // to ensure uniqueness and proper animation behavior.
          key: ValueKey(
            '${slot.name}_${layoutInfo.activeBreakpointId}_${layoutInfo.orientation}_${content?.key}',
          ),
          child:
              content ??
              const SizedBox.shrink(), // Use SizedBox.shrink for null content
        ),
      );
    }
    return content ??
        const SizedBox.shrink(); // Return content directly or SizedBox.shrink
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final targetPlatform = Theme.of(context).platform;
        final orientation = mediaQuery.orientation;
        final screenSize = mediaQuery.size;

        // Determine AdaptivePlatform
        final AdaptivePlatform adaptivePlatform;
        if (kIsWeb) {
          adaptivePlatform = AdaptivePlatform.WEB;
        } else {
          switch (targetPlatform) {
            case TargetPlatform.android:
              adaptivePlatform = AdaptivePlatform.ANDROID;
              break;
            case TargetPlatform.iOS:
              adaptivePlatform = AdaptivePlatform.IOS;
              break;
            case TargetPlatform.macOS:
              adaptivePlatform = AdaptivePlatform.MACOS;
              break;
            case TargetPlatform.windows:
              adaptivePlatform = AdaptivePlatform.WINDOWS;
              break;
            case TargetPlatform.linux:
              adaptivePlatform = AdaptivePlatform.LINUX;
              break;
            case TargetPlatform.fuchsia:
              adaptivePlatform = AdaptivePlatform.FUCHSIA;
              break;
          }
        }

        debugPrint(
          '[AdaptiveLayoutWidget] Screen: ${screenSize.width}w x ${screenSize.height}h, Orientation: $orientation, TargetPlatform: $targetPlatform, AdaptivePlatform: $adaptivePlatform',
        );

        final platformConfigs =
            widget.platformBreakpointConfigs ??
            DefaultBreakpoints.defaultConfigs;
        final platformConfig = DefaultBreakpoints.getConfigForPlatform(
          adaptivePlatform,
          customConfigs: platformConfigs,
        );

        final activeBreakpointId = platformConfig.getActiveBreakpointId(
          screenSize.width,
        );

        // Determine DeviceFormFactor
        final DeviceFormFactor formFactor;
        final double shortestSide = screenSize.shortestSide;
        if (shortestSide < 600) {
          formFactor = DeviceFormFactor.phone;
        } else if (shortestSide < 1000) {
          // Example threshold for tablets
          formFactor = DeviceFormFactor.tablet;
        } else {
          formFactor = DeviceFormFactor.desktop;
        }

        debugPrint(
          '[AdaptiveLayoutWidget] Active Breakpoint ID: $activeBreakpointId, Form Factor: $formFactor',
        );

        final layoutInfo = ActiveLayoutInfo(
          context: context,
          platform: targetPlatform,
          adaptivePlatform: adaptivePlatform,
          orientation: orientation,
          activeBreakpointId: activeBreakpointId,
          screenSize: screenSize,
          formFactor: formFactor,
          // Material Drawer Callbacks
          openLeftDrawer: _openMaterialLeftDrawer,
          closeLeftDrawer: _closeMaterialLeftDrawer,
          toggleLeftDrawer: _toggleMaterialLeftDrawer,
          openRightDrawer: _openMaterialRightDrawer,
          closeRightDrawer: _closeMaterialRightDrawer,
          toggleRightDrawer: _toggleMaterialRightDrawer,
          // Cupertino Pane Callbacks
          openLeftPane: _openCupertinoLeftPane,
          closeLeftPane: _closeCupertinoLeftPane,
          toggleLeftPane: _toggleCupertinoLeftPane,
          openRightPane: _openCupertinoRightPane,
          closeRightPane: _closeCupertinoRightPane,
          toggleRightPane: _toggleCupertinoRightPane,
        );

        // --- Direct Content Retrieval for Scaffold/CupertinoPageScaffold Properties ---
        // Retrieve content for slots that are direct properties of Scaffold
        // (like appBar, drawer) without AnimatedSwitcher to avoid type mismatches
        // and ensure compatibility (e.g., Scaffold.appBar expects PreferredSizeWidget).

        Widget? appBarDirectContent;
        final appBarSlotBuilderInstance =
            widget.slotBuilders[LayoutSlot.appBar];
        if (appBarSlotBuilderInstance != null) {
          appBarDirectContent = appBarSlotBuilderInstance.build(layoutInfo);
        }

        Widget? sliverAppBarDirectContent;
        final sliverAppBarSlotBuilderInstance =
            widget.slotBuilders[LayoutSlot.sliverAppBar];
        if (sliverAppBarSlotBuilderInstance != null) {
          sliverAppBarDirectContent = sliverAppBarSlotBuilderInstance.build(
            layoutInfo,
          );
        }

        Widget? leftDrawerDirectContent;
        final leftDrawerSlotBuilderInstance =
            widget.slotBuilders[LayoutSlot.leftDrawer];
        if (leftDrawerSlotBuilderInstance != null) {
          leftDrawerDirectContent = leftDrawerSlotBuilderInstance.build(
            layoutInfo,
          );
        }

        Widget? rightDrawerDirectContent;
        final rightDrawerSlotBuilderInstance =
            widget.slotBuilders[LayoutSlot.rightDrawer];
        if (rightDrawerSlotBuilderInstance != null) {
          rightDrawerDirectContent = rightDrawerSlotBuilderInstance.build(
            layoutInfo,
          );
        }

        // --- Check for Actual Content in Dynamic Slots ---
        // Determine if certain slots (drawers, secondary navigation) have "actual"
        // content, meaning they are not null and not just an empty SizedBox.
        // This helps in deciding whether to render their containers (e.g., a Row for secondary nav).
        final rawLeftDrawerContent = widget.slotBuilders[LayoutSlot.leftDrawer]
            ?.build(layoutInfo);
        final rawRightDrawerContent = widget
            .slotBuilders[LayoutSlot.rightDrawer]
            ?.build(layoutInfo);
        final rawSecondaryNavContent = widget
            .slotBuilders[LayoutSlot.secondaryNavigation]
            ?.build(layoutInfo);

        // Helper to check if a widget is non-null and not an empty SizedBox.
        bool isWidgetPresent(Widget? widget) =>
            widget != null &&
            !(widget is SizedBox && widget.width == 0 && widget.height == 0);

        bool hasActualLeftContent = isWidgetPresent(rawLeftDrawerContent);
        bool hasActualRightContent = isWidgetPresent(rawRightDrawerContent);
        bool hasActualSecondaryNav = isWidgetPresent(rawSecondaryNavContent);

        // Store current layout info for the next build cycle to detect changes.
        _previousLayoutInfo = layoutInfo;

        // --- Build Core and Auxiliary Slots using _buildSlot (with animation) ---
        Widget? bodyContent = _buildSlot(
          layoutInfo,
          LayoutSlot.body,
          defaultWidget: widget.defaultBody ?? const SizedBox.shrink(),
        );
        final leftDrawerContent = _buildSlot(layoutInfo, LayoutSlot.leftDrawer);
        final rightDrawerContent = _buildSlot(
          layoutInfo,
          LayoutSlot.rightDrawer,
        );
        final secondaryNav = _buildSlot(
          layoutInfo,
          LayoutSlot.secondaryNavigation,
        );
        final bottomNav = _buildSlot(
          layoutInfo,
          LayoutSlot.bottomNavigationBar,
        );
        final fab = _buildSlot(layoutInfo, LayoutSlot.floatingActionButton);
        final persistentFooter = _buildSlot(
          layoutInfo,
          LayoutSlot.persistentFooter,
        );
        final overlayContent = _buildSlot(layoutInfo, LayoutSlot.overlay);
        final footerContent = _buildSlot(layoutInfo, LayoutSlot.footer);

        // --- AppBar and Body Configuration ---
        PreferredSizeWidget? finalAppBar;
        Widget? finalBody =
            bodyContent; // Initialize finalBody with potentially animated bodyContent

        if (sliverAppBarDirectContent != null) {
          // If a SliverAppBar is provided, wrap the body in a NestedScrollView.
          finalBody = NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    // sliverAppBarDirectContent is already checked for nullity.
                    sliverAppBarDirectContent!, // Use ! to assert non-null
                  ];
                },
            body: bodyContent ?? const SizedBox.shrink(),
          );
          finalAppBar =
              null; // A regular AppBar is not used with NestedScrollView.
        } else if (appBarDirectContent is PreferredSizeWidget) {
          // If a regular AppBar is provided, use it.
          finalAppBar = appBarDirectContent;
          // finalBody remains the (potentially animated) bodyContent.
        } else {
          // No AppBar provided or it's not a PreferredSizeWidget.
          finalAppBar = null;
          // finalBody remains the (potentially animated) bodyContent.
        }

        // --- Platform-Specific Scaffold Construction ---
        if (adaptivePlatform == AdaptivePlatform.IOS ||
            (adaptivePlatform == AdaptivePlatform.MACOS && !kIsWeb)) {
          // Use Cupertino scaffold for native iOS or native macOS (not web on macOS)
          Widget? cupertinoBodyContent = finalBody;

          // If secondary navigation has actual content, arrange it in a Row with the main body.
          // This modification of cupertinoBodyContent happens BEFORE persistent pane logic.
          if (hasActualSecondaryNav && secondaryNav != null) {
            cupertinoBodyContent = Row(
              children: [
                Expanded(
                  flex: 1, // Typically smaller flex for navigation
                  child:
                      secondaryNav, // This is the animated version from _buildSlot
                ),
                Expanded(
                  flex: 3, // Larger flex for main content
                  child:
                      finalBody ??
                      const SizedBox.shrink(), // Use original finalBody for detail
                ),
              ],
            );
          }

          // Determine if iOS panes should be persistent
          bool isPersistentIOSLeftPane = false;
          final leftDrawerSlotBuilder =
              widget.slotBuilders[LayoutSlot.leftDrawer];
          if (adaptivePlatform == AdaptivePlatform.IOS &&
              leftDrawerDirectContent != null &&
              leftDrawerSlotBuilder is DeclarativeSlotBuilder) {
            final matchedConfig = leftDrawerSlotBuilder.getMatchedConfig(
              layoutInfo,
            );
            if (matchedConfig != null && matchedConfig.isPersistent) {
              isPersistentIOSLeftPane = true;
            }
          }

          bool isPersistentIOSRightPane = false;
          final rightDrawerSlotBuilder =
              widget.slotBuilders[LayoutSlot.rightDrawer];
          if (adaptivePlatform == AdaptivePlatform.IOS &&
              rightDrawerDirectContent != null &&
              rightDrawerSlotBuilder is DeclarativeSlotBuilder) {
            final matchedConfig = rightDrawerSlotBuilder.getMatchedConfig(
              layoutInfo,
            );
            if (matchedConfig != null && matchedConfig.isPersistent) {
              isPersistentIOSRightPane = true;
            }
          }

          // This is the content that will be flanked by persistent panes or fill the body
          Widget? bodyCenterContent = cupertinoBodyContent;

          if (isPersistentIOSLeftPane && isPersistentIOSRightPane) {
            cupertinoBodyContent = Row(
              children: [
                SizedBox(width: 200, child: leftDrawerDirectContent!),
                Expanded(child: bodyCenterContent ?? const SizedBox.shrink()),
                SizedBox(width: 200, child: rightDrawerDirectContent!),
              ],
            );
          } else if (isPersistentIOSLeftPane) {
            cupertinoBodyContent = Row(
              children: [
                SizedBox(width: 200, child: leftDrawerDirectContent!),
                Expanded(child: bodyCenterContent ?? const SizedBox.shrink()),
              ],
            );
          } else if (isPersistentIOSRightPane) {
            cupertinoBodyContent = Row(
              children: [
                Expanded(child: bodyCenterContent ?? const SizedBox.shrink()),
                SizedBox(width: 200, child: rightDrawerDirectContent!),
              ],
            );
          }
          // cupertinoBodyContent now incorporates persistent side panes if applicable.

          Widget pageScaffoldChild;
          // Start with the main body content (which might now include persistent panes)
          Widget mainContentArea =
              cupertinoBodyContent ?? const SizedBox.shrink();

          // Prepare a list of widgets for the final Column, ordered from top to bottom.
          List<Widget> columnChildren = [];

          // Add Expanded main content area
          columnChildren.add(Expanded(child: mainContentArea));

          // Add footer if present
          if (footerContent != null && footerContent is! SizedBox) {
            columnChildren.add(footerContent);
          }

          // Add bottom navigation if present
          if (bottomNav != null) {
            columnChildren.add(bottomNav);
          }

          // If there's only the expanded main content (no footer, no bottomNav),
          // then pageScaffoldChild is just the mainContentArea.
          // Otherwise, it's a Column of the assembled children.
          if (columnChildren.length == 1) {
            // Only Expanded(mainContentArea)
            pageScaffoldChild = mainContentArea;
          } else {
            pageScaffoldChild = Column(children: columnChildren);
          }

          final double paneWidth = 250.0; // Standard width for slide-out panes.

          return CupertinoPageScaffold(
            // The navigationBar expects an ObstructingPreferredSizeWidget.
            // If finalAppBar is a regular PreferredSizeWidget, it might not behave
            // correctly with translucency. Here, we cast if it's already of the correct type.
            navigationBar: finalAppBar is ObstructingPreferredSizeWidget
                ? finalAppBar
                : null,
            child: Stack(
              children: [
                // Wrap the main content area with Material to support Material widgets
                // like ListTile when running in a Cupertino context (e.g., web on macOS).
                Material(
                  type: MaterialType
                      .transparency, // Allows content to define its own background
                  child: pageScaffoldChild,
                ),
                // Backdrop for dismissing MODAL panes
                if ((_isCupertinoLeftPaneOpen && !isPersistentIOSLeftPane) ||
                    (_isCupertinoRightPaneOpen && !isPersistentIOSRightPane))
                  GestureDetector(
                    onTap: () {
                      if (_isCupertinoLeftPaneOpen &&
                          !isPersistentIOSLeftPane) {
                        _closeCupertinoLeftPane();
                      }
                      if (_isCupertinoRightPaneOpen &&
                          !isPersistentIOSRightPane) {
                        _closeCupertinoRightPane();
                      }
                    },
                    child: Container(color: Colors.black.withOpacity(0.3)),
                  ),
                // Left Cupertino Pane (MODAL/overlay drawer)
                // Show only if it's actual content, not null, and NOT a persistent pane
                if (hasActualLeftContent &&
                    leftDrawerContent != null &&
                    !isPersistentIOSLeftPane)
                  _buildCupertinoPane(
                    isOpen: _isCupertinoLeftPaneOpen,
                    width: paneWidth,
                    alignment: Alignment.centerLeft,
                    context: context,
                    child:
                        leftDrawerContent, // Animated content from _buildSlot
                  ),
                // Right Cupertino Pane (MODAL/overlay drawer)
                // Show only if it's actual content, not null, and NOT a persistent pane
                if (hasActualRightContent &&
                    rightDrawerContent != null &&
                    !isPersistentIOSRightPane)
                  _buildCupertinoPane(
                    isOpen: _isCupertinoRightPaneOpen,
                    width: paneWidth,
                    alignment: Alignment.centerRight,
                    context: context,
                    child:
                        rightDrawerContent, // Animated content from _buildSlot
                  ),
                // General overlay slot, rendered on top
                // Wrap overlayContent as well if it might contain Material widgets.
                if (overlayContent != null)
                  Material(
                    type: MaterialType.transparency,
                    child: overlayContent, // Animated content
                  ),
              ],
            ),
          );
        } else {
          // --- Material Layout (Android, Fuchsia, Linux, Windows, Web) ---
          List<Widget>? finalPersistentFooterButtons;
          if (persistentFooter is Column || persistentFooter is Row) {
            finalPersistentFooterButtons = (persistentFooter as dynamic)
                .children
                .cast<Widget>();
          } else if (persistentFooter != null &&
              persistentFooter is! SizedBox) {
            finalPersistentFooterButtons = <Widget>[persistentFooter];
          } else {
            finalPersistentFooterButtons = null;
          }

          Widget finalMaterialBody = finalBody ?? const SizedBox.shrink();

          // Check for persistent left panel
          Widget? persistentLeftPanelWidget;
          bool isLeftPanelPersistent = false;
          if (leftDrawerDirectContent != null &&
              leftDrawerDirectContent is! Drawer && // Key check: not a Drawer
              layoutInfo.adaptivePlatform == AdaptivePlatform.WEB &&
              layoutInfo.activeBreakpointId.isLargerThan(BreakpointId.l)) {
            isLeftPanelPersistent = true;
            persistentLeftPanelWidget = leftDrawerDirectContent;
          }

          // Check for persistent right panel
          Widget? persistentRightPanelWidget;
          bool isRightPanelPersistent = false;
          if (rightDrawerDirectContent != null &&
              rightDrawerDirectContent is! Drawer && // Key check: not a Drawer
              layoutInfo.adaptivePlatform == AdaptivePlatform.WEB &&
              layoutInfo.activeBreakpointId.isLargerThan(BreakpointId.l)) {
            isRightPanelPersistent = true;
            persistentRightPanelWidget = rightDrawerDirectContent;
          }

          // Integrate persistent panels into the body
          if (isLeftPanelPersistent && persistentLeftPanelWidget != null) {
            finalMaterialBody = Row(
              children: [
                persistentLeftPanelWidget,
                Expanded(child: finalMaterialBody),
              ],
            );
          }
          if (isRightPanelPersistent && persistentRightPanelWidget != null) {
            finalMaterialBody = Row(
              children: [
                Expanded(child: finalMaterialBody),
                persistentRightPanelWidget,
              ],
            );
          }

          // Integrate footer if not using sliver app bar and persistent panels don't complicate it excessively
          // (This footer logic might need refinement if persistent panels are also full height)
          if (sliverAppBarDirectContent == null &&
              footerContent != null &&
              footerContent is! SizedBox) {
            // If persistent panels are present, the footer should ideally be part of the main content area
            // or handled more globally. For now, let's assume it's part of the central column.
            if (isLeftPanelPersistent || isRightPanelPersistent) {
              // If there are persistent side panels, the main content (which now includes the original body)
              // should be wrapped in a Column with its footer.
              // This requires finalMaterialBody (which could be a Row with panels) to be structured correctly.
              // Let's adjust: the Expanded part of the Row should be a Column with the footer.

              if (isLeftPanelPersistent && !isRightPanelPersistent) {
                finalMaterialBody = Row(
                  children: [
                    persistentLeftPanelWidget!,
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(child: finalBody ?? const SizedBox.shrink()),
                          footerContent,
                        ],
                      ),
                    ),
                  ],
                );
              } else if (!isLeftPanelPersistent && isRightPanelPersistent) {
                finalMaterialBody = Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(child: finalBody ?? const SizedBox.shrink()),
                          footerContent,
                        ],
                      ),
                    ),
                    persistentRightPanelWidget!,
                  ],
                );
              } else if (isLeftPanelPersistent && isRightPanelPersistent) {
                finalMaterialBody = Row(
                  children: [
                    persistentLeftPanelWidget!,
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(child: finalBody ?? const SizedBox.shrink()),
                          footerContent,
                        ],
                      ),
                    ),
                    persistentRightPanelWidget!,
                  ],
                );
              } else {
                // Should not happen if we are in this block
                finalMaterialBody = Column(
                  children: [
                    Expanded(child: finalBody ?? const SizedBox.shrink()),
                    footerContent,
                  ],
                );
              }
            } else {
              finalMaterialBody = Column(
                children: [
                  Expanded(child: finalBody ?? const SizedBox.shrink()),
                  footerContent,
                ],
              );
            }
          }

          return Scaffold(
            key: _scaffoldKey,
            appBar: finalAppBar,
            body: finalMaterialBody,
            drawer:
                isLeftPanelPersistent // If panel is persistent, no standard drawer
                ? null
                : (leftDrawerDirectContent != null
                      ? Drawer(child: leftDrawerDirectContent)
                      : null),
            endDrawer:
                isRightPanelPersistent // If panel is persistent, no standard end drawer
                ? null
                : (rightDrawerDirectContent != null
                      ? Drawer(child: rightDrawerDirectContent)
                      : null),
            bottomNavigationBar: bottomNav,
            floatingActionButton: fab,
            persistentFooterButtons: finalPersistentFooterButtons,
          );
        }
      },
    );
  }

  /// Helper method to build an animated slide-in pane for Cupertino layouts.
  ///
  /// This simulates a drawer-like behavior common in iOS applications.
  /// The pane slides in from the left or right edge of the screen.
  ///
  /// [isOpen]: Controls whether the pane is visible or hidden.
  /// [width]: The width of the pane when open.
  /// [alignment]: Determines if the pane slides from the left or right.
  /// [child]: The content of the pane.
  /// [context]: The build context, used to get media query data (padding).
  /// [appBarHeight]: The height of the app bar, used to offset the pane vertically.
  ///                 Defaults to [kMinInteractiveDimensionCupertino].
  Widget _buildCupertinoPane({
    required bool isOpen,
    required double width,
    required Alignment alignment,
    required Widget child,
    required BuildContext context,
    // Default value for typical Cupertino AppBar height.
    // This ensures the pane appears below the status bar and navigation bar.
    double appBarHeight = kMinInteractiveDimensionCupertino,
  }) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    // The pane should appear below the status bar and any visible app bar.
    final double topOffset =
        statusBarHeight +
        (ModalRoute.of(context)?.barrierDismissible == true
            ? appBarHeight
            : 0); // Only add app bar height if not in a modal route fullscreen

    double xPosition;
    if (alignment == Alignment.centerLeft) {
      // For a left-aligned pane:
      // - When open (isOpen = true), xPosition = 0 (aligned with the left edge).
      // - When closed (isOpen = false), xPosition = -width (off-screen to the left).
      xPosition = isOpen ? 0 : -width;
    } else {
      // For a right-aligned pane (Alignment.centerRight):
      // - When open (isOpen = true), xPosition = 0 (aligned with the right edge,
      //   because AnimatedPositioned's 'right' property will be set to this).
      // - When closed (isOpen = false), xPosition = -width (off-screen to the right,
      //   effectively making 'right' be -width, pushing it out).
      xPosition = isOpen ? 0 : -width;
    }

    return AnimatedPositioned(
      duration: widget.animationDuration,
      curve: widget.animationCurve,
      top: topOffset,
      bottom: 0,
      // Conditionally set 'left' or 'right' based on alignment.
      // If 'left' is set, 'right' should be null, and vice-versa.
      left: alignment == Alignment.centerLeft ? xPosition : null,
      right: alignment == Alignment.centerRight ? xPosition : null,
      width: width,
      // Material widget adds elevation (shadow) to the pane for better visual separation.
      child: Material(elevation: 8.0, child: child),
    );
  }
}

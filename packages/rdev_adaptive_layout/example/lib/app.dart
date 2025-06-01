import 'package:example/adaptive_list_view.dart';
import 'package:example/adaptive_profile_view.dart';
import 'package:example/detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rdev_adaptive_layout/adaptive_layout_widget.dart';
import 'package:rdev_adaptive_layout/device_form_factor.dart';
import 'package:rdev_adaptive_layout/layout_slot.dart';
import 'package:rdev_adaptive_layout/slot_building_rules.dart';
import 'package:rdev_adaptive_layout/adaptive_breakpoint_definitions.dart';
import 'package:rdev_adaptive_layout/adaptive_platform.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cupertinoTheme = CupertinoTheme.of(context);

    final Map<LayoutSlot, SlotBuilderType> slotBuilders = {};

    slotBuilders.addAll({
      LayoutSlot.body: DeclarativeSlotBuilder(
        configs: [
          /// Android Body
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.ANDROID},
            builder: (layoutInfo) => _selectedIndex == 0
                ? AdaptiveListView(layoutInfo: layoutInfo)
                : AdaptiveProfileView(layoutInfo: layoutInfo),
          ),

          /// iOS Body
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.IOS},
            builder: (layoutInfo) => _selectedIndex == 0
                ? AdaptiveListView(layoutInfo: layoutInfo)
                : AdaptiveProfileView(layoutInfo: layoutInfo),
          ),

          /// Web Body
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.WEB},
            builder: (layoutInfo) => _selectedIndex == 0
                ? AdaptiveListView(layoutInfo: layoutInfo)
                : AdaptiveProfileView(layoutInfo: layoutInfo),
          ),
        ],
        defaultBuilder: (layoutInfo) =>
            AdaptiveListView(layoutInfo: layoutInfo),
      ),
      LayoutSlot.appBar: DeclarativeSlotBuilder(
        configs: [
          /// Web AppBar
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.WEB},
            builder: (layoutInfo) {
              // Determine if the left drawer is in standard (non-persistent) mode
              final bool showDrawerButton =
                  layoutInfo.activeBreakpointId.isSmallerOrEqualTo(
                    BreakpointId.l,
                  ) &&
                  layoutInfo.activeBreakpointId.isLargerThan(BreakpointId.s);

              return PreferredSize(
                preferredSize: const Size.fromHeight(60.0), // Custom height
                child: Container(
                  color: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      if (showDrawerButton) // Conditionally show hamburger icon
                        IconButton(
                          icon: Icon(Icons.menu, color: colorScheme.onPrimary),
                          onPressed: layoutInfo.toggleLeftDrawer,
                        ),
                      Icon(
                        Icons.webhook,
                        color: colorScheme.onPrimary,
                      ), // Example Icon
                      const SizedBox(width: 10),
                      Text(
                        'Web App Bar (${layoutInfo.activeBreakpointId})',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 20,
                        ),
                      ),
                      const Spacer(), // Pushes a logout button to the right
                      TextButton.icon(
                        icon: Icon(Icons.logout, color: colorScheme.onPrimary),
                        label: Text(
                          'Logout',
                          style: TextStyle(color: colorScheme.onPrimary),
                        ),
                        onPressed: () {
                          // Handle logout
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          /// Android AppBar
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.ANDROID},
            builder: (layoutInfo) => AppBar(
              key: ValueKey(
                'material_appbar_${layoutInfo.activeBreakpointId}_${layoutInfo.orientation}',
              ),
              title: Text('AppBar (Android): ${layoutInfo.activeBreakpointId}'),
            ),
          ),

          /// iOS AppBar
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.IOS},
            builder: (layoutInfo) {
              // Determine if the hamburger icon for the Cupertino right pane should be shown
              final rightDrawerBuilder =
                  slotBuilders[LayoutSlot.rightDrawer]
                      as DeclarativeSlotBuilder?;
              final bool showHamburger =
                  rightDrawerBuilder?.build(layoutInfo) != null;

              return CupertinoNavigationBar(
                key: ValueKey(
                  'cupertino_appbar_${layoutInfo.activeBreakpointId}_${layoutInfo.orientation}',
                ),
                middle: Text('AppBar (iOS): ${layoutInfo.activeBreakpointId}'),
                trailing: showHamburger
                    ? CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: layoutInfo.toggleRightPane,
                        child: const Icon(
                          CupertinoIcons.bars,
                        ), // Use callback from layoutInfo
                      )
                    : null,
              );
            },
          ),
        ],
        defaultBuilder: (layoutInfo) => null,
      ),
      LayoutSlot.leftDrawer: DeclarativeSlotBuilder(
        configs: [
          /// Web Left Navigation Panel (shows if breakpoint > L, as persistent panel)
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.WEB},
            breakpointMatcher: (activeId) =>
                activeId.isLargerThan(BreakpointId.l),
            builder: (layoutInfo) => Container(
              // This is the content for the persistent panel
              width: 200,
              color: colorScheme.surface,
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.explore),
                    title: const Text('Explore'),
                    selected: _selectedIndex == 0,
                    selectedTileColor: colorScheme.primaryContainer,
                    selectedColor: colorScheme.onPrimaryContainer,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                      // Optionally close drawer if it's not persistent
                      if (layoutInfo.activeBreakpointId.isSmallerOrEqualTo(
                        BreakpointId.l,
                      )) {
                        layoutInfo.closeLeftDrawer?.call();
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profile'),
                    selected: _selectedIndex == 1,
                    selectedTileColor: colorScheme.primaryContainer,
                    selectedColor: colorScheme.onPrimaryContainer,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                      // Optionally close drawer if it's not persistent
                      if (layoutInfo.activeBreakpointId.isSmallerOrEqualTo(
                        BreakpointId.l,
                      )) {
                        layoutInfo.closeLeftDrawer?.call();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          /// Web Left Drawer (shows if breakpoint <= L, as standard Drawer)
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.WEB},
            breakpointMatcher: (activeId) =>
                activeId.isSmallerOrEqualTo(BreakpointId.l),
            builder: (layoutInfo) => Drawer(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.explore, color: colorScheme.onPrimary),
                    title: Text(
                      'Explore',
                      style: TextStyle(color: colorScheme.onPrimary),
                    ),
                    selected: _selectedIndex == 0,
                    tileColor: colorScheme.primary,
                    selectedTileColor: colorScheme.primaryContainer,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                      layoutInfo.closeLeftDrawer
                          ?.call(); // Close drawer after selection
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.person, color: colorScheme.onPrimary),
                    title: Text(
                      'Profile',
                      style: TextStyle(color: colorScheme.onPrimary),
                    ),
                    selected: _selectedIndex == 1,
                    tileColor: colorScheme.primary,
                    selectedTileColor: colorScheme.primaryContainer,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                      layoutInfo.closeLeftDrawer
                          ?.call(); // Close drawer after selection
                    },
                  ),
                ],
              ),
            ),
          ),

          /// Android Left Drawer/Rail Content (<= L)
          LayoutMatchConfig(
            breakpointMatcher: (activeId) => activeId.isLargerOrEqualTo(
              BreakpointId.m,
            ), // Show as Drawer for smaller Android screens
            platforms: const {AdaptivePlatform.ANDROID},
            builder: (layoutInfo) => SizedBox(
              width: 250, // Constrain the width of the ListView
              child: ListView(
                // Content for Drawer
                children: [
                  ListTile(
                    leading: const Icon(Icons.explore),
                    title: const Text('Explore'),
                    selected: _selectedIndex == 0,
                    selectedTileColor: colorScheme.primaryContainer,
                    selectedColor: colorScheme.onPrimaryContainer,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                      layoutInfo.closeLeftDrawer
                          ?.call(); // Close drawer after selection
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profile'),
                    selected: _selectedIndex == 1,
                    selectedTileColor: colorScheme.primaryContainer,
                    selectedColor: colorScheme.onPrimaryContainer,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                      layoutInfo.closeLeftDrawer
                          ?.call(); // Close drawer after selection
                    },
                  ),
                ],
              ),
            ),
          ),

          /// iOS Left Persistent Pane (iPad)
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.IOS},
            breakpointMatcher: (activeId) =>
                activeId.isLargerThan(BreakpointId.s),
            formFactorMatcher: (formFactor) =>
                formFactor == DeviceFormFactor.tablet ||
                formFactor == DeviceFormFactor.desktop,
            isPersistent: true,
            builder: (layoutInfo) => Container(
              // This is the content for the persistent panel
              width: 200,
              color: cupertinoTheme.barBackgroundColor,
              child: ListView(
                children: [
                  CupertinoListTile(
                    leading: const Icon(
                      CupertinoIcons.search,
                    ), // Using search icon for Explore
                    title: const Text('Explore'),
                    backgroundColor: _selectedIndex == 0
                        ? cupertinoTheme.primaryColor.withOpacity(0.1)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                      // If this pane can be closed (e.g., it's an overlay drawer on some breakpoints)
                      // you might call layoutInfo.closeRightPane?.call();
                    },
                  ),
                  CupertinoListTile(
                    leading: const Icon(
                      CupertinoIcons.person,
                    ), // Using person icon for Profile
                    title: const Text('Profile'),
                    backgroundColor: _selectedIndex == 1
                        ? cupertinoTheme.primaryColor.withOpacity(0.1)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                      // If this pane can be closed, you might call layoutInfo.closeRightPane?.call();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
        defaultBuilder: (layoutInfo) => null,
      ),
      LayoutSlot.rightDrawer: DeclarativeSlotBuilder(
        configs: [
          // iOS Right Pane Content (replaces the old overlay logic)
          LayoutMatchConfig(
            breakpointMatcher: (activeId) =>
                activeId.isLargerThan(BreakpointId.s) &&
                activeId.isSmallerThan(BreakpointId.l),
            platforms: const {AdaptivePlatform.IOS},
            formFactorMatcher: (formFactor) =>
                formFactor == DeviceFormFactor.phone,
            builder: (layoutInfo) => Container(
              color: cupertinoTheme.barBackgroundColor,
              child: ListView(
                children: [
                  CupertinoListTile(
                    leading: const Icon(
                      CupertinoIcons.search,
                    ), // Using search icon for Explore
                    title: const Text('Explore'),
                    backgroundColor: _selectedIndex == 0
                        ? cupertinoTheme.primaryColor.withOpacity(0.1)
                        : null,
                    onTap: () {
                      bool indexChanged = _selectedIndex != 0;
                      if (indexChanged) {
                        setState(() {
                          _selectedIndex = 0;
                        });
                      }
                      layoutInfo.closeRightPane?.call();
                    },
                  ),
                  CupertinoListTile(
                    leading: const Icon(
                      CupertinoIcons.person,
                    ), // Using person icon for Profile
                    title: const Text('Profile'),
                    backgroundColor: _selectedIndex == 1
                        ? cupertinoTheme.primaryColor.withOpacity(0.1)
                        : null,
                    onTap: () {
                      bool indexChanged = _selectedIndex != 1;
                      if (indexChanged) {
                        setState(() {
                          _selectedIndex = 1;
                        });
                      }
                      layoutInfo.closeRightPane?.call();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
        defaultBuilder: (layoutInfo) => null,
      ),
      LayoutSlot.bottomNavigationBar: DeclarativeSlotBuilder(
        configs: [
          /// Web Bottom Navigation Bar (small screens)
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.WEB},
            breakpointMatcher: (activeId) =>
                activeId.isSmallerOrEqualTo(BreakpointId.s),
            builder: (layoutInfo) => BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),

          /// Android Bottom Navigation Bar (small screens)
          LayoutMatchConfig(
            breakpointMatcher: (activeId) =>
                activeId.isSmallerOrEqualTo(BreakpointId.s),
            platforms: const {AdaptivePlatform.ANDROID},
            builder: (layoutInfo) => NavigationBar(
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.explore),
                  label: 'Explore',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            ),
          ),

          /// iOS Bottom Navigation Bar (small screens)
          LayoutMatchConfig(
            breakpointMatcher: (activeId) =>
                activeId.isSmallerOrEqualTo(BreakpointId.s),
            platforms: const {AdaptivePlatform.IOS},
            builder: (layoutInfo) => CupertinoTabBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ],

        /// Web and other conditions should NOT have a bottom navigation bar
        defaultBuilder: (layoutInfo) => null,
      ),
      LayoutSlot.floatingActionButton: DeclarativeSlotBuilder(
        configs: [
          /// Android Floating Action Button (small screens)
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.ANDROID},
            builder: (layoutInfo) => FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetailPage()),
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
        defaultBuilder: (layoutInfo) => null,
      ),
      LayoutSlot.sliverAppBar: DeclarativeSlotBuilder(
        configs: [
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.IOS},
            builder: (layoutInfo) {
              // Determine if the hamburger icon for the Cupertino right pane should be shown
              final rightDrawerBuilder =
                  slotBuilders[LayoutSlot.rightDrawer]
                      as DeclarativeSlotBuilder?;
              final bool showHamburger =
                  rightDrawerBuilder?.build(layoutInfo) != null;

              return CupertinoSliverNavigationBar(
                key: ValueKey(
                  'cupertino_sliver_appbar_${layoutInfo.activeBreakpointId}_${layoutInfo.orientation}',
                ),
                largeTitle: Text(
                  'Sliver AppBar (iOS): ${layoutInfo.activeBreakpointId}',
                ),
                trailing: showHamburger
                    ? CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: layoutInfo.toggleRightPane,
                        child: const Icon(CupertinoIcons.bars),
                      )
                    : null,
              );
            },
          ),
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.ANDROID},
            builder: (layoutInfo) {
              // Example: Show a drawer icon if a left drawer is present
              final leftDrawerBuilder =
                  slotBuilders[LayoutSlot.leftDrawer]
                      as DeclarativeSlotBuilder?;
              final bool hasLeftDrawer =
                  leftDrawerBuilder?.build(layoutInfo) != null;

              return SliverAppBar(
                key: ValueKey(
                  'material_sliver_appbar_${layoutInfo.activeBreakpointId}_${layoutInfo.orientation}',
                ),
                expandedHeight: 150.0, // Height when fully expanded
                floating:
                    false, // Keep false for a more standard large title collapse
                pinned: true, // Essential to keep the collapsed bar visible
                snap: false, // Keep false with floating: false
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true, // iOS-like centered title when collapsed
                  titlePadding: const EdgeInsetsDirectional.only(
                    bottom: 16.0,
                  ), // Adjust padding
                  title: Text(
                    'Sliver (Android): ${layoutInfo.activeBreakpointId}',
                    style: const TextStyle(
                      fontSize: 16.0,
                    ), // Smaller font for collapsed title
                  ),
                  background: Padding(
                    padding: const EdgeInsets.only(
                      top: kToolbarHeight + 20,
                    ), // approximate padding to clear status bar and toolbar
                    child: Center(
                      child: Text(
                        'Large Title (Android): ${layoutInfo.activeBreakpointId}',
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ), // Content for the expanded part
                ),
                leading:
                    hasLeftDrawer &&
                        layoutInfo.activeBreakpointId.isSmallerOrEqualTo(
                          BreakpointId.s,
                        )
                    ? IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed:
                            layoutInfo.toggleLeftDrawer, // Or openLeftDrawer
                      )
                    : null,
                // You can add actions or other properties here as needed
              );
            },
          ),
        ],
        defaultBuilder: (layoutInfo) => null,
      ),
    });

    // Add footer for web
    slotBuilders[LayoutSlot.footer] = DeclarativeSlotBuilder(
      configs: [
        LayoutMatchConfig(
          platforms: const {AdaptivePlatform.WEB},
          breakpointMatcher: (activeId) =>
              activeId.isLargerThan(BreakpointId.s),
          builder: (layoutInfo) => Container(
            height: 60,
            color: colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                '© 2024 Rdev Adaptive Layout - Web Footer Example (${layoutInfo.activeBreakpointId})',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        ),
      ],
      defaultBuilder: (layoutInfo) =>
          null, // No footer for other platforms by default
    );

    return AdaptiveLayoutWidget(slotBuilders: slotBuilders);
  }
}

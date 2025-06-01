import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rdev_adaptive_layout/adaptive_platform.dart';
import 'package:rdev_adaptive_layout/device_form_factor.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import 'package:rdev_adaptive_layout/adaptive_layout_widget.dart';
import 'package:rdev_adaptive_layout/layout_slot.dart';
import 'package:rdev_adaptive_layout/slot_building_rules.dart';
import 'package:rdev_adaptive_layout/adaptive_breakpoint_definitions.dart';

@UseCase(name: 'Basic Layout', type: AdaptiveLayoutWidget)
Widget adaptiveLayoutUseCase(BuildContext context) {
  final Map<LayoutSlot, SlotBuilderType> slotBuilders = {};

  slotBuilders.addAll({
    LayoutSlot.body: DeclarativeSlotBuilder(
      configs: [
        LayoutMatchConfig(
          platforms: const {AdaptivePlatform.ANDROID},
          builder: (layoutInfo) => ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) => ListTile(
              leading: const Icon(Icons.android),
              title: Text('Android Item ${index + 1}'),
              subtitle: Text('Breakpoint: ${layoutInfo.activeBreakpointId}'),
            ),
          ),
        ),
        LayoutMatchConfig(
          platforms: const {AdaptivePlatform.IOS},
          builder: (layoutInfo) => ListView(
            children: [
              CupertinoListSection.insetGrouped(
                header: Text(
                  'iOS Section - BP: ${layoutInfo.activeBreakpointId}',
                ),
                children: List.generate(
                  20,
                  (index) => CupertinoListTile(
                    leading: const Icon(CupertinoIcons.profile_circled),
                    title: Text('iOS Item ${index + 1}'),
                    subtitle: const Text('Tap to view'),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => CupertinoPageScaffold(
                            navigationBar: CupertinoNavigationBar(
                              middle: Text(
                                'iOS Section - BP: ${layoutInfo.activeBreakpointId}',
                              ),
                            ),
                            child: CupertinoListSection.insetGrouped(
                              header: Text(
                                'iOS Section - BP: ${layoutInfo.activeBreakpointId}',
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      defaultBuilder: (layoutInfo) => Center(
        child: Text(
          'Body (Default): ${layoutInfo.activeBreakpointId}\n${layoutInfo.orientation}\n${layoutInfo.screenSize}',
        ),
      ),
    ),
    LayoutSlot.appBar: DeclarativeSlotBuilder(
      configs: [
        LayoutMatchConfig(
          platforms: const {AdaptivePlatform.ANDROID},
          builder: (layoutInfo) => AppBar(
            title: Text('AppBar (Android): ${layoutInfo.activeBreakpointId}'),
            leading:
                (slotBuilders[LayoutSlot.leftDrawer] as DeclarativeSlotBuilder?)
                        ?.build(layoutInfo) !=
                    null
                ? IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: layoutInfo.toggleLeftDrawer,
                  )
                : null,
          ),
        ),
        LayoutMatchConfig(
          platforms: const {AdaptivePlatform.IOS},
          builder: (layoutInfo) {
            final rightDrawerBuilder =
                slotBuilders[LayoutSlot.rightDrawer] as DeclarativeSlotBuilder?;
            final bool showHamburger =
                rightDrawerBuilder?.build(layoutInfo) != null;

            return CupertinoNavigationBar(
              middle: Text('AppBar (iOS): ${layoutInfo.activeBreakpointId}'),
              trailing: showHamburger
                  ? CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Icon(CupertinoIcons.bars),
                      onPressed: layoutInfo.toggleRightPane,
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
        LayoutMatchConfig(
          breakpointMatcher: (activeId) =>
              activeId.isLargerThan(BreakpointId.l),
          platforms: const {AdaptivePlatform.ANDROID},
          builder: (layoutInfo) => NavigationRail(
            selectedIndex: 0,
            onDestinationSelected: (index) {
              // Example: handle navigation
            },
            labelType: NavigationRailLabelType.all,
            leading: FloatingActionButton(
              elevation: 0,
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.favorite_border),
                selectedIcon: Icon(Icons.favorite),
                label: Text('First'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bookmark_border),
                selectedIcon: Icon(Icons.book),
                label: Text('Second'),
              ),
            ],
          ),
        ),
        LayoutMatchConfig(
          breakpointMatcher: (activeId) =>
              activeId.isSmallerOrEqualTo(BreakpointId.l),
          platforms: const {AdaptivePlatform.ANDROID},
          builder: (layoutInfo) => ListView(
            children: const [
              ListTile(
                leading: Icon(Icons.menu_book),
                title: Text('Drawer Item 1 (Android)'),
              ),
              ListTile(
                leading: Icon(Icons.people),
                title: Text('Drawer Item 2 (Android)'),
              ),
            ],
          ),
        ),
        LayoutMatchConfig(
          platforms: const {AdaptivePlatform.IOS},
          builder: (layoutInfo) => Container(
            color: CupertinoColors.systemGrey6.resolveFrom(context),
            child: ListView(
              children: const [
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.folder_fill),
                  title: Text('Browse (iOS Left Pane)'),
                ),
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.search),
                  title: Text('Search (iOS Left Pane)'),
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
        LayoutMatchConfig(
          breakpointMatcher: (activeId) =>
              activeId.isLargerThan(BreakpointId.s),
          platforms: const {AdaptivePlatform.IOS},
          builder: (layoutInfo) => Container(
            color: CupertinoColors.systemGrey6.resolveFrom(context),
            padding: EdgeInsets.only(
              top: MediaQuery.of(layoutInfo.context).padding.top + 44,
            ),
            child: ListView(
              children: const [
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.mail),
                  title: Text('Inbox (iOS Right Pane)'),
                ),
                CupertinoListTile(
                  leading: Icon(CupertinoIcons.person_3),
                  title: Text('Contacts (iOS Right Pane)'),
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
              NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
            ],
            selectedIndex: 0,
            onDestinationSelected: (index) {},
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          ),
        ),
        LayoutMatchConfig(
          breakpointMatcher: (activeId) =>
              activeId.isSmallerOrEqualTo(BreakpointId.s),
          platforms: const {AdaptivePlatform.IOS},
          builder: (layoutInfo) => CupertinoTabBar(
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
      defaultBuilder: (layoutInfo) => null,
    ),
    LayoutSlot.floatingActionButton: DeclarativeSlotBuilder(
      configs: [
        LayoutMatchConfig(
          platforms: const {AdaptivePlatform.ANDROID},
          builder: (layoutInfo) => FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
      ],
      defaultBuilder: (layoutInfo) => null,
    ),
  });

  return AdaptiveLayoutWidget(slotBuilders: slotBuilders);
}

@UseCase(name: 'With Secondary Navigation', type: AdaptiveLayoutWidget)
Widget adaptiveLayoutWithSecondaryNavUseCase(BuildContext context) {
  return AdaptiveLayoutWidget(
    slotBuilders: {
      LayoutSlot.body: SimpleSlotBuilder(
        (layoutInfo) => Center(
          child: Text(
            'Body with Secondary Nav: ${layoutInfo.activeBreakpointId}\n${layoutInfo.orientation}\n${layoutInfo.screenSize}',
          ),
        ),
      ),
      LayoutSlot.appBar: SimpleSlotBuilder(
        (layoutInfo) =>
            AppBar(title: Text('AppBar: ${layoutInfo.activeBreakpointId}')),
      ),
      LayoutSlot.leftDrawer: DeclarativeSlotBuilder(
        configs: [
          LayoutMatchConfig(
            breakpointMatcher: (activeId) =>
                activeId.isSmallerOrEqualTo(BreakpointId.s),
            platforms: const {
              AdaptivePlatform.ANDROID,
              AdaptivePlatform.FUCHSIA,
              AdaptivePlatform.LINUX,
              AdaptivePlatform.WINDOWS,
              AdaptivePlatform.MACOS,
            },
            builder: (layoutInfo) => Drawer(
              child: ListView(
                children: [
                  const ListTile(
                    leading: Icon(Icons.menu_book),
                    title: Text('Drawer Item 1 (Small Screen)'),
                  ),
                ],
              ),
            ),
          ),
          LayoutMatchConfig(
            breakpointMatcher: (activeId) =>
                activeId.isLargerThan(BreakpointId.s),
            platforms: const {
              AdaptivePlatform.ANDROID,
              AdaptivePlatform.FUCHSIA,
              AdaptivePlatform.LINUX,
              AdaptivePlatform.WINDOWS,
              AdaptivePlatform.MACOS,
            },
            builder: (layoutInfo) => NavigationRail(
              selectedIndex: 0,
              destinations: const <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),
          ),
        ],
        defaultBuilder: (layoutInfo) => null,
      ),
      LayoutSlot.secondaryNavigation: SimpleSlotBuilder(
        (layoutInfo) => Container(
          width: 200,
          color: Colors.grey[200],
          child: Center(
            child: Text('Secondary Nav: ${layoutInfo.activeBreakpointId}'),
          ),
        ),
      ),
      LayoutSlot.bottomNavigationBar: SimpleSlotBuilder(
        (layoutInfo) => NavigationBar(
          destinations: const [
            NavigationDestination(icon: Icon(Icons.explore), label: 'Explore'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ],
          selectedIndex: 0,
          onDestinationSelected: (index) {},
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      ),
    },
  );
}

@UseCase(name: 'Form Factor Responsive', type: AdaptiveLayoutWidget)
Widget formFactorResponsiveUseCase(BuildContext context) {
  return AdaptiveLayoutWidget(
    slotBuilders: {
      LayoutSlot.body: DeclarativeSlotBuilder(
        configs: [
          LayoutMatchConfig(
            formFactorMatcher: (factor) => factor == DeviceFormFactor.phone,
            builder: (layoutInfo) => ListView(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phone Layout',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text('Form Factor: ${layoutInfo.formFactor}'),
                        Text('Breakpoint: ${layoutInfo.activeBreakpointId}'),
                        Text('Orientation: ${layoutInfo.orientation}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          LayoutMatchConfig(
            formFactorMatcher: (factor) => factor == DeviceFormFactor.tablet,
            builder: (layoutInfo) => GridView.count(
              crossAxisCount: 2,
              children: List.generate(
                8,
                (index) => Card(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.tablet, size: 48),
                        Text('Tablet Item ${index + 1}'),
                        Text('${layoutInfo.formFactor}'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          LayoutMatchConfig(
            formFactorMatcher: (factor) => factor == DeviceFormFactor.desktop,
            builder: (layoutInfo) => GridView.count(
              crossAxisCount: 4,
              children: List.generate(
                16,
                (index) => Card(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.desktop_windows, size: 48),
                        Text('Desktop ${index + 1}'),
                        Text('${layoutInfo.formFactor}'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        defaultBuilder: (layoutInfo) => Center(
          child: Text('Unknown form factor: ${layoutInfo.formFactor}'),
        ),
      ),
      LayoutSlot.appBar: SimpleSlotBuilder(
        (layoutInfo) =>
            AppBar(title: Text('Form Factor: ${layoutInfo.formFactor}')),
      ),
    },
  );
}

@UseCase(name: 'Orientation Responsive', type: AdaptiveLayoutWidget)
Widget orientationResponsiveUseCase(BuildContext context) {
  return AdaptiveLayoutWidget(
    slotBuilders: {
      LayoutSlot.body: DeclarativeSlotBuilder(
        configs: [
          LayoutMatchConfig(
            orientationMatcher: Orientation.portrait,
            builder: (layoutInfo) => ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) => ListTile(
                leading: Icon(Icons.portrait),
                title: Text('Portrait Item ${index + 1}'),
                subtitle: Text('${layoutInfo.orientation}'),
              ),
            ),
          ),
          LayoutMatchConfig(
            orientationMatcher: Orientation.landscape,
            builder: (layoutInfo) => GridView.count(
              crossAxisCount: 3,
              children: List.generate(
                20,
                (index) => Card(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.landscape),
                        Text('Landscape ${index + 1}'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        defaultBuilder: (layoutInfo) =>
            Center(child: Text('Orientation: ${layoutInfo.orientation}')),
      ),
      LayoutSlot.appBar: SimpleSlotBuilder(
        (layoutInfo) =>
            AppBar(title: Text('Orientation: ${layoutInfo.orientation}')),
      ),
    },
  );
}

@UseCase(name: 'Sliver App Bar Demo', type: AdaptiveLayoutWidget)
Widget sliverAppBarDemoUseCase(BuildContext context) {
  return AdaptiveLayoutWidget(
    slotBuilders: {
      LayoutSlot.body: SimpleSlotBuilder(
        (layoutInfo) => ListView.builder(
          itemCount: 50,
          itemBuilder: (context, index) => ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text('Scrollable Item ${index + 1}'),
            subtitle: Text('Breakpoint: ${layoutInfo.activeBreakpointId}'),
          ),
        ),
      ),
      LayoutSlot.sliverAppBar: DeclarativeSlotBuilder(
        configs: [
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.ANDROID, AdaptivePlatform.WEB},
            builder: (layoutInfo) => SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('Sliver AppBar (${layoutInfo.activeBreakpointId})'),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue, Colors.purple],
                    ),
                  ),
                ),
              ),
            ),
          ),
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.IOS},
            builder: (layoutInfo) => CupertinoSliverNavigationBar(
              largeTitle: Text('iOS Sliver (${layoutInfo.activeBreakpointId})'),
            ),
          ),
        ],
        defaultBuilder: (layoutInfo) => null,
      ),
    },
  );
}

@UseCase(name: 'Persistent Panels', type: AdaptiveLayoutWidget)
Widget persistentPanelsUseCase(BuildContext context) {
  return AdaptiveLayoutWidget(
    slotBuilders: {
      LayoutSlot.body: SimpleSlotBuilder(
        (layoutInfo) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Main Content Area',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 16),
              Text('Breakpoint: ${layoutInfo.activeBreakpointId}'),
              Text('Platform: ${layoutInfo.adaptivePlatform}'),
              Text('Form Factor: ${layoutInfo.formFactor}'),
            ],
          ),
        ),
      ),
      LayoutSlot.appBar: SimpleSlotBuilder(
        (layoutInfo) => AppBar(title: Text('Persistent Panels Demo')),
      ),
      LayoutSlot.leftDrawer: DeclarativeSlotBuilder(
        configs: [
          LayoutMatchConfig(
            breakpointMatcher: (activeId) =>
                activeId.isLargerThan(BreakpointId.m),
            platforms: const {AdaptivePlatform.WEB},
            isPersistent: true,
            builder: (layoutInfo) => Container(
              width: 250,
              color: Colors.blue[50],
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.dashboard),
                    title: Text('Dashboard'),
                    subtitle: Text('Persistent Left Panel'),
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                  ),
                  ListTile(leading: Icon(Icons.help), title: Text('Help')),
                ],
              ),
            ),
          ),
          LayoutMatchConfig(
            breakpointMatcher: (activeId) =>
                activeId.isSmallerOrEqualTo(BreakpointId.m),
            builder: (layoutInfo) => Drawer(
              child: ListView(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: Colors.blue),
                    child: Text('Menu', style: TextStyle(color: Colors.white)),
                  ),
                  ListTile(
                    leading: Icon(Icons.dashboard),
                    title: Text('Dashboard'),
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
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
          LayoutMatchConfig(
            breakpointMatcher: (activeId) =>
                activeId.isLargerThan(BreakpointId.l),
            platforms: const {AdaptivePlatform.WEB},
            isPersistent: true,
            builder: (layoutInfo) => Container(
              width: 200,
              color: Colors.green[50],
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.notifications),
                    title: Text('Notifications'),
                    subtitle: Text('Persistent Right Panel'),
                  ),
                  ListTile(
                    leading: Icon(Icons.message),
                    title: Text('Messages'),
                  ),
                  ListTile(leading: Icon(Icons.person), title: Text('Profile')),
                ],
              ),
            ),
          ),
        ],
        defaultBuilder: (layoutInfo) => null,
      ),
    },
  );
}

@UseCase(name: 'All Slots Demo', type: AdaptiveLayoutWidget)
Widget allSlotsDemoUseCase(BuildContext context) {
  return AdaptiveLayoutWidget(
    slotBuilders: {
      LayoutSlot.body: SimpleSlotBuilder(
        (layoutInfo) => ListView(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Main Body Content',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text('This demonstrates all available slots'),
                    SizedBox(height: 8),
                    Text('Breakpoint: ${layoutInfo.activeBreakpointId}'),
                    Text('Platform: ${layoutInfo.adaptivePlatform}'),
                    Text('Form Factor: ${layoutInfo.formFactor}'),
                    Text('Orientation: ${layoutInfo.orientation}'),
                  ],
                ),
              ),
            ),
            ...List.generate(
              10,
              (index) => ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text('Content Item ${index + 1}'),
                subtitle: Text('Sample content for demonstration'),
              ),
            ),
          ],
        ),
      ),
      LayoutSlot.appBar: SimpleSlotBuilder(
        (layoutInfo) => AppBar(
          title: Text('All Slots Demo'),
          actions: [
            IconButton(icon: Icon(Icons.search), onPressed: () {}),
            IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
      ),
      LayoutSlot.leftDrawer: DeclarativeSlotBuilder(
        configs: [
          LayoutMatchConfig(
            breakpointMatcher: (activeId) =>
                activeId.isLargerThan(BreakpointId.s),
            builder: (layoutInfo) => NavigationRail(
              selectedIndex: 0,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.business),
                  label: Text('Business'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.school),
                  label: Text('School'),
                ),
              ],
            ),
          ),
          LayoutMatchConfig(
            breakpointMatcher: (activeId) =>
                activeId.isSmallerOrEqualTo(BreakpointId.s),
            builder: (layoutInfo) => Drawer(
              child: ListView(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      'Navigation',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                  ListTile(leading: Icon(Icons.home), title: Text('Home')),
                  ListTile(
                    leading: Icon(Icons.business),
                    title: Text('Business'),
                  ),
                  ListTile(leading: Icon(Icons.school), title: Text('School')),
                ],
              ),
            ),
          ),
        ],
        defaultBuilder: (layoutInfo) => null,
      ),
      LayoutSlot.secondaryNavigation: DeclarativeSlotBuilder(
        configs: [
          LayoutMatchConfig(
            breakpointMatcher: (activeId) =>
                activeId.isLargerThan(BreakpointId.m),
            builder: (layoutInfo) => Container(
              width: 200,
              color: Colors.grey[100],
              child: ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Secondary Nav',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.folder),
                    title: Text('Documents'),
                    dense: true,
                  ),
                  ListTile(
                    leading: Icon(Icons.image),
                    title: Text('Images'),
                    dense: true,
                  ),
                  ListTile(
                    leading: Icon(Icons.video_library),
                    title: Text('Videos'),
                    dense: true,
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
          LayoutMatchConfig(
            breakpointMatcher: (activeId) =>
                activeId.isSmallerOrEqualTo(BreakpointId.s),
            builder: (layoutInfo) => NavigationBar(
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(
                  icon: Icon(Icons.business),
                  label: 'Business',
                ),
                NavigationDestination(
                  icon: Icon(Icons.school),
                  label: 'School',
                ),
              ],
              selectedIndex: 0,
              onDestinationSelected: (index) {},
            ),
          ),
        ],
        defaultBuilder: (layoutInfo) => null,
      ),
      LayoutSlot.floatingActionButton: SimpleSlotBuilder(
        (layoutInfo) => FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
          tooltip: 'Add new item',
        ),
      ),
      LayoutSlot.persistentFooter: DeclarativeSlotBuilder(
        configs: [
          LayoutMatchConfig(
            breakpointMatcher: (activeId) =>
                activeId.isLargerThan(BreakpointId.s),
            builder: (layoutInfo) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(onPressed: () {}, child: Text('Action 1')),
                TextButton(onPressed: () {}, child: Text('Action 2')),
                ElevatedButton(onPressed: () {}, child: Text('Primary Action')),
              ],
            ),
          ),
        ],
        defaultBuilder: (layoutInfo) => null,
      ),
      LayoutSlot.footer: DeclarativeSlotBuilder(
        configs: [
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.WEB},
            breakpointMatcher: (activeId) =>
                activeId.isLargerThan(BreakpointId.s),
            builder: (layoutInfo) => Container(
              height: 60,
              color: Colors.grey[200],
              child: Center(
                child: Text(
                  '© 2024 Adaptive Layout Demo - Footer Example',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
        defaultBuilder: (layoutInfo) => null,
      ),
      LayoutSlot.overlay: DeclarativeSlotBuilder(
        configs: [
          LayoutMatchConfig(
            breakpointMatcher: (activeId) =>
                activeId.isLargerThan(BreakpointId.m),
            builder: (layoutInfo) => Positioned(
              top: 100,
              right: 20,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(height: 8),
                      Text('Overlay Content'),
                      Text('${layoutInfo.activeBreakpointId}'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        defaultBuilder: (layoutInfo) => null,
      ),
    },
  );
}

@UseCase(name: 'Complex Multi-Platform', type: AdaptiveLayoutWidget)
Widget complexMultiPlatformUseCase(BuildContext context) {
  return AdaptiveLayoutWidget(
    slotBuilders: {
      LayoutSlot.body: DeclarativeSlotBuilder(
        configs: [
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.ANDROID},
            formFactorMatcher: (factor) => factor == DeviceFormFactor.phone,
            orientationMatcher: Orientation.portrait,
            builder: (layoutInfo) => ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) => Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Icon(Icons.android, color: Colors.green),
                  title: Text('Android Phone Portrait ${index + 1}'),
                  subtitle: Text('${layoutInfo.activeBreakpointId}'),
                ),
              ),
            ),
          ),
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.ANDROID},
            formFactorMatcher: (factor) => factor == DeviceFormFactor.phone,
            orientationMatcher: Orientation.landscape,
            builder: (layoutInfo) => GridView.count(
              crossAxisCount: 2,
              children: List.generate(
                20,
                (index) => Card(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.android, color: Colors.green),
                        Text('Android Landscape ${index + 1}'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.IOS},
            formFactorMatcher: (factor) => factor == DeviceFormFactor.tablet,
            builder: (layoutInfo) => GridView.count(
              crossAxisCount: 3,
              children: List.generate(
                20,
                (index) => Card(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.tablet_mac, color: Colors.blue),
                        Text('iPad ${index + 1}'),
                        Text('${layoutInfo.activeBreakpointId}'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.WEB},
            breakpointMatcher: (activeId) =>
                activeId.isLargerThan(BreakpointId.l),
            builder: (layoutInfo) => GridView.count(
              crossAxisCount: 4,
              children: List.generate(
                20,
                (index) => Card(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.web, color: Colors.purple),
                        Text('Web Large ${index + 1}'),
                        Text('${layoutInfo.activeBreakpointId}'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        defaultBuilder: (layoutInfo) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.device_unknown, size: 64),
              SizedBox(height: 16),
              Text('Default Layout'),
              Text('Platform: ${layoutInfo.adaptivePlatform}'),
              Text('Form Factor: ${layoutInfo.formFactor}'),
              Text('Breakpoint: ${layoutInfo.activeBreakpointId}'),
              Text('Orientation: ${layoutInfo.orientation}'),
            ],
          ),
        ),
      ),
      LayoutSlot.appBar: DeclarativeSlotBuilder(
        configs: [
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.ANDROID},
            builder: (layoutInfo) => AppBar(
              title: Text('Android - ${layoutInfo.formFactor}'),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.IOS},
            builder: (layoutInfo) => CupertinoNavigationBar(
              middle: Text('iOS - ${layoutInfo.formFactor}'),
              backgroundColor: Colors.blue.withOpacity(0.8),
            ),
          ),
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.WEB},
            builder: (layoutInfo) => AppBar(
              title: Text('Web - ${layoutInfo.activeBreakpointId}'),
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
        defaultBuilder: (layoutInfo) =>
            AppBar(title: Text('Multi-Platform Demo')),
      ),
    },
  );
}

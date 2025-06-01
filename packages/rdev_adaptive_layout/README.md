# RDEV Adaptive Layout

A powerful Flutter package for building responsive and adaptive layouts that automatically adjust to different screen sizes, platforms, and orientations.

## Features

- **Responsive Breakpoints**: Define custom breakpoints for different screen sizes
- **Platform-Specific Layouts**: Create different layouts for iOS, Android, Web, macOS, Windows, Linux, and Fuchsia
- **Orientation Support**: Handle portrait and landscape orientations
- **Device Form Factor Detection**: Automatically detect phone, tablet, and desktop form factors
- **Slot-Based Architecture**: Organize your UI into logical slots (body, drawers, navigation, etc.)
- **Declarative Configuration**: Use rule-based builders for complex layout logic
- **Smooth Animations**: Built-in animations for layout transitions
- **Persistent Panels**: Support for persistent side panels on larger screens
- **Drawer/Pane Management**: Unified API for Material drawers and Cupertino panes
- **Master-Detail Layouts**: Built-in support for responsive master-detail patterns
- **Platform-Native Components**: Automatic selection of Material vs Cupertino components

## Demo

![Demo](https://zapp.run/edit/zyc2063pzc30?theme=dark&lazy=false)


## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  rdev_adaptive_layout: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:rdev_adaptive_layout/rdev_adaptive_layout.dart';

class MyAdaptiveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdaptiveLayoutWidget(
      slotBuilders: {
        LayoutSlot.body: SimpleSlotBuilder((info) => 
          Center(child: Text('Hello Adaptive Layout!'))
        ),
        LayoutSlot.appBar: SimpleSlotBuilder((info) => 
          AppBar(title: Text('My App'))
        ),
      },
    );
  }
}
```

## Core Concepts

### Layout Slots

The package organizes UI components into predefined slots:

- `body` - Main content area
- `appBar` - Top app bar
- `sliverAppBar` - Scrollable app bar
- `leftDrawer` - Left side drawer/panel
- `rightDrawer` - Right side drawer/panel
- `secondaryNavigation` - Secondary navigation area
- `bottomNavigationBar` - Bottom navigation
- `floatingActionButton` - Floating action button
- `persistentFooter` - Persistent footer buttons
- `footer` - General footer area
- `overlay` - Overlay content

### Breakpoints

Default breakpoints are provided but can be customized:

- `xxs` - 0px+ (Extra extra small)
- `xs` - 360px+ (Extra small)
- `s` - 600px+ (Small)
- `m` - 800px+ (Medium)
- `l` - 1024px+ (Large)
- `xl` - 1280px+ (Extra large)
- `xxl` - 1440px+ (Extra extra large)
- `xxxl` - 1600px+ (Extra extra extra large)
- `xxxxl` - 1920px+ (Extra extra extra extra large)

### Slot Builders

Four types of slot builders are available:

1. **SimpleSlotBuilder** - Single function builder
2. **DeclarativeSlotBuilder** - Rule-based builder with conditions
3. **StaticSlotBuilder** - Always returns the same widget
4. **ConditionalSlotBuilder** - Conditional builder with true/false branches

## Real-World Examples

### Complete Adaptive App with Navigation

```dart
class AdaptiveApp extends StatefulWidget {
  @override
  State<AdaptiveApp> createState() => _AdaptiveAppState();
}

class _AdaptiveAppState extends State<AdaptiveApp> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayoutWidget(
      slotBuilders: {
        // Adaptive body content
        LayoutSlot.body: DeclarativeSlotBuilder(
          configs: [
            LayoutMatchConfig(
              platforms: {AdaptivePlatform.ANDROID},
              builder: (info) => _selectedIndex == 0
                  ? ExploreView(layoutInfo: info)
                  : ProfileView(layoutInfo: info),
            ),
            LayoutMatchConfig(
              platforms: {AdaptivePlatform.IOS},
              builder: (info) => _selectedIndex == 0
                  ? ExploreView(layoutInfo: info)
                  : ProfileView(layoutInfo: info),
            ),
            LayoutMatchConfig(
              platforms: {AdaptivePlatform.WEB},
              builder: (info) => _selectedIndex == 0
                  ? ExploreView(layoutInfo: info)
                  : ProfileView(layoutInfo: info),
            ),
          ],
        ),

        // Platform-specific app bars
        LayoutSlot.appBar: DeclarativeSlotBuilder(
          configs: [
            LayoutMatchConfig(
              platforms: {AdaptivePlatform.ANDROID},
              builder: (info) => AppBar(
                title: Text('My App (${info.activeBreakpointId})'),
              ),
            ),
            LayoutMatchConfig(
              platforms: {AdaptivePlatform.IOS},
              builder: (info) => CupertinoNavigationBar(
                middle: Text('My App (${info.activeBreakpointId})'),
              ),
            ),
            LayoutMatchConfig(
              platforms: {AdaptivePlatform.WEB},
              builder: (info) => PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: Container(
                  color: Theme.of(context).primaryColor,
                  child: Row(
                    children: [
                      if (info.activeBreakpointId.isSmallerOrEqualTo(BreakpointId.l))
                        IconButton(
                          icon: Icon(Icons.menu),
                          onPressed: info.toggleLeftDrawer,
                        ),
                      Text('Web App', style: TextStyle(fontSize: 20)),
                      Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: Text('Logout'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // Responsive navigation
        LayoutSlot.leftDrawer: DeclarativeSlotBuilder(
          configs: [
            // Web persistent panel for large screens
            LayoutMatchConfig(
              platforms: {AdaptivePlatform.WEB},
              breakpointMatcher: (id) => id.isLargerThan(BreakpointId.l),
              builder: (info) => Container(
                width: 200,
                child: NavigationList(
                  selectedIndex: _selectedIndex,
                  onItemSelected: (index) => setState(() => _selectedIndex = index),
                ),
              ),
            ),
            // Web drawer for smaller screens
            LayoutMatchConfig(
              platforms: {AdaptivePlatform.WEB},
              breakpointMatcher: (id) => id.isSmallerOrEqualTo(BreakpointId.l),
              builder: (info) => Drawer(
                child: NavigationList(
                  selectedIndex: _selectedIndex,
                  onItemSelected: (index) {
                    setState(() => _selectedIndex = index);
                    info.closeLeftDrawer?.call();
                  },
                ),
              ),
            ),
            // Android drawer
            LayoutMatchConfig(
              platforms: {AdaptivePlatform.ANDROID},
              breakpointMatcher: (id) => id.isLargerOrEqualTo(BreakpointId.m),
              builder: (info) => Drawer(
                child: NavigationList(
                  selectedIndex: _selectedIndex,
                  onItemSelected: (index) {
                    setState(() => _selectedIndex = index);
                    info.closeLeftDrawer?.call();
                  },
                ),
              ),
            ),
            // iOS persistent pane for tablets
            LayoutMatchConfig(
              platforms: {AdaptivePlatform.IOS},
              formFactorMatcher: (factor) => factor == DeviceFormFactor.tablet,
              isPersistent: true,
              builder: (info) => Container(
                width: 200,
                child: CupertinoNavigationList(
                  selectedIndex: _selectedIndex,
                  onItemSelected: (index) => setState(() => _selectedIndex = index),
                ),
              ),
            ),
          ],
        ),

        // Bottom navigation for small screens
        LayoutSlot.bottomNavigationBar: DeclarativeSlotBuilder(
          configs: [
            LayoutMatchConfig(
              breakpointMatcher: (id) => id.isSmallerOrEqualTo(BreakpointId.s),
              platforms: {AdaptivePlatform.ANDROID},
              builder: (info) => NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                destinations: [
                  NavigationDestination(icon: Icon(Icons.explore), label: 'Explore'),
                  NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
                ],
              ),
            ),
            LayoutMatchConfig(
              breakpointMatcher: (id) => id.isSmallerOrEqualTo(BreakpointId.s),
              platforms: {AdaptivePlatform.IOS},
              builder: (info) => CupertinoTabBar(
                currentIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
                items: [
                  BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
                  BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                ],
              ),
            ),
          ],
        ),
      },
    );
  }
}
```

### Platform-Specific List Views

```dart
class AdaptiveListView extends StatelessWidget {
  final ActiveLayoutInfo layoutInfo;

  const AdaptiveListView({required this.layoutInfo});

  @override
  Widget build(BuildContext context) {
    if (layoutInfo.platform == TargetPlatform.android) {
      return ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) => ListTile(
          leading: Icon(Icons.android),
          title: Text('Android Item ${index + 1}'),
          subtitle: Text('Breakpoint: ${layoutInfo.activeBreakpointId}'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailPage()),
          ),
        ),
      );
    } else if (layoutInfo.platform == TargetPlatform.iOS) {
      return ListView(
        children: [
          CupertinoListSection.insetGrouped(
            header: Text('iOS Section - ${layoutInfo.activeBreakpointId}'),
            children: List.generate(20, (index) => CupertinoListTile(
              leading: Icon(CupertinoIcons.profile_circled),
              title: Text('iOS Item ${index + 1}'),
              trailing: CupertinoListTileChevron(),
              onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => DetailPage()),
              ),
            )),
          ),
        ],
      );
    }
    
    // Fallback for other platforms
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) => ListTile(
        leading: Icon(Icons.desktop_mac),
        title: Text('Item ${index + 1}'),
        subtitle: Text('Breakpoint: ${layoutInfo.activeBreakpointId}'),
      ),
    );
  }
}
```

### Master-Detail Layout Pattern

```dart
class MasterDetailLayout extends StatefulWidget {
  @override
  State<MasterDetailLayout> createState() => _MasterDetailLayoutState();
}

class _MasterDetailLayoutState extends State<MasterDetailLayout> {
  String? selectedItem;

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayoutWidget(
      slotBuilders: {
        LayoutSlot.body: DeclarativeSlotBuilder(
          configs: [
            // Large screens: side-by-side layout
            LayoutMatchConfig(
              breakpointMatcher: (id) => id.isLargerThan(BreakpointId.m),
              builder: (info) => Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: MasterView(
                      selectedItem: selectedItem,
                      onItemSelected: (item) => setState(() => selectedItem = item),
                    ),
                  ),
                  VerticalDivider(width: 1),
                  Expanded(
                    flex: 2,
                    child: DetailView(item: selectedItem),
                  ),
                ],
              ),
            ),
            // Small screens: navigation-based layout
            LayoutMatchConfig(
              breakpointMatcher: (id) => id.isSmallerOrEqualTo(BreakpointId.m),
              builder: (info) => MasterView(
                selectedItem: selectedItem,
                onItemSelected: (item) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailView(item: item),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      },
    );
  }
}
```

## Advanced Usage

### Declarative Slot Builder with Complex Rules

```dart
LayoutSlot.leftDrawer: DeclarativeSlotBuilder(
  configs: [
    // Web persistent navigation rail for large screens
    LayoutMatchConfig(
      platforms: {AdaptivePlatform.WEB},
      breakpointMatcher: (id) => id.isLargerThan(BreakpointId.l),
      isPersistent: true,
      builder: (info) => NavigationRail(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: [
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
    // Mobile drawer for all platforms on small screens
    LayoutMatchConfig(
      breakpointMatcher: (id) => id.isSmallerOrEqualTo(BreakpointId.m),
      builder: (info) => Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Text('Navigation')),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() => _selectedIndex = 0);
                info.closeLeftDrawer?.call();
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() => _selectedIndex = 1);
                info.closeLeftDrawer?.call();
              },
            ),
          ],
        ),
      ),
    ),
  ],
)
```

### Custom Breakpoints

```dart
final customBreakpoints = [
  PlatformBreakpointConfig(
    platform: AdaptivePlatform.WEB,
    breakpoints: [
      (id: BreakpointId.s, settings: BreakpointSettings(minWidth: 768)),
      (id: BreakpointId.m, settings: BreakpointSettings(minWidth: 1024)),
      (id: BreakpointId.l, settings: BreakpointSettings(minWidth: 1440)),
    ],
  ),
];

AdaptiveLayoutWidget(
  platformBreakpointConfigs: customBreakpoints,
  slotBuilders: {...},
)
```

### Accessing Layout Information

```dart
LayoutSlot.body: SimpleSlotBuilder((info) {
  return Column(
    children: [
      Text('Platform: ${info.adaptivePlatform}'),
      Text('Breakpoint: ${info.activeBreakpointId}'),
      Text('Form Factor: ${info.formFactor}'),
      Text('Orientation: ${info.orientation}'),
      Text('Screen Size: ${info.screenSize}'),
      if (info.isLargerThan(BreakpointId.m))
        Text('Large screen detected!'),
      ElevatedButton(
        onPressed: info.toggleLeftDrawer,
        child: Text('Toggle Navigation'),
      ),
    ],
  );
})
```

### Conditional Slot Builder

```dart
LayoutSlot.floatingActionButton: ConditionalSlotBuilder(
  condition: (info) => info.platform == TargetPlatform.android,
  trueBuilder: SimpleSlotBuilder((info) => FloatingActionButton(
    onPressed: () => _addItem(),
    child: Icon(Icons.add),
  )),
  falseBuilder: StaticSlotBuilder(null),
)
```

### Sliver App Bars

```dart
LayoutSlot.sliverAppBar: DeclarativeSlotBuilder(
  configs: [
    LayoutMatchConfig(
      platforms: {AdaptivePlatform.IOS},
      builder: (info) => CupertinoSliverNavigationBar(
        largeTitle: Text('Large Title (${info.activeBreakpointId})'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: info.toggleRightPane,
          child: Icon(CupertinoIcons.bars),
        ),
      ),
    ),
    LayoutMatchConfig(
      platforms: {AdaptivePlatform.ANDROID},
      builder: (info) => SliverAppBar(
        expandedHeight: 150.0,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          title: Text('Sliver (${info.activeBreakpointId})'),
          background: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
              ),
            ),
          ),
        ),
      ),
    ),
  ],
)
```

## API Reference

### AdaptiveLayoutWidget

Main widget for creating adaptive layouts.

**Properties:**
- `slotBuilders` - Map of slot builders
- `platformBreakpointConfigs` - Custom breakpoint configurations
- `animationDuration` - Animation duration for layout transitions (default: 300ms)
- `animationCurve` - Animation curve for transitions (default: Curves.easeInOut)
- `defaultBody` - Default body widget

### ActiveLayoutInfo

Contains current layout state information.

**Properties:**
- `context` - Build context
- `platform` - Target platform (TargetPlatform)
- `adaptivePlatform` - Adaptive platform enum (AdaptivePlatform)
- `orientation` - Screen orientation (Orientation)
- `activeBreakpointId` - Current breakpoint (BreakpointId)
- `screenSize` - Screen dimensions (Size)
- `formFactor` - Device form factor (DeviceFormFactor)
- Drawer/pane control callbacks:
  - `openLeftDrawer`, `closeLeftDrawer`, `toggleLeftDrawer`
  - `openRightDrawer`, `closeRightDrawer`, `toggleRightDrawer`
  - `openLeftPane`, `closeLeftPane`, `toggleLeftPane`
  - `openRightPane`, `closeRightPane`, `toggleRightPane`

**Methods:**
- `isSmallerOrEqualTo(BreakpointId)` - Compare breakpoints
- `isLargerOrEqualTo(BreakpointId)` - Compare breakpoints
- `isSmallerThan(BreakpointId)` - Compare breakpoints
- `isLargerThan(BreakpointId)` - Compare breakpoints

### LayoutMatchConfig

Configuration for declarative slot builders.

**Properties:**
- `platforms` - Set of target platforms
- `breakpointMatcher` - Function to match breakpoints
- `orientationMatcher` - Target orientation
- `formFactorMatcher` - Function to match form factors
- `builder` - Widget builder function
- `isPersistent` - Whether drawer/pane should be persistent (default: false)
- `specificity` - Calculated specificity for conflict resolution

### SlotBuilderType Implementations

**SimpleSlotBuilder**
```dart
SimpleSlotBuilder((info) => Widget)
```

**DeclarativeSlotBuilder**
```dart
DeclarativeSlotBuilder(
  configs: [LayoutMatchConfig(...)],
  defaultBuilder: (info) => Widget?, // Optional
)
```

**StaticSlotBuilder**
```dart
StaticSlotBuilder(Widget?)
```

**ConditionalSlotBuilder**
```dart
ConditionalSlotBuilder(
  condition: (info) => bool,
  trueBuilder: SlotBuilderType,
  falseBuilder: SlotBuilderType,
)
```

## Best Practices

### 1. Use Declarative Builders for Complex Logic
```dart
// Good: Clear, maintainable rules
LayoutSlot.navigation: DeclarativeSlotBuilder(
  configs: [
    LayoutMatchConfig(
      platforms: {AdaptivePlatform.WEB},
      breakpointMatcher: (id) => id.isLargerThan(BreakpointId.l),
      builder: (info) => NavigationRail(...),
    ),
    LayoutMatchConfig(
      platforms: {AdaptivePlatform.ANDROID, AdaptivePlatform.IOS},
      builder: (info) => Drawer(...),
    ),
  ],
)

// Avoid: Complex conditional logic in simple builders
LayoutSlot.navigation: SimpleSlotBuilder((info) {
  if (info.adaptivePlatform == AdaptivePlatform.WEB && 
      info.activeBreakpointId.isLargerThan(BreakpointId.l)) {
    return NavigationRail(...);
  } else if (info.adaptivePlatform == AdaptivePlatform.ANDROID) {
    return Drawer(...);
  }
  // ... more complex logic
})
```

### 2. Leverage Form Factor Detection
```dart
LayoutMatchConfig(
  formFactorMatcher: (factor) => factor == DeviceFormFactor.tablet,
  isPersistent: true,
  builder: (info) => PersistentSidePanel(),
)
```

### 3. Use Persistent Panels Wisely
```dart
// Web: Persistent navigation on large screens
LayoutMatchConfig(
  platforms: {AdaptivePlatform.WEB},
  breakpointMatcher: (id) => id.isLargerThan(BreakpointId.l),
  isPersistent: true,
  builder: (info) => NavigationPanel(),
)

// Mobile: Modal drawers
LayoutMatchConfig(
  platforms: {AdaptivePlatform.ANDROID, AdaptivePlatform.IOS},
  builder: (info) => Drawer(child: NavigationList()),
)
```

### 4. Handle Platform Differences Gracefully
```dart
// Use platform-appropriate components
LayoutSlot.appBar: DeclarativeSlotBuilder(
  configs: [
    LayoutMatchConfig(
      platforms: {AdaptivePlatform.IOS},
      builder: (info) => CupertinoNavigationBar(...),
    ),
    LayoutMatchConfig(
      platforms: {AdaptivePlatform.ANDROID},
      builder: (info) => AppBar(...),
    ),
  ],
  defaultBuilder: (info) => AppBar(...), // Fallback
)
```

## Platform Support

- ✅ Android (Material Design)
- ✅ iOS (Cupertino Design)
- ✅ Web (Responsive layouts)
- ✅ macOS (Native and web)
- ✅ Windows (Material Design)
- ✅ Linux (Material Design)
- ✅ Fuchsia (Material Design)

## Migration Guide

### From Traditional Responsive Layouts

**Before:**
```dart
class ResponsiveLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return DesktopLayout();
        } else if (constraints.maxWidth > 800) {
          return TabletLayout();
        } else {
          return MobileLayout();
        }
      },
    );
  }
}
```

**After:**
```dart
class AdaptiveLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdaptiveLayoutWidget(
      slotBuilders: {
        LayoutSlot.body: DeclarativeSlotBuilder(
          configs: [
            LayoutMatchConfig(
              breakpointMatcher: (id) => id.isLargerThan(BreakpointId.xl),
              builder: (info) => DesktopContent(),
            ),
            LayoutMatchConfig(
              breakpointMatcher: (id) => id.isLargerThan(BreakpointId.m),
              builder: (info) => TabletContent(),
            ),
          ],
          defaultBuilder: (info) => MobileContent(),
        ),
      },
    );
  }
}
```

## Examples

The `/example` directory contains complete examples demonstrating:

- **Basic Responsive Layout** - Simple adaptive layouts with breakpoints
- **Platform-Specific Navigation** - Material vs Cupertino navigation patterns
- **Master-Detail Layout** - Responsive master-detail implementation
- **Custom Breakpoints** - Defining custom breakpoint configurations
- **Persistent Panels** - Web-style persistent navigation panels
- **Animation Configurations** - Custom animation settings
- **Form Factor Detection** - Phone, tablet, and desktop adaptations
- **Complex Declarative Rules** - Advanced slot building patterns

### Running Examples

```bash
cd example
flutter run
```

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests to our repository.

### Development Setup

1. Clone the repository
2. Run `flutter pub get` in both root and example directories
3. Make your changes
4. Add tests for new functionality
5. Run `flutter test` to ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions and support:
- Visit [https://rdev.co.nz](https://rdev.co.nz)
- Open an issue on our GitHub repository
- Check the `/example` directory for implementation patterns
- Review the API documentation above

## Changelog

### 0.0.1
- Initial release
- Basic adaptive layout functionality
- Platform-specific slot builders
- Responsive breakpoint system
- Material and Cupertino support

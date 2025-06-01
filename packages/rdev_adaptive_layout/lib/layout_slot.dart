/// Defines standard layout slots where UI components can be placed.
/// This enum can be extended as needed for more specific layout requirements.
enum LayoutSlot {
  /// The main content area of the screen.
  body,

  /// A slot for a side drawer, typically on the left.
  leftDrawer,

  /// A slot for a side drawer, typically on the right.
  rightDrawer,

  /// A slot for secondary navigation or content, often used in master-detail layouts.
  secondaryNavigation,

  /// Slot for an AppBar or a similar top-level header bar.
  appBar,

  /// Slot for a SliverAppBar or a similar scrolling top-level header bar.
  sliverAppBar,

  /// Slot specifically for a BottomNavigationBar if not handled by primaryNavigation.
  /// Useful if primaryNavigation is a Drawer/Rail and a BottomNav is also desired on small screens.
  bottomNavigationBar,

  /// Slot for a FloatingActionButton.
  floatingActionButton,

  /// A slot for a persistent bottom sheet or a similar UI element at the bottom of the screen.
  persistentFooter,

  /// A slot for content that might overlay the body, like a snackbar or custom toast area,
  /// though these are often handled differently via ScaffoldMessenger or Overlay.
  /// Including it for completeness if direct widget placement is desired.
  overlay,

  /// A general-purpose footer area, typically at the bottom of the page content.
  footer,
}

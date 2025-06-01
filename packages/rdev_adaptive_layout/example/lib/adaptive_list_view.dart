import 'package:example/detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rdev_adaptive_layout/active_layout_info.dart';

class AdaptiveListView extends StatelessWidget {
  final ActiveLayoutInfo layoutInfo;

  const AdaptiveListView({super.key, required this.layoutInfo});

  @override
  Widget build(BuildContext context) {
    if (layoutInfo.platform == TargetPlatform.android) {
      return ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) => ListTile(
          key: ValueKey(index),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailPage()),
            );
          },
          leading: const Icon(Icons.android),
          title: Text('Android Item ${index + 1}'),
          subtitle: Text('Breakpoint: ${layoutInfo.activeBreakpointId}'),
        ),
      );
    } else if (layoutInfo.platform == TargetPlatform.iOS) {
      return ListView(
        key: const PageStorageKey('myListView'),
        children: [
          CupertinoListSection.insetGrouped(
            header: Text('iOS Section - BP: ${layoutInfo.activeBreakpointId}'),
            children: List.generate(
              20,
              (index) => CupertinoListTile(
                key: ValueKey(index),
                leading: const Icon(CupertinoIcons.profile_circled),
                title: Text('iOS Item ${index + 1}'),
                subtitle: const Text('Tap to view'),
                trailing: const CupertinoListTileChevron(),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => DetailPage()),
                  );
                },
              ),
            ),
          ),
        ],
      );
    } else {
      // Default fallback
      return ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) => ListTile(
          leading: const Icon(Icons.desktop_mac),
          title: Text(' Item ${index + 1}'),
          subtitle: Text('Breakpoint: ${layoutInfo.activeBreakpointId}'),
        ),
      );
    }
  }
}

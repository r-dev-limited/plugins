import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rdev_adaptive_layout/adaptive_layout_widget.dart';
import 'package:rdev_adaptive_layout/layout_slot.dart';
import 'package:rdev_adaptive_layout/slot_building_rules.dart';
import 'package:rdev_adaptive_layout/adaptive_platform.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    final Map<LayoutSlot, SlotBuilderType> slotBuilders = {};

    slotBuilders.addAll({
      LayoutSlot.body: DeclarativeSlotBuilder(
        configs: [
          /// Android Body
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.ANDROID},
            builder: (layoutInfo) => ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) => ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Android Detail Page'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DetailPage()),
                  );
                },
                subtitle: Text('Breakpoint: ${layoutInfo.activeBreakpointId}'),
              ),
            ),
          ),

          /// iOS Body
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.IOS},
            builder: (layoutInfo) => ListView(
              children: [
                CupertinoListSection.insetGrouped(
                  header: Text(
                    'iOS Section - BP: ${layoutInfo.activeBreakpointId}',
                  ),
                  children: List.generate(
                    1,
                    (index) => CupertinoListTile(
                      leading: const Icon(CupertinoIcons.profile_circled),
                      title: Text('iOS Item ${index + 1}'),
                      subtitle: const Text('Tap to view'),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => DetailPage(),
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
        defaultBuilder: (layoutInfo) => ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) => ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Detail Page'),
            subtitle: Text('Breakpoint: ${layoutInfo.activeBreakpointId}'),
          ),
        ),
      ),
      LayoutSlot.appBar: DeclarativeSlotBuilder(
        configs: [
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.ANDROID},
            builder: (layoutInfo) => AppBar(
              title: Text('Detail (Android): ${layoutInfo.activeBreakpointId}'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          LayoutMatchConfig(
            platforms: const {AdaptivePlatform.IOS},
            builder: (layoutInfo) {
              return CupertinoNavigationBar(
                middle: Text('Detail (iOS): ${layoutInfo.activeBreakpointId}'),
                leading: CupertinoNavigationBarBackButton(
                  onPressed: () => Navigator.of(context).pop(),
                ),
              );
            },
          ),
        ],
        defaultBuilder: (layoutInfo) => AppBar(
          title: Text('Detail Page: ${layoutInfo.activeBreakpointId}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    });

    return AdaptiveLayoutWidget(slotBuilders: slotBuilders);
  }
}

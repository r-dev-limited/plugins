import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rdev_helpers/extensions.dart';
import 'package:rdev_helpers/extensions/color_extension.dart';

import '../data/shared_providers.dart';
import '../domain/flavor_enum.dart';

class VersionWidget extends ConsumerWidget {
  final bool showVersionOnly;
  final TextStyle? textStyle;

  const VersionWidget({
    super.key,
    this.showVersionOnly = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backendVersion = ref.watch(firewayProvider).asData?.value;
    final packageInfo = ref.watch(packageInfoProvider).asData?.value;
    final flavor = ref.watch(flavorProvider);

    final textStyle = context.textTheme.bodyMedium?.apply(
      color: context.colorScheme.outlineVariant.darken(0.5),
    );

    if (showVersionOnly) {
      return SelectableText(
        'v${packageInfo?.version}(${packageInfo?.buildNumber})',
        style: textStyle,
      );
    } else {
      return SelectableText(
        '${_getFlavorText(flavor)}v${packageInfo?.version}(${packageInfo?.buildNumber})${backendVersion?.version is String ? '~${backendVersion?.version}' : ''}',
        style: textStyle,
      );
    }
  }

  String _getFlavorText(Flavor? flavor) {
    return flavor is Flavor
        ? flavor == Flavor.prod
            ? ''
            : flavor == Flavor.dev
                ? 'Dev - '
                : 'Staging - '
        : '';
  }
}

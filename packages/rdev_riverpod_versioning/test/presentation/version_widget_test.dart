import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rdev_riverpod_versioning/data/shared_providers.dart';
import 'package:rdev_riverpod_versioning/domain/fireway_vo.dart';
import 'package:rdev_riverpod_versioning/domain/flavor_enum.dart';
import 'package:rdev_riverpod_versioning/presentation/version_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('should display version only', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firewayProvider.overrideWith(
            (ref) async => Future.value(
              FirewayVO(
                version: '1.0.0',
                description: 'description',
                uid: 'uid',
                success: true,
                script: 'script',
                installedOn: DateTime.now(),
                executionTime: Duration.zero,
              ),
            ),
          ),
          packageInfoProvider.overrideWith(
            (ref) => Future.value(
              PackageInfo(
                version: '1.0.0',
                buildNumber: '1',
                appName: 'app',
                packageName: 'com.app',
                buildSignature: 'signature',
                installerStore: 'store',
              ),
            ),
          ),
          flavorProvider.overrideWithValue(Flavor.prod),
        ],
        child: MaterialApp(
          home: VersionWidget(
            showVersionOnly: true,
          ),
        ),
      ),
    );

    expect(find.widgetWithText(SelectableText, 'v1.0.0(1)'), findsNothing);

    await tester.pumpAndSettle();
    expect(find.widgetWithText(SelectableText, 'v1.0.0(1)'), findsOneWidget);
  });

  testWidgets('should display version and flavor', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firewayProvider.overrideWith(
            (ref) async => Future.value(
              FirewayVO(
                version: '1.0.0',
                description: 'description',
                uid: 'uid',
                success: true,
                script: 'script',
                installedOn: DateTime.now(),
                executionTime: Duration.zero,
              ),
            ),
          ),
          packageInfoProvider.overrideWith(
            (ref) => Future.value(
              PackageInfo(
                version: '1.0.0',
                buildNumber: '1',
                appName: 'app',
                packageName: 'com.app',
                buildSignature: 'signature',
                installerStore: 'store',
              ),
            ),
          ),
          flavorProvider.overrideWithValue(Flavor.dev),
        ],
        child: MaterialApp(
          home: VersionWidget(),
        ),
      ),
    );
    expect(find.widgetWithText(SelectableText, 'Dev - v1.0.0(1)~1.0.0'),
        findsNothing);

    await tester.pumpAndSettle();
    expect(find.widgetWithText(SelectableText, 'Dev - v1.0.0(1)~1.0.0'),
        findsOneWidget);
  });
}

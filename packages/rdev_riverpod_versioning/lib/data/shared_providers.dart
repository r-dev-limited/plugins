import 'package:device_info_plus/device_info_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rdev_riverpod_versioning/domain/fireway_vo.dart';
import 'package:universal_platform/universal_platform.dart';

import '../application/fireway_service.dart';
import '../domain/flavor_enum.dart';

final flavorProvider = Provider<Flavor>((ref) => Flavor.prod);

final packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  final log = Logger('packageInfoProvider');
  try {
    return PackageInfo.fromPlatform();
  } catch (err) {
    log.severe('Getting packageInfo failed.', err);
    rethrow;
  }
});

final isEmulatorProvider = FutureProvider<bool>((ref) async {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  if (UniversalPlatform.isAndroid) {
    var build = await deviceInfoPlugin.androidInfo;
    return build.isPhysicalDevice == false;
  } else if (UniversalPlatform.isIOS) {
    var data = await deviceInfoPlugin.iosInfo;
    return data.isPhysicalDevice == false;
  }
  return false;
});

final firewayProvider = FutureProvider<FirewayVO>((ref) {
  final log = Logger('firewayProvider');
  final _firewayService = ref.watch(FirewayService.provider);
  try {
    return _firewayService.getLatestBackendVersion();
  } catch (err) {
    log.severe('Getting fireway failed.', err);
    rethrow;
  }
});

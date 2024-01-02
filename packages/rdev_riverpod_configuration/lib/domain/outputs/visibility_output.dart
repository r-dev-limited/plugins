import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

import '../../data/configuration_manager_repository.dart';

abstract class VisibilityOutput {
  final log = Logger('VisibilityOutput');
  final AsyncNotifierProviderRef<ConfigurationManagerState> ref;

  VisibilityOutput(this.ref);

  ConfigurationManagerRepository get repo =>
      ref.watch(ConfigurationManagerRepository.provider.notifier);

  Map<ConfigurationOutputs, bool> processOutputs();
}

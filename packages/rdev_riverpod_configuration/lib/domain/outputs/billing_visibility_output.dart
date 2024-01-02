import 'package:logging/logging.dart';

import '../../data/configuration_manager_repository.dart';
import '../inputs/configuration_inputs.dart';
import 'visibility_output.dart';

/// This class contains business logic, joining different inputs and outputs
/// Also keeping information about order and exceptions.
///
/// Configuration repo is injected in, so we have full control over it.(tests)
class BillingVisibilityOutput extends VisibilityOutput {
  @override
  // ignore: overridden_fields
  final log = Logger('BillingVisibilityOutput');

  BillingVisibilityOutput(super.configurationManager);

  @override
  Map<ConfigurationOutputs, bool> processOutputs() {
    final outputs = <ConfigurationOutputs, bool>{};

    outputs[ConfigurationOutputs.isBillingTabEnabled] =
        isSettingsBillingTabEnabled();
    return outputs;
  }

  /// Controls visibility of billing tab.
  bool isSettingsBillingTabEnabled() {
    return repo.checkVisiblity(
      ConfigurationInputEnum<ConfigurationFirestoreConfigInputEnum>(
          ConfigurationFirestoreConfigInputEnum.isBillingTabEnabled),

      /// However when you are developer you will see it.
      overrides: [
        ConfigurationInputEnum<ConfigurationAuthStateInputEnum>(
          ConfigurationAuthStateInputEnum.isDeveloper,
          value: true,
        )
      ],
    );
  }
}

import 'package:logging/logging.dart';

import '../../data/configuration_manager_repository.dart';
import '../inputs/configuration_inputs.dart';
import 'visibility_output.dart';

/// This class contains business logic, joining different inputs and outputs
/// Also keeping information about order and exceptions.
///
/// Configuration repo is injected in, so we have full control over it.(tests)
class LibraryVisibilityOutput extends VisibilityOutput {
  @override
  // ignore: overridden_fields
  final log = Logger('LibraryVisibilityOutput');

  LibraryVisibilityOutput(super.configurationManager);

  @override
  Map<ConfigurationOutputs, bool> processOutputs() {
    final outputs = <ConfigurationOutputs, bool>{};

    outputs[ConfigurationOutputs.isLibraryFABEnabled] = isLibraryFABEnabled();
    outputs[ConfigurationOutputs.isAccessibleMeetingsTabEnabled] =
        isAccessibleMeetingsTabEnabled();

    return outputs;
  }

  /// Controls visibility of library FAB.
  bool isLibraryFABEnabled() {
    return repo.checkVisiblity(
      ConfigurationInputEnum<ConfigurationFirestoreConfigInputEnum>(
          ConfigurationFirestoreConfigInputEnum.isLibraryFABEnabled),

      /// However when you are developer you will see it.
      overrides: [
        ConfigurationInputEnum<ConfigurationAuthStateInputEnum>(
          ConfigurationAuthStateInputEnum.isDeveloper,
          value: true,
        )
      ],
    );
  }

  /// Controls visibility of accessible meetings tab.
  bool isAccessibleMeetingsTabEnabled() {
    return repo.checkVisiblity(
        ConfigurationInputEnum<ConfigurationFirestoreConfigInputEnum>(
          ConfigurationFirestoreConfigInputEnum.isAccessibleMeetingsTabEnabled,
        ),

        /// However when you are developer you will see it.
        overrides: [
          ConfigurationInputEnum<ConfigurationAuthStateInputEnum>(
              ConfigurationAuthStateInputEnum.isDeveloper,
              value: true)
        ]);
  }

  /// Controls visibility of workspace prompting.
  bool isWorkspacePromptingEnabled() {
    return repo.checkVisiblity(
        ConfigurationInputEnum<ConfigurationFirestoreConfigInputEnum>(
          ConfigurationFirestoreConfigInputEnum.isWorkspacePromptingEnabled,
        ),

        /// However when you are developer you will see it.
        overrides: [
          ConfigurationInputEnum<ConfigurationAuthStateInputEnum>(
              ConfigurationAuthStateInputEnum.isDeveloper,
              value: true)
        ]);
  }
}

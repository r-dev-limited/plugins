import 'package:logging/logging.dart';

import '../../data/configuration_manager_repository.dart';
import '../inputs/configuration_inputs.dart';
import 'visibility_output.dart';

/// This class contains business logic, joining different inputs and outputs
/// Also keeping information about order and exceptions.
///
/// Configuration repo is injected in, so we have full control over it.(tests)
class AuthenticationVisibilityOutput extends VisibilityOutput {
  @override
  // ignore: overridden_fields
  final log = Logger('AuthConfigurationOutputs');

  AuthenticationVisibilityOutput(super.ref);

  @override
  Map<ConfigurationOutputs, bool> processOutputs() {
    final outputs = <ConfigurationOutputs, bool>{};

    outputs[ConfigurationOutputs.isAuthEmailPasswordEnabled] =
        isAuthEmailPasswordEnabled();

    outputs[ConfigurationOutputs.isAuthAppleEnabled] = isAuthAppleEnabled();

    outputs[ConfigurationOutputs.isAuthFacebookEnabled] =
        isAuthFacebookEnabled();

    outputs[ConfigurationOutputs.isAuthGoogleEnabled] = isAuthGoogleEnabled();

    outputs[ConfigurationOutputs.isAuthMicrosoftEnabled] =
        isAuthMicrosoftEnabled();

    outputs[ConfigurationOutputs.isMaintenanceModeEnabled] =
        isMaintenanceModeEnabled();

    return outputs;
  }

  /// Controls visibility of maintenance page.
  bool isMaintenanceModeEnabled() {
    return repo.checkVisiblity(
      ConfigurationInputEnum<ConfigurationFirestoreConfigInputEnum>(
          ConfigurationFirestoreConfigInputEnum.isMaintenanceModeEnabled),

      /// However when you are developer you can still access the app
      overrides: [
        ConfigurationInputEnum<ConfigurationAuthStateInputEnum>(
          ConfigurationAuthStateInputEnum.isDeveloper,
          value: false,
        )
      ],
    );
  }

  /// Controls visibility of email password authentication.
  bool isAuthEmailPasswordEnabled() {
    return repo.checkVisiblity(
      ConfigurationInputEnum<ConfigurationFirestoreConfigInputEnum>(
          ConfigurationFirestoreConfigInputEnum.isAuthEmailPasswordEnabled),

      /// However when you are developer you will see it.
      overrides: [
        ConfigurationInputEnum<ConfigurationAuthStateInputEnum>(
          ConfigurationAuthStateInputEnum.isDeveloper,
          value: true,
        )
      ],
    );
  }

  /// Controls visibility of apple authentication.
  bool isAuthAppleEnabled() {
    return repo.checkVisiblity(
        ConfigurationInputEnum<ConfigurationFirestoreConfigInputEnum>(
          ConfigurationFirestoreConfigInputEnum.isAuthAppleEnabled,
        ),

        /// However when you are developer you will see it.
        overrides: [
          ConfigurationInputEnum<ConfigurationAuthStateInputEnum>(
            ConfigurationAuthStateInputEnum.isDeveloper,
            value: true,
          ),
        ]);
  }

  bool isAuthFacebookEnabled() {
    return repo.checkVisiblity(
        ConfigurationInputEnum<ConfigurationFirestoreConfigInputEnum>(
          ConfigurationFirestoreConfigInputEnum.isAuthFacebookEnabled,
        ),

        /// However when you are developer you will see it.
        overrides: [
          ConfigurationInputEnum<ConfigurationAuthStateInputEnum>(
            ConfigurationAuthStateInputEnum.isDeveloper,
            value: true,
          ),
        ]);
  }

  /// Controls visibility of google authentication.
  bool isAuthGoogleEnabled() {
    return repo.checkVisiblity(
        ConfigurationInputEnum<ConfigurationFirestoreConfigInputEnum>(
          ConfigurationFirestoreConfigInputEnum.isAuthGoogleEnabled,
        ),

        /// However when you are developer you will see it.
        overrides: [
          ConfigurationInputEnum<ConfigurationAuthStateInputEnum>(
            ConfigurationAuthStateInputEnum.isDeveloper,
            value: true,
          )
        ]);
  }

  /// Controls visibility of microsoft authentication.
  bool isAuthMicrosoftEnabled() {
    return repo.checkVisiblity(
        ConfigurationInputEnum<ConfigurationFirestoreConfigInputEnum>(
          ConfigurationFirestoreConfigInputEnum.isAuthMicrosoftEnabled,
        ),

        /// However when you are developer you will see it.
        overrides: [
          ConfigurationInputEnum<ConfigurationAuthStateInputEnum>(
            ConfigurationAuthStateInputEnum.isDeveloper,
            value: true,
          )
        ]);
  }
}

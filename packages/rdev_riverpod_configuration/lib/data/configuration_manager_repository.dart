import 'dart:async';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:rdev_feature_toggles/application/feature_toggles_data_service.dart';
import 'package:rdev_feature_toggles/domain/feature_toggle_entry_model.dart';
import 'package:rdev_feature_toggles/domain/feature_toggle_model.dart';
import 'package:rdev_riverpod_firebase_auth/data/auth_repository.dart';

import '../application/source_shared_preferences_service.dart';
import '../domain/inputs/configuration_inputs.dart';
import '../domain/outputs/authentication_visibility_output.dart';
import '../domain/outputs/billing_visibility_output.dart';
import '../domain/outputs/library_visibility_output.dart';

enum ConfigurationOutputs {
  isAccessibleMeetingsTabEnabled,
  isAuthAppleEnabled,
  isAuthFacebookEnabled,
  isAuthEmailPasswordEnabled,
  isAuthGoogleEnabled,
  isAuthMicrosoftEnabled,
  isBillingTabEnabled,
  isLibraryFABEnabled,
  isMaintenanceModeEnabled,
}

class ConfigurationManagerState extends Equatable {
  final Map<ConfigurationOutputs, bool> outputs;

  bool getOutput(ConfigurationOutputs output) => outputs[output] ?? false;

  const ConfigurationManagerState({
    this.outputs = const {},
  });

  ConfigurationManagerState copyWith({
    Map<ConfigurationOutputs, bool>? outputs,
    bool? isReady,
  }) {
    return ConfigurationManagerState(
      outputs: outputs ?? this.outputs,
    );
  }

  @override
  List<Object?> get props => [
        outputs.hashCode,
      ];
}

class ConfigurationManagerRepository
    extends AsyncNotifier<ConfigurationManagerState> {
  final log = Logger('ConfigurationManagerNotifier');

  /// Dependencies
  late FeatureTogglesDataService _featureToggleService;
  late SourceSharedPreferencesService _sharedPreferences;
  // late SourceRemoteConfigService _sourceRemoteConfigService;
  late AuthRepositoryState _authRepositoryState;
  late String _version;

  /// Variables
  final Map<ConfigurationEnvInputEnum, dynamic> _intputEnvVariables = {};
  Map<String, FeatureToggleEntryModel> _rootFeatureToggleMap = {};
  Map<String, FeatureToggleEntryModel> _userFeatureToggleMap = {};
  StreamSubscription? _firestoreRootConfigUpdateSubscription;
  StreamSubscription? _firestoreUserConfigUpdateSubscription;

  /// Tests
  @visibleForTesting
  SourceSharedPreferencesService get sharedPreferences => _sharedPreferences;
  //@visibleForTesting
  // SourceRemoteConfigService get remoteConfig => _sourceRemoteConfigService;

  /// Build (initialize)
  @override
  Future<ConfigurationManagerState> build() async {
    _authRepositoryState = ref.watch(AuthRepository.provider).value ??
        const AuthRepositoryState();
    _featureToggleService = ref.watch(FeatureTogglesDataService.provider);
    _sharedPreferences = ref.watch(SourceSharedPreferencesService.provider);
    // _sourceRemoteConfigService = ref.watch(SourceRemoteConfigService.provider);
    final envVersion = const String.fromEnvironment(
      ConfigurationEnvInputKeys.sentryRelease,
      defaultValue: '1.0.0',
    );
    _version = envVersion.startsWith('v') ? envVersion : 'v$envVersion';

    /// Init all sources
    await _initEnv();
    await _sharedPreferences.initialize();
    // await _sourceRemoteConfigService.initialize();

    final userId = _authRepositoryState.authUser?.uid;

    if (userId is String) {
      try {
        final userFeatureToggle = await _featureToggleService.getFeatureToggle(
          version: _version,
          parent: {'Users': userId},
        );
        _userFeatureToggleMap =
            _toggleListToMap(userFeatureToggle.toggles);

        /// Start streaming
        await _firestoreUserConfigUpdateSubscription?.cancel();
        _firestoreUserConfigUpdateSubscription =
            _featureToggleService.streamUserFeatureToggles(
          parent: {'Users': userId},
        ).listen((event) {
          final currentVersionToggle =
              event.firstWhereOrNull((element) => element.uid == _version);
          if (currentVersionToggle is FeatureToggleModel) {
            _userFeatureToggleMap =
                _toggleListToMap(currentVersionToggle.toggles);

            state = AsyncValue.data(_yieldState());
          }
        });
      } catch (e) {
        log.severe('Error getting user feature toggle: $e');
      }
    }

    try {
      final rootFeatureToggle =
          await _featureToggleService.getFeatureToggle(version: _version);
      _rootFeatureToggleMap =
          _toggleListToMap(rootFeatureToggle.toggles);

      /// Start streaming
      await _firestoreRootConfigUpdateSubscription?.cancel();
      _firestoreRootConfigUpdateSubscription =
          _featureToggleService.streamUserFeatureToggles().listen((event) {
        final currentVersionToggle =
            event.firstWhereOrNull((element) => element.uid == _version);
        if (currentVersionToggle is FeatureToggleModel) {
          _rootFeatureToggleMap.clear();
          _rootFeatureToggleMap =
              _toggleListToMap(currentVersionToggle.toggles);
          final newState = _yieldState();
          state = AsyncValue.data(newState);
        }
      });
    } catch (e) {
      log.severe('Error getting root feature toggle: $e');
    }

    return _yieldState();
  }

  /// Private Methods
  Future<void> _initEnv() async {
    _intputEnvVariables[ConfigurationEnvInputEnum.enableEmulator] =
        const bool.fromEnvironment(ConfigurationEnvInputKeys.enableEmulator);
    _intputEnvVariables[ConfigurationEnvInputEnum.flutterTest] =
        const bool.fromEnvironment(ConfigurationEnvInputKeys.flutterTest);
    _intputEnvVariables[ConfigurationEnvInputEnum.inRelease] =
        const bool.fromEnvironment(ConfigurationEnvInputKeys.inRelease);
    _intputEnvVariables[ConfigurationEnvInputEnum.isEmulator] =
        const bool.fromEnvironment(ConfigurationEnvInputKeys.isEmulator);
    _intputEnvVariables[ConfigurationEnvInputEnum.useHost] =
        const bool.fromEnvironment(ConfigurationEnvInputKeys.useHost);
    _intputEnvVariables[ConfigurationEnvInputEnum.gcpServiceAccount] =
        const String.fromEnvironment(
            ConfigurationEnvInputKeys.gcpServiceAccount);
    _intputEnvVariables[ConfigurationEnvInputEnum.googleWebClientId] =
        const String.fromEnvironment(
            ConfigurationEnvInputKeys.googleWebClientId);
    _intputEnvVariables[ConfigurationEnvInputEnum.typesenseUrl] =
        const String.fromEnvironment(ConfigurationEnvInputKeys.typesenseUrl);
  }

  bool? _firestoreHasFeature(
    ConfigurationFirestoreConfigInputEnum configurationInputEnum,
  ) {
    if (_userFeatureToggleMap.containsKey(configurationInputEnum.key)) {
      return _userFeatureToggleMap[configurationInputEnum.key]?.value;
    }

    if (_rootFeatureToggleMap.containsKey(configurationInputEnum.key)) {
      return _rootFeatureToggleMap[configurationInputEnum.key]?.value;
    }
    return null;
  }

  // void _initRemoteConfigListener() {
  //   _remoteConfigUpdateSubscription?.cancel();
  //   _remoteConfigUpdateSubscription =
  //       _sourceRemoteConfigService.configUpdatedListener.listen((event) async {
  //     log.info('Remote config updated on the updatedListener');
  //     await _sourceRemoteConfigService.activateConfigs();
  //     state = AsyncValue.data(_yieldState());
  //   });
  // }

  ConfigurationManagerState _yieldState() {
    final authOutputs = AuthenticationVisibilityOutput(ref);
    final billingOutputs = BillingVisibilityOutput(ref);
    final libraryOutput = LibraryVisibilityOutput(ref);

    ///
    final processedAuthOutputs = authOutputs.processOutputs();
    final processedBillingOutputs = billingOutputs.processOutputs();
    final processedLibraryOutputs = libraryOutput.processOutputs();

    ///
    final outputs = {
      ...processedAuthOutputs,
      ...processedBillingOutputs,
      ...processedLibraryOutputs,
    };

    return ConfigurationManagerState(outputs: outputs);
  }

  /// Actions
  dynamic getValue(dynamic configurationInputEnum) {
    if (configurationInputEnum is ConfigurationEnvInputEnum) {
      return _intputEnvVariables[configurationInputEnum];
    }

    ///
    else if (configurationInputEnum is ConfigurationRemoteConfigInputEnum) {
      return false;
      // return _sourceRemoteConfigService.hasFeature(configurationInputEnum);
    }

    ///
    else if (configurationInputEnum is ConfigurationFirestoreConfigInputEnum) {
      return _firestoreHasFeature(configurationInputEnum);
    }

    ///
    else if (configurationInputEnum
        is ConfigurationSharedPreferencesInputEnum) {
      return _sharedPreferences.getBool(configurationInputEnum.key);
    }

    ///
    else if (configurationInputEnum is ConfigurationAuthStateInputEnum) {
      return _authStateValue(configurationInputEnum) ?? false;
    }
    return false;
  }

  bool? _authStateValue(ConfigurationAuthStateInputEnum input) {
    switch (input) {
      case ConfigurationAuthStateInputEnum.isDeveloper:
        return _authRepositoryState.authUser != null &&
            _authRepositoryState.authUser!.isAnonymous == false;
      case ConfigurationAuthStateInputEnum.isPrivateWorkspace:
        return false;
    }
  }

  Map<String, FeatureToggleEntryModel> _toggleListToMap(
    List<FeatureToggleEntryModel>? toggles,
  ) {
    if (toggles == null) {
      return {};
    }
    return {
      for (final toggle in toggles) toggle.name: toggle,
    };
  }

  bool checkVisiblity(
    ConfigurationInputEnum flag, {
    List<ConfigurationInputEnum> overrides = const [],
    bool defaultIfNull = false,
  }) {
    bool? isEnabled;
    try {
      // Check overrides
      for (var element in overrides) {
        if (element is ConfigurationRemoteConfigInputEnum) {
          throw Exception(
              'ConfigurationRemoteConfigInputEnum is not allowed in overrides');
        }
        final result = getValue(element.inputEnum);
        final tmpIsEnabled = result is bool
            ? result
            : result is String
                ? result == 'true'
                : result is int
                    ? result == 1
                    : false;

        /// override is true, then use value
        if (tmpIsEnabled) {
          isEnabled = element.value;
        }
      }
      if (isEnabled != null) {
        return isEnabled;
      } else {
        /// Get value from remote config
        final result = getValue(flag.inputEnum);
        isEnabled = result is bool
            ? result
            : result is String
                ? result == 'true'
                : result is int
                    ? result == 1
                    : false;
      }
    } catch (err) {
      log.severe(err);
    }
    return isEnabled is bool ? isEnabled : defaultIfNull;
  }

  /// Provider
  static AsyncNotifierProvider<ConfigurationManagerRepository,
          ConfigurationManagerState> provider =
      AsyncNotifierProvider<ConfigurationManagerRepository,
          ConfigurationManagerState>(() {
    return ConfigurationManagerRepository();
  });
}

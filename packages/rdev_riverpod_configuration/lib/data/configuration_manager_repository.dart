import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

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
  //late FeatureToggleDataSource _featureToggleService;
  late SourceSharedPreferencesService _sharedPreferences;
  // late SourceRemoteConfigService _sourceRemoteConfigService;
  //late AuthUserRepositoryState _authUserRepositoryState;
  late String _version;

  /// Variables
  final Map<ConfigurationEnvInputEnum, dynamic> _intputEnvVariables = {};
  // Map<String, FeatureToggleEntry>? _rootFeatureToggleMap = {};
  // Map<String, FeatureToggleEntry>? _userFeatureToggleMap = {};
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
    _authUserRepositoryState = ref.watch(AuthUserRepository.provider).value ??
        const AuthUserRepositoryState();
    //_featureToggleService = ref.watch(FeatureToggleDataSource.provider);
    _sharedPreferences = ref.watch(SourceSharedPreferencesService.provider);
    // _sourceRemoteConfigService = ref.watch(SourceRemoteConfigService.provider);
    //_version =
    //  'v${ref.watch(packageInfoProvider.select((value) => value.value?.version)) ?? '1.0.0'}';

    /// Init all sources
    await _initEnv();
    await _sharedPreferences.initialize();
    // await _sourceRemoteConfigService.initialize();

    final userId = _authUserRepositoryState.authRepositoryState?.authUser?.uid;

    if (userId is String) {
      try {
        final userFeatureToggle = await _featureToggleService
            .getUserFeatureToggle(version: _version, userId: userId);
        _userFeatureToggleMap = userFeatureToggle.data.toggles;

        /// Start streaming
        await _firestoreUserConfigUpdateSubscription?.cancel();
        _firestoreUserConfigUpdateSubscription = _featureToggleService
            .streamUserFeatureToggles(
          userId: userId,
        )
            .listen((event) {
          final currentVersionToggle =
              event.firstWhereOrNull((element) => element.uid == _version);
          if (currentVersionToggle is FeatureToggleModel) {
            _userFeatureToggleMap = currentVersionToggle.data.toggles;

            state = AsyncValue.data(_yieldState());
          }
        });
      } catch (e) {
        log.severe('Error getting user feature toggle: $e');
      }
    }

    try {
      final rootFeatureToggle =
          await _featureToggleService.getFeatureRootToggle(version: _version);
      _rootFeatureToggleMap = rootFeatureToggle.data.toggles;

      /// Start streaming
      await _firestoreRootConfigUpdateSubscription?.cancel();
      _firestoreRootConfigUpdateSubscription =
          _featureToggleService.streamRootFeatureToggles().listen((event) {
        final currentVersionToggle =
            event.firstWhereOrNull((element) => element.uid == _version);
        if (currentVersionToggle is FeatureToggleModel) {
          _rootFeatureToggleMap?.clear();
          _rootFeatureToggleMap = currentVersionToggle.data.toggles;
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
    if (_userFeatureToggleMap?.containsKey(configurationInputEnum.key) ==
        true) {
      return _userFeatureToggleMap![configurationInputEnum.key]?.value;
    }

    if (_rootFeatureToggleMap?.containsKey(configurationInputEnum.key) ==
        true) {
      return _rootFeatureToggleMap![configurationInputEnum.key]?.value;
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
      final map = _authUserRepositoryState.authRepositoryState?.toMap();
      return map?[configurationInputEnum.key] ?? false;
    }
    return false;
  }

  Future<void> _setValue(
      dynamic configurationInputEnum, String newValue) async {
    if (configurationInputEnum is ConfigurationEnvInputEnum) {
      throw ErrorDescription('It is not possible to set environment values');
    }

    ///
    else if (configurationInputEnum is ConfigurationRemoteConfigInputEnum) {
      throw ErrorDescription('It is not possible to set remote config values');
    }

    ///
    else if (configurationInputEnum
        is ConfigurationSharedPreferencesInputEnum) {
      _sharedPreferences.setString(configurationInputEnum.key, newValue);
    }
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

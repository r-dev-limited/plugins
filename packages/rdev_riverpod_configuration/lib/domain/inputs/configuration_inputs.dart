/// Keys for configuration inputs
abstract class ConfigurationInputKey {}

class ConfigurationAuthStateInputKeys extends ConfigurationInputKey {
  static const String isDeveloper = 'isDeveloper';
  static const String isPrivateWorkspace = 'isPrivateWorkspace';
}

class ConfigurationEnvInputKeys extends ConfigurationInputKey {
  static const String enableEmulator = 'ENABLE_EMULATOR';
  static const String flutterTest = 'FLUTTER_TEST';
  static const String inRelease = 'IN_RELEASE';
  static const String isEmulator = 'IS_EMULATOR';
  static const String useHost = 'USE_HOST';
  static const String gcpServiceAccount = 'GCP_SERVICE_ACCOUNT';
  static const String googleWebClientId = 'GOOGLE_WEB_CLIENT_ID';
  static const String typesenseUrl = 'TYPESENSE_URL';
  static const String sentryRelease = 'SENTRY_RELEASE';
}

class ConfigurationRemoteConfigInputKeys extends ConfigurationInputKey {
  static const String testValue = 'test_value';
}

class ConfigurationFirestoreConfigInputKeys extends ConfigurationInputKey {
  static const String isMaintenanceModeEnabled = 'isMaintenanceModeEnabled';
  static const String isAuthEmailPasswordEnabled = 'isAuthEmailPasswordEnabled';
  static const String isAuthAppleEnabled = 'isAuthAppleEnabled';
  static const String isAuthFacebookEnabled = 'isAuthFacebookEnabled';
  static const String isAuthGoogleEnabled = 'isAuthGoogleEnabled';
  static const String isAuthMicrosoftEnabled = 'isAuthMicrosoftEnabled';
  static const String isAccessibleMeetingsTabEnabled =
      'isAccessibleMeetingsTabEnabled';
  static const String isBillingTabEnabled = 'isBillingTabEnabled';
  static const String isWorkspaceSwitcherEnabled = 'isWorkspaceSwitcherEnabled';
  static const String isWorkspaceInvitationDialogEnabled =
      'isWorkspaceInvitationDialogEnabled';
  static const String isLibraryFABEnabled = 'isLibraryFABEnabled';
  static const String isSettingsMenuEnabled = 'isSettingsMenuEnabled';
  static const String isWorkspaceMembersTabEnabled =
      'isWorkspaceMembersTabEnabled';
  static const String isSettingsWorkspaceTabEnabled =
      'isSettingsWorkspaceTabEnabled';
  static const String isMeetingPromptTabEnabled = 'isMeetingPromptTabEnabled';
  static const String isWorkspacePromptingEnabled =
      'isWorkspacePromptingEnabled';
  static const String isMeetingShareAccessControlEnabled =
      'isMeetingShareAccessControlEnabled';
}

class ConfigurationAnalyticsUserPropertyKeys extends ConfigurationInputKey {
  static const String isInternalUser = 'is_internal_user';
  static const String isAdminUser = 'is_admin_user';
  static const String organisation = 'user_organisation';
}

class ConfigurationSharedPreferencesInputKeys extends ConfigurationInputKey {
  static const String skipOnboarding = 'skip_onboarding';
}

/// Enums to make sure we can only access certain inputs for certain type
enum ConfigurationAuthStateInputEnum {
  isDeveloper(ConfigurationAuthStateInputKeys.isDeveloper),
  isPrivateWorkspace(ConfigurationAuthStateInputKeys.isPrivateWorkspace);

  final String key;

  const ConfigurationAuthStateInputEnum(this.key);
}

enum ConfigurationSharedPreferencesInputEnum {
  skipOnboarding(ConfigurationSharedPreferencesInputKeys.skipOnboarding);

  final String key;

  const ConfigurationSharedPreferencesInputEnum(this.key);
}

enum ConfigurationEnvInputEnum {
  enableEmulator(ConfigurationEnvInputKeys.enableEmulator),
  flutterTest(ConfigurationEnvInputKeys.flutterTest),
  inRelease(ConfigurationEnvInputKeys.inRelease),
  isEmulator(ConfigurationEnvInputKeys.isEmulator),
  useHost(ConfigurationEnvInputKeys.useHost),
  gcpServiceAccount(ConfigurationEnvInputKeys.gcpServiceAccount),
  googleWebClientId(ConfigurationEnvInputKeys.googleWebClientId),
  typesenseUrl(ConfigurationEnvInputKeys.typesenseUrl),
  sentryRelease(ConfigurationEnvInputKeys.sentryRelease);

  final String key;

  const ConfigurationEnvInputEnum(this.key);
}

enum ConfigurationFirestoreConfigInputEnum {
  isMaintenanceModeEnabled(
    ConfigurationFirestoreConfigInputKeys.isMaintenanceModeEnabled,
    false,
  ),

  isAuthEmailPasswordEnabled(
    ConfigurationFirestoreConfigInputKeys.isAuthEmailPasswordEnabled,
    false,
  ),

  isAuthAppleEnabled(
      ConfigurationFirestoreConfigInputKeys.isAuthAppleEnabled, false),

  isAuthFacebookEnabled(
      ConfigurationFirestoreConfigInputKeys.isAuthFacebookEnabled, false),

  isAuthGoogleEnabled(
    ConfigurationFirestoreConfigInputKeys.isAuthGoogleEnabled,
    true,
  ),

  isAuthMicrosoftEnabled(
      ConfigurationFirestoreConfigInputKeys.isAuthMicrosoftEnabled, false),

  isAccessibleMeetingsTabEnabled(
      ConfigurationFirestoreConfigInputKeys.isAccessibleMeetingsTabEnabled,
      false),

  isBillingTabEnabled(
      ConfigurationFirestoreConfigInputKeys.isBillingTabEnabled, true),

  isWorkspaceSwitcherEnabled(
    ConfigurationFirestoreConfigInputKeys.isWorkspaceSwitcherEnabled,
    true,
  ),

  isWorkspaceInvitationDialogEnabled(
    ConfigurationFirestoreConfigInputKeys.isWorkspaceInvitationDialogEnabled,
    true,
  ),

  isLibraryFABEnabled(
      ConfigurationFirestoreConfigInputKeys.isLibraryFABEnabled, true),

  isSettingsMenuEnabled(
    ConfigurationFirestoreConfigInputKeys.isSettingsMenuEnabled,
    false,
  ),

  isWorkspaceMembersTabEnabled(
    ConfigurationFirestoreConfigInputKeys.isWorkspaceMembersTabEnabled,
    false,
  ),

  isSettingsWorkspaceTabEnabled(
    ConfigurationFirestoreConfigInputKeys.isSettingsWorkspaceTabEnabled,
    false,
  ),

  isMeetingPromptTabEnabled(
      ConfigurationFirestoreConfigInputKeys.isMeetingPromptTabEnabled, false),

  isWorkspacePromptingEnabled(
      ConfigurationFirestoreConfigInputKeys.isWorkspacePromptingEnabled, false),

  isMeetingShareAccessControlEnabled(
      ConfigurationFirestoreConfigInputKeys.isMeetingShareAccessControlEnabled,
      false);

  final String key;
  final dynamic defaultValue;
  Map<String, dynamic> get map => {key: defaultValue};
  const ConfigurationFirestoreConfigInputEnum(
    this.key,
    this.defaultValue,
  );
}

enum ConfigurationRemoteConfigInputEnum {
  testValue(
    ConfigurationRemoteConfigInputKeys.testValue,
    'N/A',
  );

  final String key;
  final dynamic defaultValue;
  Map<String, dynamic> get map => {key: defaultValue};
  const ConfigurationRemoteConfigInputEnum(
    this.key,
    this.defaultValue,
  );
}

/// Enum holder
class ConfigurationInputEnum<T> {
  late final T inputEnum;
  final bool? value;

  ConfigurationInputEnum(T inputEnum, {this.value}) {
    if (inputEnum is ConfigurationAuthStateInputEnum ||
        inputEnum is ConfigurationSharedPreferencesInputEnum ||
        inputEnum is ConfigurationEnvInputEnum ||
        inputEnum is ConfigurationRemoteConfigInputEnum ||
        inputEnum is ConfigurationFirestoreConfigInputEnum) {
      //OK
      this.inputEnum = inputEnum;
    } else {
      assert(false, 'inputEnum: invalid type');
    }
  }
}

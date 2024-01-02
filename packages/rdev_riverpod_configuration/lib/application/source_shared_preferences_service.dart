import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SourceSharedPreferencesServiceException extends RdevException {
  SourceSharedPreferencesServiceException({
    String? message,
    RdevCode? code,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          stackTrace: stackTrace,
        );
}

/// FB: We can add more methods to this class as needed.
/// FB: Should limit the 'key' to a proto? Limiting our key options
/// FB: Should these be singletons :thinking:
class SourceSharedPreferencesService {
  final log = Logger('SourceSharedPreferencesService');

  late SharedPreferences sharedPreferences;

  static final _instance = SourceSharedPreferencesService._();

  factory SourceSharedPreferencesService() => _instance;

  static SourceSharedPreferencesService get instance => _instance;

  SourceSharedPreferencesService._() {
    initialize();
  }

  Future<void> initialize() async {
    log.info('initializeSharedPreferences()');
    try {
      sharedPreferences = await SharedPreferences.getInstance();
    } catch (error) {
      log.severe('initializeSharedPreferences()', error);
      throw SourceSharedPreferencesServiceException();
    }
  }

  Future<bool> setString(
    String key,
    String value,
  ) async {
    log.info('setString() - "key": $key, "value": $value');
    try {
      return await sharedPreferences.setString(key, value);
    } catch (error) {
      log.severe('setString()', error);
      throw SourceSharedPreferencesServiceException();
    }
  }

  Future<bool> setBool(
    String key,
    bool value,
  ) async {
    log.info('setBool() - "key": $key, "value": $value');
    try {
      return await sharedPreferences.setBool(key, value);
    } catch (error) {
      log.severe('setBool()', error);
      throw SourceSharedPreferencesServiceException();
    }
  }

  bool? getBool(String key) {
    log.info('getBool() - "key": $key');

    try {
      return sharedPreferences.getBool(key);
    } catch (error) {
      log.severe('getBool()', error);
      throw SourceSharedPreferencesServiceException();
    }
  }

  String? getString(String key) {
    log.info('getString() - "key": $key');
    try {
      return sharedPreferences.getString(key);
    } catch (error) {
      log.severe('getBool()', error);
      throw SourceSharedPreferencesServiceException();
    }
  }

  Object? get(String key) {
    log.info('get() - "key": $key');
    try {
      return sharedPreferences.get(key);
    } catch (error) {
      log.severe('get()', error);
      throw SourceSharedPreferencesServiceException();
    }
  }

  static Provider<SourceSharedPreferencesService> provider =
      Provider<SourceSharedPreferencesService>(
    (ref) => SourceSharedPreferencesService(),
  );
}

import 'dart:math';

import 'package:logging/logging.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';
import '../application/event_logger.dart';

class EventException extends RdevException {
  EventException({
    String? message,
    RdevCode? code,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          stackTrace: stackTrace,
        );
}

class Event {
  final logging = Logger('Event');

  /// Analytics limitation.
  static const int eventNameMaximumLength = 40;

  ///
  static const String parameterNullValue = 'null';

  ///
  static const String parameterSourceKey = 'source';

  ///
  final Map<String, Object> _parameters = {};

  ///
  final String _name;

  ///
  final EventLogger _eventLogger;

  Event._(this._name, String source, Map<String, Object> optionalParameters,
      this._eventLogger) {
    if (_name.isEmpty) {
      logging.severe('Event names may not be empty');
      throw EventException();
    }

    if (_name.length > eventNameMaximumLength) {
      logging.severe(
          'Event names can not be more then 40 characters! name: $_name');
      throw EventException();
    }

    if (source.isEmpty) {
      logging.severe('Event source may not be empty.');
      throw EventException();
    }

    if (_name.trim().isEmpty) {
      logging.severe('Event names may not contain whitespace.');
      throw EventException();
    }

    _parameters[parameterSourceKey] = source;
    if (optionalParameters.isNotEmpty) {
      _parameters.addAll(_sanitiseParameters(optionalParameters));
    }
  }

  /// Create an event, providing the source yourself.
  Event.source({
    required String name,
    required String source,
    Map<String, Object> parameters = const {},
    required EventLogger logger,
  }) : this._(name.trim(), source.trim(), parameters, logger);

  String get name =>
      _name.substring(0, min(_name.length, eventNameMaximumLength));

  Map<String, Object> get parameters => _parameters;

  void addParameter({required String name, dynamic value}) {
    final trimmedNamed = name.trim();
    if (_name.trim().isEmpty) {
      logging.severe('Parameter names may not contain whitespace');
      throw EventException();
    }

    if (trimmedNamed.isEmpty) {
      logging.severe('Parameter names may not be empty');
      throw EventException();
    }
    _parameters[trimmedNamed] = value ?? parameterNullValue;
  }

  void addParameters(Map<String, Object> parameters) {
    if (parameters.isNotEmpty) {
      _parameters.addAll(_sanitiseParameters(parameters));
    }
  }

  Map<String, Object> _sanitiseParameters(Map<String, Object> parameters) {
    return parameters.map((String key, dynamic value) {
      final trimmedKey = key.trim();
      if (_name.trim().isEmpty) {
        logging.severe('Event names may not contain whitespace');
        throw EventException();
      }

      if (trimmedKey.isEmpty) {
        logging.severe('Parameter may not be empty');
        throw EventException();
      }

      dynamic sanitisedValue = value;
      if (value is String) {
        if (value.length > 100) {
          // Parameter values may not exceed 100 characters in length.
          // This shouldn't happen but we trigger the event nevertheless
          sanitisedValue = value.substring(0, 100).trim();

          /// This way we will have triggered an event but we log the error.
          /// Otherwise we might lose data by truncating it at same time if we
          /// throw an error we might lose the event because of the throw.
          logging.severe(
              'Parameter values may not exceed 100 characters in length. Parameter: $trimmedKey, Value: $sanitisedValue');
        }
      }
      return MapEntry(trimmedKey, sanitisedValue ?? parameterNullValue);
    });
  }

  Future<void> log() async {
    return await _eventLogger.log(this);
  }
}

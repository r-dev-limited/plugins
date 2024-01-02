import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:rdev_errors_logging/rdev_exception.dart';

///
import 'event_logger.dart';
import '../domain/event.dart';
import '../domain/analytics_event.dart';

class AnalyticsDataSourceException extends RdevException {
  AnalyticsDataSourceException({
    String? message,
    RdevCode? code,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          stackTrace: stackTrace,
        );
}

/// Singleton AnalyticsDataSource class
class AnalyticsDataSource implements EventLogger {
  final logging = Logger('AnalyticsDataSource');

  late FirebaseAnalytics analytics;

  static final _instance = AnalyticsDataSource._();

  factory AnalyticsDataSource() => _instance;

  AnalyticsDataSource._() {
    logging.info('AnalyticsDataSource._()');
  }

  static AnalyticsDataSource get instance => _instance;

  void initializeFirebaseAnalytics(FirebaseAnalytics analytics) {
    if (kDebugMode) {
      _instance.analytics = FirebaseAnalytics.instance;
    } else {
      _instance.analytics = analytics;
    }
  }

  Future<void> setAnalyticsUserId(
    String? userId,
  ) async {
    logging.info('setAnalyticsUserId() - userId: $userId ');
    try {
      return await _instance.analytics.setUserId(id: userId);
    } catch (error) {
      logging.severe('setAnalyticsUserId()', error);
      throw AnalyticsDataSourceException();
    }
  }

  Future<void> setUserProperty(
    String name,
    String value,
  ) async {
    logging.info(
      'setUserProperty() - "name": $name, "value": $value',
    );
    try {
      return await _instance.analytics
          .setUserProperty(name: name, value: value);
    } catch (error) {
      logging.severe('setUserProperty()', error);
      throw AnalyticsDataSourceException();
    }
  }

  Future<void> logEvent(
    String name, [
    Map<String, dynamic> parameters = const {'source': 'currentScreenName'},
  ]) async {
    logging.info('logEvent() - name: $name, parameters: $parameters');
    if (name.length > 40) {
      logging.severe(
          'Event names must be a maximum of 40 characters. name: $name');
      throw AnalyticsDataSourceException();
    }

    if (parameters['source'] == null) {
      logging.severe('Event must have a source value');
      throw AnalyticsDataSourceException();
    }

    return _instance.analytics.logEvent(name: name, parameters: parameters);
  }

  @override
  Future<void> log(Event event) async {
    logging.info('log()');

    try {
      await _instance.analytics.logEvent(
        name: event.name,
        parameters: event.parameters,
      );
    } catch (error) {
      logging.severe('log()', error);
    }
  }

  @override
  Future<void> logEventFor(AnalyticsEvent value) async {
    logging.info('logEventFor() value: $value');
    try {
      final event = this.event(value.eventName);
      final parameters = value.toJson();
      parameters.remove('name');
      event.addParameters(parameters);
      return event.log();
    } catch (error) {
      logging.severe('logEventFor()', error);
      throw AnalyticsDataSourceException();
    }
  }

  Event event(String name, {bool duringAppStart = false}) {
    logging.info('event() - "name": $name, "duringAppStart": $duringAppStart');

    final String source;

    source = 'currentScreenName'; // Default screen name

    return Event.source(name: name, source: source, logger: this);
  }
}

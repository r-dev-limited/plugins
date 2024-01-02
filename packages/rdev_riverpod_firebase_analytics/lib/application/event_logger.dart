import '../domain/analytics_event.dart';
import '../domain/event.dart';

abstract class EventLogger {
  Future<void> log(Event event);

  Future<void> logEventFor(AnalyticsEvent event);
}

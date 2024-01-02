import 'package:equatable/equatable.dart';

abstract class AnalyticsEvent extends Equatable {
  final String eventName;
  const AnalyticsEvent(this.eventName);
  Map<String, dynamic> toJson();
}

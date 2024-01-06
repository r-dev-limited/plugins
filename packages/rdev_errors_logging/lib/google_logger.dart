// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:googleapis/logging/v2.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'dart:convert';

import 'package:logging/logging.dart';

enum GoogleLoggerSeverity {
  DEFAULT,
  DEBUG,
  INFO,
  NOTICE,
  WARNING,
  ERROR,
  CRITICAL,
  ALERT,
  EMERGENCY,
}

class GoogleLogger {
  final String projectId;
  AutoRefreshingAuthClient? _httpClient;
  LoggingApi? _logger;

  ///
  GoogleLogger({
    required this.projectId,
    String? serviceAccount,
    AutoRefreshingAuthClient? client,
  }) {
    if (client is AutoRefreshingAuthClient) {
      _httpClient = client;
      _logger = LoggingApi(_httpClient!);
    } else if (serviceAccount is String) {
      clientViaServiceAccount(
          ServiceAccountCredentials.fromJson(
            utf8.decode(
              base64Decode(
                serviceAccount,
              ),
            ),
          ),
          [
            LoggingApi.loggingWriteScope,
          ]).then((value) {
        _httpClient = value;
        _logger = LoggingApi(_httpClient!);
      }).catchError((err) {
        debugPrint(err.toString());
      });
    }
  }

  Future<void> logEvent({
    String? message,
    Map<String, Object?>? args,
    GoogleLoggerSeverity? severity = GoogleLoggerSeverity.DEFAULT,
    Map<String, String>? labels,
    LogEntryOperation? operation,
    String? functionName,
    String? fileName,
  }) async {
    try {
      final Map<String, Object> params = {};
      if (message is String) {
        params['message'] = message;
      }
      if (args is Map<String, Object?>) {
        args.forEach((key, value) {
          if (value != null) {
            params[key] = value.toString();
          }
        });
      }
      final logEntry = LogEntry(
          logName: 'projects/$projectId/logs/flutter-log',
          jsonPayload: params,
          severity: severity.toString().split('.').last,
          operation: operation,
          sourceLocation: LogEntrySourceLocation(
            function: functionName,
            file: fileName,
          ),
          resource: MonitoredResource(type: 'global'),
          labels: labels);
      final req = WriteLogEntriesRequest(entries: [logEntry]);
      _logger?.entries.write(req);
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  Future<void> onRecord(
      {required LogRecord record,
      String? deviceId,
      String? buildNumber,
      String? version}) async {
    /// First write logs to console
    print(
        '${record.level.name}: ${record.time}: ${record.loggerName}\n${record.message.isNotEmpty ? record.message : ''}${record.object != null && record.object!.toString().isNotEmpty ? '\n${record.object!.toString()}' : ''}${record.error != null && record.error!.toString().isNotEmpty ? '\n${record.error!.toString()}' : ''}${record.stackTrace != null && record.stackTrace!.toString().isNotEmpty ? '\n${record.stackTrace!.toString()}' : ''}');

    /// Then send it via Bugfender
    if (record.level == Level.SHOUT) {
      logEvent(
        severity: GoogleLoggerSeverity.EMERGENCY,
        args: {
          'message': record.message,
          'object': record.object,
          'error': record.error,
          'stackTrace': record.stackTrace,
          'deviceId': deviceId,
          'buildNumber': buildNumber,
          'version': version,
        },
        functionName: record.message,
        fileName: record.loggerName,
      );
    } else if (record.level == Level.SEVERE) {
      logEvent(
        severity: GoogleLoggerSeverity.ALERT,
        args: {
          'message': record.message,
          'object': record.object,
          'error': record.error,
          'stackTrace': record.stackTrace,
          'deviceId': deviceId,
          'buildNumber': buildNumber,
          'version': version,
        },
        functionName: record.message,
        fileName: record.loggerName,
      );
    } else if (record.level == Level.WARNING) {
      logEvent(
        severity: GoogleLoggerSeverity.WARNING,
        args: {
          'message': record.message,
          'object': record.object,
          'error': record.error,
          'stackTrace': record.stackTrace,
          'deviceId': deviceId,
          'buildNumber': buildNumber,
          'version': version,
        },
        functionName: record.message,
        fileName: record.loggerName,
      );
    } else if (record.level == Level.INFO) {
      logEvent(
        severity: GoogleLoggerSeverity.INFO,
        args: {
          'message': record.message,
          'object': record.object,
          'error': record.error,
          'stackTrace': record.stackTrace,
          'deviceId': deviceId,
          'buildNumber': buildNumber,
          'version': version,
        },
        functionName: record.message,
        fileName: record.loggerName,
      );
    } else if (record.level == Level.FINE) {
      logEvent(
        severity: GoogleLoggerSeverity.NOTICE,
        args: {
          'message': record.message,
          'object': record.object,
          'error': record.error,
          'stackTrace': record.stackTrace,
          'deviceId': deviceId,
          'buildNumber': buildNumber,
          'version': version,
        },
        functionName: record.message,
        fileName: record.loggerName,
      );
    } else if (record.level == Level.FINER) {
      logEvent(
        severity: GoogleLoggerSeverity.DEBUG,
        args: {
          'message': record.message,
          'object': record.object,
          'error': record.error,
          'stackTrace': record.stackTrace,
          'deviceId': deviceId,
          'buildNumber': buildNumber,
          'version': version,
        },
        functionName: record.message,
        fileName: record.loggerName,
      );
    } else if (record.level == Level.FINEST) {
      logEvent(
        severity: GoogleLoggerSeverity.DEFAULT,
        args: {
          'message': record.message,
          'object': record.object,
          'error': record.error,
          'stackTrace': record.stackTrace,
          'deviceId': deviceId,
          'buildNumber': buildNumber,
          'version': version,
        },
        functionName: record.message,
        fileName: record.loggerName,
      );
    }
  }
}

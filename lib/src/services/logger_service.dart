import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:dio/dio.dart';

/// Robust Logger Service
/// Comprehensive logging with Talker, Bloc, GoRouter, and remote logging
class LoggerService {
  LoggerService._();

  static LoggerService? _instance;
  static Talker? _talker;
  static Dio? _remoteLogger;
  static String? _remoteEndpoint;
  static bool _remoteLoggingEnabled = false;

  static LoggerService get instance => _instance ??= LoggerService._();

  /// Initialize logger with comprehensive configuration
  static void init({
    bool enabled = true,
    LogLevel logLevel = LogLevel.debug,
    List<TalkerObserver>? observers,
    TalkerSettings? settings,
    TalkerLoggerSettings? loggerSettings,
    // Remote logging
    String? remoteEndpoint,
    Map<String, String>? remoteHeaders,
    bool enableRemoteLogging = false,
    // Filtering
    List<String>? excludedTitles,
  }) {
    _talker = TalkerFlutter.init(
      settings:
          settings ??
          TalkerSettings(
            enabled: enabled,
            useConsoleLogs: kDebugMode,
            useHistory: true,
            maxHistoryItems: 1000,
            titles: excludedTitles != null
                ? {for (var title in excludedTitles) title: ''}
                : {},
          ),
      logger: TalkerLogger(
        settings:
            loggerSettings ??
            TalkerLoggerSettings(
              level: logLevel,
              enableColors: kDebugMode,
              lineSymbol: '│',
              // enableBorder: true,
            ),
      ),
      observer: observers != null && observers.isNotEmpty
          ? TalkerObserverWrapper(observers)
          : null,
    );

    // Setup remote logging
    if (enableRemoteLogging && remoteEndpoint != null) {
      _remoteEndpoint = remoteEndpoint;
      _remoteLoggingEnabled = true;
      _remoteLogger = Dio(
        BaseOptions(
          baseUrl: remoteEndpoint,
          headers: remoteHeaders ?? {},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
    }
  }

  Talker get talker {
    if (_talker == null) {
      throw Exception(
        'LoggerService not initialized. Call LoggerService.init() first.',
      );
    }
    return _talker!;
  }

  // ==================== Basic Logging ====================

  void debug(dynamic message, [Object? exception, StackTrace? stackTrace]) {
    talker.debug(message, exception, stackTrace);
  }

  void info(dynamic message, [Object? exception, StackTrace? stackTrace]) {
    talker.info(message, exception, stackTrace);
  }

  void warning(dynamic message, [Object? exception, StackTrace? stackTrace]) {
    talker.warning(message, exception, stackTrace);
  }

  void error(dynamic message, [Object? exception, StackTrace? stackTrace]) {
    talker.error(message, exception, stackTrace);
  }

  void critical(dynamic message, [Object? exception, StackTrace? stackTrace]) {
    talker.critical(message, exception, stackTrace);
  }

  void verbose(dynamic message) {
    if (kDebugMode) talker.verbose(message);
  }

  // ==================== HTTP Logging ====================

  void logHttpRequest(
    String method,
    String url, {
    Map<String, dynamic>? headers,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('🌐 HTTP $method: $url');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      buffer.writeln('Query: $queryParameters');
    }
    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('Headers: $headers');
    }
    if (data != null) {
      buffer.writeln('Data: $data');
    }
    talker.log(buffer.toString());
  }

  void logHttpResponse(
    String method,
    String url,
    int statusCode, {
    dynamic data,
    Duration? duration,
    Map<String, dynamic>? headers,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('✅ HTTP $method: $url - $statusCode');
    if (duration != null) {
      buffer.writeln('Duration: ${duration.inMilliseconds}ms');
    }
    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('Response Headers: $headers');
    }
    if (data != null) {
      buffer.writeln('Response: $data');
    }
    talker.log(buffer.toString());
  }

  void logHttpError(
    String method,
    String url, {
    int? statusCode,
    String? error,
    dynamic data,
  }) {
    final buffer = StringBuffer();
    buffer.writeln(
      '❌ HTTP $method: $url${statusCode != null ? ' - $statusCode' : ''}',
    );
    buffer.writeln('Error: ${error ?? 'Unknown error'}');
    if (data != null) {
      buffer.writeln('Data: $data');
    }
    talker.error(buffer.toString());
  }

  // ==================== Navigation Logging ====================

  void logNavigation(
    String from,
    String to, {
    Map<String, dynamic>? arguments,
    NavigationType type = NavigationType.push,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('🧭 Navigation ${type.name}: $from → $to');
    if (arguments != null && arguments.isNotEmpty) {
      buffer.writeln('Arguments: $arguments');
    }
    talker.info(buffer.toString());
  }

  void logRoute(String route, {Map<String, dynamic>? params}) {
    final buffer = StringBuffer();
    buffer.writeln('🛣️  Route: $route');
    if (params != null && params.isNotEmpty) {
      buffer.writeln('Params: $params');
    }
    talker.info(buffer.toString());
  }

  // ==================== User Actions ====================

  void logAction(String action, {Map<String, dynamic>? data, String? screen}) {
    final buffer = StringBuffer();
    buffer.writeln('👆 Action: $action');
    if (screen != null) {
      buffer.writeln('Screen: $screen');
    }
    if (data != null && data.isNotEmpty) {
      buffer.writeln('Data: $data');
    }
    talker.info(buffer.toString());
  }

  void logButtonClick(String buttonName, {String? screen}) {
    logAction('Button Click: $buttonName', screen: screen);
  }

  void logScreenView(String screenName, {Map<String, dynamic>? data}) {
    final buffer = StringBuffer();
    buffer.writeln('📱 Screen View: $screenName');
    if (data != null && data.isNotEmpty) {
      buffer.writeln('Data: $data');
    }
    talker.info(buffer.toString());
  }

  // ==================== Performance Logging ====================

  void logPerformance(
    String operation,
    Duration duration, {
    Map<String, dynamic>? metadata,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('⚡ Performance: $operation - ${duration.inMilliseconds}ms');
    if (metadata != null && metadata.isNotEmpty) {
      buffer.writeln('Metadata: $metadata');
    }
    talker.info(buffer.toString());
  }

  PerformanceTracker startPerformanceTracking(String operation) {
    return PerformanceTracker(operation);
  }

  // ==================== Bloc Logging ====================

  static TalkerBlocObserver getBlocObserver({
    TalkerBlocLoggerSettings? settings,
    Talker? customTalker,
    // Filters
    bool Function(Bloc bloc, Transition transition)? transitionFilter,
    bool Function(Bloc bloc, Object? event)? eventFilter,
    bool Function(Bloc bloc, Change change)? changeFilter,
  }) {
    return TalkerBlocObserver(
      talker: customTalker ?? _talker,
      settings:
          settings ??
          TalkerBlocLoggerSettings(
            enabled: true,
            printChanges: true,
            printClosings: true,
            printCreations: true,
            printEvents: true,
            printTransitions: true,
            printEventFullData: false,
            printStateFullData: false,
            transitionFilter: transitionFilter,
            eventFilter: eventFilter,
            // changeFilter: changeFilter,
          ),
    );
  }

  void logBlocEvent(String blocName, String eventName, {dynamic data}) {
    talker.info(
      '🎯 Bloc Event: $blocName.$eventName${data != null ? '\nData: $data' : ''}',
    );
  }

  void logBlocState(String blocName, String stateName, {dynamic data}) {
    talker.info(
      '📦 Bloc State: $blocName.$stateName${data != null ? '\nData: $data' : ''}',
    );
  }

  // ==================== Exception Handling ====================

  void handleException(
    Object exception, {
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    talker.handle(exception, stackTrace ?? StackTrace.current, context);
    if (additionalData != null) {
      debug('Exception context: $additionalData');
    }
  }

  // ==================== JSON & Data Logging ====================

  void logJson(Map<String, dynamic> json, {String? title}) {
    final formatted = const JsonEncoder.withIndent('  ').convert(json);
    info('${title ?? 'JSON Data'}:\n$formatted');
  }

  void logList(List<dynamic> list, {String? title}) {
    info('${title ?? 'List Data'} (${list.length} items):\n$list');
  }

  // ==================== History & Search ====================

  List<TalkerData> get history => talker.history;

  List<T> getLogsByType<T extends TalkerData>() {
    return talker.history.whereType<T>().toList();
  }

  List<TalkerError> get errors =>
      talker.history.whereType<TalkerError>().toList();
  List<TalkerException> get exceptions =>
      talker.history.whereType<TalkerException>().toList();

  List<TalkerData> searchLogs(String query) {
    return talker.history.where((log) {
      return log.displayMessage.toLowerCase().contains(query.toLowerCase()) ||
              log.title != null
          ? log.title!.toLowerCase().contains(query.toLowerCase())
          : log.displayMessage.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<TalkerData> filterByTimeRange(DateTime start, DateTime end) {
    return talker.history.where((log) {
      return log.time.isAfter(start) && log.time.isBefore(end);
    }).toList();
  }

  List<TalkerData> filterByLevel(LogLevel level) {
    return talker.history.where((log) {
      if (log is TalkerLog) {
        return (log.logLevel?.index ?? 0) >= level.index;
      }
      return true;
    }).toList();
  }

  // ==================== Configuration ====================

  void setEnabled(bool enabled) {
    talker.configure(settings: talker.settings.copyWith(enabled: enabled));
  }

  void setLogLevel(LogLevel level) {
    talker.configure(
      logger: TalkerLogger(
        settings: TalkerLoggerSettings(level: level, enableColors: kDebugMode),
      ),
    );
  }

  void setMaxHistoryItems(int max) {
    talker.configure(settings: talker.settings.copyWith(maxHistoryItems: max));
  }

  // ==================== Export & Remote Logging ====================

  String exportLogsAsText() {
    return talker.history
        .map(
          (log) => '[${log.time}] ${(log.title ?? '')}: ${log.displayMessage}',
        )
        .join('\n');
  }

  List<Map<String, dynamic>> exportLogsAsJson() {
    return talker.history.map((log) {
      return {
        'timestamp': log.time.toIso8601String(),
        'title': log.title,
        'message': log.displayMessage,
        'type': log.runtimeType.toString(),
      };
    }).toList();
  }

  Future<bool> sendLogsToServer({
    Duration? timeRange,
    LogLevel? minLevel,
  }) async {
    if (!_remoteLoggingEnabled || _remoteLogger == null) {
      warning('Remote logging not enabled');
      return false;
    }

    try {
      var logs = talker.history;

      if (timeRange != null) {
        final cutoff = DateTime.now().subtract(timeRange);
        logs = logs.where((log) => log.time.isAfter(cutoff)).toList();
      }

      if (minLevel != null) {
        logs = logs.where((log) {
          if (log is TalkerLog)
            return (log.logLevel?.index ?? 0) >= minLevel.index;
          return true;
        }).toList();
      }

      final logsJson = exportLogsAsJson();
      await _remoteLogger!.post(_remoteEndpoint!, data: {'logs': logsJson});

      info('Successfully sent ${logsJson.length} logs to server');
      return true;
    } catch (e, stackTrace) {
      error('Failed to send logs to server', e, stackTrace);
      return false;
    }
  }

  // ==================== UI ====================

  void showTalkerScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TalkerScreen(talker: talker)),
    );
  }

  void showTalkerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: TalkerScreen(talker: talker),
      ),
    );
  }

  // ==================== Cleanup ====================

  void clearLogs() => talker.cleanHistory();
  String getLogsAsString() =>
      talker.history.map((log) => log.generateTextMessage()).join('\n');
  void dispose() {
    _talker = null;
    _remoteLogger = null;
  }
}

// ==================== Helpers ====================

enum NavigationType { push, pop, replace, pushReplacement }

class PerformanceTracker {
  final String operation;
  final Stopwatch _stopwatch = Stopwatch();
  final LoggerService _logger = LoggerService.instance;
  Map<String, dynamic>? metadata;

  PerformanceTracker(this.operation) {
    _stopwatch.start();
  }

  void addMetadata(String key, dynamic value) {
    metadata ??= {};
    metadata![key] = value;
  }

  void stop() {
    _stopwatch.stop();
    _logger.logPerformance(operation, _stopwatch.elapsed, metadata: metadata);
  }

  Duration get elapsed => _stopwatch.elapsed;
}

class TalkerObserverWrapper extends TalkerObserver {
  final List<TalkerObserver> observers;
  TalkerObserverWrapper(this.observers);

  @override
  void onError(TalkerError err) {
    for (final observer in observers) observer.onError(err);
  }

  @override
  void onException(TalkerException exception) {
    for (final observer in observers) observer.onException(exception);
  }

  @override
  void onLog(TalkerData log) {
    for (final observer in observers) observer.onLog(log);
  }
}

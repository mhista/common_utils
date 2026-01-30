import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Logger Service
/// Comprehensive logging service using Talker package
class LoggerService {
  LoggerService._();

  static LoggerService? _instance;
  static Talker? _talker;

  static LoggerService get instance {
    _instance ??= LoggerService._();
    return _instance!;
  }

  static void init({
    bool enabled = true,
    LogLevel logLevel = LogLevel.debug,
    List<TalkerObserver>? observers,
    TalkerSettings? settings,
  }) {
    _talker = TalkerFlutter.init(
      settings: settings ??
          TalkerSettings(
            enabled: enabled,
            useConsoleLogs: kDebugMode,
            useHistory: true,
            maxHistoryItems: 1000,
          ),
      logger: TalkerLogger(
        settings: TalkerLoggerSettings(
          level: logLevel,
          enableColors: true,
        ),
      ),
    );
  }

  Talker get talker {
    if (_talker == null) {
      throw Exception('LoggerService not initialized. Call LoggerService.init() first.');
    }
    return _talker!;
  }

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

  void logRequest(String method, String url, {Map<String, dynamic>? data}) {
    talker.info('🌐 HTTP $method: $url${data != null ? '\nData: $data' : ''}');
  }

  void logResponse(String method, String url, int statusCode, {dynamic data}) {
    talker.log('✅ HTTP $method: $url\nStatus: $statusCode');
  }

  void logHttpError(String method, String url, int? statusCode, String error) {
    talker.error('❌ HTTP $method: $url\nStatus: $statusCode\nError: $error');
  }

  void logNavigation(String route, {Map<String, dynamic>? arguments}) {
    talker.info('🧭 Navigation: $route${arguments != null ? '\nArgs: $arguments' : ''}');
  }

  void logAction(String action, {Map<String, dynamic>? data}) {
    talker.info('👆 Action: $action${data != null ? '\nData: $data' : ''}');
  }

  void logPerformance(String operation, Duration duration) {
    talker.info('⏱️ Performance: $operation - ${duration.inMilliseconds}ms');
  }

  void showTalkerScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TalkerScreen(talker: talker)),
    );
  }

  List<TalkerData> get history => talker.history;
  void clearLogs() => talker.cleanHistory();
  String getLogsAsString() => talker.history.map((log) => log.generateTextMessage()).join('\n');
}

class PerformanceTracker {
  final String operation;
  final Stopwatch _stopwatch = Stopwatch();
  final LoggerService _logger = LoggerService.instance;

  PerformanceTracker(this.operation) {
    _stopwatch.start();
  }

  void stop() {
    _stopwatch.stop();
    _logger.logPerformance(operation, _stopwatch.elapsed);
  }

  Duration get elapsed => _stopwatch.elapsed;
}
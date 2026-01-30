import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Network Connectivity Utility
/// Monitor network status, connection type, and connectivity changes
class NetworkConnectivity {
  NetworkConnectivity._();

  static NetworkConnectivity? _instance;
  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  static ConnectivityResult _connectionStatus = ConnectivityResult.none;
  static bool _isConnected = false;

  /// Stream controller for connectivity changes
  static final _connectivityController = StreamController<NetworkStatus>.broadcast();

  /// Get singleton instance
  static NetworkConnectivity get instance {
    _instance ??= NetworkConnectivity._();
    return _instance!;
  }

  /// Initialize network monitoring
  static Future<void> init({
    Function(NetworkStatus)? onConnectivityChanged,
  }) async {
    // Get initial status
    final initialStatus = await checkConnectivity();
    _connectionStatus = initialStatus.connectivityResult;
    _isConnected = initialStatus.isConnected;

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        final result = results.first;
        _connectionStatus = result;
        
        // Check actual internet connectivity
        final hasInternet = await hasInternetConnection();
        _isConnected = hasInternet;

        final status = NetworkStatus(
          connectivityResult: result,
          isConnected: hasInternet,
          connectionType: _getConnectionType(result),
          timestamp: DateTime.now(),
        );

        // Emit to stream
        _connectivityController.add(status);

        // Call callback if provided
        onConnectivityChanged?.call(status);
      },
    );
  }

  // ==================== Connection Status ====================

  /// Check current connectivity status
  static Future<NetworkStatus> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final connectivityResult = result.first;
      final hasInternet = await hasInternetConnection();

      return NetworkStatus(
        connectivityResult: connectivityResult,
        isConnected: hasInternet,
        connectionType: _getConnectionType(connectivityResult),
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return NetworkStatus(
        connectivityResult: ConnectivityResult.none,
        isConnected: false,
        connectionType: ConnectionType.none,
        timestamp: DateTime.now(),
      );
    }
  }

  /// Check if device has internet connection (actual connectivity test)
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Ping a host to check connectivity
  static Future<PingResult> ping({
    String host = 'google.com',
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await InternetAddress.lookup(host).timeout(timeout);
      stopwatch.stop();
      
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return PingResult(
          success: true,
          host: host,
          responseTime: stopwatch.elapsed,
        );
      }
      
      return PingResult(
        success: false,
        host: host,
        responseTime: stopwatch.elapsed,
        error: 'No response from host',
      );
    } catch (e) {
      stopwatch.stop();
      return PingResult(
        success: false,
        host: host,
        responseTime: stopwatch.elapsed,
        error: e.toString(),
      );
    }
  }

  // ==================== Connection Type ====================

  /// Get current connection type
  static ConnectionType get connectionType => _getConnectionType(_connectionStatus);

  /// Check if connected via WiFi
  static bool get isWifi => _connectionStatus == ConnectivityResult.wifi;

  /// Check if connected via mobile data
  static bool get isMobile => _connectionStatus == ConnectivityResult.mobile;

  /// Check if connected via ethernet
  static bool get isEthernet => _connectionStatus == ConnectivityResult.ethernet;

  /// Check if connected via VPN
  static bool get isVPN => _connectionStatus == ConnectivityResult.vpn;

  /// Check if connected via Bluetooth
  static bool get isBluetooth => _connectionStatus == ConnectivityResult.bluetooth;

  /// Check if no connection
  static bool get isNone => _connectionStatus == ConnectivityResult.none;

  /// Check if currently connected to internet
  static bool get isConnected => _isConnected;

  // ==================== Network Quality ====================

  /// Estimate connection quality
  static Future<ConnectionQuality> getConnectionQuality() async {
    if (!_isConnected) {
      return ConnectionQuality.none;
    }

    // Ping test to measure latency
    final pingResult = await ping();

    if (!pingResult.success) {
      return ConnectionQuality.poor;
    }

    final latency = pingResult.responseTime.inMilliseconds;

    // Classify based on latency
    if (latency < 50) {
      return ConnectionQuality.excellent;
    } else if (latency < 100) {
      return ConnectionQuality.good;
    } else if (latency < 200) {
      return ConnectionQuality.fair;
    } else {
      return ConnectionQuality.poor;
    }
  }

  /// Get connection speed estimate (simplified)
  static Future<SpeedTestResult> estimateSpeed() async {
    if (!_isConnected) {
      return SpeedTestResult(
        downloadSpeed: 0,
        quality: ConnectionQuality.none,
      );
    }

    final quality = await getConnectionQuality();
    
    // Estimate speed based on connection type and quality
    double estimatedSpeed = 0;
    
    if (isWifi) {
      switch (quality) {
        case ConnectionQuality.excellent:
          estimatedSpeed = 100; // Mbps
          break;
        case ConnectionQuality.good:
          estimatedSpeed = 50;
          break;
        case ConnectionQuality.fair:
          estimatedSpeed = 20;
          break;
        case ConnectionQuality.poor:
          estimatedSpeed = 5;
          break;
        case ConnectionQuality.none:
          estimatedSpeed = 0;
          break;
      }
    } else if (isMobile) {
      switch (quality) {
        case ConnectionQuality.excellent:
          estimatedSpeed = 50; // Mbps (5G/4G+)
          break;
        case ConnectionQuality.good:
          estimatedSpeed = 20; // 4G
          break;
        case ConnectionQuality.fair:
          estimatedSpeed = 5; // 3G
          break;
        case ConnectionQuality.poor:
          estimatedSpeed = 1; // 2G
          break;
        case ConnectionQuality.none:
          estimatedSpeed = 0;
          break;
      }
    }

    return SpeedTestResult(
      downloadSpeed: estimatedSpeed,
      quality: quality,
    );
  }

  // ==================== Stream ====================

  /// Get stream of connectivity changes
  static Stream<NetworkStatus> get onConnectivityChanged {
    return _connectivityController.stream;
  }

  // ==================== Helper Methods ====================

  static ConnectionType _getConnectionType(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return ConnectionType.wifi;
      case ConnectivityResult.mobile:
        return ConnectionType.mobile;
      case ConnectivityResult.ethernet:
        return ConnectionType.ethernet;
      case ConnectivityResult.vpn:
        return ConnectionType.vpn;
      case ConnectivityResult.bluetooth:
        return ConnectionType.bluetooth;
      case ConnectivityResult.other:
        return ConnectionType.other;
      case ConnectivityResult.none:
        return ConnectionType.none;
    }
  }

  /// Wait for internet connection
  static Future<void> waitForConnection({
    Duration timeout = const Duration(seconds: 30),
    Duration checkInterval = const Duration(seconds: 2),
  }) async {
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      if (await hasInternetConnection()) {
        return;
      }
      await Future.delayed(checkInterval);
    }

    throw TimeoutException('No internet connection within timeout period');
  }

  // ==================== Dispose ====================

  /// Dispose resources
  static void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
  }
}

// ==================== Models ====================

/// Network status
class NetworkStatus {
  final ConnectivityResult connectivityResult;
  final bool isConnected;
  final ConnectionType connectionType;
  final DateTime timestamp;

  NetworkStatus({
    required this.connectivityResult,
    required this.isConnected,
    required this.connectionType,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'NetworkStatus(type: $connectionType, connected: $isConnected)';
  }
}

/// Connection type enum
enum ConnectionType {
  wifi,
  mobile,
  ethernet,
  vpn,
  bluetooth,
  other,
  none,
}

/// Extension on ConnectionType
extension ConnectionTypeExtension on ConnectionType {
  String get name {
    switch (this) {
      case ConnectionType.wifi:
        return 'WiFi';
      case ConnectionType.mobile:
        return 'Mobile Data';
      case ConnectionType.ethernet:
        return 'Ethernet';
      case ConnectionType.vpn:
        return 'VPN';
      case ConnectionType.bluetooth:
        return 'Bluetooth';
      case ConnectionType.other:
        return 'Other';
      case ConnectionType.none:
        return 'No Connection';
    }
  }

  String get icon {
    switch (this) {
      case ConnectionType.wifi:
        return '📶';
      case ConnectionType.mobile:
        return '📱';
      case ConnectionType.ethernet:
        return '🔌';
      case ConnectionType.vpn:
        return '🔒';
      case ConnectionType.bluetooth:
        return '🔵';
      case ConnectionType.other:
        return '🌐';
      case ConnectionType.none:
        return '❌';
    }
  }
}

/// Connection quality enum
enum ConnectionQuality {
  excellent,
  good,
  fair,
  poor,
  none,
}

/// Extension on ConnectionQuality
extension ConnectionQualityExtension on ConnectionQuality {
  String get name {
    switch (this) {
      case ConnectionQuality.excellent:
        return 'Excellent';
      case ConnectionQuality.good:
        return 'Good';
      case ConnectionQuality.fair:
        return 'Fair';
      case ConnectionQuality.poor:
        return 'Poor';
      case ConnectionQuality.none:
        return 'No Connection';
    }
  }

  String get icon {
    switch (this) {
      case ConnectionQuality.excellent:
        return '🟢';
      case ConnectionQuality.good:
        return '🟡';
      case ConnectionQuality.fair:
        return '🟠';
      case ConnectionQuality.poor:
        return '🔴';
      case ConnectionQuality.none:
        return '⚫';
    }
  }

  int get bars {
    switch (this) {
      case ConnectionQuality.excellent:
        return 4;
      case ConnectionQuality.good:
        return 3;
      case ConnectionQuality.fair:
        return 2;
      case ConnectionQuality.poor:
        return 1;
      case ConnectionQuality.none:
        return 0;
    }
  }
}

/// Ping result
class PingResult {
  final bool success;
  final String host;
  final Duration responseTime;
  final String? error;

  PingResult({
    required this.success,
    required this.host,
    required this.responseTime,
    this.error,
  });

  int get latencyMs => responseTime.inMilliseconds;

  @override
  String toString() {
    if (success) {
      return 'Ping to $host: ${latencyMs}ms';
    }
    return 'Ping to $host failed: $error';
  }
}

/// Speed test result
class SpeedTestResult {
  final double downloadSpeed; // Mbps
  final ConnectionQuality quality;

  SpeedTestResult({
    required this.downloadSpeed,
    required this.quality,
  });

  String get formattedSpeed {
    if (downloadSpeed < 1) {
      return '${(downloadSpeed * 1000).toStringAsFixed(0)} Kbps';
    }
    return '${downloadSpeed.toStringAsFixed(1)} Mbps';
  }

  @override
  String toString() {
    return 'Speed: $formattedSpeed (${quality.name})';
  }
}

/// Usage Examples
void networkConnectivityExamples() async {
  // Initialize
  await NetworkConnectivity.init(
    onConnectivityChanged: (status) {
      debugPrint('Connection changed: ${status.connectionType.name}');
      if (status.isConnected) {
        debugPrint('✓ Connected to internet');
      } else {
        debugPrint('✗ No internet connection');
      }
    },
  );

  // Check current status
  final status = await NetworkConnectivity.checkConnectivity();
  debugPrint('Current status: ${status.connectionType.name}');
  debugPrint('Connected: ${status.isConnected}');

  // Check connection type
  if (NetworkConnectivity.isWifi) {
    debugPrint('Connected via WiFi');
  } else if (NetworkConnectivity.isMobile) {
    debugPrint('Connected via Mobile Data');
  }

  // Check internet connectivity
  final hasInternet = await NetworkConnectivity.hasInternetConnection();
  debugPrint('Has internet: $hasInternet');

  // Ping test
  final pingResult = await NetworkConnectivity.ping(host: 'google.com');
  // debugPrint(pingResult);

  // Check connection quality
  final quality = await NetworkConnectivity.getConnectionQuality();
  debugPrint('Connection quality: ${quality.icon} ${quality.name}');

  // Estimate speed
  final speedTest = await NetworkConnectivity.estimateSpeed();
  debugPrint('Estimated speed: ${speedTest.formattedSpeed}');

  // Listen to connectivity changes
  NetworkConnectivity.onConnectivityChanged.listen((status) {
    debugPrint('${status.connectionType.icon} ${status.connectionType.name}');
  });

  // Wait for connection
  try {
    await NetworkConnectivity.waitForConnection(
      timeout: Duration(seconds: 10),
    );
    debugPrint('Connection established!');
  } catch (e) {
    debugPrint('Timeout waiting for connection');
  }

  // Get quick status
  final isConnected = NetworkConnectivity.isConnected;
  final connectionType = NetworkConnectivity.connectionType;

  // Cleanup
  NetworkConnectivity.dispose();
}
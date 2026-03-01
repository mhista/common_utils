import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Device Info Helper
class DeviceInfoHelper {
  DeviceInfoHelper._();

  static DeviceInfoHelper? _instance;
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static PackageInfo? _packageInfo;

  static DeviceInfoHelper get instance => _instance ??= DeviceInfoHelper._();

  static Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  // Platform Detection
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isWeb => kIsWeb;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isMacOS => !kIsWeb && Platform.isMacOS;
  bool get isLinux => !kIsWeb && Platform.isLinux;
  bool get isMobile => isAndroid || isIOS;
  bool get isDesktop => isWindows || isMacOS || isLinux;

  String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  Future<String> getDeviceModel() async {
    if (isAndroid) {
      final info = await _deviceInfo.androidInfo;
      return info.model;
    } else if (isIOS) {
      final info = await _deviceInfo.iosInfo;
      return info.model;
    }
    return 'Unknown';
  }

  Future<String> getDeviceBrand() async {
    if (isAndroid) {
      final info = await _deviceInfo.androidInfo;
      return info.manufacturer;
    } else if (isIOS) {
      return 'Apple';
    }
    return platformName;
  }

  Future<String> getDeviceId() async {
    if (isAndroid) {
      final info = await _deviceInfo.androidInfo;
      return info.id;
    } else if (isIOS) {
      return 'Apple';
    }
    return platformName;
  }

  Future<String> getOSVersion() async {
    if (isAndroid) {
      final info = await _deviceInfo.androidInfo;
      return info.version.release;
    } else if (isIOS) {
      final info = await _deviceInfo.iosInfo;
      return info.systemVersion;
    }
    return 'Unknown';
  }

  Future<String> getPlatformInfo() async {
    if (isAndroid) {
      final info = await _deviceInfo.androidInfo;
      return "Android ${info.version.release}";
    } else if (isIOS) {
      final info = await _deviceInfo.iosInfo;
      return "iOS ${info.systemVersion}"; // e.g. "iPhone 12 Pro (iOS 14.4)"
    }
    return 'Unknown';
  }

  Future<String> getDeviceInfo() async {
    if (isAndroid) {
      final info = await _deviceInfo.androidInfo;
      return "${info.manufacturer} ${info.model}";
    } else if (isIOS) {
      final info = await _deviceInfo.iosInfo;
      return "${info.name} ${info.utsname.machine}"; // e.g. "iPhone 12 Pro"
    }

    return platformName;
  }

  // App Information
  String get appName => _packageInfo!.appName;
  String get packageName => _packageInfo!.packageName;
  String get appVersion => _packageInfo!.version;
  String get buildNumber => _packageInfo!.buildNumber;
  String get fullAppVersion => '$appVersion ($buildNumber)';

  bool get isReleaseMode => kReleaseMode;
  bool get isDebugMode => kDebugMode;
  bool get isProfileMode => kProfileMode;
  String get platformId =>
      '${platformName}_${getDeviceModel()}_${getOSVersion()}';

  Future<Map<String, dynamic>> getAllInfo() async {
    return {
      'platform': platformName,
      'deviceModel': await getDeviceModel(),
      'deviceBrand': await getDeviceBrand(),
      'osVersion': await getOSVersion(),
      'appName': appName,
      'appVersion': fullAppVersion,
      'buildMode': isReleaseMode ? 'release' : 'debug',
    };
  }

  
}

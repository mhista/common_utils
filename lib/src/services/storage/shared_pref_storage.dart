import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage Service
/// Type-safe wrapper around SharedPreferences with support for complex data types
class StorageService {
  StorageService._();

  static StorageService? _instance;
  static SharedPreferences? _preferences;

  /// Get singleton instance
  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  /// Initialize the storage service
  /// Must be called before using any storage methods
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  SharedPreferences get _prefs {
    if (_preferences == null) {
      throw Exception(
        'StorageService not initialized. Call StorageService.init() first.',
      );
    }
    return _preferences!;
  }

  // ==================== String Operations ====================

  /// Save string value
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// Get string value
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Get string with default value
  String getStringOrDefault(String key, String defaultValue) {
    return _prefs.getString(key) ?? defaultValue;
  }

  // ==================== Integer Operations ====================

  /// Save integer value
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  /// Get integer value
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// Get integer with default value
  int getIntOrDefault(String key, int defaultValue) {
    return _prefs.getInt(key) ?? defaultValue;
  }

  // ==================== Double Operations ====================

  /// Save double value
  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  /// Get double value
  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  /// Get double with default value
  double getDoubleOrDefault(String key, double defaultValue) {
    return _prefs.getDouble(key) ?? defaultValue;
  }

  // ==================== Boolean Operations ====================

  /// Save boolean value
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  /// Get boolean value
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// Get boolean with default value
  bool getBoolOrDefault(String key, bool defaultValue) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  // ==================== List Operations ====================

  /// Save list of strings
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  /// Get list of strings
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  /// Get list of strings with default value
  List<String> getStringListOrDefault(String key, List<String> defaultValue) {
    return _prefs.getStringList(key) ?? defaultValue;
  }

  // ==================== JSON Operations ====================

  /// Save object as JSON
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    return await _prefs.setString(key, jsonString);
  }

  /// Get object from JSON
  Map<String, dynamic>? getJson(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Save list of objects as JSON
  Future<bool> setJsonList(String key, List<Map<String, dynamic>> value) async {
    final jsonString = jsonEncode(value);
    return await _prefs.setString(key, jsonString);
  }

  /// Get list of objects from JSON
  List<Map<String, dynamic>>? getJsonList(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    try {
      final decoded = jsonDecode(jsonString) as List;
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      return null;
    }
  }

  // ==================== Generic Operations ====================

  /// Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  /// Remove value by key
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  /// Clear all stored data
  Future<bool> clear() async {
    return await _prefs.clear();
  }

  /// Get all keys
  Set<String> getAllKeys() {
    return _prefs.getKeys();
  }

  /// Reload preferences from disk
  Future<void> reload() async {
    await _prefs.reload();
  }

  // ==================== Batch Operations ====================

  /// Set multiple values at once
  Future<bool> setBatch(Map<String, dynamic> values) async {
    bool success = true;
    for (final entry in values.entries) {
      final key = entry.key;
      final value = entry.value;

      bool result = false;
      if (value is String) {
        result = await setString(key, value);
      } else if (value is int) {
        result = await setInt(key, value);
      } else if (value is double) {
        result = await setDouble(key, value);
      } else if (value is bool) {
        result = await setBool(key, value);
      } else if (value is List<String>) {
        result = await setStringList(key, value);
      } else if (value is Map<String, dynamic>) {
        result = await setJson(key, value);
      }

      if (!result) success = false;
    }
    return success;
  }

  /// Remove multiple keys at once
  Future<bool> removeBatch(List<String> keys) async {
    bool success = true;
    for (final key in keys) {
      final result = await remove(key);
      if (!result) success = false;
    }
    return success;
  }

  // ==================== Utility Methods ====================

  /// Get storage size estimate (approximate)
  int getStorageSizeEstimate() {
    int totalSize = 0;
    for (final key in getAllKeys()) {
      final value = _prefs.get(key);
      if (value is String) {
        totalSize += value.length;
      } else if (value is List<String>) {
        totalSize += value.join().length;
      }
    }
    return totalSize;
  }

  /// Export all data as JSON
  Map<String, dynamic> exportData() {
    final data = <String, dynamic>{};
    for (final key in getAllKeys()) {
      data[key] = _prefs.get(key);
    }
    return data;
  }

  /// Import data from JSON
  Future<bool> importData(Map<String, dynamic> data) async {
    return await setBatch(data);
  }
}

// Usage examples live in the package README and example/ app —
// they are intentionally not part of the public library API.

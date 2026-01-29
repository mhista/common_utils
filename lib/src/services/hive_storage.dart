// ============================================================================
// ENHANCED SINGLETON HIVE STORAGE SERVICE
// ============================================================================
// Add to pubspec.yaml:
// dependencies:
//   hive: ^2.2.3
//   hive_flutter: ^1.1.0
//
// dev_dependencies:
//   hive_generator: ^2.0.1
//   build_runner: ^2.4.6

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/storage_keys.dart';

/// Centralized singleton local storage service using Hive
/// Automatically handles user-specific data isolation
class HiveStorageService {
  HiveStorageService._();

  static HiveStorageService? _instance;
  static HiveStorageService get instance {
    _instance ??= HiveStorageService._();
    return _instance!;
  }

  final String _userBoxPrefix = 'user_';
  final String _globalBox = 'app_global';

  Box? _currentUserBox;
  Box? _globalBox_;
  String? _currentUserId;

  // ==================== Initialization ====================

  /// Initialize Hive (call once in main.dart before runApp)
  static Future<void> init() async {
    await Hive.initFlutter();
    debugPrint('Hive initialized');
  }

  /// Set current user and open their box
  Future<void> setUser(String userId) async {
    try {
      if (_currentUserId == userId && _currentUserBox != null) {
        debugPrint('User box already open for: $userId');
        return;
      }

      // Close previous user box if open
      if (_currentUserBox != null && _currentUserBox!.isOpen) {
        await _currentUserBox!.close();
      }

      _currentUserId = userId;
      final boxName = '$_userBoxPrefix$userId';

      // Open user-specific box
      _currentUserBox = await Hive.openBox(boxName);
      debugPrint('Opened user box: $boxName');

      // Open global box if not already open
      if (_globalBox_ == null || !_globalBox_!.isOpen) {
        _globalBox_ = await Hive.openBox(_globalBox);
        debugPrint('Opened global box');
      }
    } catch (e) {
      debugPrint('Error setting user: $e');
      rethrow;
    }
  }

  /// Clear current user (on logout)
  Future<void> clearUser() async {
    if (_currentUserBox != null && _currentUserBox!.isOpen) {
      await _currentUserBox!.close();
    }
    _currentUserBox = null;
    _currentUserId = null;
    debugPrint('User box closed');
  }

  // ============================================================================
  // USER-SPECIFIC OPERATIONS (Type-safe methods)
  // ============================================================================

  // ==================== String Operations ====================

  /// Save user string value
  Future<bool> setString(String key, String value) async {
    _ensureUserBox();
    try {
      await _currentUserBox!.put(key, value);
      debugPrint('Saved user string: $key');
      return true;
    } catch (e) {
      debugPrint('Error saving user string: $e');
      return false;
    }
  }

  /// Get user string value
  String? getString(String key) {
    _ensureUserBox();
    return _currentUserBox!.get(key) as String?;
  }

  /// Get user string with default value
  String getStringOrDefault(String key, String defaultValue) {
    return getString(key) ?? defaultValue;
  }

  // ==================== Integer Operations ====================

  /// Save user integer value
  Future<bool> setInt(String key, int value) async {
    _ensureUserBox();
    try {
      await _currentUserBox!.put(key, value);
      debugPrint('Saved user int: $key');
      return true;
    } catch (e) {
      debugPrint('Error saving user int: $e');
      return false;
    }
  }

  /// Get user integer value
  int? getInt(String key) {
    _ensureUserBox();
    return _currentUserBox!.get(key) as int?;
  }

  /// Get user integer with default value
  int getIntOrDefault(String key, int defaultValue) {
    return getInt(key) ?? defaultValue;
  }

  // ==================== Double Operations ====================

  /// Save user double value
  Future<bool> setDouble(String key, double value) async {
    _ensureUserBox();
    try {
      await _currentUserBox!.put(key, value);
      debugPrint('Saved user double: $key');
      return true;
    } catch (e) {
      debugPrint('Error saving user double: $e');
      return false;
    }
  }

  /// Get user double value
  double? getDouble(String key) {
    _ensureUserBox();
    return _currentUserBox!.get(key) as double?;
  }

  /// Get user double with default value
  double getDoubleOrDefault(String key, double defaultValue) {
    return getDouble(key) ?? defaultValue;
  }

  // ==================== Boolean Operations ====================

  /// Save user boolean value
  Future<bool> setBool(String key, bool value) async {
    _ensureUserBox();
    try {
      await _currentUserBox!.put(key, value);
      debugPrint('Saved user bool: $key');
      return true;
    } catch (e) {
      debugPrint('Error saving user bool: $e');
      return false;
    }
  }

  /// Get user boolean value
  bool? getBool(String key) {
    _ensureUserBox();
    return _currentUserBox!.get(key) as bool?;
  }

  /// Get user boolean with default value
  bool getBoolOrDefault(String key, bool defaultValue) {
    return getBool(key) ?? defaultValue;
  }

  // ==================== List Operations ====================

  /// Save user list of strings
  Future<bool> setStringList(String key, List<String> value) async {
    _ensureUserBox();
    try {
      await _currentUserBox!.put(key, value);
      debugPrint('Saved user string list: $key');
      return true;
    } catch (e) {
      debugPrint('Error saving user string list: $e');
      return false;
    }
  }

  /// Get user list of strings
  List<String>? getStringList(String key) {
    _ensureUserBox();
    final value = _currentUserBox!.get(key);
    if (value == null) return null;
    return (value as List).cast<String>();
  }

  /// Get user list of strings with default value
  List<String> getStringListOrDefault(String key, List<String> defaultValue) {
    return getStringList(key) ?? defaultValue;
  }

  // ==================== Generic Operations ====================

  /// Save user-specific data (generic)
  Future<void> saveUserData<T>(String key, T value) async {
    _ensureUserBox();
    try {
      if (value is String ||
          value is int ||
          value is double ||
          value is bool ||
          value is List ||
          value is Map) {
        await _currentUserBox!.put(key, value);
        debugPrint('Saved user data: $key');
      } else {
        // For complex objects, convert to JSON
        final jsonString = jsonEncode(value);
        await _currentUserBox!.put(key, jsonString);
        debugPrint('Saved user data (JSON): $key');
      }
    } catch (e) {
      debugPrint('Error saving user data: $e');
      rethrow;
    }
  }

  /// Get user-specific data (generic)
  T? getUserData<T>(String key, {T? defaultValue}) {
    _ensureUserBox();
    try {
      final value = _currentUserBox!.get(key, defaultValue: defaultValue);
      if (value == null) return defaultValue;
      return value as T;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return defaultValue;
    }
  }

  // ==================== JSON Operations ====================

  /// Save user object as JSON
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    _ensureUserBox();
    try {
      final jsonString = jsonEncode(value);
      await _currentUserBox!.put(key, jsonString);
      debugPrint('Saved user JSON: $key');
      return true;
    } catch (e) {
      debugPrint('Error saving user JSON: $e');
      return false;
    }
  }

  /// Get user object from JSON
  Map<String, dynamic>? getJson(String key) {
    _ensureUserBox();
    final jsonString = _currentUserBox!.get(key) as String?;
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error decoding JSON: $e');
      return null;
    }
  }

  /// Save user data as JSON string (legacy method)
  Future<void> saveUserJson(String key, Map<String, dynamic> json) async {
    await setJson(key, json);
  }

  /// Get user data as JSON (legacy method)
  Map<String, dynamic>? getUserJson(String key) {
    return getJson(key);
  }

  /// Save user list of objects as JSON
  Future<bool> setJsonList(String key, List<Map<String, dynamic>> value) async {
    _ensureUserBox();
    try {
      final jsonString = jsonEncode(value);
      await _currentUserBox!.put(key, jsonString);
      debugPrint('Saved user JSON list: $key');
      return true;
    } catch (e) {
      debugPrint('Error saving user JSON list: $e');
      return false;
    }
  }

  /// Get user list of objects from JSON
  List<Map<String, dynamic>>? getJsonList(String key) {
    _ensureUserBox();
    final jsonString = _currentUserBox!.get(key) as String?;
    if (jsonString == null) return null;
    try {
      final decoded = jsonDecode(jsonString) as List;
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Error decoding JSON list: $e');
      return null;
    }
  }

  /// Save list of JSON objects (legacy method)
  Future<void> saveUserJsonList(
    String key,
    List<Map<String, dynamic>> list,
  ) async {
    await setJsonList(key, list);
  }

  /// Get list of JSON objects (legacy method)
  List<Map<String, dynamic>>? getUserJsonList(String key) {
    return getJsonList(key);
  }

  // ==================== Key Checking Operations ====================

  /// Check if user data key exists
  bool containsKey(String key) {
    _ensureUserBox();
    return _currentUserBox!.containsKey(key);
  }

  /// Check if user data exists (legacy method)
  bool hasUserData(String key) {
    return containsKey(key);
  }

  // ==================== Remove Operations ====================

  /// Remove user-specific data
  Future<bool> remove(String key) async {
    _ensureUserBox();
    try {
      await _currentUserBox!.delete(key);
      debugPrint('Removed user data: $key');
      return true;
    } catch (e) {
      debugPrint('Error removing user data: $e');
      return false;
    }
  }

  /// Remove user-specific data (legacy method)
  Future<void> removeUserData(String key) async {
    await remove(key);
  }

  // ==================== Clear Operations ====================

  /// Clear all user data (use with caution)
  Future<bool> clear() async {
    _ensureUserBox();
    try {
      await _currentUserBox!.clear();
      debugPrint('Cleared all user data for: $_currentUserId');
      return true;
    } catch (e) {
      debugPrint('Error clearing user data: $e');
      return false;
    }
  }

  /// Clear all user data (legacy method)
  Future<void> clearUserData() async {
    await clear();
  }

  // ==================== Get All Keys ====================

  /// Get all user data keys
  Set<String> getAllKeys() {
    _ensureUserBox();
    return _currentUserBox!.keys.cast<String>().toSet();
  }

  /// Get all user data keys (legacy method)
  List<String> getUserDataKeys() {
    return getAllKeys().toList();
  }

  // ============================================================================
  // BATCH OPERATIONS
  // ============================================================================

  /// Set multiple user data values at once
  Future<bool> setBatch(Map<String, dynamic> values) async {
    _ensureUserBox();
    try {
      await _currentUserBox!.putAll(values);
      debugPrint('Saved batch user data: ${values.keys.length} items');
      return true;
    } catch (e) {
      debugPrint('Error saving batch: $e');
      return false;
    }
  }

  /// Save multiple user data entries at once (legacy method)
  Future<void> saveUserDataBatch(Map<String, dynamic> data) async {
    await setBatch(data);
  }

  /// Get multiple user data entries at once
  Map<String, dynamic> getBatch(List<String> keys) {
    _ensureUserBox();
    final result = <String, dynamic>{};
    for (final key in keys) {
      final value = _currentUserBox!.get(key);
      if (value != null) {
        result[key] = value;
      }
    }
    return result;
  }

  /// Get multiple user data entries at once (legacy method)
  Map<String, dynamic> getUserDataBatch(List<String> keys) {
    return getBatch(keys);
  }

  /// Remove multiple keys at once
  Future<bool> removeBatch(List<String> keys) async {
    _ensureUserBox();
    bool success = true;
    for (final key in keys) {
      try {
        await _currentUserBox!.delete(key);
      } catch (e) {
        debugPrint('Error removing key $key: $e');
        success = false;
      }
    }
    debugPrint('Removed batch user data: ${keys.length} items');
    return success;
  }

  // ============================================================================
  // GLOBAL APP OPERATIONS (not user-specific)
  // ============================================================================

  /// Save global app data
  Future<bool> setGlobalData<T>(String key, T value) async {
    _ensureGlobalBox();
    try {
      await _globalBox_!.put(key, value);
      debugPrint('Saved global data: $key');
      return true;
    } catch (e) {
      debugPrint('Error saving global data: $e');
      return false;
    }
  }

  /// Get global app data
  T? getGlobalData<T>(String key, {T? defaultValue}) {
    _ensureGlobalBox();
    return _globalBox_!.get(key, defaultValue: defaultValue) as T?;
  }

  /// Save global string
  Future<bool> setGlobalString(String key, String value) async {
    return await setGlobalData(key, value);
  }

  /// Get global string
  String? getGlobalString(String key) {
    return getGlobalData<String>(key);
  }

  /// Save global int
  Future<bool> setGlobalInt(String key, int value) async {
    return await setGlobalData(key, value);
  }

  /// Get global int
  int? getGlobalInt(String key) {
    return getGlobalData<int>(key);
  }

  /// Save global bool
  Future<bool> setGlobalBool(String key, bool value) async {
    return await setGlobalData(key, value);
  }

  /// Get global bool
  bool? getGlobalBool(String key) {
    return getGlobalData<bool>(key);
  }

  /// Save global JSON
  Future<bool> setGlobalJson(String key, Map<String, dynamic> value) async {
    _ensureGlobalBox();
    try {
      final jsonString = jsonEncode(value);
      await _globalBox_!.put(key, jsonString);
      debugPrint('Saved global JSON: $key');
      return true;
    } catch (e) {
      debugPrint('Error saving global JSON: $e');
      return false;
    }
  }

  /// Get global JSON
  Map<String, dynamic>? getGlobalJson(String key) {
    _ensureGlobalBox();
    final jsonString = _globalBox_!.get(key) as String?;
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error decoding global JSON: $e');
      return null;
    }
  }

  /// Remove global data
  Future<bool> removeGlobalData(String key) async {
    _ensureGlobalBox();
    try {
      await _globalBox_!.delete(key);
      debugPrint('Removed global data: $key');
      return true;
    } catch (e) {
      debugPrint('Error removing global data: $e');
      return false;
    }
  }

  /// Check if global data exists
  bool hasGlobalData(String key) {
    _ensureGlobalBox();
    return _globalBox_!.containsKey(key);
  }

  /// Get all global keys
  Set<String> getGlobalKeys() {
    _ensureGlobalBox();
    return _globalBox_!.keys.cast<String>().toSet();
  }

  /// Clear all global data
  Future<bool> clearGlobalData() async {
    _ensureGlobalBox();
    try {
      await _globalBox_!.clear();
      debugPrint('Cleared all global data');
      return true;
    } catch (e) {
      debugPrint('Error clearing global data: $e');
      return false;
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Get current user ID
  String? get currentUserId => _currentUserId;

  /// Check if user box is open
  bool get isUserBoxOpen => _currentUserBox != null && _currentUserBox!.isOpen;

  /// Check if global box is open
  bool get isGlobalBoxOpen => _globalBox_ != null && _globalBox_!.isOpen;

  /// Get storage size for current user (approximate)
  int getUserStorageSize() {
    _ensureUserBox();
    return _currentUserBox!.length;
  }

  /// Get storage size estimate (approximate in bytes)
  int getStorageSizeEstimate() {
    _ensureUserBox();
    int totalSize = 0;
    for (final key in _currentUserBox!.keys) {
      final value = _currentUserBox!.get(key);
      if (value is String) {
        totalSize += value.length;
      } else if (value is List) {
        totalSize += value.join().toString().length;
      }
    }
    return totalSize;
  }

  /// Export user data (for backup/migration)
  Map<String, dynamic> exportUserData() {
    _ensureUserBox();
    return Map<String, dynamic>.from(_currentUserBox!.toMap());
  }

  /// Export all data as JSON
  Map<String, dynamic> exportData() {
    return exportUserData();
  }

  /// Import user data (for backup/migration)
  Future<void> importUserData(Map<String, dynamic> data) async {
    _ensureUserBox();
    await _currentUserBox!.putAll(data);
    debugPrint('Imported user data: ${data.keys.length} items');
  }

  /// Import data from JSON
  Future<bool> importData(Map<String, dynamic> data) async {
    try {
      await importUserData(data);
      return true;
    } catch (e) {
      debugPrint('Error importing data: $e');
      return false;
    }
  }

  /// Reload (not applicable for Hive, but kept for API compatibility)
  Future<void> reload() async {
    debugPrint('Reload called (no-op for Hive)');
  }

  // ============================================================================
  // ADMIN OPERATIONS (use with caution)
  // ============================================================================

  /// Delete all data for a specific user (admin only)
  Future<void> deleteUserBox(String userId) async {
    final boxName = '$_userBoxPrefix$userId';
    if (await Hive.boxExists(boxName)) {
      await Hive.deleteBoxFromDisk(boxName);
      debugPrint('Deleted user box: $boxName');
    }
  }

  /// List all available box names
  Future<List<String>> listAllBoxes() async {
    // Note: Hive doesn't provide a direct way to list all boxes
    // This is a limitation of the Hive API
    debugPrint('Listing boxes is not directly supported by Hive');
    return [];
  }

  // ============================================================================
  // PRIVATE HELPERS
  // ============================================================================

  void _ensureUserBox() {
    if (_currentUserBox == null || !_currentUserBox!.isOpen) {
      throw Exception('User box not initialized. Call setUser() first.');
    }
  }

  void _ensureGlobalBox() {
    if (_globalBox_ == null || !_globalBox_!.isOpen) {
      throw Exception('Global box not initialized. Call init() first.');
    }
  }

  // ============================================================================
  // DISPOSAL
  // ============================================================================

  /// Dispose (call on app shutdown)
  Future<void> dispose() async {
    if (_currentUserBox != null && _currentUserBox!.isOpen) {
      await _currentUserBox!.close();
    }
    if (_globalBox_ != null && _globalBox_!.isOpen) {
      await _globalBox_!.close();
    }
    debugPrint('HiveStorageService disposed');
  }
}

// ============================================================================
// EXAMPLE USAGE
// ============================================================================

class HiveStorageExample {
  final _storage = HiveStorageService.instance;

  // Initialize in main.dart
  Future<void> initialize() async {
    await HiveStorageService.init();
  }

  // Set user when they log in
  Future<void> onLogin(String userId) async {
    await _storage.setUser(userId);
  }

  // Save user data
  Future<void> saveUserData({
    required String token,
    required String userId,
    required Map<String, dynamic> profile,
  }) async {
    await _storage.setBatch({
      StorageKeys.authToken: token,
      StorageKeys.userId: userId,
      StorageKeys.isLoggedIn: true,
    });
    await _storage.setJson(StorageKeys.userProfile, profile);
  }

  // Get user data
  Map<String, dynamic>? getUserData() {
    if (!_storage.getBoolOrDefault(StorageKeys.isLoggedIn, false)) {
      return null;
    }

    return {
      'token': _storage.getString(StorageKeys.authToken),
      'userId': _storage.getString(StorageKeys.userId),
      'profile': _storage.getJson(StorageKeys.userProfile),
    };
  }

  // Logout
  Future<void> logout() async {
    await _storage.removeBatch([
      StorageKeys.authToken,
      StorageKeys.refreshToken,
      StorageKeys.userId,
      StorageKeys.userEmail,
      StorageKeys.userProfile,
    ]);
    await _storage.setBool(StorageKeys.isLoggedIn, false);
    await _storage.clearUser();
  }

  // Save app settings (global)
  Future<void> saveSettings({
    required bool isDarkMode,
    required String language,
    required bool notificationsEnabled,
  }) async {
    await _storage.setGlobalBool(StorageKeys.isDarkMode, isDarkMode);
    await _storage.setGlobalString(StorageKeys.language, language);
    await _storage.setGlobalBool(
      StorageKeys.notificationsEnabled,
      notificationsEnabled,
    );
  }

  // Get app settings (global)
  Map<String, dynamic> getSettings() {
    return {
      'isDarkMode':
          _storage.getGlobalData<bool>(
            StorageKeys.isDarkMode,
            defaultValue: false,
          ) ??
          false,
      'language':
          _storage.getGlobalData<String>(
            StorageKeys.language,
            defaultValue: 'en',
          ) ??
          'en',
      'notificationsEnabled':
          _storage.getGlobalData<bool>(
            StorageKeys.notificationsEnabled,
            defaultValue: true,
          ) ??
          true,
    };
  }
}

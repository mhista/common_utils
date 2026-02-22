import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// SecureStorageService
/// ====================
/// Type-safe wrapper around flutter_secure_storage for sensitive data.
///
/// USE THIS FOR: tokens, credentials, session data, any sensitive value.
/// USE StorageService (SharedPreferences) FOR: settings, preferences, non-sensitive flags.
///
/// iOS:  Data stored in Keychain. Supports keychain groups for cross-app sharing.
/// Android: AES-256 encrypted via EncryptedSharedPreferences.
///
/// TWO WAYS TO USE:
///
/// 1. Singleton via [init] + [instance] — for the main app-wide storage instance:
/// ```dart
/// await SecureStorageService.init();
/// SecureStorageService.instance.setString('key', 'value');
/// ```
///
/// 2. Scoped instance via [withOptions] — when you need separate storage
///    configurations (e.g. merkado_auth needs a shared scope AND a local scope):
/// ```dart 
/// final sharedStorage = SecureStorageService.withOptions(
///   iOSOptions: IOSOptions(groupId: 'com.grascope.sharedauth'),
///   androidOptions: AndroidOptions(sharedPreferencesName: 'grascope_shared'),
/// );
/// ```
class SecureStorageService {
  SecureStorageService._internal(FlutterSecureStorage storage)
      : _storage = storage;

  static SecureStorageService? _instance;
  final FlutterSecureStorage _storage;

  /// The app-wide singleton instance.
  /// Only available after [init] has been called.
  static SecureStorageService get instance {
    assert(
      _instance != null,
      'SecureStorageService not initialized. Call SecureStorageService.init() first.',
    );
    return _instance!;
  }

  /// Initialize the app-wide singleton instance.
  ///
  /// [enableCrossAppSharing] — when true, uses the shared Grascope keychain
  /// group on iOS and the shared keystore namespace on Android.
  /// Set to true on all apps once the shared keystore is configured.
  ///
  /// Call this in main() after StorageService.init().
  static Future<void> init({bool enableCrossAppSharing = false}) async {
    final iOSOptions = enableCrossAppSharing
        ? const IOSOptions(
            groupId: 'com.grascope.sharedauth',
            accountName: 'grascope_session',
            accessibility: KeychainAccessibility.first_unlock,
          )
        : const IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          );

    const androidOptions = AndroidOptions(
      sharedPreferencesName: 'grascope_secure_prefs',
      preferencesKeyPrefix: 'grascope_',
    );

    _instance = SecureStorageService._internal(
      FlutterSecureStorage(iOptions: iOSOptions, aOptions: androidOptions),
    );
  }

  /// Create a scoped instance with custom storage options.
  ///
  /// Use this when you need a storage instance configured differently
  /// from the app-wide singleton — for example, the merkado_auth package
  /// creates two instances: one for cross-app shared data and one for
  /// private per-app data.
  ///
  /// This does NOT affect the singleton [instance].
  factory SecureStorageService.withOptions({
    IOSOptions iOSOptions = const IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
    AndroidOptions androidOptions = const AndroidOptions(
      // encryptedSharedPreferences: true,
    ),
  }) {
    return SecureStorageService._internal(
      FlutterSecureStorage(iOptions: iOSOptions, aOptions: androidOptions),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // STRING
  // ══════════════════════════════════════════════════════════════

  Future<void> setString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> getString(String key) async {
    return await _storage.read(key: key);
  }

  Future<String> getStringOrDefault(String key, String defaultValue) async {
    return await _storage.read(key: key) ?? defaultValue;
  }

  // ══════════════════════════════════════════════════════════════
  // BOOLEAN
  // ══════════════════════════════════════════════════════════════

  Future<void> setBool(String key, bool value) async {
    await _storage.write(key: key, value: value.toString());
  }

  Future<bool?> getBool(String key) async {
    final value = await _storage.read(key: key);
    if (value == null) return null;
    return value == 'true';
  }

  Future<bool> getBoolOrDefault(String key, bool defaultValue) async {
    final value = await _storage.read(key: key);
    if (value == null) return defaultValue;
    return value == 'true';
  }

  // ══════════════════════════════════════════════════════════════
  // INTEGER
  // ══════════════════════════════════════════════════════════════

  Future<void> setInt(String key, int value) async {
    await _storage.write(key: key, value: value.toString());
  }

  Future<int?> getInt(String key) async {
    final value = await _storage.read(key: key);
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<int> getIntOrDefault(String key, int defaultValue) async {
    final value = await _storage.read(key: key);
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  // ══════════════════════════════════════════════════════════════
  // JSON
  // ══════════════════════════════════════════════════════════════

  Future<void> setJson(String key, Map<String, dynamic> value) async {
    await _storage.write(key: key, value: jsonEncode(value));
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    final raw = await _storage.read(key: key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> setJsonList(String key, List<Map<String, dynamic>> value) async {
    await _storage.write(key: key, value: jsonEncode(value));
  }

  Future<List<Map<String, dynamic>>?> getJsonList(String key) async {
    final raw = await _storage.read(key: key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (_) {
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // GENERIC OPERATIONS
  // ══════════════════════════════════════════════════════════════

  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }

  /// ⚠️ Deletes ALL keys in this storage instance.
  /// On the singleton, this includes all app data.
  /// On a scoped instance, only that scope's data is cleared.
  Future<void> clear() async {
    await _storage.deleteAll();
  }

  Future<Set<String>> getAllKeys() async {
    final all = await _storage.readAll();
    return all.keys.toSet();
  }

  // ══════════════════════════════════════════════════════════════
  // BATCH OPERATIONS
  // ══════════════════════════════════════════════════════════════

  Future<void> setBatch(Map<String, dynamic> values) async {
    for (final entry in values.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is String) {
        await setString(key, value);
      } else if (value is bool) {
        await setBool(key, value);
      } else if (value is int) {
        await setInt(key, value);
      } else if (value is Map<String, dynamic>) {
        await setJson(key, value);
      }
    }
  }

  Future<void> removeBatch(List<String> keys) async {
    for (final key in keys) {
      await remove(key);
    }
  }
}
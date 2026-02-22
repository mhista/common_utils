/// StorageKeys
/// ===========
/// Centralized key constants for [StorageService] (SharedPreferences) and
/// [SecureStorageService] (flutter_secure_storage).
///
/// SCOPE: App-level, non-auth-specific keys only.
/// Auth-specific keys (tokens, session IDs, OTP state) live in
/// [AuthStorageKeys] inside the merkado_auth package. This keeps
/// common_utils free of auth domain knowledge.
///
/// RULE: Never rename a key after shipping. Renaming invalidates all
/// existing stored values on user devices. If a rename is unavoidable,
/// write a migration that reads the old key, writes to the new key,
/// then deletes the old one on first launch.
class StorageKeys {
  StorageKeys._();

  // ── Cross-app shared identity (written by merkado_auth, read by all apps) ─
  // These keys must be IDENTICAL across all Grascope apps because they are
  // stored in the shared keychain group / shared encrypted prefs.
  // merkado_auth writes to these. Apps read them for display purposes only.

  /// The userId of the account currently signed in on this device.
  /// Written by merkado_auth after login. Read-only for consuming apps.
  static const String userId = 'grascope_user_id';

  /// The display name of the signed-in user.
  /// Written after onboarding completes. Used in app headers, avatars, etc.
  static const String userDisplayName = 'grascope_user_display_name';

  /// The avatar URL of the signed-in user.
  static const String userAvatarUrl = 'grascope_user_avatar_url';

  /// The email address of the signed-in user.
  static const String userEmail = 'grascope_user_email';

  // ── App settings (SharedPreferences — not sensitive) ──────────────────────

  /// Whether the app is in dark mode.
  static const String isDarkMode = 'is_dark_mode';

  /// The user's selected language code (e.g. 'en', 'fr', 'yo').
  static const String language = 'language';

  /// Whether this is the first app launch (used for splash/onboarding routing).
  static const String isFirstLaunch = 'is_first_launch';

  /// Whether push notifications are enabled by the user.
  static const String notificationsEnabled = 'notifications_enabled';

  // ── User preferences ──────────────────────────────────────────────────────

  static const String fontSize = 'font_size';
  static const String currency = 'currency';
  static const String country = 'country';

  // ── Cache ─────────────────────────────────────────────────────────────────

  static const String cacheVersion = 'cache_version';
  static const String lastSyncTime = 'last_sync_time';

  // ── Onboarding & tutorials ────────────────────────────────────────────────
  // NOTE: These are UI-level flags (has the user seen the tutorial?).
  // The auth-level onboarding completion flag (has the user submitted
  // their profile to /onboarding/complete?) lives in AuthStorageKeys
  // inside merkado_auth — it is part of the auth flow, not a UI preference.

  static const String tutorialCompleted = 'tutorial_completed';
  static const String hasSeenWelcome = 'has_seen_welcome';

  // ── Biometrics preference (UI flag only) ──────────────────────────────────
  // Whether the user has chosen to enable biometrics in app settings.
  // The actual biometric enrollment state is tracked in AuthStorageKeys.
  static const String biometricsPreferenceEnabled = 'biometrics_preference_enabled';
}
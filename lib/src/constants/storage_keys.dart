
/// Storage Keys
/// Centralized storage keys to avoid typos and conflicts
class StorageKeys {
  StorageKeys._();

  // ==================== Authentication ====================
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String isLoggedIn = 'is_logged_in';
  static const String userProfile = 'user_profile';

  // ==================== App Settings ====================
  static const String isDarkMode = 'is_dark_mode';
  static const String language = 'language';
  static const String isFirstLaunch = 'is_first_launch';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String biometricsEnabled = 'biometrics_enabled';

  // ==================== User Preferences ====================
  static const String fontSize = 'font_size';
  static const String currency = 'currency';
  static const String country = 'country';

  // ==================== Cache ====================
  static const String cacheVersion = 'cache_version';
  static const String lastSyncTime = 'last_sync_time';

  // ==================== Onboarding ====================
  static const String onboardingCompleted = 'onboarding_completed';
  static const String tutorialCompleted = 'tutorial_completed';
}
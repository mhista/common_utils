
// ─────────────────────────────────────────────────────────────────────────────
// FILE: notification_config.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:common_utils2/common_utils2.dart';


/// Configuration object passed once at initialization.
/// Create one per app — this is the primary customization surface.
class NotificationConfig {
  // ── Android ───────────────────────────────────────────────────────────────

  /// Drawable resource for the small notification icon.
  /// Must be white with a transparent background (Android system requirement).
  /// e.g. '@drawable/ic_notification' or '@mipmap/ic_launcher'
  final String androidIcon;

  // ── iOS ───────────────────────────────────────────────────────────────────

  final bool iosRequestAlert;
  final bool iosRequestBadge;
  final bool iosRequestSound;

  // ── Channels ──────────────────────────────────────────────────────────────

  /// Full list of channels to create at startup.
  /// Use [NotificationConfig.withDefaults] and pass [extraChannels] to
  /// include both the shared defaults and app-specific channels.
  final List<NotificationChannelDef> channels;

  // ── Customization: two layers ─────────────────────────────────────────────
  //
  // LAYER 1 — inline callbacks (quick, no class needed):
  //   onTokenRefreshed, onNotificationTap, onForegroundMessage
  //
  // LAYER 2 — handler class (for complex routing logic):
  //   payloadHandler (implements INotificationHandler)
  //
  // Execution order on any event:
  //   1. inline callback (returns bool → true stops chain)
  //   2. payloadHandler method (returns bool → true stops chain)
  //   3. built-in default (show local notification / no-op)

  /// LAYER 2: App-specific handler class.
  /// Implement [INotificationHandler] in your app and pass it here.
  final INotificationHandler? payloadHandler;

  /// LAYER 1: Called when a new token arrives or the token refreshes.
  /// Send this to your backend immediately.
  ///   onTokenRefreshed: (token) => myApi.saveFcmToken(userId, token)
  final Future<void> Function(String token)? onTokenRefreshed;

  /// LAYER 1: Called when the user taps a notification.
  /// Return true once you've navigated. Return false to fall through.
  ///   onNotificationTap: (payload) async {
  ///     router.push(payload.deepLink!);
  ///     return true;
  ///   }
  final Future<bool> Function(NotificationPayload payload)? onNotificationTap;

  /// LAYER 1: Called for foreground FCM messages before local display.
  /// Return true to suppress automatic local notification display.
  /// Return false to let the service show it.
  final Future<bool> Function(NotificationPayload payload)? onForegroundMessage;

  /// Topics to subscribe to immediately after initialization.
  /// For user-specific topics (e.g. 'user_123'), subscribe after login instead.
  final List<String> initialTopics;

  const NotificationConfig({
    this.androidIcon = '@mipmap/ic_launcher',
    this.iosRequestAlert = true,
    this.iosRequestBadge = true,
    this.iosRequestSound = true,
    required this.channels,
    this.payloadHandler,
    this.onTokenRefreshed,
    this.onNotificationTap,
    this.onForegroundMessage,
    this.initialTopics = const [],
  });

  /// Creates a config that includes all [AppNotificationChannel.all] channels
  /// plus any [extraChannels] your app needs. Recommended for most apps.
  factory NotificationConfig.withDefaults({
    String androidIcon = '@mipmap/ic_launcher',
    List<NotificationChannelDef> extraChannels = const [],
    INotificationHandler? payloadHandler,
    Future<void> Function(String token)? onTokenRefreshed,
    Future<bool> Function(NotificationPayload payload)? onNotificationTap,
    Future<bool> Function(NotificationPayload payload)? onForegroundMessage,
    List<String> initialTopics = const [],
    bool iosRequestAlert = true,
    bool iosRequestBadge = true,
    bool iosRequestSound = true,
  }) {
    return NotificationConfig(
      androidIcon: androidIcon,
      iosRequestAlert: iosRequestAlert,
      iosRequestBadge: iosRequestBadge,
      iosRequestSound: iosRequestSound,
      channels: [...AppNotificationChannel.all, ...extraChannels],
      payloadHandler: payloadHandler,
      onTokenRefreshed: onTokenRefreshed,
      onNotificationTap: onNotificationTap,
      onForegroundMessage: onForegroundMessage,
      initialTopics: initialTopics,
    );
  }
}


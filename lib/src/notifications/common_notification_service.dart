import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart' as fm;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'handlers/default_notification_handler.dart';
import 'handlers/i_notification_handler.dart';
import 'managers/display_manager.dart';
import 'managers/notification_token_manager.dart';
import 'managers/topic_manager.dart';
import 'notification_config.dart';
import 'notification_payload.dart';
import 'notification_preferences.dart';

// ── Background FCM handler — MUST be top-level ───────────────────────────────
@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(fm.RemoteMessage message) async {
  // Runs in a separate Dart isolate: no getIt, no router, no singletons from
  // the main isolate. Allowed: Firebase calls, SharedPreferences, local DB.
  //
  // If you need custom background work, register your OWN top-level handler
  // with `FirebaseMessaging.onBackgroundMessage(...)` BEFORE calling
  // `CommonNotificationService.initialize` and pass
  // `registerBackgroundHandler: false`.
  debugPrint('🔔 [BG FCM] ${message.notification?.title}');
}

/// Unified FCM + local notification service.
///
/// Lifecycle:
/// ```dart
/// await Firebase.initializeApp(...);
/// await CommonNotificationService.instance.initialize(config);
/// // …later, when the router is ready:
/// final tap = CommonNotificationService.instance.consumePendingTap();
/// ```
class CommonNotificationService {
  CommonNotificationService._();
  static final CommonNotificationService instance =
      CommonNotificationService._();

  late NotificationTokenManager _tokens;
  late TopicManager _topics;
  late DisplayManager _display;
  late INotificationHandler _handler;
  NotificationConfig? _cfg;
  NotificationConfig get _config => _cfg!;

  /// Per-channel mute preferences (see [NotificationPreferences]).
  final NotificationPreferences preferences = NotificationPreferences();

  // Stores a pending tap payload when the app launches from a terminated-state
  // notification (FCM or local). The router reads this once it's ready.
  NotificationPayload? _pendingTap;

  final _messages = StreamController<NotificationPayload>.broadcast();
  final _taps = StreamController<NotificationPayload>.broadcast();

  StreamSubscription<fm.RemoteMessage>? _fgSub;
  StreamSubscription<fm.RemoteMessage>? _openedSub;
  bool _initialized = false;

  /// Whether [initialize] has completed.
  bool get isInitialized => _initialized;

  static bool get _isIOS =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  // ── Initialization ────────────────────────────────────────────────────────

  /// Call once in main(), after `Firebase.initializeApp()` and before `runApp()`.
  ///
  /// Set [registerBackgroundHandler] to false if your app registers its own
  /// `FirebaseMessaging.onBackgroundMessage` handler.
  Future<void> initialize(
    NotificationConfig config, {
    bool registerBackgroundHandler = true,
  }) async {
    if (_initialized) return;
    _cfg = config;
    _handler = config.payloadHandler ?? const DefaultNotificationHandler();

    final fcm = fm.FirebaseMessaging.instance;
    final plugin = FlutterLocalNotificationsPlugin();

    _tokens = NotificationTokenManager(
      fcm,
      onRefreshed: config.onTokenRefreshed,
    );
    _topics = TopicManager(fcm);
    _display = DisplayManager(
      plugin,
      androidIcon: config.androidIcon,
      onTap: _handleTap,
    );

    // Register FCM background handler before any other FCM setup.
    if (registerBackgroundHandler) {
      fm.FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);
    }

    await preferences.switchScope(config.preferencesScope);

    if (config.requestPermissionOnInit) {
      await requestPermission();
    }

    final localLaunch = await _display.initialize(config.channels);
    await _tokens.initialize();

    if (config.initialTopics.isNotEmpty) {
      await _topics.subscribeMany(config.initialTopics);
    }

    _listenForeground();
    _listenOpened();

    // Store the launch payload — do NOT navigate yet (router not ready).
    // Call consumePendingTap() from your router redirect or first screen.
    final initial = await fcm.getInitialMessage();
    if (initial != null) {
      _pendingTap = NotificationPayload.fromFCM(initial);
    } else if (localLaunch != null) {
      _pendingTap = localLaunch;
    }
    if (_pendingTap != null) {
      debugPrint('🔔 [INIT] Stored pending tap: ${_pendingTap?.type}');
    }

    _initialized = true;
    debugPrint('✅ CommonNotificationService ready');
  }

  // ── Permissions ───────────────────────────────────────────────────────────

  /// Ask the OS for notification permission.
  ///
  /// Safe to call multiple times; the OS only prompts once. Returns true when
  /// notifications are allowed (authorized or provisional).
  Future<bool> requestPermission() async {
    try {
      if (_isAndroid) {
        final granted = await FlutterLocalNotificationsPlugin()
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
        return granted ?? false;
      }
      final settings = await fm.FirebaseMessaging.instance.requestPermission(
        alert: _cfg?.iosRequestAlert ?? true,
        badge: _cfg?.iosRequestBadge ?? true,
        sound: _cfg?.iosRequestSound ?? true,
      );
      return settings.authorizationStatus ==
              fm.AuthorizationStatus.authorized ||
          settings.authorizationStatus == fm.AuthorizationStatus.provisional;
    } catch (e) {
      debugPrint('❌ requestPermission error: $e');
      return false;
    }
  }

  /// Current permission status without prompting.
  Future<bool> hasPermission() async {
    final s = await fm.FirebaseMessaging.instance.getNotificationSettings();
    return s.authorizationStatus == fm.AuthorizationStatus.authorized ||
        s.authorizationStatus == fm.AuthorizationStatus.provisional;
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  void _listenForeground() {
    _fgSub = fm.FirebaseMessaging.onMessage.listen((message) async {
      final payload = NotificationPayload.fromFCM(message);
      debugPrint('🔔 [FG] ${payload.title} | type:${payload.type}');
      _messages.add(payload);

      // Layer 1: config callback
      if (await _config.onForegroundMessage?.call(payload) == true) return;
      // Layer 2: handler class
      if (await _handler.onForegroundMessage(payload)) return;
      // Respect per-channel mute
      if (preferences.isMuted(payload.channelId)) {
        debugPrint('🔕 [FG] channel "${payload.channelId}" muted — not shown');
        return;
      }
      // Default: show local notification
      await _display.show(payload);
    });
  }

  void _listenOpened() {
    _openedSub = fm.FirebaseMessaging.onMessageOpenedApp.listen((
      message,
    ) async {
      final payload = NotificationPayload.fromFCM(message);
      debugPrint('🔔 [OPENED] type:${payload.type}');
      await _handleTap(payload);
    });
  }

  Future<void> _handleTap(NotificationPayload payload) async {
    debugPrint('👆 Tapped: type=${payload.type} entity=${payload.entityId}');
    _taps.add(payload);
    // Layer 1
    if (await _config.onNotificationTap?.call(payload) == true) return;
    // Layer 2
    await _handler.onNotificationTap(payload);
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Every foreground FCM message (before display decisions). Pipe this into
  /// your in-app inbox, e.g. `messages.listen(notificationCubit.addFromPayload)`.
  Stream<NotificationPayload> get messages => _messages.stream;

  /// Every notification tap (FCM or local), after the app is running.
  Stream<NotificationPayload> get taps => _taps.stream;

  // --- Token ---

  /// Current FCM token. Null until initialize() completes.
  String? get token => _tokens.currentToken;

  /// Stream of token changes — subscribe and send to your backend.
  Stream<String> get tokenStream => _tokens.stream;

  // --- Topics ---

  Future<void> subscribe(String topic) => _topics.subscribe(topic);
  Future<void> unsubscribe(String topic) => _topics.unsubscribe(topic);
  Future<void> subscribeMany(List<String> topics) =>
      _topics.subscribeMany(topics);

  /// Call on logout — cleans up all topic subscriptions.
  Future<void> unsubscribeAll() => _topics.unsubscribeAll();

  // --- Display ---

  /// Show a local notification from a fully built [NotificationPayload].
  /// Muted channels are skipped unless [ignoreMute] is true.
  Future<void> showFromPayload(
    NotificationPayload payload, {
    bool ignoreMute = false,
  }) async {
    if (!ignoreMute && preferences.isMuted(payload.channelId)) return;
    await _display.show(payload);
  }

  /// Show a simple local notification inline without building a payload object.
  /// Muted channels are skipped unless [ignoreMute] is true.
  Future<void> show({
    required String title,
    required String body,
    String channelId = 'general',
    String? payloadString,
    bool ignoreMute = false,
  }) async {
    if (!ignoreMute && preferences.isMuted(channelId)) return;
    await _display.showSimple(
      title: title,
      body: body,
      channelId: channelId,
      payloadString: payloadString,
    );
  }

  Future<void> cancel(int id) => _display.cancel(id);

  /// Cancel the notification shown for a stable key (`notificationId`, `tag`,
  /// `threadId` or `conversationId` in the payload data) — e.g. clear a chat
  /// thread's notification when the user opens that conversation.
  Future<void> cancelByKey(String key) => _display.cancelByKey(key);

  Future<void> cancelAll() => _display.cancelAll();

  // --- Pending tap (terminated-state launch) ---

  /// Call this once your router/navigator is ready (e.g. inside the redirect
  /// callback or from the first post-login route).
  ///
  /// If the app was launched by tapping a notification while terminated,
  /// this returns the payload so you can navigate to the right screen.
  /// Returns null if there is no pending tap. Consumed once.
  NotificationPayload? consumePendingTap() {
    final p = _pendingTap;
    _pendingTap = null;
    return p;
  }

  /// Whether a launch tap is waiting to be consumed.
  bool get hasPendingTap => _pendingTap != null;

  // --- Runtime handler replacement ---

  /// Replace the handler at runtime (e.g. after login when user type is known).
  void setHandler(INotificationHandler handler) => _handler = handler;

  // --- iOS foreground presentation ---

  /// iOS/macOS: controls whether FCM shows alerts/badges/sounds itself while
  /// the app is in the foreground. The service already displays foreground
  /// messages as local notifications, so leave these false to avoid duplicates
  /// unless you disable local display in `onForegroundMessage`.
  Future<void> setForegroundPresentationOptions({
    bool alert = false,
    bool badge = false,
    bool sound = false,
  }) async {
    if (!_isIOS) return;
    await fm.FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: alert,
          badge: badge,
          sound: sound,
        );
  }

  /// Deprecated: the name never matched the behaviour.
  @Deprecated('Use setForegroundPresentationOptions(badge: ...) instead')
  Future<void> setBadgeCount(bool badge) =>
      setForegroundPresentationOptions(badge: badge);

  // --- Token cleanup ---

  /// Call on logout. Deletes the FCM token so this device stops receiving
  /// notifications for the logged-out user.
  Future<void> deleteToken() => _tokens.delete();

  // --- Lifecycle ---

  void dispose() {
    _fgSub?.cancel();
    _openedSub?.cancel();
    _tokens.dispose();
    _messages.close();
    _taps.close();
    preferences.dispose();
  }
}

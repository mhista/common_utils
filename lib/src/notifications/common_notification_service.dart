
import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart' as fm;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'managers/display_manager.dart';
import 'managers/notification_token_manager.dart';
import 'managers/topic_manager.dart';
import 'notifications.dart';

// ── Background FCM handler — MUST be top-level ───────────────────────────────
@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(fm.RemoteMessage message) async {
  // This runs in a separate Dart isolate.
  // No access to getIt, GoRouter, or any singleton from the main isolate.
  // Allowed: Firebase calls, SharedPreferences, sqflite writes.
  debugPrint('🔔 [BG FCM] ${message.notification?.title}');
}

class CommonNotificationService {
  CommonNotificationService._();
  static final CommonNotificationService instance =
      CommonNotificationService._();

  late NotificationTokenManager _tokens;
  late TopicManager _topics;
  late DisplayManager _display;
  late INotificationHandler _handler;
  late NotificationConfig _config;

  // Stores a pending tap payload when the app launches from a terminated-state
  // notification. The router reads this once it's ready.
  NotificationPayload? _pendingTap;

  StreamSubscription<fm.RemoteMessage>? _fgSub;
  StreamSubscription<fm.RemoteMessage>? _openedSub;
  bool _initialized = false;

  // ── Initialization ────────────────────────────────────────────────────────

  /// Call once in main(), after Firebase.initializeApp() and before runApp().
  Future<void> initialize(NotificationConfig config) async {
    if (_initialized) return;
    _config = config;
    _handler = config.payloadHandler ?? const DefaultNotificationHandler();

    final fcm = fm.FirebaseMessaging.instance;
    final plugin = FlutterLocalNotificationsPlugin();

    _tokens = NotificationTokenManager(fcm, onRefreshed: config.onTokenRefreshed);
    _topics = TopicManager(fcm);
    _display = DisplayManager(
      plugin,
      androidIcon: config.androidIcon,
      onTap: _handleTap,
    );

    // Register FCM background handler before any other FCM setup.
    fm.FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);

    await _requestPermissions(fcm, config);
    await _display.initialize(config.channels);
    await _tokens.initialize();

    if (config.initialTopics.isNotEmpty) {
      await _topics.subscribeMany(config.initialTopics);
    }

    _listenForeground();
    _listenOpened();

    // Store the initial message payload — do NOT navigate yet.
    // The router is not ready at this point. Call consumePendingTap()
    // from your router's redirect or from the first authenticated route.
    final initial = await fcm.getInitialMessage();
    if (initial != null) {
      _pendingTap = NotificationPayload.fromFCM(initial);
      debugPrint('🔔 [INIT] Stored pending tap: ${_pendingTap?.type}');
    }

    _initialized = true;
    debugPrint('✅ CommonNotificationService ready');
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  Future<void> _requestPermissions(
    fm.FirebaseMessaging fcm,
    NotificationConfig config,
  ) async {
    if (Platform.isIOS) {
      await fcm.requestPermission(
        alert: config.iosRequestAlert,
        badge: config.iosRequestBadge,
        sound: config.iosRequestSound,
      );
    }
    if (Platform.isAndroid) {
      await FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  void _listenForeground() {
    _fgSub = fm.FirebaseMessaging.onMessage.listen((message) async {
      final payload = NotificationPayload.fromFCM(message);
      debugPrint('🔔 [FG] ${payload.title} | type:${payload.type}');

      // Layer 1: config callback
      if (await _config.onForegroundMessage?.call(payload) == true) return;
      // Layer 2: handler class
      if (await _handler.onForegroundMessage(payload)) return;
      // Default: show local notification
      await _display.show(payload);
    });
  }

  void _listenOpened() {
    _openedSub =
        fm.FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      final payload = NotificationPayload.fromFCM(message);
      debugPrint('🔔 [OPENED] type:${payload.type}');
      await _handleTap(payload);
    });
  }

  Future<void> _handleTap(NotificationPayload payload) async {
    debugPrint('👆 Tapped: type=${payload.type} entity=${payload.entityId}');
    // Layer 1
    if (await _config.onNotificationTap?.call(payload) == true) return;
    // Layer 2
    await _handler.onNotificationTap(payload);
  }

  // ── Public API ────────────────────────────────────────────────────────────

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
  /// Use when you've already constructed the payload (e.g. from a BLoC event).
  Future<void> showFromPayload(NotificationPayload payload) =>
      _display.show(payload);

  /// Show a simple local notification inline without building a payload object.
  Future<void> show({
    required String title,
    required String body,
    String channelId = 'general',
    String? payloadString,
  }) =>
      _display.showSimple(
        title: title,
        body: body,
        channelId: channelId,
        payloadString: payloadString,
      );

  Future<void> cancel(int id) => _display.cancel(id);
  Future<void> cancelAll() => _display.cancelAll();

  // --- Pending tap (terminated-state launch) ---

  /// Call this once your router/navigator is ready (e.g. inside the redirect
  /// callback or from the first post-login route).
  ///
  /// If the app was launched by tapping a notification while terminated,
  /// this returns the payload so you can navigate to the right screen.
  /// Returns null if there is no pending tap.
  ///
  /// Example in your router redirect:
  ///   final pending = CommonNotificationService.instance.consumePendingTap();
  ///   if (pending != null) return pending.deepLink;
  NotificationPayload? consumePendingTap() {
    final p = _pendingTap;
    _pendingTap = null;
    return p;
  }

  // --- Runtime handler replacement ---

  /// Replace the handler at runtime (e.g. after login when user type is known).
  void setHandler(INotificationHandler handler) => _handler = handler;

  // --- Badge ---

  Future<void> setBadgeCount(bool badge) async {
    if (Platform.isIOS) {
      await fm.FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(badge: badge);
    }
  }

  // --- Token cleanup ---

  /// Call on logout. Deletes the FCM token so this device stops receiving
  /// notifications for the logged-out user.
  Future<void> deleteToken() => _tokens.delete();

  // --- Lifecycle ---

  void dispose() {
    _fgSub?.cancel();
    _openedSub?.cancel();
    _tokens.dispose();
  }
}


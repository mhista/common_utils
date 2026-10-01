import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../notification_channel.dart';
import '../notification_payload.dart';

/// Owns the [FlutterLocalNotificationsPlugin]: channel creation, display,
/// cancellation and local-notification tap routing.
class DisplayManager {
  final FlutterLocalNotificationsPlugin _plugin;
  final String _androidIcon;
  final void Function(NotificationPayload)? _onTap;
  final Map<String, NotificationChannelDef> _channels = {};

  DisplayManager(
    this._plugin, {
    required String androidIcon,
    void Function(NotificationPayload)? onTap,
  }) : _androidIcon = androidIcon,
       _onTap = onTap;

  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Initializes the plugin and creates the Android channels.
  ///
  /// Returns the payload of the local notification that launched the app from
  /// a terminated state (if any), so the caller can defer navigation until
  /// the router is ready.
  Future<NotificationPayload?> initialize(
    List<NotificationChannelDef> channels,
  ) async {
    for (final c in channels) {
      _channels[c.id] = c;
    }

    await _plugin.initialize(
      settings: InitializationSettings(
        android: AndroidInitializationSettings(_androidIcon),
        // Permissions are requested explicitly by CommonNotificationService so
        // the app controls *when* the prompt appears.
        iOS: const DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) {
        _onTap?.call(NotificationPayload.fromLocalPayload(r.payload));
      },
      // Background isolate — navigator not available. See _onBackgroundLocalTap.
      onDidReceiveBackgroundNotificationResponse: _onBackgroundLocalTap,
    );

    if (_isAndroid) await _createChannels(channels);

    // Local notification that cold-started the app?
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp ?? false) {
        final payload = details!.notificationResponse?.payload;
        return NotificationPayload.fromLocalPayload(payload);
      }
    } catch (e) {
      debugPrint('⚠️ getNotificationAppLaunchDetails failed: $e');
    }
    return null;
  }

  Future<void> _createChannels(List<NotificationChannelDef> defs) async {
    final impl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (impl == null) return;

    for (final d in defs) {
      await impl.createNotificationChannel(
        AndroidNotificationChannel(
          d.id,
          d.name,
          description: d.description,
          importance: d.importance,
          playSound: d.playSound,
          enableVibration: d.enableVibration,
          showBadge: d.showBadge,
        ),
      );
    }
    debugPrint('✅ Android channels created (${defs.length})');
  }

  /// Display a notification built from [payload].
  ///
  /// Payload data keys understood here (all optional):
  /// * `notificationId` / `tag` / `threadId` / `conversationId` — stable key;
  ///   a new notification with the same key REPLACES the previous one instead
  ///   of stacking (ideal for chat threads and order status updates).
  /// * `groupKey` — Android group key so related notifications bundle.
  Future<void> show(NotificationPayload payload) async {
    await _plugin.show(
      id: _idFor(payload),
      title: payload.title ?? '',
      body: payload.body ?? '',
      notificationDetails: _details(
        payload.channelId,
        groupKey: payload.get<String>('groupKey'),
      ),
      payload: payload.toPayloadString(),
    );
  }

  Future<void> showSimple({
    required String title,
    required String body,
    String channelId = 'general',
    String? payloadString,
    int? id,
  }) async {
    await _plugin.show(
      id: id ?? _notificationId(),
      title: title,
      body: body,
      notificationDetails: _details(channelId),
      payload: payloadString,
    );
  }

  NotificationDetails _details(String channelId, {String? groupKey}) {
    final def = _channels[channelId];
    final importance = def?.importance ?? Importance.high;
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        // Channel name shown in system settings. Falls back to the ID only if
        // the app displays on a channel it never declared.
        def?.name ?? channelId,
        channelDescription: def?.description,
        importance: importance,
        priority: _priorityFor(importance),
        playSound: def?.playSound ?? true,
        enableVibration: def?.enableVibration ?? true,
        icon: _androidIcon,
        groupKey: groupKey,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: def?.showBadge ?? true,
        presentSound: def?.playSound ?? true,
        threadIdentifier: groupKey ?? channelId,
      ),
    );
  }

  static Priority _priorityFor(Importance i) {
    if (i == Importance.max) return Priority.max;
    if (i == Importance.high) return Priority.high;
    if (i == Importance.low || i == Importance.min) return Priority.low;
    return Priority.defaultPriority;
  }

  int _idFor(NotificationPayload p) {
    final key =
        p.get<String>('notificationId') ??
        p.get<String>('tag') ??
        p.get<String>('threadId') ??
        p.get<String>('conversationId');
    if (key != null && key.isNotEmpty) return key.hashCode & 0x7fffffff;
    return _notificationId();
  }

  int _notificationId() => DateTime.now().millisecondsSinceEpoch % 2147483647;

  Future<void> cancel(int id) => _plugin.cancel(id: id);

  /// Cancel the notification that was shown for a stable key (see [show]).
  Future<void> cancelByKey(String key) =>
      _plugin.cancel(id: key.hashCode & 0x7fffffff);

  Future<void> cancelAll() => _plugin.cancelAll();
}

// Must be top-level — called in a background isolate.
@pragma('vm:entry-point')
void _onBackgroundLocalTap(NotificationResponse response) {
  // Cannot navigate here — this isolate has no router.
  // On Android the app is brought to the foreground afterwards and the tap is
  // re-delivered through getNotificationAppLaunchDetails / the foreground
  // callback, which CommonNotificationService turns into a pending tap.
  debugPrint('📥 [BG LOCAL TAP] payload: ${response.payload}');
}

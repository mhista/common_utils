import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../notifications.dart';

class DisplayManager {
  final FlutterLocalNotificationsPlugin _plugin;
  final String _androidIcon;
  final void Function(NotificationPayload)? _onTap;

  DisplayManager(
    this._plugin, {
    required String androidIcon,
    void Function(NotificationPayload)? onTap,
  }) : _androidIcon = androidIcon,
       _onTap = onTap;

  Future<void> initialize(List<NotificationChannelDef> channels) async {
    await _plugin.initialize(
      settings: InitializationSettings(
        android: AndroidInitializationSettings(_androidIcon),
        iOS: const DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
      onDidReceiveNotificationResponse: (r) {
        _onTap?.call(NotificationPayload.fromLocalPayload(r.payload));
      },
      // Handle tap when app was terminated (separate isolate — navigator not ready)
      // Navigation is deferred inside CommonNotificationService._handleTap.
      onDidReceiveBackgroundNotificationResponse: _onBackgroundLocalTap,
    );

    if (Platform.isAndroid) await _createChannels(channels);
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
        ),
      );
    }
    debugPrint('✅ Android channels created');
  }

  Future<void> show(NotificationPayload payload) async {
    await _plugin.show(
      id: _notificationId(),
      title: payload.title ?? '',
      body: payload.body ?? '',
      notificationDetails: _details(payload.channelId),
      payload: payload.toPayloadString(),
    );
  }

  Future<void> showSimple({
    required String title,
    required String body,
    String channelId = 'general',
    String? payloadString,
  }) async {
    await _plugin.show(
      id: _notificationId(),
      title: title,
      body: body,
      notificationDetails: _details(channelId),
      payload: payloadString,
    );
  }

  NotificationDetails _details(String channelId) => NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      channelId,
      importance: Importance.high,
      priority: Priority.high,
      icon: _androidIcon,
    ),
    iOS: const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  int _notificationId() => DateTime.now().millisecondsSinceEpoch % 2147483647;

  Future<void> cancel(int id) => _plugin.cancel(id: id);
  Future<void> cancelAll() => _plugin.cancelAll();
}

// Must be top-level — called in a background isolate
@pragma('vm:entry-point')
void _onBackgroundLocalTap(NotificationResponse response) {
  // Cannot navigate here — isolate has no access to the router.
  // CommonNotificationService stores the payload; the app reads it on next resume.
  debugPrint('📥 [BG LOCAL TAP] payload: ${response.payload}');
}




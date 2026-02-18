
// ignore_for_file: one_member_abstracts
import 'package:flutter/foundation.dart';

import '../notifications.dart';

// Forward-declared here so notification_config.dart can reference it.
// The actual import in each file is from handlers/i_notification_handler.dart.

/// Implement this in each app to handle notification routing and display.
///
/// Every method returns a [bool]:
///   true  → you handled it, stop processing
///   false → fall through to the next layer (config callback → default behavior)
abstract class INotificationHandler {
  /// Foreground FCM message received.
  /// Return true to suppress the automatic local notification display.
  Future<bool> onForegroundMessage(NotificationPayload payload) async => false;

  /// User tapped a notification (from any app state).
  /// Return true once you've navigated or handled it.
  Future<bool> onNotificationTap(NotificationPayload payload) async => false;

  /// Background FCM message (separate isolate — no UI, no router).
  /// Use for data sync, badge updates, local DB writes only.
  Future<void> onBackgroundMessage(NotificationPayload payload) async {
    debugPrint('📥 [BG] type=${payload.type} id=${payload.entityId}');
  }
}

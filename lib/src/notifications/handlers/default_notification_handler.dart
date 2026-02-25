import 'package:common_utils2/common_utils2.dart';


/// No-op handler — used when an app doesn't supply a custom handler.
/// Foreground messages are shown as local notifications automatically.
class DefaultNotificationHandler implements INotificationHandler {
  const DefaultNotificationHandler();

  @override
  Future<bool> onForegroundMessage(NotificationPayload payload) async => false;

  @override
  Future<bool> onNotificationTap(NotificationPayload payload) async => false;

  @override
  Future<void> onBackgroundMessage(NotificationPayload payload) async {}
}

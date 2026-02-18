
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Defines one Android notification channel.
/// Channels are permanent once created — users can adjust them in Settings.
/// Never change an existing channel's importance; create a new channel instead.
class NotificationChannelDef {
  final String id;
  final String name;
  final String description;
  final Importance importance;
  final bool playSound;
  final bool enableVibration;

  const NotificationChannelDef({
    required this.id,
    required this.name,
    required this.description,
    this.importance = Importance.high,
    this.playSound = true,
    this.enableVibration = true,
  });
}


/// Shared channels included by default in every app.
/// Apps extend this via [NotificationConfig.extraChannels].
class AppNotificationChannel {
  const AppNotificationChannel._();

  static const general = NotificationChannelDef(
    id: 'general',
    name: 'General',
    description: 'General app notifications',
    importance: Importance.defaultImportance,
  );

  static const orders = NotificationChannelDef(
    id: 'orders',
    name: 'Orders',
    description: 'Order updates and confirmations',
    importance: Importance.high,
  );

  static const messages = NotificationChannelDef(
    id: 'messages',
    name: 'Messages',
    description: 'Chat messages and replies',
    importance: Importance.high,
  );

  static const promotions = NotificationChannelDef(
    id: 'promotions',
    name: 'Promotions',
    description: 'Deals, offers and promotions',
    importance: Importance.defaultImportance,
    playSound: false,
  );

  static const alerts = NotificationChannelDef(
    id: 'alerts',
    name: 'Alerts',
    description: 'Urgent system alerts',
    importance: Importance.max,
  );

  static const List<NotificationChannelDef> all = [
    general,
    orders,
    messages,
    promotions,
    alerts,
  ];
}



import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart' as fm;

/// Unified payload wrapping both FCM remote messages and local notifications.
///
/// The [data] map accepts anything your server sends — there are no fixed keys
/// beyond the convenience getters below. Every app and every notification type
/// can carry whatever it needs.
///
/// Access patterns:
///   payload.type              → data['type'] shortcut
///   payload.entityId          → resolves orderId / productId / id
///   payload.deepLink          → resolves deepLink / deep_link
///   payload.get<T>('myKey')   → typed access to any key
///   payload.typed<MyModel>(MyModel.fromJson)  → full model extraction
class NotificationPayload {
  final String? messageId;
  final String? title;
  final String? body;
  final String? imageUrl;

  /// Matches an [AppNotificationChannel.id] or a custom channel ID.
  final String channelId;

  /// The complete data map from the FCM `data` block, or the decoded local
  /// notification payload string. Everything your server sends lands here.
  final Map<String, dynamic> data;

  final DateTime receivedAt;

  const NotificationPayload({
    this.messageId,
    this.title,
    this.body,
    this.imageUrl,
    this.channelId = 'general',
    required this.data,
    required this.receivedAt,
  });

  // ── Constructors ──────────────────────────────────────────────────────────

  /// Build from a Firebase RemoteMessage (foreground, background, or initial).
  factory NotificationPayload.fromFCM(fm.RemoteMessage message) {
    final n = message.notification;
    // FCM data values are always strings. Cast carefully.
    final rawData = Map<String, dynamic>.from(message.data);

    return NotificationPayload(
      messageId: message.messageId,
      title: n?.title,
      body: n?.body,
      // Android can send a large image URL; iOS sends it differently.
      imageUrl: n?.android?.imageUrl ?? n?.apple?.imageUrl,
      channelId: rawData['channel'] as String? ?? 'general',
      data: rawData,
      receivedAt: message.sentTime ?? DateTime.now(),
    );
  }

  /// Build from a local notification payload string.
  ///
  /// Supports two formats:
  ///   1. JSON string  → decoded into [data]
  ///   2. Plain URL string → stored under data['deepLink']
  factory NotificationPayload.fromLocalPayload(String? payloadString) {
    if (payloadString == null || payloadString.isEmpty) {
      return NotificationPayload(data: const {}, receivedAt: DateTime.now());
    }
    try {
      final decoded = jsonDecode(payloadString) as Map<String, dynamic>;
      return NotificationPayload(
        title: decoded['title'] as String?,
        body: decoded['body'] as String?,
        imageUrl: decoded['imageUrl'] as String?,
        channelId: decoded['channel'] as String? ?? 'general',
        data: decoded,
        receivedAt: DateTime.now(),
      );
    } catch (_) {
      // Plain string — treat as a bare deep link.
      return NotificationPayload(
        data: {'deepLink': payloadString},
        receivedAt: DateTime.now(),
      );
    }
  }

  /// Build a payload for a locally triggered notification (no FCM involved).
  factory NotificationPayload.local({
    required String title,
    required String body,
    String channelId = 'general',
    String? deepLink,
    String? type,
    String? entityId,
    Map<String, dynamic> extras = const {},
  }) {
    return NotificationPayload(
      title: title,
      body: body,
      channelId: channelId,
      data: {
        if (type != null) 'type': type,
        if (entityId != null) 'id': entityId,
        if (deepLink != null) 'deepLink': deepLink,
        ...extras,
      },
      receivedAt: DateTime.now(),
    );
  }

  // ── Convenience getters ───────────────────────────────────────────────────

  /// Notification type string sent by your server (e.g. 'order_shipped').
  String? get type => data['type'] as String?;

  /// Resolves common entity ID key variants sent by different backends.
  String? get entityId =>
      data['id'] as String? ??
      data['orderId'] as String? ??
      data['order_id'] as String? ??
      data['productId'] as String? ??
      data['product_id'] as String? ??
      data['userId'] as String? ??
      data['user_id'] as String?;

  /// Resolves common deep link key variants.
  String? get deepLink =>
      data['deepLink'] as String? ?? data['deep_link'] as String?;

  // ── Data access helpers ───────────────────────────────────────────────────

  /// Typed access to any key in [data].
  ///   final code = payload.get<String>('promoCode');
  ///   final amount = payload.get<double>('amount');
  T? get<T>(String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is T) return value;
    // FCM sends everything as String — attempt common coercions.
    if (T == double && value is String) return double.tryParse(value) as T?;
    if (T == int && value is String) return int.tryParse(value) as T?;
    if (T == bool && value is String) {
      return (value == 'true') as T?;
    }
    return null;
  }

  /// Extract a typed model from [data].
  ///   final order = payload.typed(OrderNotificationData.fromJson);
  T? typed<T>(T Function(Map<String, dynamic>) fromJson) {
    try {
      return fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Serialize to a JSON string — used as the local notification payload.
  String toPayloadString() => jsonEncode({
        if (title != null) 'title': title,
        if (body != null) 'body': body,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'channel': channelId,
        ...data,
      });

  @override
  String toString() =>
      'NotificationPayload(type:$type, channel:$channelId, '
      'entity:$entityId, deepLink:$deepLink)';
}


import 'package:freezed_annotation/freezed_annotation.dart';
import '../notification_payload.dart';

part 'notification_entry.freezed.dart';
part 'notification_entry.g.dart';

@freezed
abstract class NotificationEntry with _$NotificationEntry {
  const NotificationEntry._(); // needed for custom getters

  const factory NotificationEntry({
    required String id,
    String? title,
    String? body,
    String? imageUrl,
    String? deepLink,
    @Default('general') String type,
    @Default('general') String channelId,
    @Default({}) Map<String, dynamic> data,
    required DateTime receivedAt,
    @Default(false) bool isRead,
  }) = _NotificationEntry;

  factory NotificationEntry.fromJson(Map<String, dynamic> json) =>
      _$NotificationEntryFromJson(json);

  /// Build from a [NotificationPayload] coming off the wire.
  factory NotificationEntry.fromPayload(NotificationPayload payload) {
    return NotificationEntry(
      id: payload.messageId ??
          'local_${DateTime.now().millisecondsSinceEpoch}',
      title: payload.title,
      body: payload.body,
      imageUrl: payload.imageUrl,
      deepLink: payload.deepLink,
      type: payload.type ?? 'general',
      channelId: payload.channelId,
      data: Map<String, dynamic>.from(payload.data),
      receivedAt: payload.receivedAt,
    );
  }
}

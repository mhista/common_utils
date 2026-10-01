
import 'package:freezed_annotation/freezed_annotation.dart';
import 'notification_entry.dart';

part 'notification_state.freezed.dart';

@freezed
abstract class NotificationState with _$NotificationState {
  const NotificationState._();

  const factory NotificationState({
    @Default([]) List<NotificationEntry> entries,
    @Default(false) bool isLoading,
    String? error,
  }) = _NotificationState;

  // ── Derived values — computed from state, not stored ─────────────────────

  int get unreadCount => entries.where((e) => !e.isRead).length;
  bool get hasUnread => unreadCount > 0;
  bool get isEmpty => entries.isEmpty;

  List<NotificationEntry> get unread =>
      entries.where((e) => !e.isRead).toList();

  /// Entries for one channel/category (e.g. 'orders').
  List<NotificationEntry> entriesFor(String channelId) =>
      entries.where((e) => e.channelId == channelId).toList();

  /// Unread count for one channel/category.
  int unreadCountFor(String channelId) =>
      entries.where((e) => !e.isRead && e.channelId == channelId).length;

  /// Unread count per channel — handy for category tabs.
  Map<String, int> get unreadByChannel {
    final map = <String, int>{};
    for (final e in entries) {
      if (!e.isRead) map[e.channelId] = (map[e.channelId] ?? 0) + 1;
    }
    return map;
  }
}
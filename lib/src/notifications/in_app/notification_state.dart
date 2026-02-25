
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
}
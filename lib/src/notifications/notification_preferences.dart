import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-channel ("category") notification preferences, persisted on device.
///
/// Apps with many notification categories (messages, orders, payments,
/// security…) should let users mute each one independently. This class stores
/// the muted channel IDs and is consulted by [CommonNotificationService]
/// before it displays a foreground notification.
///
/// ```dart
/// final prefs = CommonNotificationService.instance.preferences;
/// await prefs.setMuted('promotions', true);
/// prefs.isMuted('promotions'); // true
/// prefs.changes.listen((muted) => print('muted: $muted'));
/// ```
///
/// IMPORTANT — device-side muting only affects notifications the app itself
/// displays (foreground FCM + local notifications). Notification-type FCM
/// messages that arrive while the app is in the background are rendered by
/// the OS. To fully respect a mute, also store the preference on your
/// backend and skip sending (or send data-only messages). Use [changes] to
/// sync the muted set to your server.
///
/// Scopes: pass a [scope] (e.g. the active account ID) to keep separate
/// preferences per account on the same device. See [switchScope].
class NotificationPreferences {
  NotificationPreferences({String? scope}) : _scope = scope;

  static const _prefix = 'notification_muted_channels_v1';

  String? _scope;
  Set<String> _muted = <String>{};
  bool _loaded = false;
  final _controller = StreamController<Set<String>>.broadcast();

  /// Current storage scope (null = device-wide).
  String? get scope => _scope;

  String get _key => _scope == null ? _prefix : '${_prefix}_$_scope';

  /// Emits the full muted set every time it changes.
  Stream<Set<String>> get changes => _controller.stream;

  /// Snapshot of muted channel IDs.
  Set<String> get mutedChannels => Set.unmodifiable(_muted);

  /// Whether [channelId] is muted. Returns false until [load] completes.
  bool isMuted(String channelId) => _muted.contains(channelId);

  /// Load persisted preferences. Called automatically by the service.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _muted = (prefs.getStringList(_key) ?? const <String>[]).toSet();
    } catch (e) {
      debugPrint('❌ NotificationPreferences load error: $e');
      _muted = <String>{};
    }
    _loaded = true;
    _controller.add(mutedChannels);
  }

  /// Whether [load] has completed at least once.
  bool get isLoaded => _loaded;

  /// Mute or unmute a single channel.
  Future<void> setMuted(String channelId, bool muted) async {
    final changed = muted ? _muted.add(channelId) : _muted.remove(channelId);
    if (!changed) return;
    await _persist();
  }

  /// Replace the whole muted set (e.g. after fetching from your backend).
  Future<void> setAll(Iterable<String> mutedChannelIds) async {
    _muted = mutedChannelIds.toSet();
    await _persist();
  }

  /// Switch to another scope (e.g. when the user switches accounts) and load
  /// that scope's preferences.
  Future<void> switchScope(String? scope) async {
    if (scope == _scope && _loaded) return;
    _scope = scope;
    await load();
  }

  Future<void> _persist() async {
    _controller.add(mutedChannels);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, _muted.toList());
    } catch (e) {
      debugPrint('❌ NotificationPreferences persist error: $e');
    }
  }

  void dispose() => _controller.close();
}

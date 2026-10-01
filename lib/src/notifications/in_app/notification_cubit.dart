import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../notification_payload.dart';
import 'notification_entry.dart';
import 'notification_state.dart';

/// Persistent in-app notification inbox (drives badges + notification centre).
///
/// Scopes: multi-account apps should keep a separate inbox per account.
/// Pass [scope] (e.g. the active account ID) or call [switchScope] when the
/// user switches accounts — entries are stored under a scope-specific key.
/// A null scope uses the 3.x storage key, so existing data is preserved.
class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({String? scope, int maxEntries = 100})
    : _scope = scope,
      _maxEntries = maxEntries,
      super(const NotificationState());

  static const _basePrefsKey = 'notification_entries_v1';
  final int _maxEntries;
  String? _scope;

  /// Current storage scope (null = device-wide / legacy).
  String? get scope => _scope;

  String get _prefsKey =>
      _scope == null ? _basePrefsKey : '${_basePrefsKey}_$_scope';

  /// Switch the inbox to another scope (e.g. account switch) and load it.
  Future<void> switchScope(String? scope) async {
    if (scope == _scope) return;
    _scope = scope;
    await initialize();
  }

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true));
    try {
      final loaded = await _loadFromPrefs();
      emit(state.copyWith(entries: loaded, isLoading: false));
      debugPrint('📬 NotificationCubit: loaded ${loaded.length} entries');
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // ── Add ───────────────────────────────────────────────────────────────────

  /// Add from an incoming [NotificationPayload].
  Future<void> addFromPayload(NotificationPayload payload) async {
    // Deduplicate by id
    if (payload.messageId != null &&
        state.entries.any((e) => e.id == payload.messageId)) {
      return;
    }
    await _addEntry(NotificationEntry.fromPayload(payload));
  }

  /// Add a pre-built entry (e.g. from your backend fetch).
  Future<void> addEntry(NotificationEntry entry) async {
    if (state.entries.any((e) => e.id == entry.id)) return;
    await _addEntry(entry);
  }

  Future<void> _addEntry(NotificationEntry entry) async {
    var updated = [entry, ...state.entries];
    if (updated.length > _maxEntries) {
      updated = updated.sublist(0, _maxEntries);
    }
    emit(state.copyWith(entries: updated));
    await _persist(updated);
  }

  // ── Read state ────────────────────────────────────────────────────────────

  Future<void> markRead(String id) async {
    final updated = state.entries.map((e) {
      return e.id == id ? e.copyWith(isRead: true) : e;
    }).toList();
    emit(state.copyWith(entries: updated));
    await _persist(updated);
  }

  /// Mark every entry of one channel/category as read.
  Future<void> markChannelRead(String channelId) async {
    final updated = state.entries
        .map((e) => e.channelId == channelId ? e.copyWith(isRead: true) : e)
        .toList();
    emit(state.copyWith(entries: updated));
    await _persist(updated);
  }

  Future<void> markAllRead() async {
    final updated =
        state.entries.map((e) => e.copyWith(isRead: true)).toList();
    emit(state.copyWith(entries: updated));
    await _persist(updated);
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> remove(String id) async {
    final updated = state.entries.where((e) => e.id != id).toList();
    emit(state.copyWith(entries: updated));
    await _persist(updated);
  }

  Future<void> clearAll() async {
    emit(state.copyWith(entries: []));
    await _persist([]);
  }

  // ── Merge from backend ────────────────────────────────────────────────────

  /// Merges server-fetched entries with local ones.
  /// - Preserves local [isRead] state.
  /// - Deduplicates by id.
  /// - Re-sorts newest first.
  /// - Trims to [_maxEntries].
  Future<void> mergeFromServer(List<NotificationEntry> serverEntries) async {
    final localById = {for (final e in state.entries) e.id: e};

    for (final server in serverEntries) {
      final local = localById[server.id];
      // Keep local read state if we already have the entry locally
      localById[server.id] = local != null
          ? server.copyWith(isRead: local.isRead)
          : server;
    }

    var merged = localById.values.toList()
      ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));

    if (merged.length > _maxEntries) {
      merged = merged.sublist(0, _maxEntries);
    }

    emit(state.copyWith(entries: merged));
    await _persist(merged);
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> _persist(List<NotificationEntry> entries) async {
    if (isClosed) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
      await prefs.setString(_prefsKey, encoded);
    } catch (e) {
      debugPrint('❌ NotificationCubit persist error: $e');
    }
  }

  Future<List<NotificationEntry>> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => NotificationEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ NotificationCubit load error: $e');
      return [];
    }
  }
}

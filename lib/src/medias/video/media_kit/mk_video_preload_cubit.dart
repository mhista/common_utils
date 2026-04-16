// ═════════════════════════════════════════════════════════════════════════════
// FILE: mk_video_preload_cubit.dart
//
// media_kit variant of VideoPreloadCubit.
//
// KEY DIFFERENCE FROM THE video_player VERSION:
//   media_kit's [Media] constructor accepts [httpHeaders] natively, giving
//   reliable Authorization header delivery on all platforms (Android, iOS,
//   macOS, Windows, Linux, Web).
//
// AUTH — use either or both:
//   • HTTP headers  → Media(httpHeaders: {'Authorization': 'Bearer $t'})
//   • Query params  → appended to the URL before Media() is constructed
//
// SETUP — pubspec.yaml:
//   media_kit: ^1.2.6
//   media_kit_video: ^2.0.1
//   media_kit_libs_video: ^1.0.7
//   flutter_bloc: ^9.0.0
//   freezed_annotation: ^3.0.0
//
// SETUP — main():
//   MediaKit.ensureInitialized();
//
// RENDERING — use [Video] widget from media_kit_video:
//   Video(controller: state.controllers[item.id]!)
//
// HEADER / QUERY PARAM API (drop-in match with the original cubit):
//   cubit.setHeaders({'Authorization': 'Bearer $token'});
//   cubit.addHeader('X-Custom', 'value');
//   cubit.removeHeader('X-Custom');
//   cubit.clearHeaders();
//   cubit.currentHeaders
//
//   cubit.setQueryParameters({'token': bearerToken});
//   cubit.addQueryParameter('token', bearerToken);
//   cubit.removeQueryParameter('token');
//   cubit.clearQueryParameters();
//   cubit.currentQueryParameters
//
//   // Per-item overrides via MkVideoItem fields (survive list updates):
//   MkVideoItem(headers: {…}, queryParameters: {…})
//
//   // Or at runtime:
//   cubit.setItemHeaders('itemId', {…});
//   cubit.setItemQueryParameters('itemId', {…});
//   cubit.reinitItem('itemId'); // force re-open with new creds
// ═════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'mk_video_item.dart';

part 'mk_video_preload_state.dart';
part 'mk_video_preload_cubit.freezed.dart';

// ── Config ────────────────────────────────────────────────────────────────────

class MkVideoPreloadConfig {
  final int preloadAhead;
  final int keepBehind;
  final int maxConcurrentInits;
  final bool singleVideoMode;
  final bool mutedByDefault;

  const MkVideoPreloadConfig({
    this.preloadAhead = 2,
    this.keepBehind = 1,
    this.maxConcurrentInits = 3,
    this.singleVideoMode = false,
    this.mutedByDefault = false,
  });
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class MkVideoPreloadCubit<T> extends Cubit<MkVideoPreloadState<T>> {
  List<MkVideoItem<T>> _items;
  final MkVideoPreloadConfig config;

  // media_kit players & controllers (one pair per item ID)
  final Map<String, Player> _players = {};
  final Map<String, VideoController> _controllers = {};
  final Map<String, bool> _initializationStatus = {};
  final Set<String> _disposingPlayers = {};
  int _currentInitializations = 0;

  bool _globalMuted = false;
  bool _isExpanded = true;

  bool get isMuted => _globalMuted;
  bool get isExpanded => _isExpanded;

  // ── Header state ───────────────────────────────────────────────────────────
  final Map<String, String> _globalHeaders;
  final Map<String, Map<String, String>> _runtimeItemHeaders = {};

  // ── Query parameter state ──────────────────────────────────────────────────
  final Map<String, String> _globalQueryParams;
  final Map<String, Map<String, String>> _runtimeItemQueryParams = {};

  // ── Constructor ────────────────────────────────────────────────────────────

  MkVideoPreloadCubit({
    required List<MkVideoItem<T>> items,
    MkVideoPreloadConfig? config,
    Map<String, String> headers = const {},
    Map<String, String> queryParameters = const {},
  })  : _items = items,
        _globalHeaders = Map<String, String>.from(headers),
        _globalQueryParams = Map<String, String>.from(queryParameters),
        config = config ??
            MkVideoPreloadConfig(singleVideoMode: items.length == 1),
        super(const MkVideoPreloadState.initial()) {
    _globalMuted = this.config.mutedByDefault;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GLOBAL HEADER API
  // ═══════════════════════════════════════════════════════════════════════════

  void setHeaders(Map<String, String> headers) =>
      _globalHeaders..clear()..addAll(headers);

  void addHeader(String key, String value) => _globalHeaders[key] = value;
  void removeHeader(String key) => _globalHeaders.remove(key);
  void clearHeaders() => _globalHeaders.clear();

  Map<String, String> get currentHeaders =>
      Map<String, String>.unmodifiable(_globalHeaders);

  // ── Per-item header API ────────────────────────────────────────────────────

  void setItemHeaders(String itemId, Map<String, String> headers) =>
      _runtimeItemHeaders[itemId] = Map<String, String>.from(headers);

  void removeItemHeaders(String itemId) => _runtimeItemHeaders.remove(itemId);

  Map<String, String> _headersFor(String itemId) {
    final item = _items._firstOrNull((i) => i.id == itemId);
    return {
      ..._globalHeaders,
      ...(item?.headers ?? const {}),
      ...(_runtimeItemHeaders[itemId] ?? const {}),
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GLOBAL QUERY PARAMETER API
  // ═══════════════════════════════════════════════════════════════════════════

  void setQueryParameters(Map<String, String> params) =>
      _globalQueryParams..clear()..addAll(params);

  void addQueryParameter(String key, String value) =>
      _globalQueryParams[key] = value;

  void removeQueryParameter(String key) => _globalQueryParams.remove(key);
  void clearQueryParameters() => _globalQueryParams.clear();

  Map<String, String> get currentQueryParameters =>
      Map<String, String>.unmodifiable(_globalQueryParams);

  void setItemQueryParameters(String itemId, Map<String, String> params) =>
      _runtimeItemQueryParams[itemId] = Map<String, String>.from(params);

  void removeItemQueryParameters(String itemId) =>
      _runtimeItemQueryParams.remove(itemId);

  // ── URL builder ────────────────────────────────────────────────────────────

  String _buildUrl(String videoUrl, String itemId) {
    final item = _items._firstOrNull((i) => i.id == itemId);
    final itemParams = item?.queryParameters ?? const <String, String>{};
    final runtimeParams = _runtimeItemQueryParams[itemId] ?? const {};

    if (_globalQueryParams.isEmpty &&
        itemParams.isEmpty &&
        runtimeParams.isEmpty) {
      return videoUrl;
    }

    final uri = Uri.parse(videoUrl);
    final merged = {
      ...uri.queryParameters,   // existing URL params (lowest priority)
      ..._globalQueryParams,    // global
      ...itemParams,            // VideoItem-level
      ...runtimeParams,         // runtime setItemQueryParameters() (highest)
    };
    return uri.replace(queryParameters: merged).toString();
  }

  // ── reinitItem ─────────────────────────────────────────────────────────────

  /// Disposes the [Player] for [itemId] and re-initialises it from scratch.
  /// Call this after rotating credentials on an already-playing video.
  Future<void> reinitItem(String itemId) async {
    await _safeDisposePlayer(itemId);
    _initializationStatus.remove(itemId);

    final item = _items.firstWhere(
      (i) => i.id == itemId,
      orElse: () => throw StateError('MkVideoPreloadCubit: item $itemId not found'),
    );
    await _initializePlayer(itemId, item.videoUrl);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC: Initialize
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> init(int currentIndex) async {
    if (_items.isEmpty || currentIndex >= _items.length) {
      emit(const MkVideoPreloadState.initial());
      return;
    }

    final currentItem = _items[currentIndex];
    emit(MkVideoPreloadState.loading(currentIndex: currentIndex));

    await _disposeDistantPlayers(currentIndex);
    await _initializePlayer(
      currentItem.id,
      currentItem.videoUrl,
      priority: true,
    );

    if (!config.singleVideoMode) {
      _initializePlayersInParallel(currentIndex);
    }

    if (isClosed) return;

    emit(
      MkVideoPreloadState.ready(
        currentIndex: currentIndex,
        currentItemId: currentItem.id,
        players: Map.from(_players),
        controllers: Map.from(_controllers),
        items: List.from(_items),
        isPlaying: true,
        isExpanded: _isExpanded,
        isMuted: _globalMuted,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC: Update items
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> updateItems(List<MkVideoItem<T>> newItems) async {
    final newIds = newItems.map((i) => i.id).toSet();
    final toDispose =
        _players.keys.where((id) => !newIds.contains(id)).toList();

    for (final id in toDispose) {
      await _safeDisposePlayer(id);
      _runtimeItemHeaders.remove(id);
      _runtimeItemQueryParams.remove(id);
    }

    _items = newItems;

    final currentState = state;
    if (currentState is _MkReady<T> && !isClosed) {
      final newIndex =
          _items.indexWhere((i) => i.id == currentState.currentItemId);
      if (newIndex != -1) {
        emit(currentState.copyWith(
          currentIndex: newIndex,
          items: List.from(_items),
          players: Map.from(_players),
          controllers: Map.from(_controllers),
        ));
      } else if (_items.isNotEmpty) {
        await init(0);
      } else {
        emit(const MkVideoPreloadState.initial());
      }
    }
  }

  void updateItemData(String itemId, T newData) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index == -1) return;
    _items[index] = _items[index].copyWithData(newData) as MkVideoItem<T>;

    final currentState = state;
    if (currentState is _MkReady<T> && !isClosed) {
      emit(currentState.copyWith(items: List.from(_items)));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC: Playback controls
  // ═══════════════════════════════════════════════════════════════════════════

  void togglePlayPause() {
    final currentState = state;
    if (currentState is _MkReady<T>) {
      final player = _players[currentState.currentItemId];
      if (player != null) {
        if (player.state.playing) {
          player.pause();
          emit(currentState.copyWith(isPlaying: false));
        } else {
          player.play();
          emit(currentState.copyWith(isPlaying: true));
        }
      }
    }
  }

  void toggleMute() {
    _globalMuted = !_globalMuted;
    for (final player in _players.values) {
      try {
        player.setVolume(_globalMuted ? 0 : 100);
      } catch (e) {
        debugPrint('MkVideoPreloadCubit: setVolume error — $e');
      }
    }
    final currentState = state;
    if (currentState is _MkReady<T> && !isClosed) {
      emit(currentState.copyWith(isMuted: _globalMuted));
    }
  }

  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    final currentState = state;
    if (currentState is _MkReady<T> && !isClosed) {
      emit(currentState.copyWith(isExpanded: _isExpanded));
    }
  }

  void pauseCurrent(int index) {
    if (index < _items.length) {
      final player = _players[_items[index].id];
      if (player != null && player.state.playing) {
        player.pause();
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC: Controller / Player access
  // ═══════════════════════════════════════════════════════════════════════════

  /// Returns the [VideoController] for the item at [index], or null.
  VideoController? getControllerForIndex(int index) {
    if (index >= 0 && index < _items.length) {
      return _controllers[_items[index].id];
    }
    return null;
  }

  VideoController? getControllerForItemId(String itemId) =>
      _controllers[itemId];

  Player? getPlayerForIndex(int index) {
    if (index >= 0 && index < _items.length) {
      return _players[_items[index].id];
    }
    return null;
  }

  Player? getPlayerForItemId(String itemId) => _players[itemId];

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC: Preload management
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> disposeExcept(int currentIndex) async {
    if (currentIndex >= _items.length) return;
    final keepIds = <String>{_items[currentIndex].id};

    if (!config.singleVideoMode) {
      for (int i = currentIndex - config.keepBehind;
          i <= currentIndex + config.preloadAhead;
          i++) {
        if (_isValidIndex(i)) keepIds.add(_items[i].id);
      }
    }

    final toDispose =
        _players.keys.where((id) => !keepIds.contains(id)).toList();
    for (final id in toDispose) {
      await _safeDisposePlayer(id);
    }

    final currentState = state;
    if (currentState is _MkReady<T> && !isClosed) {
      emit(currentState.copyWith(
        players: Map.from(_players),
        controllers: Map.from(_controllers),
      ));
    }
  }

  void preloadNext(int currentIndex) {
    if (config.singleVideoMode) return;
    for (int i = currentIndex + config.preloadAhead + 1;
        i <= currentIndex + config.preloadAhead + 2;
        i++) {
      if (!_isValidIndex(i)) continue;
      final item = _items[i];
      if (!_players.containsKey(item.id) &&
          !_initializationStatus.containsKey(item.id) &&
          _currentInitializations < config.maxConcurrentInits) {
        _initializePlayer(item.id, item.videoUrl);
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INTERNAL: Player management
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _disposeDistantPlayers(int currentIndex) async {
    final keepIds = <String>{};
    for (int i = currentIndex - config.keepBehind;
        i <= currentIndex + config.preloadAhead;
        i++) {
      if (_isValidIndex(i)) keepIds.add(_items[i].id);
    }

    final toDispose = _players.keys
        .where((id) =>
            !keepIds.contains(id) && !_disposingPlayers.contains(id))
        .toList();
    for (final id in toDispose) {
      await _safeDisposePlayer(id);
    }
  }

  Future<void> _safeDisposePlayer(String itemId) async {
    if (_disposingPlayers.contains(itemId)) return;
    _disposingPlayers.add(itemId);

    try {
      final player = _players[itemId];
      if (player != null) {
        if (player.state.playing) await player.pause();
        await Future.delayed(const Duration(milliseconds: 50));
        await player.dispose();
        _players.remove(itemId);
        _controllers.remove(itemId);
        _initializationStatus.remove(itemId);
      }
    } catch (e) {
      debugPrint('MkVideoPreloadCubit: dispose error for $itemId — $e');
    } finally {
      _disposingPlayers.remove(itemId);
    }
  }

  void _initializePlayersInParallel(int currentIndex) {
    for (int i = currentIndex - config.keepBehind;
        i <= currentIndex + config.preloadAhead;
        i++) {
      if (i == currentIndex || !_isValidIndex(i)) continue;
      if (_currentInitializations >= config.maxConcurrentInits) break;
      final item = _items[i];
      if (!_players.containsKey(item.id) &&
          !_initializationStatus.containsKey(item.id)) {
        _initializePlayer(item.id, item.videoUrl);
      }
    }
  }

  Future<void> _initializePlayer(
    String itemId,
    String videoUrl, {
    bool priority = false,
  }) async {
    if (_players.containsKey(itemId) ||
        _initializationStatus[itemId] == true ||
        _disposingPlayers.contains(itemId)) {
      return;
    }

    if (!priority && _currentInitializations >= config.maxConcurrentInits) {
      return;
    }

    _initializationStatus[itemId] = true;
    _currentInitializations++;

    try {
      final finalUrl = _buildUrl(videoUrl, itemId);

      // One Player + one VideoController per item
      final player = Player();
      final controller = VideoController(player);

      // media_kit natively accepts httpHeaders in Media()
      final media = Media(
        finalUrl,
        httpHeaders: _headersFor(itemId),
      );

      // Open and begin buffering, but let init() control first play
      await player.open(media, play: false);

      if (isClosed || _disposingPlayers.contains(itemId)) {
        await player.dispose();
        return;
      }

      await player.setVolume(_globalMuted ? 0 : 100);
      await player.setPlaylistMode(PlaylistMode.loop);

      _players[itemId] = player;
      _controllers[itemId] = controller;

      final currentState = state;
      if (currentState is _MkReady<T> && !isClosed) {
        emit(currentState.copyWith(
          players: Map.from(_players),
          controllers: Map.from(_controllers),
        ));
      }
    } catch (e, st) {
      debugPrint('MkVideoPreloadCubit: init failed for $itemId — $e\n$st');
      _initializationStatus[itemId] = false;
    } finally {
      _currentInitializations--;
    }
  }

  bool _isValidIndex(int index) {
    return index >= 0 &&
        index < _items.length &&
        _items[index].videoUrl.isNotEmpty &&
        (Uri.tryParse(_items[index].videoUrl)?.isAbsolute ?? false);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CLEANUP
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> clear() async {
    _currentInitializations = 0;
    for (final id in List<String>.from(_players.keys)) {
      await _safeDisposePlayer(id);
    }
    _players.clear();
    _controllers.clear();
    _initializationStatus.clear();
    _disposingPlayers.clear();
    _runtimeItemHeaders.clear();
    _runtimeItemQueryParams.clear();
  }

  @protected
  List<MkVideoItem<T>> get items => _items;

  @override
  Future<void> close() async {
    await clear();
    return super.close();
  }
}

// ── Internal extension ────────────────────────────────────────────────────────

extension<T> on List<T> {
  T? _firstOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
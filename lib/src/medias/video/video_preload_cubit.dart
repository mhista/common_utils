// ─────────────────────────────────────────────────────────────────────────────
// FILE: video_preload_cubit.dart
//
// CHANGES — HTTP header support added:
//
//   Global headers (apply to every controller this cubit creates):
//     cubit.setHeaders({'Authorization': 'Bearer $token'});
//     cubit.addHeader('X-Client-ID', '123');
//     cubit.removeHeader('X-Client-ID');
//     cubit.clearHeaders();
//     cubit.currentHeaders   // read-only snapshot
//
//   Per-item headers — two ways to supply them:
//
//   1. Via VideoItem (preferred — survives list updates):
//        VideoItem(id: '…', videoUrl: '…', headers: {'X-Token': 'abc'}, data: …)
//
//   2. Via setItemHeaders() at runtime:
//        cubit.setItemHeaders('itemId', {'X-Token': 'abc'});
//        cubit.removeItemHeaders('itemId');
//
//   Merge order: global ← VideoItem.headers ← runtime item headers
//   (later entries win on key collision)
//
//   Constructor:
//     VideoPreloadCubit(items: items, headers: {'Authorization': 'Bearer $t'})
//
//   IMPORTANT: headers are applied at controller-init time only.
//   Changing headers after a controller is already initialized has no
//   effect on that controller. Call reinitItem(itemId) (new method) to
//   dispose and re-init a single controller with fresh headers.
// ─────────────────────────────────────────────────────────────────────────────
// ignore_for_file: unnecessary_cast

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_player/video_player.dart';

import 'video_item.dart';

part 'video_preload_state.dart';
part 'video_preload_cubit.freezed.dart';

// ── Config ────────────────────────────────────────────────────────────────────

class VideoPreloadConfig {
  final int preloadAhead;
  final int keepBehind;
  final int maxConcurrentInits;
  final bool singleVideoMode;
  final bool mutedByDefault;

  const VideoPreloadConfig({
    this.preloadAhead = 2,
    this.keepBehind = 1,
    this.maxConcurrentInits = 3,
    this.singleVideoMode = false,
    this.mutedByDefault = false,
  });
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class VideoPreloadCubit<T> extends Cubit<VideoPreloadState<T>> {
  List<VideoItem<T>> _items;
  final VideoPreloadConfig config;

  final Map<String, VideoPlayerController> _controllers = {};
  final Map<String, bool> _initializationStatus = {};
  final Set<String> _disposingControllers = {};
  int _currentInitializations = 0;

  bool _globalMuted = false;
  bool _isExpanded = true;

  bool get isMuted => _globalMuted;
  bool get isExpanded => _isExpanded;

  // ── Header state ───────────────────────────────────────────────────

  /// Headers applied to every controller created by this cubit.
  final Map<String, String> _globalHeaders;

  /// Runtime per-item header overrides.
  /// These are merged on top of global headers AND VideoItem.headers.
  final Map<String, Map<String, String>> _runtimeItemHeaders = {};

  // ── Constructor ────────────────────────────────────────────────────

  VideoPreloadCubit({
    required List<VideoItem<T>> items,
    VideoPreloadConfig? config,
    /// Initial global headers, e.g. {'Authorization': 'Bearer $token'}.
    Map<String, String> headers = const {},
  })  : _items = items,
        _globalHeaders = Map<String, String>.from(headers),
        config = config ??
            VideoPreloadConfig(singleVideoMode: items.length == 1),
        super(const VideoPreloadState.initial()) {
    _globalMuted = this.config.mutedByDefault;
  }

  // ── Global header API ──────────────────────────────────────────────

  /// Replaces ALL global headers. Does not restart existing controllers.
  void setHeaders(Map<String, String> headers) {
    _globalHeaders
      ..clear()
      ..addAll(headers);
  }

  /// Adds or overwrites a single global header.
  void addHeader(String key, String value) => _globalHeaders[key] = value;

  /// Removes a single global header. No-op if key is absent.
  void removeHeader(String key) => _globalHeaders.remove(key);

  /// Removes all global headers.
  void clearHeaders() => _globalHeaders.clear();

  /// Read-only snapshot of the current global headers.
  Map<String, String> get currentHeaders =>
      Map<String, String>.unmodifiable(_globalHeaders);

  // ── Per-item header API ────────────────────────────────────────────

  /// Sets runtime per-item header overrides for [itemId].
  /// These are merged on top of global and VideoItem.headers at init time.
  /// Call [reinitItem] afterwards if the controller is already running.
  void setItemHeaders(String itemId, Map<String, String> headers) {
    _runtimeItemHeaders[itemId] = Map<String, String>.from(headers);
  }

  /// Removes runtime per-item header overrides for [itemId].
  void removeItemHeaders(String itemId) => _runtimeItemHeaders.remove(itemId);

  /// Disposes the controller for [itemId] and re-initializes it from scratch.
  /// Use this after changing headers for a video that is already playing.
  Future<void> reinitItem(String itemId) async {
    await _safeDisposeController(itemId);
    _initializationStatus.remove(itemId);
    final item = _items.firstWhere(
      (i) => i.id == itemId,
      orElse: () => throw StateError('Item $itemId not found'),
    );
    await _initializeController(itemId, item.videoUrl);
  }

  /// Builds the final merged headers for [itemId]:
  ///   global headers
  ///   ← VideoItem.headers (if the VideoItem carries its own headers field)
  ///   ← runtime setItemHeaders() overrides
  Map<String, String> _headersFor(String itemId) {
    // Find the item to pull its own headers (if VideoItem exposes them)
    final item = _items.firstWhereOrNull((i) => i.id == itemId);
    final itemHeaders = item?.headers ?? const <String, String>{};
    final runtimeHeaders = _runtimeItemHeaders[itemId] ?? const {};
    return {
      ..._globalHeaders,
      ...itemHeaders,
      ...runtimeHeaders,
    };
  }

  // ── Public: Initialize ─────────────────────────────────────────────

  Future<void> init(int currentIndex) async {
    if (_items.isEmpty || currentIndex >= _items.length) {
      emit(const VideoPreloadState.initial());
      return;
    }

    final currentItem = _items[currentIndex];
    emit(VideoPreloadState.loading(currentIndex: currentIndex));

    await _disposeDistantControllers(currentIndex);
    await _initializeController(
      currentItem.id,
      currentItem.videoUrl,
      priority: true,
    );

    if (!config.singleVideoMode) {
      _initializeControllersInParallel(currentIndex);
    }

    if (isClosed) return;

    emit(
      VideoPreloadState.ready(
        currentIndex: currentIndex,
        currentItemId: currentItem.id,
        controllers: Map.from(_controllers),
        items: List.from(_items),
        isPlaying: true,
        isExpanded: _isExpanded,
        isMuted: _globalMuted,
      ),
    );
  }

  // ── Public: Update items ───────────────────────────────────────────

  Future<void> updateItems(List<VideoItem<T>> newItems) async {
    final newItemIds = newItems.map((i) => i.id).toSet();
    final toDispose =
        _controllers.keys.where((id) => !newItemIds.contains(id)).toList();

    for (final id in toDispose) {
      await _safeDisposeController(id);
      _runtimeItemHeaders.remove(id);
    }

    _items = newItems;

    final currentState = state;
    if (currentState is _Ready<T> && !isClosed) {
      final newIndex =
          _items.indexWhere((i) => i.id == currentState.currentItemId);
      if (newIndex != -1) {
        emit(currentState.copyWith(
          currentIndex: newIndex,
          items: List.from(_items),
          controllers: Map.from(_controllers),
        ));
      } else {
        if (_items.isNotEmpty) {
          await init(0);
        } else {
          emit(const VideoPreloadState.initial());
        }
      }
    }
  }

  void updateItemData(String itemId, T newData) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index == -1) return;
    _items[index] = _items[index].copyWithData(newData) as VideoItem<T>;
    final currentState = state;
    if (currentState is _Ready<T> && !isClosed) {
      emit(currentState.copyWith(items: List.from(_items)));
    }
  }

  // ── Public: Playback controls ──────────────────────────────────────

  void togglePlayPause() {
    final currentState = state;
    if (currentState is _Ready<T>) {
      final controller = _controllers[currentState.currentItemId];
      if (controller != null) {
        if (controller.value.isPlaying) {
          controller.pause();
          emit(currentState.copyWith(isPlaying: false));
        } else {
          controller.play();
          emit(currentState.copyWith(isPlaying: true));
        }
      }
    }
  }

  void toggleMute() {
    _globalMuted = !_globalMuted;
    for (final controller in _controllers.values) {
      try {
        controller.setVolume(_globalMuted ? 0 : 1);
      } catch (e) {
        debugPrint('Error setting volume: $e');
      }
    }
    final currentState = state;
    if (currentState is _Ready<T> && !isClosed) {
      emit(currentState.copyWith(isMuted: _globalMuted));
    }
  }

  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    final currentState = state;
    if (currentState is _Ready<T> && !isClosed) {
      emit(currentState.copyWith(isExpanded: _isExpanded));
    }
  }

  void pauseCurrent(int index) {
    if (index < _items.length) {
      final controller = _controllers[_items[index].id];
      if (controller != null && controller.value.isPlaying) {
        controller.pause();
      }
    }
  }

  // ── Public: Controller access ──────────────────────────────────────

  VideoPlayerController? getControllerForIndex(int index) {
    if (index >= 0 && index < _items.length) {
      return _controllers[_items[index].id];
    }
    return null;
  }

  VideoPlayerController? getControllerForItemId(String itemId) =>
      _controllers[itemId];

  // ── Public: Preload management ─────────────────────────────────────

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
        _controllers.keys.where((id) => !keepIds.contains(id)).toList();
    for (final id in toDispose) {
      await _safeDisposeController(id);
    }

    final currentState = state;
    if (currentState is _Ready<T> && !isClosed) {
      emit(currentState.copyWith(controllers: Map.from(_controllers)));
    }
  }

  void preloadNext(int currentIndex) {
    if (config.singleVideoMode) return;
    for (int i = currentIndex + config.preloadAhead + 1;
        i <= currentIndex + config.preloadAhead + 2;
        i++) {
      if (!_isValidIndex(i)) continue;
      final item = _items[i];
      if (!_controllers.containsKey(item.id) &&
          !_initializationStatus.containsKey(item.id) &&
          _currentInitializations < config.maxConcurrentInits) {
        _initializeController(item.id, item.videoUrl);
      }
    }
  }

  // ── Internal: Controller management ───────────────────────────────

  Future<void> _disposeDistantControllers(int currentIndex) async {
    final keepIds = <String>{};
    for (int i = currentIndex - config.keepBehind;
        i <= currentIndex + config.preloadAhead;
        i++) {
      if (_isValidIndex(i)) keepIds.add(_items[i].id);
    }

    final toDispose = _controllers.keys
        .where((id) =>
            !keepIds.contains(id) && !_disposingControllers.contains(id))
        .toList();
    for (final id in toDispose) {
      await _safeDisposeController(id);
    }
  }

  Future<void> _safeDisposeController(String itemId) async {
    if (_disposingControllers.contains(itemId)) return;
    _disposingControllers.add(itemId);
    try {
      final controller = _controllers[itemId];
      if (controller != null) {
        if (controller.value.isPlaying) controller.pause();
        await Future.delayed(const Duration(milliseconds: 50));
        await controller.dispose();
        _controllers.remove(itemId);
        _initializationStatus.remove(itemId);
      }
    } catch (e) {
      debugPrint('Error disposing controller for $itemId: $e');
    } finally {
      _disposingControllers.remove(itemId);
    }
  }

  void _initializeControllersInParallel(int currentIndex) {
    for (int i = currentIndex - config.keepBehind;
        i <= currentIndex + config.preloadAhead;
        i++) {
      if (i == currentIndex || !_isValidIndex(i)) continue;
      if (_currentInitializations >= config.maxConcurrentInits) break;
      final item = _items[i];
      if (!_controllers.containsKey(item.id) &&
          !_initializationStatus.containsKey(item.id)) {
        _initializeController(item.id, item.videoUrl);
      }
    }
  }

  Future<void> _initializeController(
    String itemId,
    String videoUrl, {
    bool priority = false,
  }) async {
    if (_controllers.containsKey(itemId) ||
        _initializationStatus[itemId] == true ||
        _disposingControllers.contains(itemId)) return;

    if (!priority && _currentInitializations >= config.maxConcurrentInits) {
      return;
    }

    _initializationStatus[itemId] = true;
    _currentInitializations++;

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        // ── Merged headers for this item ──────────────────────────
        httpHeaders: _headersFor(itemId),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      await controller.initialize();

      if (isClosed || _disposingControllers.contains(itemId)) {
        await controller.dispose();
        return;
      }

      controller.setLooping(true);
      controller.setVolume(_globalMuted ? 0 : 1);
      _controllers[itemId] = controller;

      final currentState = state;
      if (currentState is _Ready<T> && !isClosed) {
        emit(currentState.copyWith(controllers: Map.from(_controllers)));
      }
    } catch (e) {
      debugPrint('Failed to init video for $itemId: $e');
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

  // ── Cleanup ────────────────────────────────────────────────────────

  Future<void> clear() async {
    _currentInitializations = 0;
    for (final id in List<String>.from(_controllers.keys)) {
      await _safeDisposeController(id);
    }
    _controllers.clear();
    _initializationStatus.clear();
    _disposingControllers.clear();
    _runtimeItemHeaders.clear();
  }

  @protected
  List<VideoItem<T>> get items => _items;

  @override
  Future<void> close() async {
    await clear();
    return super.close();
  }
}

// ── Extension helper used internally ─────────────────────────────────

extension _FirstWhereOrNull<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
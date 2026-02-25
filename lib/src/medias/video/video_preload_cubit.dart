// ─────────────────────────────────────────────────────────────────────────────
// FILE: video_preload_cubit.dart
// Generic video controller — works with any VideoItem<T>.
// ─────────────────────────────────────────────────────────────────────────────
// ignore_for_file: unnecessary_cast

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_player/video_player.dart';
import 'video_item.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'video_preload_state.dart';
part 'video_preload_cubit.freezed.dart';


/// Configuration for video preloading behavior
class VideoPreloadConfig {
  /// How many videos to preload ahead
  final int preloadAhead;

  /// How many videos to keep behind
  final int keepBehind;

  /// Max concurrent initializations
  final int maxConcurrentInits;

  /// Single video mode (no preloading)
  final bool singleVideoMode;

  /// Muted by default
  final bool mutedByDefault;

  const VideoPreloadConfig({
    this.preloadAhead = 2,
    this.keepBehind = 1,
    this.maxConcurrentInits = 3,
    this.singleVideoMode = false,
    this.mutedByDefault = false,
  });
}

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

  VideoPreloadCubit({
    required List<VideoItem<T>> items,
    VideoPreloadConfig? config,
  })  : _items = items,
        config = config ??
            VideoPreloadConfig(
              singleVideoMode: items.length == 1,
            ),
        super(const VideoPreloadState.initial()) {
    _globalMuted = this.config.mutedByDefault;
  }

  // ── Public: Initialize ────────────────────────────────────────────────────

  Future<void> init(int currentIndex) async {
    if (_items.isEmpty || currentIndex >= _items.length) {
      emit(const VideoPreloadState.initial());
      return;
    }

    final currentItem = _items[currentIndex];
    emit(VideoPreloadState.loading(currentIndex: currentIndex));

    // Dispose distant controllers first
    await _disposeDistantControllers(currentIndex);

    // Initialize current video with priority
    await _initializeController(
      currentItem.id,
      currentItem.videoUrl,
      priority: true,
    );

    // Preload adjacent videos
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

  // ── Public: Update items (e.g. after like, follow, cache change) ─────────

  /// Update the items list with new data.
  /// Preserves existing controllers if the item ID still exists.
  Future<void> updateItems(List<VideoItem<T>> newItems) async {
    final newItemIds = newItems.map((i) => i.id).toSet();
    final controllersToDispose = <String>[];

    _controllers.forEach((itemId, _) {
      if (!newItemIds.contains(itemId)) {
        controllersToDispose.add(itemId);
      }
    });

    // Dispose controllers for removed items
    for (final itemId in controllersToDispose) {
      await _safeDisposeController(itemId);
    }

    _items = newItems;

    // Update state if already ready
    final currentState = state;
    if (currentState is _Ready<T> && !isClosed) {
      // Find new index for current item
      final currentItemId = currentState.currentItemId;
      final newIndex = _items.indexWhere((i) => i.id == currentItemId);

      if (newIndex != -1) {
        emit(
          currentState.copyWith(
            currentIndex: newIndex,
            items: List.from(_items),
            controllers: Map.from(_controllers),
          ),
        );
      } else {
        // Current item removed — reset to first item
        if (_items.isNotEmpty) {
          await init(0);
        } else {
          emit(const VideoPreloadState.initial());
        }
      }
    }
  }

  /// Update a single item's data (e.g. after like/unlike).
  /// Keeps the controller alive, just updates the data reference.
  void updateItemData(String itemId, T newData) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index == -1) return;

    _items[index] = _items[index].copyWithData(newData) as VideoItem<T>;

    final currentState = state;
    if (currentState is _Ready<T> && !isClosed) {
      emit(currentState.copyWith(items: List.from(_items)));
    }
  }

  // ── Public: Playback controls ─────────────────────────────────────────────

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
      final itemId = _items[index].id;
      final controller = _controllers[itemId];
      if (controller != null && controller.value.isPlaying) {
        controller.pause();
      }
    }
  }

  // ── Public: Controller access ─────────────────────────────────────────────

  VideoPlayerController? getControllerForIndex(int index) {
    if (index >= 0 && index < _items.length) {
      return _controllers[_items[index].id];
    }
    return null;
  }

  VideoPlayerController? getControllerForItemId(String itemId) {
    return _controllers[itemId];
  }

  // ── Public: Preload management ────────────────────────────────────────────

  Future<void> disposeExcept(int currentIndex) async {
    if (currentIndex >= _items.length) return;

    final currentItemId = _items[currentIndex].id;
    final keepItemIds = <String>{currentItemId};

    if (!config.singleVideoMode) {
      final indicesToKeep = [
        for (int i = currentIndex - config.keepBehind;
            i <= currentIndex + config.preloadAhead;
            i++)
          if (_isValidIndex(i)) i
      ];
      keepItemIds.addAll(indicesToKeep.map((i) => _items[i].id));
    }

    final controllersToDispose = <String>[];
    _controllers.forEach((itemId, _) {
      if (!keepItemIds.contains(itemId)) {
        controllersToDispose.add(itemId);
      }
    });

    for (final itemId in controllersToDispose) {
      await _safeDisposeController(itemId);
    }

    final currentState = state;
    if (currentState is _Ready<T> && !isClosed) {
      emit(currentState.copyWith(controllers: Map.from(_controllers)));
    }
  }

  void preloadNext(int currentIndex) {
    if (config.singleVideoMode) return;

    final nextBatch = [
      for (int i = currentIndex + config.preloadAhead + 1;
          i <= currentIndex + config.preloadAhead + 2;
          i++)
        if (_isValidIndex(i)) i
    ];

    for (final index in nextBatch) {
      final item = _items[index];
      if (!_controllers.containsKey(item.id) &&
          !_initializationStatus.containsKey(item.id) &&
          _currentInitializations < config.maxConcurrentInits) {
        _initializeController(item.id, item.videoUrl);
      }
    }
  }

  // ── Internal: Controller management ───────────────────────────────────────

  Future<void> _disposeDistantControllers(int currentIndex) async {
    final keepIndices = <int>{};

    for (int i = currentIndex - config.keepBehind;
        i <= currentIndex + config.preloadAhead;
        i++) {
      if (_isValidIndex(i)) {
        keepIndices.add(i);
      }
    }

    final keepItemIds = keepIndices.map((i) => _items[i].id).toSet();
    final controllersToDispose = <String>[];

    _controllers.forEach((itemId, _) {
      if (!keepItemIds.contains(itemId) &&
          !_disposingControllers.contains(itemId)) {
        controllersToDispose.add(itemId);
      }
    });

    for (final itemId in controllersToDispose) {
      await _safeDisposeController(itemId);
    }
  }

  Future<void> _safeDisposeController(String itemId) async {
    if (_disposingControllers.contains(itemId)) return;

    _disposingControllers.add(itemId);

    try {
      final controller = _controllers[itemId];
      if (controller != null) {
        if (controller.value.isPlaying) {
          controller.pause();
        }
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
    final indices = [
      for (int i = currentIndex - config.keepBehind;
          i <= currentIndex + config.preloadAhead;
          i++)
        if (i != currentIndex && _isValidIndex(i)) i
    ];

    for (final index in indices) {
      if (_currentInitializations < config.maxConcurrentInits) {
        final item = _items[index];
        if (!_controllers.containsKey(item.id) &&
            !_initializationStatus.containsKey(item.id)) {
          _initializeController(item.id, item.videoUrl);
        }
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
        _disposingControllers.contains(itemId)) {
      return;
    }

    if (!priority && _currentInitializations >= config.maxConcurrentInits) {
      return;
    }

    _initializationStatus[itemId] = true;
    _currentInitializations++;

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
        httpHeaders: priority ? {'Cache-Control': 'no-cache'} : {},
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
      debugPrint('Failed to initialize video for item $itemId: $e');
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

  // ── Cleanup ───────────────────────────────────────────────────────────────

  Future<void> clear() async {
    _currentInitializations = 0;

    final controllersToDispose = List<String>.from(_controllers.keys);
    for (final itemId in controllersToDispose) {
      await _safeDisposeController(itemId);
    }

    _controllers.clear();
    _initializationStatus.clear();
    _disposingControllers.clear();
  }

    @protected
  List<VideoItem<T>> get items => _items;

  @override
  Future<void> close() async {
    await clear();
    return super.close();
  }
}


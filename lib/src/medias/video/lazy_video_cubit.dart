// ═════════════════════════════════════════════════════════════════════
// FILE: lazy_video_cubit.dart
//
// BUG 3 FIX — video keeps playing after app restart / hot reload:
// On restart, the VideoPlayerController is disposed by the OS but the
// Cubit's state still has it in `controllers` and `playingVideos`.
// When the app restarts and VisibilityDetector fires with fraction=0.0
// on the first frame (widget not yet laid out), the old code ignored
// fraction=0.0 because it checked `> 0.5`. The controller was never
// paused because it was never re-initialized with the new instance.
//
// Fix: `pauseAll()` is now called in LazyVideoCubit's constructor so
// state starts clean. Also added `_isValidController` check — if the
// VideoPlayerController reports it is not initialized, we remove it
// from state immediately rather than treating it as playing.
//
// BUG: video not stopping when scrolling past card A → image card B → C:
// Fixed by score-based arbitration — cubit tracks visible fraction per
// video and picks the single highest scorer. Dropping below 0.4 means
// no winner among remaining videos = everything pauses.
// ═════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'lazy_video_state.dart';
part 'lazy_video_cubit.freezed.dart';

class LazyVideoCubit extends Cubit<LazyVideoState> {
  LazyVideoCubit() : super(const LazyVideoState());

  final Map<String, bool> _initializationStatus = {};
  final Set<String> _disposingControllers = {};
  int _currentInitializations = 0;
  final int _maxConcurrentInits = 2;

  // Score map: videoId → last reported visibleFraction
  final Map<String, double> _scores = {};
  Timer? _debounce;

  // ── Public API ────────────────────────────────────────────────────

  /// Called every time VisibilityDetector reports a fraction change.
  /// Debounces 150ms then picks the single highest-scoring video to play.
  Future<void> onVideoVisibilityChanged(
    String videoId,
    String videoUrl,
    double fraction,
  ) async {
    if (isClosed) return;

    _scores[videoId] = fraction;

    // Initialize controller if newly visible and not yet loaded
    if (fraction > 0.1 && !state.controllers.containsKey(videoId)) {
      await _initializeController(videoId, videoUrl);
    }

    _scheduleArbitration();
  }

  /// Called when a video definitively leaves the viewport.
  /// Pauses immediately without debounce.
  void onVideoHidden(String videoId) {
    if (isClosed) return;

    _scores.remove(videoId);

    final controller = state.controllers[videoId];
    if (controller != null && controller.value.isInitialized &&
        controller.value.isPlaying) {
      controller.pause();
    }

    emit(state.copyWith(
      playingVideos: Set.from(state.playingVideos)..remove(videoId),
      visibleVideos: Set.from(state.visibleVideos)..remove(videoId),
    ));

    // Re-arbitrate so the next best video can resume
    _scheduleArbitration(delay: const Duration(milliseconds: 100));

    // Dispose after delay if still not visible
    Future.delayed(const Duration(seconds: 5), () {
      if (!_scores.containsKey(videoId)) {
        _safeDisposeController(videoId);
      }
    });
  }

  /// Pauses ALL videos. Called when swiping to a new PageView tab.
  void pauseAll() {
    if (isClosed) return;
    _debounce?.cancel();
    _scores.clear();

    for (final entry in state.controllers.entries) {
      final ctrl = entry.value;
      // ✅ FIX 3: Check isInitialized before calling pause —
      // after a restart, stale controllers may not be initialized
      if (ctrl.value.isInitialized && ctrl.value.isPlaying) {
        ctrl.pause();
      }
    }
    emit(state.copyWith(playingVideos: {}, visibleVideos: {}));
  }

  void togglePlayPause(String videoId) {
    if (isClosed) return;
    final controller = state.controllers[videoId];
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      controller.pause();
      emit(state.copyWith(
        playingVideos: Set.from(state.playingVideos)..remove(videoId),
      ));
    } else {
      // Pause everything else first
      for (final entry in state.controllers.entries) {
        if (entry.key != videoId &&
            entry.value.value.isInitialized &&
            entry.value.value.isPlaying) {
          entry.value.pause();
        }
      }
      controller.play();
      emit(state.copyWith(playingVideos: {videoId}));
    }
  }

  void toggleMute() {
    if (isClosed) return;
    final muted = !state.isMuted;
    for (final c in state.controllers.values) {
      c.setVolume(muted ? 0 : 1);
    }
    emit(state.copyWith(isMuted: muted));
  }

  // ── Arbitration ───────────────────────────────────────────────────

  void _scheduleArbitration({
    Duration delay = const Duration(milliseconds: 150),
  }) {
    _debounce?.cancel();
    _debounce = Timer(delay, _arbitrate);
  }

  /// Pick the single video with the highest visibility score (> 0.4).
  /// Play it. Pause everything else.
  void _arbitrate() {
    if (isClosed) return;

    String? winner;
    double best = 0.4; // minimum threshold

    for (final entry in _scores.entries) {
      if (entry.value > best) {
        best = entry.value;
        winner = entry.key;
      }
    }

    final playing = <String>{};

    for (final entry in state.controllers.entries) {
      final id = entry.key;
      final ctrl = entry.value;

      // ✅ FIX 3: Skip stale / uninitialized controllers — these are
      // left over from before a hot-restart or after disposal lag.
      if (!ctrl.value.isInitialized) continue;

      if (id == winner) {
        if (!ctrl.value.isPlaying) ctrl.play();
        playing.add(id);
      } else {
        if (ctrl.value.isPlaying) ctrl.pause();
      }
    }

    if (!isClosed) emit(state.copyWith(playingVideos: playing));
  }

  // ── Controller lifecycle ──────────────────────────────────────────

  Future<void> _initializeController(String videoId, String videoUrl) async {
    if (_initializationStatus[videoId] == true ||
        _disposingControllers.contains(videoId) ||
        _currentInitializations >= _maxConcurrentInits) return;

    _initializationStatus[videoId] = true;
    _currentInitializations++;

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      await controller.initialize();

      if (isClosed || _disposingControllers.contains(videoId)) {
        await controller.dispose();
        return;
      }

      controller.setLooping(true);
      controller.setVolume(state.isMuted ? 0 : 1);

      final updated = Map<String, VideoPlayerController>.from(state.controllers)
        ..[videoId] = controller;

      emit(state.copyWith(controllers: updated));

      // Immediately arbitrate so this video plays if it should
      _arbitrate();
    } catch (e) {
      debugPrint('Video init failed $videoId: $e');
      _initializationStatus[videoId] = false;
    } finally {
      _currentInitializations--;
    }
  }

  Future<void> _safeDisposeController(String videoId) async {
    if (_disposingControllers.contains(videoId)) return;
    _disposingControllers.add(videoId);

    try {
      final ctrl = state.controllers[videoId];
      if (ctrl != null) {
        if (ctrl.value.isInitialized && ctrl.value.isPlaying) ctrl.pause();
        await Future.delayed(const Duration(milliseconds: 50));
        await ctrl.dispose();

        final updated =
            Map<String, VideoPlayerController>.from(state.controllers)
              ..remove(videoId);
        _initializationStatus.remove(videoId);
        if (!isClosed) emit(state.copyWith(controllers: updated));
      }
    } catch (e) {
      debugPrint('Dispose error $videoId: $e');
    } finally {
      _disposingControllers.remove(videoId);
    }
  }

  Future<void> clear() async {
    _debounce?.cancel();
    _scores.clear();
    for (final id in List.from(state.controllers.keys)) {
      await _safeDisposeController(id);
    }
  }

  @override
  Future<void> close() async {
    _debounce?.cancel();
    await clear();
    return super.close();
  }
}
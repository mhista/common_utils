// ═════════════════════════════════════════════════════════════════════
// FILE: lazy_video_cubit.dart
//
// CHANGES — HTTP header support added:
//
//   Global headers (apply to every video in this cubit instance):
//     cubit.setHeaders({'Authorization': 'Bearer $token'});
//     cubit.addHeader('X-Client-ID', '123');
//     cubit.removeHeader('X-Client-ID');
//     cubit.clearHeaders();
//     cubit.currentHeaders   // read-only snapshot
//
//   Per-video headers (merged on top of global at init time):
//     cubit.onVideoVisibilityChanged(
//       videoId, videoUrl, fraction,
//       headers: {'X-Video-Token': 'abc'},
//     );
//
//   Merge order: global headers ← per-video headers
//   (per-video values win on key collision)
//
//   Constructor also accepts initial headers:
//     LazyVideoCubit(headers: {'Authorization': 'Bearer $token'})
//
//   IMPORTANT: headers only affect controllers initialized AFTER they
//   are set. Already-playing controllers are not restarted. If you
//   need to rotate a token mid-session, call setHeaders() then
//   manually call onVideoHidden() + onVideoVisibilityChanged() on
//   any currently loaded videos to force re-init.
// ═════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'lazy_video_state.dart';
part 'lazy_video_cubit.freezed.dart';

class LazyVideoCubit extends Cubit<LazyVideoState> {
  /// Optional initial headers — e.g. {'Authorization': 'Bearer $token'}.
  LazyVideoCubit({Map<String, String> headers = const {}})
      : _globalHeaders = Map<String, String>.from(headers),
        super(const LazyVideoState());

  // ── Header state ──────────────────────────────────────────────────

  /// Headers sent with every VideoPlayerController.networkUrl call.
  /// Keyed by header name (case-sensitive).
  final Map<String, String> _globalHeaders;

  /// Per-video header overrides stored at onVideoVisibilityChanged time.
  /// These are merged on top of [_globalHeaders] when the controller inits.
  final Map<String, Map<String, String>> _perVideoHeaders = {};

  // ── Header API ────────────────────────────────────────────────────

  /// Replaces ALL global headers.
  /// Does not affect already-initialized controllers.
  void setHeaders(Map<String, String> headers) {
    _globalHeaders
      ..clear()
      ..addAll(headers);
  }

  /// Adds or overwrites a single global header.
  void addHeader(String key, String value) => _globalHeaders[key] = value;

  /// Removes a single global header by key. No-op if key is absent.
  void removeHeader(String key) => _globalHeaders.remove(key);

  /// Removes all global headers.
  void clearHeaders() => _globalHeaders.clear();

  /// Read-only snapshot of the current global headers.
  Map<String, String> get currentHeaders =>
      Map<String, String>.unmodifiable(_globalHeaders);

  /// Builds the final header map for [videoId] by merging global headers
  /// with any per-video overrides (per-video wins on collision).
  Map<String, String> _headersFor(String videoId) {
    final perVideo = _perVideoHeaders[videoId];
    if (perVideo == null || perVideo.isEmpty) return Map.from(_globalHeaders);
    return {..._globalHeaders, ...perVideo};
  }

  // ── Internal state ────────────────────────────────────────────────

  final Map<String, bool> _initializationStatus = {};
  final Set<String> _disposingControllers = {};
  int _currentInitializations = 0;
  final int _maxConcurrentInits = 2;

  final Map<String, double> _scores = {};
  Timer? _debounce;

  // ── Public API ────────────────────────────────────────────────────

  /// Called every time VisibilityDetector reports a fraction change.
  ///
  /// [headers] — optional per-video headers merged on top of global ones.
  /// Supply this on the first call (when fraction > 0.1) to attach token
  /// scoped to this video, e.g. a signed CDN URL header.
  Future<void> onVideoVisibilityChanged(
    String videoId,
    String videoUrl,
    double fraction, {
    Map<String, String>? headers,
  }) async {
    if (isClosed) return;

    _scores[videoId] = fraction;

    // Store per-video header overrides if supplied
    if (headers != null && headers.isNotEmpty) {
      _perVideoHeaders[videoId] = headers;
    }

    if (fraction > 0.1 && !state.controllers.containsKey(videoId)) {
      await _initializeController(videoId, videoUrl);
    }

    _scheduleArbitration();
  }

  /// Called when a video definitively leaves the viewport.
  void onVideoHidden(String videoId) {
    if (isClosed) return;

    _scores.remove(videoId);

    final controller = state.controllers[videoId];
    if (controller != null &&
        controller.value.isInitialized &&
        controller.value.isPlaying) {
      controller.pause();
    }

    emit(state.copyWith(
      playingVideos: Set.from(state.playingVideos)..remove(videoId),
      visibleVideos: Set.from(state.visibleVideos)..remove(videoId),
    ));

    _scheduleArbitration(delay: const Duration(milliseconds: 100));

    Future.delayed(const Duration(seconds: 5), () {
      if (!_scores.containsKey(videoId)) {
        _safeDisposeController(videoId);
        _perVideoHeaders.remove(videoId);
      }
    });
  }

  /// Pauses ALL videos. Call when swiping to a different PageView tab.
  void pauseAll() {
    if (isClosed) return;
    _debounce?.cancel();
    _scores.clear();

    for (final ctrl in state.controllers.values) {
      if (ctrl.value.isInitialized && ctrl.value.isPlaying) ctrl.pause();
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

  void _arbitrate() {
    if (isClosed) return;

    String? winner;
    double best = 0.4;

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
        // ── Merged headers: global + per-video ────────────────────
        httpHeaders: _headersFor(videoId),
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

      final updated =
          Map<String, VideoPlayerController>.from(state.controllers)
            ..[videoId] = controller;
      emit(state.copyWith(controllers: updated));

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
    _perVideoHeaders.clear();
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
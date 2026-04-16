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
// ═════════════════════════════════════════════════════════════════════
// FILE: lazy_video_cubit.dart
//
// CHANGES — Query parameter support added (alongside existing headers):
//
//   Global query params (appended to every video URL):
//     cubit.setQueryParameters({'token': bearerToken});
//     cubit.addQueryParameter('token', bearerToken);
//     cubit.removeQueryParameter('token');
//     cubit.clearQueryParameters();
//     cubit.currentQueryParameters   // read-only snapshot
//
//   Per-video query params (merged on top of global at init time):
//     cubit.setVideoQueryParameters(videoId, {'token': 'abc'});
//
//   Constructor — initial query params:
//     LazyVideoCubit(
//       headers: {'Authorization': 'Bearer $token'},
//       queryParameters: {'token': bearerToken}, // opt-in
//     )
//
//   HOW IT WORKS:
//   When building a VideoPlayerController URL, query params from
//   [_globalQueryParams] and [_perVideoQueryParams] are merged with any
//   existing query params already in the URL string. The result is
//   passed to VideoPlayerController.networkUrl(). Headers are still
//   applied in parallel — use whichever your backend supports.
//
//   MERGE ORDER for both headers and query params:
//     global ← per-video  (per-video values win on key collision)
//
//   IMPORTANT: Changing params after a controller is already initialized
//   has no effect. Call onVideoHidden() then onVideoVisibilityChanged()
//   on the video to force re-init with new params.
// ═════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'lazy_video_state.dart';
part 'lazy_video_cubit.freezed.dart';

class LazyVideoCubit extends Cubit<LazyVideoState> {
  LazyVideoCubit({
    Map<String, String> headers = const {},
    /// Optional: token or other values appended to every video URL as
    /// query parameters. Leave empty to disable (default behaviour).
    Map<String, String> queryParameters = const {},
  })  : _globalHeaders = Map<String, String>.from(headers),
        _globalQueryParams = Map<String, String>.from(queryParameters),
        super(const LazyVideoState());

  // ── Header state ──────────────────────────────────────────────────
  final Map<String, String> _globalHeaders;
  final Map<String, Map<String, String>> _perVideoHeaders = {};

  // ── Query parameter state ─────────────────────────────────────────
  final Map<String, String> _globalQueryParams;
  final Map<String, Map<String, String>> _perVideoQueryParams = {};

  // ── Internal ──────────────────────────────────────────────────────
  final Map<String, bool> _initializationStatus = {};
  final Set<String> _disposingControllers = {};
  int _currentInitializations = 0;
  final int _maxConcurrentInits = 2;

  final Map<String, double> _scores = {};
  Timer? _debounce;

  // ═══════════════════════════════════════════════════════════════════
  // HEADER API (unchanged)
  // ═══════════════════════════════════════════════════════════════════

  void setHeaders(Map<String, String> headers) {
    _globalHeaders
      ..clear()
      ..addAll(headers);
  }

  void addHeader(String key, String value) => _globalHeaders[key] = value;
  void removeHeader(String key) => _globalHeaders.remove(key);
  void clearHeaders() => _globalHeaders.clear();
  Map<String, String> get currentHeaders =>
      Map<String, String>.unmodifiable(_globalHeaders);

  // ── Per-video headers ─────────────────────────────────────────────
  void setVideoHeaders(String videoId, Map<String, String> headers) {
    _perVideoHeaders[videoId] = Map<String, String>.from(headers);
  }

  Map<String, String> _headersFor(String videoId) {
    final perVideo = _perVideoHeaders[videoId];
    if (perVideo == null || perVideo.isEmpty) return Map.from(_globalHeaders);
    return {..._globalHeaders, ...perVideo};
  }

  // ═══════════════════════════════════════════════════════════════════
  // QUERY PARAMETER API  (new — opt-in)
  // ═══════════════════════════════════════════════════════════════════

  /// Replaces ALL global query parameters.
  /// Does not affect already-initialized controllers.
  void setQueryParameters(Map<String, String> params) {
    _globalQueryParams
      ..clear()
      ..addAll(params);
  }

  /// Adds or overwrites a single global query parameter.
  void addQueryParameter(String key, String value) =>
      _globalQueryParams[key] = value;

  /// Removes a single global query parameter. No-op if absent.
  void removeQueryParameter(String key) => _globalQueryParams.remove(key);

  /// Removes all global query parameters.
  void clearQueryParameters() => _globalQueryParams.clear();

  /// Read-only snapshot of the current global query parameters.
  Map<String, String> get currentQueryParameters =>
      Map<String, String>.unmodifiable(_globalQueryParams);

  /// Sets per-video query parameters for [videoId].
  /// These are merged on top of global params at controller init time.
  void setVideoQueryParameters(String videoId, Map<String, String> params) {
    _perVideoQueryParams[videoId] = Map<String, String>.from(params);
  }

  /// Removes per-video query parameters for [videoId].
  void removeVideoQueryParameters(String videoId) =>
      _perVideoQueryParams.remove(videoId);

  // ── URL builder ───────────────────────────────────────────────────
  //
  // Merges global + per-video query params into the final URL.
  // If no params are set, the original URL is returned unchanged.
  // Existing query params already in the URL string are preserved and
  // take the lowest priority (they can be overridden by global/per-video).
  String _buildUrl(String videoUrl, String videoId) {
    final perVideo = _perVideoQueryParams[videoId] ?? const {};

    if (_globalQueryParams.isEmpty && perVideo.isEmpty) return videoUrl;

    final uri = Uri.parse(videoUrl);
    final merged = {
      ...uri.queryParameters,   // existing params in URL (lowest priority)
      ..._globalQueryParams,    // global overrides
      ...perVideo,              // per-video wins on collision
    };
    return uri.replace(queryParameters: merged).toString();
  }

  // ═══════════════════════════════════════════════════════════════════
  // PUBLIC API
  // ═══════════════════════════════════════════════════════════════════

  /// Called every time VisibilityDetector reports a fraction change.
  ///
  /// [headers] — legacy per-video header overrides (still supported).
  Future<void> onVideoVisibilityChanged(
    String videoId,
    String videoUrl,
    double fraction, {
    Map<String, String>? headers,
    /// Per-video query params supplied at visibility time (optional).
    Map<String, String>? queryParameters,
  }) async {
    if (isClosed) return;

    _scores[videoId] = fraction;

    if (headers != null && headers.isNotEmpty) {
      _perVideoHeaders[videoId] = headers;
    }
    if (queryParameters != null && queryParameters.isNotEmpty) {
      _perVideoQueryParams[videoId] = queryParameters;
    }

    if (fraction > 0.1 && !state.controllers.containsKey(videoId)) {
      await _initializeController(videoId, videoUrl);
    }

    _scheduleArbitration();
  }

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
        _perVideoQueryParams.remove(videoId);
      }
    });
  }

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

  // ═══════════════════════════════════════════════════════════════════
  // ARBITRATION
  // ═══════════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════════
  // CONTROLLER LIFECYCLE
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _initializeController(String videoId, String videoUrl) async {
    if (_initializationStatus[videoId] == true ||
        _disposingControllers.contains(videoId) ||
        _currentInitializations >= _maxConcurrentInits) return;

    _initializationStatus[videoId] = true;
    _currentInitializations++;

    try {
      // ✅ Build the final URL with any configured query parameters
      final finalUrl = _buildUrl(videoUrl, videoId);

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(finalUrl),
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
    _perVideoQueryParams.clear();
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
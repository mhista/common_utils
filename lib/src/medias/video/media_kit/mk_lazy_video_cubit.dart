// ═════════════════════════════════════════════════════════════════════════════
// FILE: mk_lazy_video_cubit.dart
//
// media_kit variant of LazyVideoCubit.
//
// KEY DIFFERENCE FROM THE video_player VERSION:
//   media_kit's [Media] constructor accepts [httpHeaders] natively and passes
//   them all the way down to libmpv / the platform player. This means
//   Authorization headers work reliably on Android, iOS, macOS, Windows,
//   Linux and Web — without any workaround.
//
// AUTH OPTIONS (both work, use whichever your CDN supports):
//   • HTTP headers  → passed in Media(httpHeaders: …)
//   • Query params  → appended to the URL string before opening
//
// SETUP — add to pubspec.yaml:
//   media_kit: ^1.2.6
//   media_kit_video: ^2.0.1
//   media_kit_libs_video: ^1.0.7
//   flutter_bloc: ^9.0.0
//   freezed_annotation: ^3.0.0
//   visibility_detector: ^0.4.0   # for onVideoVisibilityChanged callers
//
// SETUP — call once in main() before runApp():
//   MediaKit.ensureInitialized();
//
// RENDERING — use the [Video] widget from media_kit_video:
//   Video(controller: state.controllers[videoId]!)
//
// HEADER / QUERY PARAM API (identical to original):
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
//   // Per-video overrides (merged on top of global at init time):
//   cubit.onVideoVisibilityChanged(id, url, fraction,
//     headers: {'X-Video-Token': 'abc'},
//     queryParameters: {'vt': 'abc'},
//   );
//
// IMPORTANT:
//   Headers/params only affect players initialised AFTER they are set.
//   To rotate a token on a live player call onVideoHidden() then
//   onVideoVisibilityChanged() to force re-init.
// ═════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

part 'mk_lazy_video_state.dart';
part 'mk_lazy_video_cubit.freezed.dart';

class MkLazyVideoCubit extends Cubit<MkLazyVideoState> {
  MkLazyVideoCubit({
    Map<String, String> headers = const {},
    Map<String, String> queryParameters = const {},
  })  : _globalHeaders = Map<String, String>.from(headers),
        _globalQueryParams = Map<String, String>.from(queryParameters),
        super(const MkLazyVideoState());

  // ── Header state ───────────────────────────────────────────────────────────
  final Map<String, String> _globalHeaders;
  final Map<String, Map<String, String>> _perVideoHeaders = {};

  // ── Query parameter state ──────────────────────────────────────────────────
  final Map<String, String> _globalQueryParams;
  final Map<String, Map<String, String>> _perVideoQueryParams = {};

  // ── Lifecycle guards ───────────────────────────────────────────────────────
  final Map<String, bool> _initializationStatus = {};
  final Set<String> _disposingPlayers = {};
  int _currentInitializations = 0;
  final int _maxConcurrentInits = 2;

  // ── Visibility / arbitration ───────────────────────────────────────────────
  final Map<String, double> _scores = {};
  Timer? _debounce;

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

  // ── Per-video header helpers ───────────────────────────────────────────────

  void setVideoHeaders(String videoId, Map<String, String> headers) =>
      _perVideoHeaders[videoId] = Map<String, String>.from(headers);

  Map<String, String> _headersFor(String videoId) {
    final per = _perVideoHeaders[videoId];
    if (per == null || per.isEmpty) return Map.from(_globalHeaders);
    return {..._globalHeaders, ...per};
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

  void setVideoQueryParameters(String videoId, Map<String, String> params) =>
      _perVideoQueryParams[videoId] = Map<String, String>.from(params);

  void removeVideoQueryParameters(String videoId) =>
      _perVideoQueryParams.remove(videoId);

  // ── URL builder ────────────────────────────────────────────────────────────

  String _buildUrl(String videoUrl, String videoId) {
    final per = _perVideoQueryParams[videoId] ?? const <String, String>{};
    if (_globalQueryParams.isEmpty && per.isEmpty) return videoUrl;

    final uri = Uri.parse(videoUrl);
    final merged = {
      ...uri.queryParameters, // lowest priority (already in URL)
      ..._globalQueryParams,
      ...per,                 // per-video wins on collision
    };
    return uri.replace(queryParameters: merged).toString();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC API
  // ═══════════════════════════════════════════════════════════════════════════

  /// Called every time VisibilityDetector reports a fraction change.
  Future<void> onVideoVisibilityChanged(
    String videoId,
    String videoUrl,
    double fraction, {
    Map<String, String>? headers,
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

    if (fraction > 0.1 && !state.players.containsKey(videoId)) {
      await _initializePlayer(videoId, videoUrl);
    }

    _scheduleArbitration();
  }

  void onVideoHidden(String videoId) {
    if (isClosed) return;

    _scores.remove(videoId);

    final player = state.players[videoId];
    if (player != null && player.state.playing) {
      player.pause();
    }

    emit(state.copyWith(
      playingVideos: Set.from(state.playingVideos)..remove(videoId),
      visibleVideos: Set.from(state.visibleVideos)..remove(videoId),
    ));

    _scheduleArbitration(delay: const Duration(milliseconds: 100));

    Future.delayed(const Duration(seconds: 5), () {
      if (!_scores.containsKey(videoId)) {
        _safeDisposePlayer(videoId);
        _perVideoHeaders.remove(videoId);
        _perVideoQueryParams.remove(videoId);
      }
    });
  }

  void pauseAll() {
    if (isClosed) return;
    _debounce?.cancel();
    _scores.clear();

    for (final player in state.players.values) {
      if (player.state.playing) player.pause();
    }
    emit(state.copyWith(playingVideos: {}, visibleVideos: {}));
  }

  void togglePlayPause(String videoId) {
    if (isClosed) return;
    final player = state.players[videoId];
    if (player == null) return;

    if (player.state.playing) {
      player.pause();
      emit(state.copyWith(
        playingVideos: Set.from(state.playingVideos)..remove(videoId),
      ));
    } else {
      // Pause all other players first
      for (final entry in state.players.entries) {
        if (entry.key != videoId && entry.value.state.playing) {
          entry.value.pause();
        }
      }
      player.play();
      emit(state.copyWith(playingVideos: {videoId}));
    }
  }

  void toggleMute() {
    if (isClosed) return;
    final muted = !state.isMuted;
    for (final player in state.players.values) {
      player.setVolume(muted ? 0 : 100);
    }
    emit(state.copyWith(isMuted: muted));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ARBITRATION
  // ═══════════════════════════════════════════════════════════════════════════

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

    for (final entry in state.players.entries) {
      final id = entry.key;
      final player = entry.value;

      if (id == winner) {
        if (!player.state.playing) player.play();
        playing.add(id);
      } else {
        if (player.state.playing) player.pause();
      }
    }

    if (!isClosed) emit(state.copyWith(playingVideos: playing));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PLAYER LIFECYCLE
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _initializePlayer(String videoId, String videoUrl) async {
    if (_initializationStatus[videoId] == true ||
        _disposingPlayers.contains(videoId) ||
        _currentInitializations >= _maxConcurrentInits) {
      return;
    }

    _initializationStatus[videoId] = true;
    _currentInitializations++;

    try {
      final finalUrl = _buildUrl(videoUrl, videoId);

      // media_kit: create one Player per video
      final player = Player();
      final controller = VideoController(player);

      // media_kit supports HTTP headers natively via Media()
      final media = Media(
        finalUrl,
        httpHeaders: _headersFor(videoId),
      );

      // Open but don't auto-play — arbitration decides who plays
      await player.open(media, play: false);

      if (isClosed || _disposingPlayers.contains(videoId)) {
        await player.dispose();
        return;
      }

      // Apply global mute state
      await player.setVolume(state.isMuted ? 0 : 100);

      // Loop the video
      await player.setPlaylistMode(PlaylistMode.loop);

      final updatedPlayers = Map<String, Player>.from(state.players)
        ..[videoId] = player;
      final updatedControllers =
          Map<String, VideoController>.from(state.controllers)
            ..[videoId] = controller;

      emit(state.copyWith(
        players: updatedPlayers,
        controllers: updatedControllers,
      ));

      _arbitrate();
    } catch (e, st) {
      debugPrint('MkLazyVideoCubit: init failed for $videoId — $e\n$st');
      _initializationStatus[videoId] = false;
    } finally {
      _currentInitializations--;
    }
  }

  Future<void> _safeDisposePlayer(String videoId) async {
    if (_disposingPlayers.contains(videoId)) return;
    _disposingPlayers.add(videoId);

    try {
      final player = state.players[videoId];
      if (player != null) {
        if (player.state.playing) await player.pause();
        await Future.delayed(const Duration(milliseconds: 50));
        await player.dispose();

        final updatedPlayers = Map<String, Player>.from(state.players)
          ..remove(videoId);
        final updatedControllers =
            Map<String, VideoController>.from(state.controllers)
              ..remove(videoId);

        _initializationStatus.remove(videoId);

        if (!isClosed) {
          emit(state.copyWith(
            players: updatedPlayers,
            controllers: updatedControllers,
          ));
        }
      }
    } catch (e) {
      debugPrint('MkLazyVideoCubit: dispose error for $videoId — $e');
    } finally {
      _disposingPlayers.remove(videoId);
    }
  }

  Future<void> clear() async {
    _debounce?.cancel();
    _scores.clear();
    _perVideoHeaders.clear();
    _perVideoQueryParams.clear();

    for (final id in List<String>.from(state.players.keys)) {
      await _safeDisposePlayer(id);
    }
  }

  @override
  Future<void> close() async {
    _debounce?.cancel();
    await clear();
    return super.close();
  }
}
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

//  1. EMIT-BEFORE-DISPOSE  (_safeDisposePlayer)
//     Remove player + controller from Bloc state FIRST so the Video widget
//     detaches and rebuilds with null. Only THEN call player.dispose().
//
//  2. FRAME-GAP  (_safeDisposePlayer)
//     After emitting the state change, wait 150 ms (≈ 9 frames at 60 fps)
//     to let the widget tree finish rebuilding before the native teardown.
//
//  3. MID-FLIGHT GUARD  (_initializePlayer)
//     If the cubit is closed (or the player starts disposing) while
//     player.open() is still awaiting, the freshly-created Player is
//     disposed immediately instead of being leaked or used after close.
//
//  4. LATE-CALLBACK GUARD  (onVideoHidden delayed callback)
//     Added isClosed check inside the Future.delayed so a closed cubit
//     never tries to emit after super.close() has run.
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
 
  final Map<String, String> _globalHeaders;
  final Map<String, Map<String, String>> _perVideoHeaders = {};
  final Map<String, String> _globalQueryParams;
  final Map<String, Map<String, String>> _perVideoQueryParams = {};
 
  final Map<String, bool> _initializationStatus = {};
  final Set<String> _disposingPlayers = {};
  int _currentInitializations = 0;
  final int _maxConcurrentInits = 2;
 
  final Map<String, double> _scores = {};
  Timer? _debounce;
 
  // ── Header / Query API (Unchanged) ─────────────────────────────────────────
  void setHeaders(Map<String, String> h) => _globalHeaders..clear()..addAll(h);
  void addHeader(String k, String v) => _globalHeaders[k] = v;
  void removeHeader(String k) => _globalHeaders.remove(k);
  void clearHeaders() => _globalHeaders.clear();
  Map<String, String> get currentHeaders => Map.from(_globalHeaders);
 
  void setQueryParameters(Map<String, String> p) => _globalQueryParams..clear()..addAll(p);
  Map<String, String> get currentQueryParameters => Map.from(_globalQueryParams);
 
  String _buildUrl(String videoUrl, String videoId) {
    final per = _perVideoQueryParams[videoId] ?? const <String, String>{};
    if (_globalQueryParams.isEmpty && per.isEmpty) return videoUrl;
    final uri = Uri.parse(videoUrl);
    return uri.replace(queryParameters: {...uri.queryParameters, ..._globalQueryParams, ...per}).toString();
  }
 
  Map<String, String> _headersFor(String videoId) {
    final per = _perVideoHeaders[videoId];
    return per == null || per.isEmpty ? Map.from(_globalHeaders) : {..._globalHeaders, ...per};
  }
 
  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC API
  // ═══════════════════════════════════════════════════════════════════════════
 
  Future<void> onVideoVisibilityChanged(String id, String url, double fraction, {Map<String, String>? headers, Map<String, String>? queryParameters}) async {
    if (isClosed) return;
    _scores[id] = fraction;
    if (headers != null) _perVideoHeaders[id] = headers;
    if (queryParameters != null) _perVideoQueryParams[id] = queryParameters;
 
    if (fraction > 0.1 && !state.players.containsKey(id)) {
      await _initializePlayer(id, url);
    }
    _scheduleArbitration();
  }
 
  void onVideoHidden(String id) {
    if (isClosed) return;
    _scores.remove(id);
    final player = state.players[id];
    if (player != null && player.state.playing) player.pause();
 
    emit(state.copyWith(
      playingVideos: Set.from(state.playingVideos)..remove(id),
      visibleVideos: Set.from(state.visibleVideos)..remove(id),
    ));
 
    _scheduleArbitration(delay: const Duration(milliseconds: 100));
 
    Future.delayed(const Duration(seconds: 5), () {
      if (isClosed) return;
      if (!_scores.containsKey(id)) {
        _safeDisposePlayer(id);
        _perVideoHeaders.remove(id);
        _perVideoQueryParams.remove(id);
      }
    });
  }
 
  void pauseAll() {
    if (isClosed) return;
    _debounce?.cancel();
    _scores.clear();
    for (final p in state.players.values) { if (p.state.playing) p.pause(); }
    emit(state.copyWith(playingVideos: {}, visibleVideos: {}));
  }
 
  void togglePlayPause(String id) {
    if (isClosed) return;
    final p = state.players[id];
    if (p == null) return;
    if (p.state.playing) {
      p.pause();
      emit(state.copyWith(playingVideos: Set.from(state.playingVideos)..remove(id)));
    } else {
      for (final entry in state.players.entries) { if (entry.key != id && entry.value.state.playing) entry.value.pause(); }
      p.play();
      emit(state.copyWith(playingVideos: {id}));
    }
  }
 
  // ═══════════════════════════════════════════════════════════════════════════
  // PLAYER LIFECYCLE (CRITICAL SECTION)
  // ═══════════════════════════════════════════════════════════════════════════
 
  Future<void> _initializePlayer(String id, String url) async {
    if (_initializationStatus[id] == true || _disposingPlayers.contains(id) || _currentInitializations >= _maxConcurrentInits) return;
 
    _initializationStatus[id] = true;
    _currentInitializations++;
    Player? player;
 
    try {
      player = Player();
      final controller = VideoController(player);
      final media = Media(_buildUrl(url, id), httpHeaders: _headersFor(id));
 
      await player.open(media, play: false);
 
      if (isClosed || _disposingPlayers.contains(id)) {
        await player.stop();
        await player.dispose();
        return;
      }
 
      await player.setVolume(state.isMuted ? 0 : 100);
      await player.setPlaylistMode(PlaylistMode.loop);
 
      if (isClosed || _disposingPlayers.contains(id)) {
        await player.stop();
        await player.dispose();
        return;
      }
 
      emit(state.copyWith(
        players: Map<String, Player>.from(state.players)..[id] = player,
        controllers: Map<String, VideoController>.from(state.controllers)..[id] = controller,
      ));
      _arbitrate();
    } catch (e) {
      _initializationStatus[id] = false;
      if (player != null) await player.dispose();
    } finally {
      _currentInitializations--;
    }
  }
 
  Future<void> _safeDisposePlayer(String id) async {
    if (_disposingPlayers.contains(id)) return;
    _disposingPlayers.add(id);
 
    try {
      final player = state.players[id];
      if (player == null) return;
 
      // 1. Remove from state immediately so UI detaches
      if (!isClosed) {
        emit(state.copyWith(
          players: Map<String, Player>.from(state.players)..remove(id),
          controllers: Map<String, VideoController>.from(state.controllers)..remove(id),
          playingVideos: Set.from(state.playingVideos)..remove(id),
          visibleVideos: Set.from(state.visibleVideos)..remove(id),
        ));
        // 2. Wait for widget tree to rebuild (detach native textures)
        await Future.delayed(const Duration(milliseconds: 150));
      }
 
      _initializationStatus.remove(id);
 
      // 3. STOP threads and SILENCE audio before disposal
      try {
        await player.setVolume(0);
        await player.stop(); // Safer than pause() for FFI stability
      } catch (_) {}
 
      await Future.delayed(const Duration(milliseconds: 50));
 
      // 4. Final native teardown
      await player.dispose();
    } catch (_) {
    } finally {
      _disposingPlayers.remove(id);
    }
  }
 
  // ── Arbitration (Unchanged) ────────────────────────────────────────────────
  void _scheduleArbitration({Duration delay = const Duration(milliseconds: 150)}) {
    _debounce?.cancel();
    _debounce = Timer(delay, _arbitrate);
  }
 
  void _arbitrate() {
    if (isClosed) return;
    String? winner;
    double best = 0.4;
    for (final entry in _scores.entries) { if (entry.value > best) { best = entry.value; winner = entry.key; } }
    final playing = <String>{};
    for (final entry in state.players.entries) {
      if (entry.key == winner) { entry.value.play(); playing.add(entry.key); }
      else { entry.value.pause(); }
    }
    if (!isClosed) emit(state.copyWith(playingVideos: playing));
  }
 
  @override
  Future<void> close() async {
    _debounce?.cancel();
    final ids = List<String>.from(state.players.keys);
    for (final id in ids) await _safeDisposePlayer(id);
    return super.close();
  }
}

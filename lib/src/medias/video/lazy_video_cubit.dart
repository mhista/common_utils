// Viewport-aware video controller — only initializes videos that are visible.
// ─────────────────────────────────────────────────────────────────────────────

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

  // ── Viewport tracking ─────────────────────────────────────────────────────

  /// Called when a video enters the viewport
  Future<void> onVideoVisible(String videoId, String videoUrl) async {
    if (isClosed) return;

    final visibleVideos = Set<String>.from(state.visibleVideos)..add(videoId);
    emit(state.copyWith(visibleVideos: visibleVideos));

    // Initialize controller if not already
    if (!state.controllers.containsKey(videoId)) {
      await _initializeController(videoId, videoUrl);
    }

    // Auto-play if this is the only visible video
    if (visibleVideos.length == 1) {
      _playVideo(videoId);
    }
  }

  /// Called when a video leaves the viewport
  void onVideoHidden(String videoId) {
    if (isClosed) return;

    final visibleVideos = Set<String>.from(state.visibleVideos)
      ..remove(videoId);
    final playingVideos = Set<String>.from(state.playingVideos)
      ..remove(videoId);

    emit(state.copyWith(
      visibleVideos: visibleVideos,
      playingVideos: playingVideos,
    ));

    // Pause video
    final controller = state.controllers[videoId];
    if (controller != null && controller.value.isPlaying) {
      controller.pause();
    }

    // Dispose after a delay (in case user scrolls back quickly)
    Future.delayed(const Duration(seconds: 5), () {
      if (!state.visibleVideos.contains(videoId)) {
        _safeDisposeController(videoId);
      }
    });
  }

  // ── Playback controls ─────────────────────────────────────────────────────

  void _playVideo(String videoId) {
    final controller = state.controllers[videoId];
    if (controller != null && controller.value.isInitialized) {
      controller.play();
      final playingVideos = Set<String>.from(state.playingVideos)
        ..add(videoId);
      emit(state.copyWith(playingVideos: playingVideos));
    }
  }

  void togglePlayPause(String videoId) {
    final controller = state.controllers[videoId];
    if (controller == null) return;

    if (controller.value.isPlaying) {
      controller.pause();
      final playingVideos = Set<String>.from(state.playingVideos)
        ..remove(videoId);
      emit(state.copyWith(playingVideos: playingVideos));
    } else {
      // Pause all other videos first
      for (final id in state.playingVideos) {
        if (id != videoId) {
          state.controllers[id]?.pause();
        }
      }
      controller.play();
      emit(state.copyWith(playingVideos: {videoId}));
    }
  }

  void toggleMute() {
    final newMuted = !state.isMuted;
    for (final controller in state.controllers.values) {
      controller.setVolume(newMuted ? 0 : 1);
    }
    emit(state.copyWith(isMuted: newMuted));
  }

  // ── Controller management ─────────────────────────────────────────────────

  Future<void> _initializeController(String videoId, String videoUrl) async {
    if (_initializationStatus[videoId] == true ||
        _disposingControllers.contains(videoId) ||
        _currentInitializations >= _maxConcurrentInits) {
      return;
    }

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

      final controllers = Map<String, VideoPlayerController>.from(
        state.controllers,
      )..[videoId] = controller;

      emit(state.copyWith(controllers: controllers));
    } catch (e) {
      debugPrint('Failed to initialize video $videoId: $e');
      _initializationStatus[videoId] = false;
    } finally {
      _currentInitializations--;
    }
  }

  Future<void> _safeDisposeController(String videoId) async {
    if (_disposingControllers.contains(videoId)) return;
    _disposingControllers.add(videoId);

    try {
      final controller = state.controllers[videoId];
      if (controller != null) {
        if (controller.value.isPlaying) {
          controller.pause();
        }
        await Future.delayed(const Duration(milliseconds: 50));
        await controller.dispose();

        final controllers = Map<String, VideoPlayerController>.from(
          state.controllers,
        )..remove(videoId);

        _initializationStatus.remove(videoId);
        if (!isClosed) {
          emit(state.copyWith(controllers: controllers));
        }
      }
    } catch (e) {
      debugPrint('Error disposing controller $videoId: $e');
    } finally {
      _disposingControllers.remove(videoId);
    }
  }

  // ── Cleanup ───────────────────────────────────────────────────────────────

  Future<void> clear() async {
    final controllersToDispose = List<String>.from(state.controllers.keys);
    for (final videoId in controllersToDispose) {
      await _safeDisposeController(videoId);
    }
  }

  @override
  Future<void> close() async {
    await clear();
    return super.close();
  }
}


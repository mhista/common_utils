// ─────────────────────────────────────────────────────────────────────────────
// FILE: video_manager_service.dart
// Global service for pause/resume across navigation.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:video_player/video_player.dart';

import 'video_preload_cubit.dart';

class VideoManagerService {
  static final VideoManagerService _instance = VideoManagerService._internal();
  factory VideoManagerService() => _instance;
  VideoManagerService._internal();

  final Set<VideoPlayerController> _controllers = {};
  bool _wasPausedForNavigation = false;

  void registerController(VideoPlayerController controller) {
    _controllers.add(controller);
  }

  void unregisterController(VideoPlayerController controller) {
    _controllers.remove(controller);
  }

  void pauseAll({bool forNavigation = false}) {
    for (final controller in _controllers) {
      if (controller.value.isPlaying) {
        controller.pause();
        if (forNavigation) {
          _wasPausedForNavigation = true;
        }
      }
    }
  }

  void resumeAll() {
    for (final controller in _controllers) {
      if (!controller.value.isPlaying && _wasPausedForNavigation) {
        controller.play();
      }
    }
    _wasPausedForNavigation = false;
  }

  void disposeAll() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
  }

  void setCurrentCubit(VideoPreloadCubit cubit) {
  }

  void clearCurrentCubit() {
  }
}


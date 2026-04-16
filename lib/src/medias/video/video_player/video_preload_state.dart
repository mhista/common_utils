// ─────────────────────────────────────────────────────────────────────────────
// FILE: video_preload_state.dart
// ─────────────────────────────────────────────────────────────────────────────
part of 'video_preload_cubit.dart';
@freezed
abstract class VideoPreloadState<T> with _$VideoPreloadState<T> {
  const factory VideoPreloadState.initial() = _Initial<T>;

  const factory VideoPreloadState.loading({
    required int currentIndex,
  }) = _Loading<T>;

  const factory VideoPreloadState.ready({
    required int currentIndex,
    required String currentItemId,
    required Map<String, VideoPlayerController> controllers,
    required List<VideoItem<T>> items,
    @Default(true) bool isPlaying,
    @Default(false) bool isMuted,
    @Default(true) bool isExpanded,
  }) = _Ready<T>;

  const factory VideoPreloadState.error(String message) = _Error<T>;
}

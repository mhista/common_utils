part of 'lazy_video_cubit.dart';

@freezed
abstract class LazyVideoState with _$LazyVideoState {
  const factory LazyVideoState({
    /// Map of video ID to controller
    @Default({}) Map<String, VideoPlayerController> controllers,
    
    /// Videos currently in viewport
    @Default({}) Set<String> visibleVideos,
    
    /// Videos that should be playing
    @Default({}) Set<String> playingVideos,
    
    /// Global mute state
    @Default(false) bool isMuted,
  }) = _LazyVideoState;
}

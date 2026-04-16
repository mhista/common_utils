// ─────────────────────────────────────────────────────────────────────────────
// FILE: mk_lazy_video_state.dart
// ─────────────────────────────────────────────────────────────────────────────
part of 'mk_lazy_video_cubit.dart';

@freezed
abstract class MkLazyVideoState with _$MkLazyVideoState {
  const factory MkLazyVideoState({
    /// Map of video ID → media_kit [Player] instance.
    @Default({}) Map<String, Player> players,

    /// Map of video ID → [VideoController] for rendering via [Video] widget.
    @Default({}) Map<String, VideoController> controllers,

    /// IDs of videos whose player is currently playing.
    @Default({}) Set<String> playingVideos,

    /// IDs of videos currently in the viewport (fraction > threshold).
    @Default({}) Set<String> visibleVideos,

    /// Global mute state — applied to all players.
    @Default(false) bool isMuted,
  }) = _MkLazyVideoState;
}
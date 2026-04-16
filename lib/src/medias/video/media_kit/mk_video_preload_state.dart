// ─────────────────────────────────────────────────────────────────────────────
// FILE: mk_video_preload_state.dart
// ─────────────────────────────────────────────────────────────────────────────
part of 'mk_video_preload_cubit.dart';

@freezed
abstract class MkVideoPreloadState<T> with _$MkVideoPreloadState<T> {
  const factory MkVideoPreloadState.initial() = _MkInitial<T>;

  const factory MkVideoPreloadState.loading({
    required int currentIndex,
  }) = _MkLoading<T>;

  const factory MkVideoPreloadState.ready({
    required int currentIndex,
    required String currentItemId,

    /// Active media_kit [Player] instances keyed by item ID.
    required Map<String, Player> players,

    /// [VideoController] instances for rendering — keyed by item ID.
    required Map<String, VideoController> controllers,

    required List<MkVideoItem<T>> items,

    @Default(true) bool isPlaying,
    @Default(false) bool isMuted,
    @Default(true) bool isExpanded,
  }) = _MkReady<T>;

  const factory MkVideoPreloadState.error(String message) = _MkError<T>;
}
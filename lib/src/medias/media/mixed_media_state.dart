// ─────────────────────────────────────────────────────────────────────────────
// FILE: mixed_media_state.dart
// ─────────────────────────────────────────────────────────────────────────────

part of 'mixed_media_cubit.dart';

@freezed
abstract class MixedMediaState<T> with _$MixedMediaState<T> {
  const factory MixedMediaState({
    @Default([]) List<MediaItem<T>> items,
    @Default({}) Set<int> preloadedIndices,
    @Default(false) bool isLoading,
    String? error,
  }) = _MixedMediaState<T>;
}

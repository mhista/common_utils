// Orchestrates videos, images, and documents together.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:freezed_annotation/freezed_annotation.dart';
import 'models/media_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../image/image_preload_service.dart';

part 'mixed_media_state.dart';
part 'mixed_media_cubit.freezed.dart';


class MixedMediaCubit<T> extends Cubit<MixedMediaState<T>> {
  final ImagePreloadService _imageService = ImagePreloadService();
  
  MixedMediaCubit({required List<MediaItem<T>> items})
      : super(MixedMediaState(items: items));

  /// Update items (e.g. after like/unlike, cache update)
  void updateItems(List<MediaItem<T>> newItems) {
    emit(state.copyWith(items: newItems));
  }

  /// Update a single item's data
  void updateItemData(String itemId, T newData) {
    final items = state.items.toList();
    final index = items.indexWhere((i) => i.id == itemId);
    
    if (index != -1) {
      items[index] = items[index].copyWithData(newData);
      emit(state.copyWith(items: items));
    }
  }

  /// Preload media for items in range
  Future<void> preloadRange(
    int startIndex,
    int endIndex,
    BuildContext context,
  ) async {
    final indicesToPreload = <int>[];
    for (int i = startIndex; i <= endIndex && i < state.items.length; i++) {
      if (!state.preloadedIndices.contains(i)) {
        indicesToPreload.add(i);
      }
    }

    if (indicesToPreload.isEmpty) return;

    // Collect image URLs to preload
    final imageUrls = <String>[];
    for (final index in indicesToPreload) {
      final item = state.items[index];
      for (final content in item.content) {
        if (content.isImage) {
          imageUrls.add(content.url);
        } else if (content.isVideo && content.thumbnailUrl != null) {
          imageUrls.add(content.thumbnailUrl!);
        }
      }
    }

    // Preload images
    if (imageUrls.isNotEmpty) {
      await _imageService.preloadRange(imageUrls, context);
    }

    // Mark as preloaded
    final preloaded = Set<int>.from(state.preloadedIndices)
      ..addAll(indicesToPreload);
    emit(state.copyWith(preloadedIndices: preloaded));
  }
}
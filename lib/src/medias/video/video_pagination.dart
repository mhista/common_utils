import 'package:flutter/foundation.dart';
import '../pagination_config.dart';
import 'video_preload_cubit.dart';
import 'video_item.dart';

class VideoPaginationCubit<T> extends VideoPreloadCubit<T> {
  final Future<List<VideoItem<T>>> Function(int page) fetchPage;
  final PaginationConfig paginationConfig;

  int _currentPage = 0;
  bool _isFetchingMore = false;
  bool _hasMorePages = true;

  VideoPaginationCubit({
    required List<VideoItem<T>> initialItems,
    required this.fetchPage,
    VideoPreloadConfig? videoConfig,
    PaginationConfig? paginationConfig,
  })  : paginationConfig = paginationConfig ?? const PaginationConfig(),
        super(items: initialItems, config: videoConfig) {
    _currentPage = 1; // page 0 = initialItems already loaded
  }

  /// Call this from onPageChanged in PageView.
  Future<void> onPageChanged(int index) async {
    await init(index);
    await disposeExcept(index);
    preloadNext(index);
    await _checkPagination(index);
  }

  Future<void> _checkPagination(int currentIndex) async {
    if (!_hasMorePages || _isFetchingMore) return;

    // `items` — the @protected getter on VideoPreloadCubit, not `_items`
    final itemsRemaining = items.length - currentIndex;
    if (itemsRemaining <= paginationConfig.fetchThreshold) {
      await _fetchMoreItems();
    }
  }

  Future<void> _fetchMoreItems() async {
    if (_isFetchingMore) return;
    _isFetchingMore = true;
    debugPrint('📄 Fetching page $_currentPage (threshold reached)');

    try {
      final newItems = await fetchPage(_currentPage);

      if (newItems.isEmpty) {
        _hasMorePages = false;
        debugPrint('📄 No more pages');
        return;
      }

      // Append via updateItems() — the public parent method that handles
      // both the list mutation AND the state update correctly.
      await updateItems([...items, ...newItems]);
      _currentPage++;

      debugPrint('✅ Loaded ${newItems.length} more items. Total: ${items.length}');
    } catch (e) {
      debugPrint('❌ Pagination fetch failed: $e');
      // Do NOT set _hasMorePages = false on error — allow retry next scroll.
    } finally {
      _isFetchingMore = false;
    }
  }

  /// Manual refresh (pull-to-refresh).
  Future<void> refresh() async {
    await clear();

    _currentPage = 0;
    _hasMorePages = true;
    _isFetchingMore = false;

    try {
      final firstPage = await fetchPage(0);
      _currentPage = 1;

      if (!isClosed) {
        // Replace the list entirely via updateItems, then init at 0
        await updateItems(firstPage);
        await init(0);
      }
    } catch (e) {
      debugPrint('❌ Refresh failed: $e');
      if (!isClosed) {
        emit(VideoPreloadState.error(e.toString()));
      }
    }
  }

  bool get hasMore => _hasMorePages;
  bool get isFetching => _isFetchingMore;
}
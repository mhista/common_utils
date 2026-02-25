/// Configuration for pagination behavior
class PaginationConfig {
  /// Trigger fetch when this many items from the end
  final int fetchThreshold;

  /// How many items to fetch per page
  final int pageSize;

  const PaginationConfig({this.fetchThreshold = 3, this.pageSize = 10});
}



// ─────────────────────────────────────────────────────────────────────────────
// USAGE EXAMPLE — In your FeedScreen
// ─────────────────────────────────────────────────────────────────────────────

/*

class _FeedScreenState extends State<FeedScreen> {
  late VideoPaginationCubit<PostModel> _videoCubit;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    // Convert first page to VideoItems
    final initialVideoItems =
        widget.postList.map((post) => PostVideoItem(post)).toList();

    // Create pagination cubit
    _videoCubit = VideoPaginationCubit<PostModel>(
      initialItems: initialVideoItems,
      fetchPage: _fetchPage,
      videoConfig: const VideoPreloadConfig(
        preloadAhead: 2,
        keepBehind: 1,
      ),
      paginationConfig: const PaginationConfig(
        fetchThreshold: 3,  // Fetch when 3 items from end
        pageSize: 10,
      ),
    );

    _videoCubit.init(0);
  }

  /// Fetch function — called by cubit when threshold is reached
  Future<List<VideoItem<PostModel>>> _fetchPage(int page) async {
    debugPrint('🔄 Fetching page $page');

    // Call your API
    final response = await getIt<PostRepository>().fetchPosts(
      page: page,
      limit: 10,
    );

    // Convert to VideoItems
    return response.map((post) => PostVideoItem(post)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _videoCubit.refresh(),
      child: BlocProvider.value(
        value: _videoCubit,
        child: BlocBuilder<VideoPaginationCubit<PostModel>,
            VideoPreloadState<PostModel>>(
          builder: (context, state) {
            if (state is _Ready<PostModel>) {
              return Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    itemCount: state.items.length,
                    onPageChanged: (index) {
                      // This triggers pagination check automatically
                      _videoCubit.onPageChanged(index);
                    },
                    itemBuilder: (context, index) {
                      return FeedPostListWidget(
                        item: state.items[index],
                        index: index,
                        isInView: state.currentIndex == index,
                      );
                    },
                  ),

                  // Loading indicator when fetching more
                  if (_videoCubit.isFetching)
                    const Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

*/


// ─────────────────────────────────────────────────────────────────────────────
// INTEGRATION WITH YOUR EXISTING PostsCacheCubit
// ─────────────────────────────────────────────────────────────────────────────

/*

The pagination cubit and cache cubit work together like this:

┌────────────────────────────────────────────────────────────────────┐
│ Flow: User scrolls to video 8                                      │
├────────────────────────────────────────────────────────────────────┤
│ 1. VideoPaginationCubit._checkPagination(8) detects threshold     │
│ 2. Calls fetchPage(1) → API request                               │
│ 3. API returns 10 new posts                                       │
│ 4. Cubit appends to _items and emits new state                    │
│ 5. BlocListener in FeedScreen detects state change                │
│ 6. Updates PostsCacheCubit with new posts                         │
│ 7. UI rebuilds with 20 total items                                │
└────────────────────────────────────────────────────────────────────┘

*/

// In your FeedScreen, add this listener:

/*

BlocListener<VideoPaginationCubit<PostModel>, VideoPreloadState<PostModel>>(
  listener: (context, state) {
    if (state is _Ready<PostModel>) {
      // Sync cache with paginated items
      final posts = state.items.map((item) => item.data).toList();
      GetIt.I<PostsCacheCubit>().setPosts(posts);
    }
  },
  child: // your PageView
)

*/


// ─────────────────────────────────────────────────────────────────────────────
// HANDLING EDGE CASES
// ─────────────────────────────────────────────────────────────────────────────

/*

EDGE CASE 1: User likes a post during pagination
Solution: updateItemData() keeps controller alive, pagination continues

EDGE CASE 2: API fails during pagination
Solution: Cubit doesn't set hasMorePages = false, will retry on next threshold

EDGE CASE 3: User scrolls back up after pagination
Solution: Controllers for old videos are disposed normally via disposeExcept()

EDGE CASE 4: User scrolls very fast through many videos
Solution: _isFetchingMore flag prevents duplicate requests

EDGE CASE 5: Pull-to-refresh while watching video 15
Solution: refresh() clears everything, resets to page 0, user returns to video 0

EDGE CASE 6: Network timeout during fetch
Solution: try-catch in fetchPage, error doesn't break pagination

EDGE CASE 7: Duplicate posts returned from API
Solution: Your PostsCacheCubit.setPosts() deduplicates by ID

*/


// ─────────────────────────────────────────────────────────────────────────────
// ADVANCED: Prefetching Next Page in Background
// ─────────────────────────────────────────────────────────────────────────────

/*

For even smoother UX, start fetching the next page BEFORE the user reaches it:

class VideoPaginationCubit<T> extends VideoPreloadCubit<T> {
  // ... existing code ...

  /// Aggressive prefetch mode: fetch when 50% through current page
  Future<void> _checkPaginationAggressive(int currentIndex) async {
    if (!_hasMorePages || _isFetchingMore) return;

    final currentPage = (currentIndex / paginationConfig.pageSize).floor();
    final positionInPage = currentIndex % paginationConfig.pageSize;

    // If halfway through current page, fetch next page
    if (positionInPage >= paginationConfig.pageSize / 2) {
      await _fetchMoreItems();
    }
  }
}

Usage:
PaginationConfig(
  fetchThreshold: 3,  // Conservative: 3 from end
  pageSize: 10,
)

vs.

PaginationConfig(
  fetchThreshold: 5,  // Aggressive: halfway through page
  pageSize: 10,
)

*/


// ─────────────────────────────────────────────────────────────────────────────
// MONITORING AND DEBUGGING
// ─────────────────────────────────────────────────────────────────────────────

/*

Add this to your cubit for debugging:

class VideoPaginationCubit<T> extends VideoPreloadCubit<T> {
  void logState() {
    debugPrint('''
📊 VideoPaginationCubit State:
   Total items: ${_items.length}
   Current page: $_currentPage
   Has more: $_hasMorePages
   Fetching: $_isFetchingMore
   Controllers: ${state.controllers.length}
   Visible videos: ${state is _Ready ? (state as _Ready).currentIndex : 'N/A'}
''');
  }
}

// Call from onPageChanged:
_videoCubit.onPageChanged(index);
_videoCubit.logState();

*/


// ─────────────────────────────────────────────────────────────────────────────
// PERFORMANCE OPTIMIZATION
// ─────────────────────────────────────────────────────────────────────────────

/*

OPTIMIZATION 1: Batch controller disposal
Instead of disposing immediately when threshold is passed, wait until
user settles on a video, then batch dispose all distant controllers.

OPTIMIZATION 2: Lazy thumbnail preload
Only preload thumbnails for next 5 videos, not all paginated items.

OPTIMIZATION 3: Cancel in-flight request on refresh
Store Future from fetchPage and cancel if refresh is called.

CancelToken? _cancelToken;

Future<void> _fetchMoreItems() async {
  _cancelToken = CancelToken();
  
  try {
    final newItems = await fetchPage(_currentPage, cancelToken: _cancelToken);
    // ... rest of logic
  } on DioException catch (e) {
    if (e.type == DioExceptionType.cancel) {
      debugPrint('Fetch cancelled');
      return;
    }
  }
}

Future<void> refresh() async {
  _cancelToken?.cancel();  // Cancel ongoing fetch
  // ... rest of refresh logic
}

*/


// ─────────────────────────────────────────────────────────────────────────────
// TESTING PAGINATION
// ─────────────────────────────────────────────────────────────────────────────

/*

Test scenarios:

1. Load initial page → scroll to video 8 → verify API call fired
2. Scroll to video 18 → verify second page loaded
3. Pull to refresh → verify reset to page 0
4. Like a post during pagination → verify data updates correctly
5. Scroll very fast to video 25 → verify no duplicate API calls
6. Network error on pagination → verify retry works
7. API returns empty list → verify hasMorePages = false
8. Scroll back to video 5 → verify old controllers disposed

Mock fetch function for testing:

Future<List<VideoItem<PostModel>>> _mockFetchPage(int page) async {
  await Future.delayed(const Duration(seconds: 1));
  
  if (page >= 5) return []; // Simulate end of content
  
  return List.generate(
    10,
    (i) => PostVideoItem(
      PostModel(
        id: 'post_${page}_$i',
        content: [Content(url: 'https://example.com/video_${page}_$i.mp4')],
        // ... other fields
      ),
    ),
  );
}

*/


// ─────────────────────────────────────────────────────────────────────────────
// SUMMARY: Pagination Checklist
// ─────────────────────────────────────────────────────────────────────────────

/*

✅ Extend VideoPreloadCubit → VideoPaginationCubit
✅ Pass fetchPage callback to cubit
✅ Configure PaginationConfig (threshold, pageSize)
✅ Call onPageChanged() instead of just init() in PageView
✅ Listen to state changes and sync with PostsCacheCubit
✅ Add RefreshIndicator for pull-to-refresh
✅ Show loading indicator when isFetching
✅ Handle network errors gracefully
✅ Test edge cases (fast scroll, errors, duplicates)

*/

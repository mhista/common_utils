// ─────────────────────────────────────────────────────────────────────────────
// FILE: video_item.dart
// Abstract base class — your app extends this with its own data type.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

/// Base class for any item that contains video content.
/// Your app's model (e.g. PostModel, ReelModel, StoryModel) should extend this.
///
/// Example:
/// ```dart
/// class PostVideoItem extends VideoItem {
///   final PostModel post;
///   
///   PostVideoItem(this.post)
///     : super(
///         id: post.id,
///         videoUrl: post.content.first.url,
///         thumbnailUrl: post.thumbNail.isNotEmpty ? post.thumbNail.first : null,
///       );
///   
///   @override
///   PostVideoItem copyWithData(data) => PostVideoItem(data);
/// }
/// ```
abstract class VideoItem<T> extends Equatable {
  /// Unique identifier
  final String id;

  /// Video URL (required)
  final String videoUrl;

  /// Optional thumbnail for loading state
  final String? thumbnailUrl;

  /// The actual data object (PostModel, ReelModel, etc.)
  final T data;

  const VideoItem({
    required this.id,
    required this.videoUrl,
    required this.data,
    this.thumbnailUrl,
  });

  /// Create a copy with updated data (for state changes like likes)
  VideoItem<T> copyWithData(T newData);

  @override
  List<Object?> get props => [id, videoUrl, thumbnailUrl, data];
}



// ─────────────────────────────────────────────────────────────────────────────
// USAGE EXAMPLE — In your Haulway app
// ─────────────────────────────────────────────────────────────────────────────

/*

// 1. Create your app-specific VideoItem wrapper
class PostVideoItem extends VideoItem<PostModel> {
  PostVideoItem(PostModel post)
      : super(
          id: post.id,
          videoUrl: post.content.first.url,
          thumbnailUrl:
              post.thumbNail.isNotEmpty ? post.thumbNail.first : null,
          data: post,
        );

  @override
  PostVideoItem copyWithData(PostModel newData) => PostVideoItem(newData);
}


// 2. In your FeedScreen, create the cubit
class _FeedScreenState extends State<FeedScreen> {
  late VideoPreloadCubit<PostModel> _preloadCubit;
  late List<PostVideoItem> _videoItems;

  @override
  void initState() {
    super.initState();

    // Convert PostModel list to VideoItem list
    _videoItems = widget.postList.map((post) => PostVideoItem(post)).toList();

    _preloadCubit = VideoPreloadCubit<PostModel>(
      items: _videoItems,
      config: const VideoPreloadConfig(
        preloadAhead: 2,
        keepBehind: 1,
        mutedByDefault: false,
      ),
    );

    _preloadCubit.init(0);
  }

  // Listen to cache changes
  @override
  Widget build(BuildContext context) {
    return BlocListener<PostsCacheCubit, PostsCacheState>(
      listener: (context, cacheState) async {
        // When cache updates, convert to VideoItems and update cubit
        final newVideoItems =
            cacheState.posts.map((post) => PostVideoItem(post)).toList();
        
        await _preloadCubit.updateItems(newVideoItems);
        setState(() {
          _videoItems = newVideoItems;
        });
      },
      child: BlocProvider.value(
        value: _preloadCubit,
        child: PageView.builder(
          onPageChanged: (index) {
            _preloadCubit.init(index);
            _preloadCubit.disposeExcept(index);
          },
          itemCount: _videoItems.length,
          itemBuilder: (context, index) {
            return PostVideoWidget(
              item: _videoItems[index],
              index: index,
            );
          },
        ),
      ),
    );
  }
}


// 3. Handle like/unlike without losing video state
void _handleLike(PostModel post, bool isLiked) {
  // Update cache
  GetIt.I<PostsCacheCubit>().likePost(post.id, isLiked);

  // Update cubit's item data (keeps controller alive)
  final updatedPost = post.copyWith(
    liked: isLiked,
    numOfLikes: isLiked ? post.numOfLikes + 1 : post.numOfLikes - 1,
  );
  _preloadCubit.updateItemData(post.id, updatedPost);

  // Fire API event
  context.read<PostVideoBloc>().add(LikePostEvent(id: post.id, isLike: isLiked));
}


// 4. Your video player widget
class PostVideoWidget extends StatelessWidget {
  final PostVideoItem item;
  final int index;

  const PostVideoWidget({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoPreloadCubit<PostModel>, VideoPreloadState<PostModel>>(
      builder: (context, state) {
        if (state is _Ready<PostModel>) {
          final controller = state.controllers[item.id];
          final isCurrentItem = state.currentItemId == item.id;

          if (controller != null && controller.value.isInitialized) {
            return Stack(
              children: [
                // Video player using Chewie
                Chewie(
                  controller: ChewieController(
                    videoPlayerController: controller,
                    autoPlay: isCurrentItem,
                    looping: true,
                    showControls: false,
                  ),
                ),

                // Your UI overlay (likes, comments, etc.)
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Column(
                    children: [
                      LikeButton(
                        isLiked: item.data.liked,
                        count: item.data.numOfLikes,
                        onTap: () => _handleLike(context, item.data),
                      ),
                      CommentButton(
                        count: item.data.numOfComments,
                        onTap: () => _showComments(context, item.data.id),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        }

        // Loading state — show thumbnail
        return Image.network(
          item.thumbnailUrl ?? '',
          fit: BoxFit.cover,
        );
      },
    );
  }

  void _handleLike(BuildContext context, PostModel post) {
    final cubit = context.read<VideoPreloadCubit<PostModel>>();
    final cacheCubit = GetIt.I<PostsCacheCubit>();

    final isLiked = !post.liked;

    // Update cache
    cacheCubit.likePost(post.id, isLiked);

    // Update cubit data (keeps video playing)
    final updatedPost = post.copyWith(
      liked: isLiked,
      numOfLikes: isLiked ? post.numOfLikes + 1 : post.numOfLikes - 1,
    );
    cubit.updateItemData(post.id, updatedPost);

    // Fire API
    context.read<PostVideoBloc>().add(
      LikePostEvent(id: post.id, isLike: isLiked),
    );
  }
}

*/


// ─────────────────────────────────────────────────────────────────────────────
// KEY BENEFITS OF THIS DESIGN
// ─────────────────────────────────────────────────────────────────────────────
//
// ✅ Generic: Works with any data type (PostModel, ReelModel, StoryModel, etc.)
// ✅ Composable: Apps define their own VideoItem wrapper
// ✅ State-preserving: updateItemData() keeps controllers alive during like/unlike
// ✅ Edge-case safe: Handles scroll-off during async operations
// ✅ Memory-efficient: Disposes distant controllers automatically
// ✅ Navigation-aware: Pause/resume via VideoManagerService
// ✅ Configurable: VideoPreloadConfig for tuning behavior
// ✅ No hardcoded types: Zero coupling to PostModel


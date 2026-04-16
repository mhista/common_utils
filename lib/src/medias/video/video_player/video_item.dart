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
/// class PostVideoItem extends VideoItem<PostModel> {
///   PostVideoItem(PostModel post)
///     : super(
///         id: post.id,
///         videoUrl: post.content.first.url,
///         thumbnailUrl: post.thumbNail.isNotEmpty ? post.thumbNail.first : null,
///         data: post,
///       );
///
///   @override
///   PostVideoItem copyWithData(PostModel newData) => PostVideoItem(newData);
/// }
/// ```
///
/// To pass auth via query parameter instead of (or alongside) headers:
/// ```dart
/// class DealVideoItem extends VideoItem<DealMedia> {
///   DealVideoItem(DealMedia media, String token)
///     : super(
///         id: media.id,
///         videoUrl: media.url,
///         data: media,
///         headers: {'Authorization': 'Bearer $token'},
///         queryParameters: {'token': token}, // opt-in: appended to URL
///       );
///
///   @override
///   DealVideoItem copyWithData(DealMedia newData) =>
///       DealVideoItem(newData, ''); // token handled by cubit globally
/// }
/// ```
abstract class VideoItem<T> extends Equatable {
  /// Unique identifier.
  final String id;

  /// Video URL (required).
  final String videoUrl;

  /// Optional thumbnail shown while the controller is initialising.
  final String? thumbnailUrl;

  /// The actual data object (PostModel, ReelModel, DealMedia, etc.).
  final T data;

  /// HTTP headers forwarded to [VideoPlayerController.networkUrl].
  /// Use for Bearer token auth: `{'Authorization': 'Bearer $token'}`.
  final Map<String, String> headers;

  /// Query parameters appended to [videoUrl] before the controller is
  /// initialised. Use when your backend accepts auth via URL param
  /// instead of (or in addition to) an HTTP header.
  ///
  /// Example: `{'token': bearerToken}` produces `…/video?token=abc123`.
  ///
  /// Leave empty (default) for no query-param modification.
  /// Global query params set on the cubit are merged on top of these
  /// (per-item values win over global values on key collision).
  final Map<String, String> queryParameters;

  const VideoItem({
    required this.id,
    required this.videoUrl,
    required this.data,
    this.thumbnailUrl,
    this.headers = const {},
    this.queryParameters = const {},
  });

  /// Creates a copy with updated data while preserving all other fields.
  /// Used by [VideoPreloadCubit.updateItemData] to reflect state changes
  /// (likes, bookmarks, etc.) without interrupting playback.
  VideoItem<T> copyWithData(T newData);

  @override
  List<Object?> get props => [id, videoUrl, thumbnailUrl, data, headers, queryParameters];
}


// ─────────────────────────────────────────────────────────────────────────────
// USAGE EXAMPLE
// ─────────────────────────────────────────────────────────────────────────────

/*

// ── 1. Basic wrapper (no auth) ────────────────────────────────────────────────

class PostVideoItem extends VideoItem<PostModel> {
  PostVideoItem(PostModel post)
      : super(
          id: post.id,
          videoUrl: post.content.first.url,
          thumbnailUrl: post.thumbNail.isNotEmpty ? post.thumbNail.first : null,
          data: post,
        );

  @override
  PostVideoItem copyWithData(PostModel newData) => PostVideoItem(newData);
}


// ── 2. Auth-gated CDN (headers + query params both set at item level) ─────────

class DealVideoItem extends VideoItem<DealMedia> {
  DealVideoItem(DealMedia media, {String token = ''})
      : super(
          id: media.id,
          videoUrl: media.url,
          data: media,
          headers: token.isNotEmpty ? {'Authorization': 'Bearer $token'} : {},
          queryParameters: token.isNotEmpty ? {'token': token} : {},
        );

  @override
  DealVideoItem copyWithData(DealMedia newData) => DealVideoItem(newData);
}


// ── 3. Preferred pattern — set token globally on the cubit ───────────────────
//    (items stay simple; token rotates without rebuilding items)

final cubit = VideoPreloadCubit<DealMedia>(
  items: mediaItems.map((m) => DealVideoItem(m)).toList(),
  // Headers for VideoPlayerController
  headers: {'Authorization': 'Bearer $bearerToken'},
  // Query param fallback for backends that don't read custom headers
  queryParameters: {'token': bearerToken},
);

// Token refreshed mid-session — update cubit, call reinitItem() if needed
cubit.setHeaders({'Authorization': 'Bearer $newToken'});
cubit.setQueryParameters({'token': newToken});


// ── 4. FeedScreen wiring ──────────────────────────────────────────────────────

class _FeedScreenState extends State<FeedScreen> {
  late VideoPreloadCubit<PostModel> _preloadCubit;

  @override
  void initState() {
    super.initState();
    final items = widget.postList.map((p) => PostVideoItem(p)).toList();
    _preloadCubit = VideoPreloadCubit<PostModel>(items: items);
    _preloadCubit.init(0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _preloadCubit,
      child: PageView.builder(
        onPageChanged: (index) {
          _preloadCubit.init(index);
          _preloadCubit.disposeExcept(index);
        },
        itemCount: _preloadCubit.items.length,
        itemBuilder: (context, index) => PostVideoWidget(
          item: _preloadCubit.items[index] as PostVideoItem,
          index: index,
        ),
      ),
    );
  }
}


// ── 5. Video player widget ────────────────────────────────────────────────────

class PostVideoWidget extends StatelessWidget {
  final PostVideoItem item;
  final int index;

  const PostVideoWidget({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoPreloadCubit<PostModel>, VideoPreloadState<PostModel>>(
      builder: (context, state) {
        if (state is _Ready<PostModel>) {
          final controller = state.controllers[item.id];
          final isCurrent = state.currentItemId == item.id;

          if (controller != null && controller.value.isInitialized) {
            return Stack(
              children: [
                Chewie(
                  controller: ChewieController(
                    videoPlayerController: controller,
                    autoPlay: isCurrent,
                    looping: true,
                    showControls: false,
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: LikeButton(
                    isLiked: item.data.liked,
                    count: item.data.numOfLikes,
                    onTap: () => _handleLike(context, item.data),
                  ),
                ),
              ],
            );
          }
        }
        // Loading state — show thumbnail
        return item.thumbnailUrl != null
            ? Image.network(item.thumbnailUrl!, fit: BoxFit.cover)
            : const ColoredBox(color: Colors.black);
      },
    );
  }

  void _handleLike(BuildContext context, PostModel post) {
    final cubit = context.read<VideoPreloadCubit<PostModel>>();
    final isLiked = !post.liked;
    final updated = post.copyWith(
      liked: isLiked,
      numOfLikes: isLiked ? post.numOfLikes + 1 : post.numOfLikes - 1,
    );
    cubit.updateItemData(post.id, updated);
    context.read<PostVideoBloc>().add(LikePostEvent(id: post.id, isLike: isLiked));
  }
}

*/
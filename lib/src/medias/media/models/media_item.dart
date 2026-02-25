// ─────────────────────────────────────────────────────────────────────────────
// FILE: models/media_item.dart
// Base class for any feed item containing media (like your PostModel).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'media_content.dart';
import 'media_type.dart';

/// Base class for feed items with media content.
/// Your PostModel, ReelModel, StoryModel should extend this.
abstract class MediaItem<T> extends Equatable {
  final String id;
  final List<MediaContent> content;
  final T data;

  const MediaItem({
    required this.id,
    required this.content,
    required this.data,
  });

  /// Primary media type (first content item's type)
  MediaType get primaryType => content.first.type;

  /// Is this a video post?
  bool get hasVideo => content.any((c) => c.isVideo);

  /// Is this an image post?
  bool get hasImage => content.any((c) => c.isImage);

  /// Is this a carousel?
  bool get isCarousel => content.length > 1;

  /// Create a copy with updated data
  MediaItem<T> copyWithData(T newData);

  @override
  List<Object?> get props => [id, content, data];
}



// ─────────────────────────────────────────────────────────────────────────────
// USAGE EXAMPLE — In your Haulway app
// ─────────────────────────────────────────────────────────────────────────────

/*

// 1. Create your MediaItem wrapper
class PostMediaItem extends MediaItem<PostModel> {
  PostMediaItem(PostModel post)
      : super(
          id: post.id,
          content: _convertContent(post),
          data: post,
        );

  static List<MediaContent> _convertContent(PostModel post) {
    return post.content.map((c) {
      return MediaContent(
        id: c.id,
        type: c.url.endsWith('.mp4') ? MediaType.video : MediaType.image,
        url: c.url,
        thumbnailUrl: post.thumbNail.isNotEmpty ? post.thumbNail.first : null,
      );
    }).toList();
  }

  @override
  PostMediaItem copyWithData(PostModel newData) => PostMediaItem(newData);
}


// 2. In your Feed screen
class FeedScreen extends StatefulWidget {
  final List<PostModel> postList;
  const FeedScreen({super.key, required this.postList});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late MixedMediaCubit<PostModel> _mediaCubit;
  late LazyVideoCubit _videoCubit;

  @override
  void initState() {
    super.initState();
    
    final mediaItems = widget.postList.map((p) => PostMediaItem(p)).toList();
    
    _mediaCubit = MixedMediaCubit<PostModel>(items: mediaItems);
    _videoCubit = LazyVideoCubit();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _mediaCubit),
        BlocProvider.value(value: _videoCubit),
      ],
      child: BlocListener<PostsCacheCubit, PostsCacheState>(
        listener: (context, cacheState) {
          final newMediaItems =
              cacheState.posts.map((p) => PostMediaItem(p)).toList();
          _mediaCubit.updateItems(newMediaItems);
        },
        child: MediaListView<PostModel>(
          items: widget.postList.map((p) => PostMediaItem(p)).toList(),
          overlayBuilder: (item) => _buildOverlay(item),
          onItemTap: (item) => _handleItemTap(item),
        ),
      ),
    );
  }

  Widget _buildOverlay(MediaItem<PostModel> item) {
    final post = item.data;
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User handle
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(post.postedBy.profilePic),
              ),
              const SizedBox(width: 8),
              Text(
                post.postedBy.fullName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Caption
          if (post.caption.isNotEmpty)
            Text(
              post.caption,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
            ),
          
          const SizedBox(height: 12),
          
          // Actions
          Row(
            children: [
              _ActionButton(
                icon: post.liked ? Icons.favorite : Icons.favorite_border,
                label: '${post.numOfLikes}',
                onTap: () => _handleLike(post),
              ),
              const SizedBox(width: 16),
              _ActionButton(
                icon: Icons.comment_outlined,
                label: '${post.numOfComments}',
                onTap: () => _showComments(post),
              ),
              const SizedBox(width: 16),
              _ActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: () => _share(post),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleLike(PostModel post) {
    final isLiked = !post.liked;
    
    // Update cache
    GetIt.I<PostsCacheCubit>().likePost(post.id, isLiked);
    
    // Update cubit (keeps media loaded)
    final updatedPost = post.copyWith(
      liked: isLiked,
      numOfLikes: isLiked ? post.numOfLikes + 1 : post.numOfLikes - 1,
    );
    _mediaCubit.updateItemData(post.id, updatedPost);
    
    // Fire API
    context.read<PostVideoBloc>().add(
      LikePostEvent(id: post.id, isLike: isLiked),
    );
  }

  @override
  void dispose() {
    _mediaCubit.close();
    _videoCubit.close();
    super.dispose();
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

*/


// ─────────────────────────────────────────────────────────────────────────────
// KEY FEATURES
// ─────────────────────────────────────────────────────────────────────────────
//
// ✅ Mixed media: Videos, images, documents in one feed
// ✅ Lazy video init: Only initializes videos when visible (VisibilityDetector)
// ✅ Smart disposal: Disposes videos 5s after leaving viewport
// ✅ Image preloading: Preloads images in scroll direction
// ✅ Document previews: Generates PDF thumbnails
// ✅ Grid + List layouts: Facebook feed and Instagram grid
// ✅ Memory efficient: Only keeps visible + buffer in memory
// ✅ State-preserving: Like/unlike doesn't reload media
// ✅ Generic: Works with any data type
// ✅ Composable: Apps define overlay UI

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../image/widgets/cached_image_widget.dart';
import '../../video/lazy_video_cubit.dart';
import '../models/media_item.dart';
import '../models/media_content.dart';
import '../models/media_type.dart';
import 'package:chewie/chewie.dart';

class MediaFeedItem<T> extends StatelessWidget {
  final MediaItem<T> item;
  final VoidCallback? onTap;
  final Widget? overlay;  // For likes, comments, etc.

  const MediaFeedItem({
    super.key,
    required this.item,
    this.onTap,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    final primaryContent = item.content.first;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Media content
          _buildMediaContent(context, primaryContent),
          
          // Overlay (UI elements)
          if (overlay != null) overlay!,
        ],
      ),
    );
  }

  Widget _buildMediaContent(BuildContext context, MediaContent content) {
    switch (content.type) {
      case MediaType.image:
        return _buildImage(content);
      
      case MediaType.video:
        return _buildVideo(context, content);
      
      case MediaType.document:
        return _buildDocument(content);
      
      case MediaType.carousel:
        return _buildCarousel(context);
    }
  }

  Widget _buildImage(MediaContent content) {
    return CachedImageWidget(
      imageUrl: content.url,
      fit: BoxFit.cover,
    );
  }

  Widget _buildVideo(BuildContext context, MediaContent content) {
    return VisibilityDetector(
      key: Key('video_${content.id}'),
      onVisibilityChanged: (info) {
        final cubit = context.read<LazyVideoCubit>();
        if (info.visibleFraction > 0.5) {
          cubit.onVideoVisible(content.id, content.url);
        } else {
          cubit.onVideoHidden(content.id);
        }
      },
      child: BlocBuilder<LazyVideoCubit, LazyVideoState>(
        builder: (context, state) {
          final controller = state.controllers[content.id];
          
          if (controller != null && controller.value.isInitialized) {
            return GestureDetector(
              onTap: () => context.read<LazyVideoCubit>()
                  .togglePlayPause(content.id),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: Chewie(
                      controller: ChewieController(
                        videoPlayerController: controller,
                        autoPlay: state.playingVideos.contains(content.id),
                        looping: true,
                        showControls: false,
                      ),
                    ),
                  ),
                  
                  // Play/pause indicator
                  if (!state.playingVideos.contains(content.id))
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }
          
          // Loading state — show thumbnail
          return content.thumbnailUrl != null
              ? CachedImageWidget(imageUrl: content.thumbnailUrl!)
              : Container(
                  color: Colors.black,
                  child: const Center(child: CircularProgressIndicator()),
                );
        },
      ),
    );
  }

  Widget _buildDocument(MediaContent content) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getDocumentIcon(content.mimeType),
            size: 48,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            content.mimeType?.split('/').last.toUpperCase() ?? 'DOC',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel(BuildContext context) {
    return PageView.builder(
      itemCount: item.content.length,
      itemBuilder: (context, index) {
        return _buildMediaContent(context, item.content[index]);
      },
    );
  }

  IconData _getDocumentIcon(String? mimeType) {
    if (mimeType == null) return Icons.description;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    if (mimeType.contains('word')) return Icons.article;
    if (mimeType.contains('sheet')) return Icons.table_chart;
    return Icons.description;
  }
}

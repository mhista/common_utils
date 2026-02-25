
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../mixed_media_cubit.dart';
import '../models/media_item.dart';
import 'media_feed_item.dart';

class MediaListView<T> extends StatefulWidget {
  final List<MediaItem<T>> items;
  final Widget Function(MediaItem<T> item)? overlayBuilder;
  final void Function(MediaItem<T> item)? onItemTap;

  const MediaListView({
    super.key,
    required this.items,
    this.overlayBuilder,
    this.onItemTap,
  });

  @override
  State<MediaListView<T>> createState() => _MediaListViewState<T>();
}

class _MediaListViewState<T> extends State<MediaListView<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Preload first batch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MixedMediaCubit<T>>().preloadRange(0, 5, context);
    });
  }

  void _onScroll() {
    final position = _scrollController.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;

    // Preload when 80% scrolled
    if (currentScroll > maxScroll * 0.8) {
      final currentIndex = (currentScroll / 400).floor(); // Assuming 400px per item
      context.read<MixedMediaCubit<T>>().preloadRange(
        currentIndex + 5,
        currentIndex + 10,
        context,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MixedMediaCubit<T>, MixedMediaState<T>>(
      builder: (context, state) {
        return ListView.builder(
          controller: _scrollController,
          itemCount: state.items.length,
          itemBuilder: (context, index) {
            final item = state.items[index];
            
            return Container(
              height: 400,  // Fixed height per item (like Facebook)
              margin: const EdgeInsets.only(bottom: 8),
              child: MediaFeedItem<T>(
                item: item,
                onTap: () => widget.onItemTap?.call(item),
                overlay: widget.overlayBuilder?.call(item),
              ),
            );
          },
        );
      },
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../mixed_media_cubit.dart';
import '../models/media_item.dart';
import 'media_feed_item.dart';

class MediaGridView<T> extends StatefulWidget {
  final List<MediaItem<T>> items;
  final int crossAxisCount;
  final void Function(MediaItem<T> item)? onItemTap;

  const MediaGridView({
    super.key,
    required this.items,
    this.crossAxisCount = 3,
    this.onItemTap,
  });

  @override
  State<MediaGridView<T>> createState() => _MediaGridViewState<T>();
}

class _MediaGridViewState<T> extends State<MediaGridView<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MixedMediaCubit<T>>().preloadRange(0, 15, context);
    });
  }

  void _onScroll() {
    final position = _scrollController.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;

    if (currentScroll > maxScroll * 0.8) {
      final currentIndex = (currentScroll / 150).floor() * widget.crossAxisCount;
      context.read<MixedMediaCubit<T>>().preloadRange(
        currentIndex + 15,
        currentIndex + 30,
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
        return GridView.builder(
          controller: _scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.crossAxisCount,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: state.items.length,
          itemBuilder: (context, index) {
            final item = state.items[index];
            
            return MediaFeedItem<T>(
              item: item,
              onTap: () => widget.onItemTap?.call(item),
            );
          },
        );
      },
    );
  }
}

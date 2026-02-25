// ─────────────────────────────────────────────────────────────────────────────
// FILE: image/image_preload_service.dart
// Preloads images into cache based on scroll position.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImagePreloadService {
  static final ImagePreloadService _instance = ImagePreloadService._();
  factory ImagePreloadService() => _instance;
  ImagePreloadService._();

  final _cacheManager = DefaultCacheManager();
  final Set<String> _preloadingUrls = {};
  final Set<String> _preloadedUrls = {};

  /// Preload images for items in range [start, end]
  Future<void> preloadRange(
    List<String> imageUrls,
    BuildContext context, {
    int bufferSize = 5,
  }) async {
    final urlsToPreload = imageUrls.take(bufferSize).toList();

    for (final url in urlsToPreload) {
      if (url.isEmpty) continue;
      if (_preloadedUrls.contains(url) || _preloadingUrls.contains(url)) {
        continue;
      }

      _preloadingUrls.add(url);

      try {
        // Download and cache the image
        await _cacheManager.downloadFile(url);
        
        // Also precache in Flutter's image cache
        final image = CachedNetworkImageProvider(url);
        await precacheImage(image, context);

        _preloadedUrls.add(url);
      } catch (e) {
        debugPrint('Failed to preload image $url: $e');
      } finally {
        _preloadingUrls.remove(url);
      }
    }
  }

  /// Preload a single image
  Future<void> preloadSingle(String url, BuildContext context) async {
    if (url.isEmpty || _preloadedUrls.contains(url)) return;

    try {
      await _cacheManager.downloadFile(url);
      final image = CachedNetworkImageProvider(url);
      await precacheImage(image, context);
      _preloadedUrls.add(url);
    } catch (e) {
      debugPrint('Failed to preload image $url: $e');
    }
  }

  /// Clear old cached images
  Future<void> clearOldCache({Duration maxAge = const Duration(days: 7)}) async {
    await _cacheManager.emptyCache();
  }

  /// Check if image is cached
  bool isCached(String url) => _preloadedUrls.contains(url);
}

// ─────────────────────────────────────────────────────────────────────────────
// FILE: models/media_content.dart
// Individual piece of media content (one image, one video, etc.)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'media_type.dart';

class MediaContent extends Equatable {
  final String id;
  final MediaType type;
  final String url;
  final String? thumbnailUrl;
  final Duration? duration;        // For videos
  final int? width;
  final int? height;
  final String? mimeType;          // For documents
  final int? fileSize;

  const MediaContent({
    required this.id,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.duration,
    this.width,
    this.height,
    this.mimeType,
    this.fileSize,
  });

  bool get isVideo => type == MediaType.video;
  bool get isImage => type == MediaType.image;
  bool get isDocument => type == MediaType.document;
  bool get isCarousel => type == MediaType.carousel;

  @override
  List<Object?> get props => [id, type, url, thumbnailUrl];
}
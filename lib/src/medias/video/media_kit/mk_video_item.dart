// ─────────────────────────────────────────────────────────────────────────────
// FILE: mk_video_item.dart
//
// Base class for video items used with media_kit cubits.
// Drop-in replacement for the original video_item.dart — same API,
// but adapted for media_kit's Player/Media/VideoController model.
//
// pubspec.yaml dependencies:
//   media_kit: ^1.2.6
//   media_kit_video: ^2.0.1
//   media_kit_libs_video: ^1.0.7
//   equatable: ^2.0.5
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

/// Base class for any item that contains video content.
/// Extend this with your app's model type.
///
/// Example — plain wrapper (no auth):
/// ```dart
/// class PostVideoItem extends MkVideoItem<PostModel> {
///   PostVideoItem(PostModel post)
///     : super(
///         id: post.id,
///         videoUrl: post.content.first.url,
///         thumbnailUrl: post.thumbnail,
///         data: post,
///       );
///
///   @override
///   PostVideoItem copyWithData(PostModel newData) => PostVideoItem(newData);
/// }
/// ```
///
/// Example — auth via header AND/OR query param:
/// ```dart
/// class DealVideoItem extends MkVideoItem<DealMedia> {
///   DealVideoItem(DealMedia media, {String token = ''})
///     : super(
///         id: media.id,
///         videoUrl: media.url,
///         data: media,
///         // media_kit natively supports HTTP headers in Media()
///         headers: token.isNotEmpty ? {'Authorization': 'Bearer $token'} : {},
///         // Fallback: append token as a query param for CDNs that need it
///         queryParameters: token.isNotEmpty ? {'token': token} : {},
///       );
///
///   @override
///   DealVideoItem copyWithData(DealMedia newData) => DealVideoItem(newData);
/// }
/// ```
abstract class MkVideoItem<T> extends Equatable {
  /// Unique identifier — used as the key in all internal maps.
  final String id;

  /// Full video URL. Must be an absolute URI.
  final String videoUrl;

  /// Optional thumbnail shown while the player initialises.
  final String? thumbnailUrl;

  /// The app's data object (PostModel, ReelModel, DealMedia, …).
  final T data;

  /// HTTP headers forwarded to [Media] when the player opens the URL.
  /// media_kit passes these natively to libmpv / the platform player,
  /// so `Authorization: Bearer …` works reliably on all platforms.
  final Map<String, String> headers;

  /// Query parameters appended to [videoUrl] before it is opened.
  /// Use when your backend authenticates via URL params instead of
  /// (or in addition to) HTTP headers.
  ///
  /// Example: `{'token': bearerToken}` → `…/video?token=abc123`
  final Map<String, String> queryParameters;

  const MkVideoItem({
    required this.id,
    required this.videoUrl,
    required this.data,
    this.thumbnailUrl,
    this.headers = const {},
    this.queryParameters = const {},
  });

  /// Return a copy with updated [data], keeping all other fields intact.
  /// Used by [MkVideoPreloadCubit.updateItemData] to reflect UI state
  /// changes (likes, bookmarks, …) without interrupting playback.
  MkVideoItem<T> copyWithData(T newData);

  @override
  List<Object?> get props => [
        id,
        videoUrl,
        thumbnailUrl,
        data,
        headers,
        queryParameters,
      ];
}
import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../common_utils2.dart';

// ─────────────────────────────────────────────────────────────────────
// RESULT TYPES
// ─────────────────────────────────────────────────────────────────────

/// Holds a single picked media item — either an image or a video.
class MediaFile {
  final File file;
  final MediaType type;

  /// Only set when [type] == [MediaType.video].
  /// The thumbnail file is written to the app's temp directory.
  final File? thumbnail;

  const MediaFile({required this.file, required this.type, this.thumbnail});

  bool get isImage => type == MediaType.image;
  bool get isVideo => type == MediaType.video;

  @override
  String toString() =>
      'MediaFile(type: $type, path: ${file.path}, hasThumbnail: ${thumbnail != null})';
}

/// Result wrapper — every public method returns this so callers
/// never have to catch; they just check [isSuccess].
class MediaResult<T> {
  final T? data;
  final String? error;

  const MediaResult.success(this.data) : error = null;
  const MediaResult.failure(this.error) : data = null;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  /// Unwrap or throw.
  T get value {
    if (data == null) throw StateError('MediaResult is a failure: $error');
    return data as T;
  }
}

// ─────────────────────────────────────────────────────────────────────
// MAIN UTILITY CLASS
// ─────────────────────────────────────────────────────────────────────

/// Unified media utility for images and videos.
///
/// ## Required pubspec dependencies
/// ```yaml
/// image_picker: ^1.1.2
/// flutter_image_compress: ^2.3.0
/// video_thumbnail: ^0.5.3
/// path_provider: ^2.1.4
/// path: ^1.9.0
/// ```
///
/// ## iOS — Info.plist
/// ```xml
/// <key>NSCameraUsageDescription</key>
/// <key>NSPhotoLibraryUsageDescription</key>
/// <key>NSMicrophoneUsageDescription</key>
/// ```
///
/// ## Android — AndroidManifest.xml
/// ```xml
/// <uses-permission android:name="android.permission.CAMERA"/>
/// <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
/// <uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
/// ```
class MediaUtils {
  MediaUtils._();

  static final ImagePicker _picker = ImagePicker();

  // ═══════════════════════════════════════════════════════════════════
  // IMAGE PICKING
  // ═══════════════════════════════════════════════════════════════════

  /// Pick a single image from the gallery.
  static Future<MediaResult<File>> pickImageFromGallery({
    int maxWidth = 1920,
    int maxHeight = 1080,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );
      if (image == null) return const MediaResult.failure('No image selected');
      return MediaResult.success(File(image.path));
    } catch (e) {
      debugPrint('[MediaUtils] pickImageFromGallery: $e');
      return MediaResult.failure(e.toString());
    }
  }

  /// Pick a single image from the camera.
  static Future<MediaResult<File>> pickImageFromCamera({
    int maxWidth = 1920,
    int maxHeight = 1080,
    int imageQuality = 85,
    CameraDevice preferredCamera = CameraDevice.rear,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
        preferredCameraDevice: preferredCamera,
      );
      if (image == null) return const MediaResult.failure('No image captured');
      return MediaResult.success(File(image.path));
    } catch (e) {
      debugPrint('[MediaUtils] pickImageFromCamera: $e');
      return MediaResult.failure(e.toString());
    }
  }

  /// Pick multiple images from the gallery.
  ///
  /// [limit] caps the number of images returned. null = no cap.
  static Future<MediaResult<List<File>>> pickMultipleImages({
    int maxWidth = 1920,
    int maxHeight = 1080,
    int imageQuality = 85,
    int? limit,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
        limit: limit,
      );
      if (images.isEmpty)
        return const MediaResult.failure('No images selected');
      return MediaResult.success(images.map((x) => File(x.path)).toList());
    } catch (e) {
      debugPrint('[MediaUtils] pickMultipleImages: $e');
      return MediaResult.failure(e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // VIDEO PICKING
  // ═══════════════════════════════════════════════════════════════════

  /// Pick a video from the gallery.
  ///
  /// [generateThumbnail] automatically extracts the first-frame thumbnail
  /// and attaches it to the returned [MediaFile].
  static Future<MediaResult<MediaFile>> pickVideoFromGallery({
    Duration? maxDuration,
    bool generateThumbnail = true,
    int thumbnailQuality = 80,
  }) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: maxDuration,
      );
      if (video == null) return const MediaResult.failure('No video selected');

      final file = File(video.path);
      File? thumb;
      if (generateThumbnail) {
        thumb = await _extractThumbnailFile(file, quality: thumbnailQuality);
      }

      return MediaResult.success(
        MediaFile(file: file, type: MediaType.video, thumbnail: thumb),
      );
    } catch (e) {
      debugPrint('[MediaUtils] pickVideoFromGallery: $e');
      return MediaResult.failure(e.toString());
    }
  }

  /// Record a video from the camera.
  static Future<MediaResult<MediaFile>> pickVideoFromCamera({
    Duration? maxDuration,
    CameraDevice preferredCamera = CameraDevice.rear,
    bool generateThumbnail = true,
    int thumbnailQuality = 80,
  }) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: maxDuration,
        preferredCameraDevice: preferredCamera,
      );
      if (video == null) return const MediaResult.failure('No video recorded');

      final file = File(video.path);
      File? thumb;
      if (generateThumbnail) {
        thumb = await _extractThumbnailFile(file, quality: thumbnailQuality);
      }

      return MediaResult.success(
        MediaFile(file: file, type: MediaType.video, thumbnail: thumb),
      );
    } catch (e) {
      debugPrint('[MediaUtils] pickVideoFromCamera: $e');
      return MediaResult.failure(e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // MIXED PICKING (images + videos together)
  // ═══════════════════════════════════════════════════════════════════

  /// Pick any mix of images and videos from the gallery in a single session.
  ///
  /// Returns a list of [MediaFile] with each item typed as image or video.
  /// Videos are automatically assigned a thumbnail.
  ///
  /// Requires `image_picker` ≥ 1.1.0 (pickMultipleMedia API).
  static Future<MediaResult<List<MediaFile>>> pickMixedMedia({
    int maxWidth = 1920,
    int maxHeight = 1080,
    int imageQuality = 85,
    int? limit,
    bool generateVideoThumbnails = true,
    int thumbnailQuality = 80,
  }) async {
    try {
      final List<XFile> picked = await _picker.pickMultipleMedia(
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
        limit: limit,
      );

      if (picked.isEmpty) return const MediaResult.failure('No media selected');

      final List<MediaFile> results = [];

      for (final xFile in picked) {
        final file = File(xFile.path);
        final isVideo = _isVideoPath(xFile.path);

        File? thumb;
        if (isVideo && generateVideoThumbnails) {
          thumb = await _extractThumbnailFile(file, quality: thumbnailQuality);
        }

        results.add(
          MediaFile(
            file: file,
            type: isVideo ? MediaType.video : MediaType.image,
            thumbnail: thumb,
          ),
        );
      }

      return MediaResult.success(results);
    } catch (e) {
      debugPrint('[MediaUtils] pickMixedMedia: $e');
      return MediaResult.failure(e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // VIDEO THUMBNAIL
  // ═══════════════════════════════════════════════════════════════════

  /// Extract a thumbnail from a video file at a given time offset.
  ///
  /// Returns the thumbnail as raw [Uint8List] bytes (useful for in-memory
  /// display, e.g. `Image.memory(bytes)`).
  ///
  /// [timeMs] — position in milliseconds to capture. Defaults to the
  /// first frame (0ms).
  static Future<MediaResult<Uint8List>> extractThumbnailBytes(
    File videoFile, {
    int timeMs = 0,
    int quality = 80,
    int maxWidth = 640,
  }) async {
    try {
      final bytes = await VideoThumbnail.thumbnailData(
        video: videoFile.path,
        imageFormat: ImageFormat.JPEG,
        timeMs: timeMs,
        quality: quality,
        maxWidth: maxWidth,
      );
      if (bytes == null) {
        return const MediaResult.failure('Could not extract thumbnail bytes');
      }
      return MediaResult.success(bytes);
    } catch (e) {
      debugPrint('[MediaUtils] extractThumbnailBytes: $e');
      return MediaResult.failure(e.toString());
    }
  }

  /// Extract a thumbnail from a video file and write it to a [File].
  ///
  /// The file is saved in the system temp directory with a unique name.
  /// You are responsible for deleting it when done.
  static Future<MediaResult<File>> extractThumbnailToFile(
    File videoFile, {
    int timeMs = 0,
    int quality = 80,
    int maxWidth = 640,
  }) async {
    try {
      final thumb = await _extractThumbnailFile(
        videoFile,
        timeMs: timeMs,
        quality: quality,
        maxWidth: maxWidth,
      );
      if (thumb == null) {
        return const MediaResult.failure('Could not write thumbnail file');
      }
      return MediaResult.success(thumb);
    } catch (e) {
      debugPrint('[MediaUtils] extractThumbnailToFile: $e');
      return MediaResult.failure(e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // IMAGE COMPRESSION
  // ═══════════════════════════════════════════════════════════════════

  /// Compress an image to a target quality.
  ///
  /// The output is written next to the original with `_c` appended to
  /// the filename stem (avoids collisions on repeated calls).
  static Future<MediaResult<File>> compressImage(
    File file, {
    int quality = 85,
    int minWidth = 1920,
    int minHeight = 1080,
  }) async {
    try {
      final dir = file.parent.path;
      final stem = p.basenameWithoutExtension(file.path);
      final targetPath = p.join(dir, '${stem}_c.jpg');

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
      );

      if (result == null) {
        return const MediaResult.failure('Compression returned null');
      }
      return MediaResult.success(File(result.path));
    } catch (e) {
      debugPrint('[MediaUtils] compressImage: $e');
      return MediaResult.failure(e.toString());
    }
  }

  /// Compress an image iteratively until it fits within [targetSizeKB].
  ///
  /// Starts at quality 95 and steps down by 15 each iteration.
  /// Returns the best result even if the target wasn't fully met.
  static Future<MediaResult<File>> compressToSize(
    File file, {
    required int targetSizeKB,
    int maxIterations = 6,
  }) async {
    try {
      int quality = 95;
      File current = file;

      for (int i = 0; i < maxIterations; i++) {
        final result = await compressImage(current, quality: quality);
        if (result.isFailure) break;

        current = result.value;
        final sizeKB = await current.length() / 1024;

        if (sizeKB <= targetSizeKB) return MediaResult.success(current);

        quality -= 15;
        if (quality < 5) break;
      }

      // Return the best we achieved even if it still exceeds target
      return MediaResult.success(current);
    } catch (e) {
      debugPrint('[MediaUtils] compressToSize: $e');
      return MediaResult.failure(e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // BASE64
  // ═══════════════════════════════════════════════════════════════════

  /// Encode a file to a base64 string.
  static Future<MediaResult<String>> fileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return MediaResult.success(base64Encode(bytes));
    } catch (e) {
      debugPrint('[MediaUtils] fileToBase64: $e');
      return MediaResult.failure(e.toString());
    }
  }

  /// Decode a base64 string and write the result to [destPath].
  static Future<MediaResult<File>> base64ToFile(
    String base64String,
    String destPath,
  ) async {
    try {
      final bytes = base64Decode(base64String);
      final file = File(destPath);
      await file.writeAsBytes(bytes);
      return MediaResult.success(file);
    } catch (e) {
      debugPrint('[MediaUtils] base64ToFile: $e');
      return MediaResult.failure(e.toString());
    }
  }

  /// Encode raw bytes to base64.
  static String uint8ListToBase64(Uint8List bytes) => base64Encode(bytes);

  /// Decode base64 to raw bytes.
  static Uint8List base64ToUint8List(String base64String) =>
      base64Decode(base64String);

  // ═══════════════════════════════════════════════════════════════════
  // FILE INFO
  // ═══════════════════════════════════════════════════════════════════

  /// File size in bytes.
  static Future<int> getSizeBytes(File file) => file.length();

  /// File size in KB.
  static Future<double> getSizeKB(File file) async =>
      await file.length() / 1024;

  /// File size in MB.
  static Future<double> getSizeMB(File file) async =>
      await getSizeKB(file) / 1024;

  /// Human-readable file size: "1.23 MB", "456.78 KB", "12 B".
  static Future<String> getFormattedSize(File file) async {
    final bytes = await file.length();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  // ═══════════════════════════════════════════════════════════════════
  // VALIDATION
  // ═══════════════════════════════════════════════════════════════════

  /// Returns true if the file has an image extension.
  static bool isImageFile(File file) {
    final ext = p.extension(file.path).toLowerCase().replaceAll('.', '');
    return {
      'jpg',
      'jpeg',
      'png',
      'gif',
      'bmp',
      'webp',
      'heic',
      'heif',
    }.contains(ext);
  }

  /// Returns true if the file has a video extension.
  static bool isVideoFile(File file) => _isVideoPath(file.path);

  /// Returns true if the file is under [maxSizeMB].
  static Future<bool> isUnderSizeLimit(File file, double maxSizeMB) async =>
      await getSizeMB(file) <= maxSizeMB;

  /// Validate a file's size and type in one call.
  ///
  /// Pass [allowedTypes] to restrict (e.g. `{MediaType.image}`).
  /// Pass [maxSizeMB] to enforce a size cap.
  static Future<MediaResult<bool>> validate(
    File file, {
    Set<MediaType>? allowedTypes,
    double? maxSizeMB,
  }) async {
    if (allowedTypes != null) {
      final fileType = isVideoFile(file) ? MediaType.video : MediaType.image;
      if (!allowedTypes.contains(fileType)) {
        return MediaResult.failure(
          'File type not allowed. Expected: ${allowedTypes.map((t) => t.name).join(', ')}',
        );
      }
    }

    if (maxSizeMB != null) {
      final ok = await isUnderSizeLimit(file, maxSizeMB);
      if (!ok) {
        final actual = await getSizeMB(file);
        return MediaResult.failure(
          'File too large: ${actual.toStringAsFixed(2)} MB (max $maxSizeMB MB)',
        );
      }
    }

    return const MediaResult.success(true);
  }

  // ═══════════════════════════════════════════════════════════════════
  // PATH HELPERS
  // ═══════════════════════════════════════════════════════════════════

  /// File extension without the dot, lower-cased.
  static String getExtension(File file) =>
      p.extension(file.path).toLowerCase().replaceAll('.', '');

  /// File name without extension.
  static String getBasename(File file) => p.basenameWithoutExtension(file.path);

  /// Generate a unique filename with a timestamp.
  ///
  /// e.g. `IMG_1710000000000.jpg`
  static String generateFilename({
    String prefix = 'IMG',
    String extension = 'jpg',
  }) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_$ts.$extension';
  }

  // ═══════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════════

  /// Write a thumbnail frame to a temp file and return it.
  /// Returns null if extraction fails (non-fatal).
  static Future<File?> _extractThumbnailFile(
    File videoFile, {
    int timeMs = 0,
    int quality = 80,
    int maxWidth = 640,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final stem = p.basenameWithoutExtension(videoFile.path);
      final thumbPath = p.join(tempDir.path, '${stem}_thumb_$timeMs.jpg');

      final path = await VideoThumbnail.thumbnailFile(
        video: videoFile.path,
        thumbnailPath: thumbPath,
        imageFormat: ImageFormat.JPEG,
        timeMs: timeMs,
        quality: quality,
        maxWidth: maxWidth,
      );

      return path != null ? File(path) : null;
    } catch (e) {
      debugPrint('[MediaUtils] _extractThumbnailFile: $e');
      return null;
    }
  }

  static const _videoExtensions = {
    'mp4',
    'mov',
    'avi',
    'mkv',
    'wmv',
    'flv',
    'm4v',
    'webm',
    '3gp',
    'ts',
    'mts',
  };

  static bool _isVideoPath(String path) {
    final ext = p.extension(path).toLowerCase().replaceAll('.', '');
    return _videoExtensions.contains(ext);
  }
}

// ─────────────────────────────────────────────────────────────────────
// EXTENSIONS
// ─────────────────────────────────────────────────────────────────────

extension ImageSourceName on ImageSource {
  String get label {
    switch (this) {
      case ImageSource.camera:
        return 'Camera';
      case ImageSource.gallery:
        return 'Gallery';
    }
  }
}

extension MediaTypeLabel on MediaType {
  String get label => switch (this) {
    MediaType.image => 'Image',
    MediaType.video => 'Video',
    MediaType.document => 'Unknown',
    MediaType.carousel => 'Unknown',
  };
}

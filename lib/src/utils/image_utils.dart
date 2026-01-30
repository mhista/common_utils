import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Image Utilities
/// Helper methods for image operations
class ImageUtils {
  ImageUtils._();

  static final ImagePicker _picker = ImagePicker();

  // ==================== Image Picking ====================

  /// Pick image from gallery
  static Future<File?> pickFromGallery({
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

      return image != null ? File(image.path) : null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick image from camera
  static Future<File?> pickFromCamera({
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

      return image != null ? File(image.path) : null;
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  /// Pick multiple images from gallery
  static Future<List<File>> pickMultiple({
    int maxWidth = 1920,
    int maxHeight = 1080,
    int imageQuality = 85,
    int? maxImages,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (maxImages != null && images.length > maxImages) {
        return images
            .take(maxImages)
            .map((xFile) => File(xFile.path))
            .toList();
      }

      return images.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }

  // ==================== Image Compression ====================

  /// Compress image file
  static Future<File?> compressImage(
    File file, {
    int quality = 85,
    int? minWidth,
    int? minHeight,
  }) async {
    try {
      final targetPath = '${file.path}_compressed.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: minWidth ?? 1920,
        minHeight: minHeight ?? 1080,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  /// Compress image to specific file size (in KB)
  static Future<File?> compressToSize(
    File file, {
    required int targetSizeKB,
    int maxIterations = 5,
  }) async {
    try {
      int quality = 95;
      File? compressed = file;

      for (int i = 0; i < maxIterations; i++) {
        compressed = await compressImage(file, quality: quality);
        
        if (compressed == null) break;

        final sizeKB = await compressed.length() / 1024;
        
        if (sizeKB <= targetSizeKB) {
          return compressed;
        }

        quality -= 15;
        if (quality < 5) break;
      }

      return compressed;
    } catch (e) {
      debugPrint('Error compressing to size: $e');
      return null;
    }
  }

  // ==================== Base64 Encoding ====================

  /// Convert image file to base64 string
  static Future<String?> fileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      debugPrint('Error converting file to base64: $e');
      return null;
    }
  }

  /// Convert base64 string to image file
  static Future<File?> base64ToFile(
    String base64String,
    String filePath,
  ) async {
    try {
      final bytes = base64Decode(base64String);
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('Error converting base64 to file: $e');
      return null;
    }
  }

  /// Convert Uint8List to base64
  static String uint8ListToBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }

  /// Convert base64 to Uint8List
  static Uint8List base64ToUint8List(String base64String) {
    return base64Decode(base64String);
  }

  // ==================== Image Info ====================

  /// Get image file size in KB
  static Future<double> getImageSizeKB(File file) async {
    final bytes = await file.length();
    return bytes / 1024;
  }

  /// Get image file size in MB
  static Future<double> getImageSizeMB(File file) async {
    final kb = await getImageSizeKB(file);
    return kb / 1024;
  }

  /// Get formatted file size
  static Future<String> getFormattedFileSize(File file) async {
    final bytes = await file.length();
    
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  // ==================== Image Validation ====================

  /// Check if file is an image
  static bool isImageFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  /// Validate image size (in MB)
  static Future<bool> validateImageSize(File file, double maxSizeMB) async {
    final sizeMB = await getImageSizeMB(file);
    return sizeMB <= maxSizeMB;
  }

  // ==================== Image Path Helpers ====================

  /// Get file extension
  static String getExtension(File file) {
    return file.path.split('.').last;
  }

  /// Get filename without extension
  static String getFilenameWithoutExtension(File file) {
    final filename = file.path.split('/').last;
    return filename.split('.').first;
  }

  /// Generate unique filename
  static String generateUniqueFilename({
    String prefix = 'IMG',
    String extension = 'jpg',
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_$timestamp.$extension';
  }
}

/// Image Source enum extension
extension ImageSourceExtension on ImageSource {
  String get name {
    switch (this) {
      case ImageSource.camera:
        return 'Camera';
      case ImageSource.gallery:
        return 'Gallery';
    }
  }
}
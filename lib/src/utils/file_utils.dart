import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// File Utilities
/// Helper methods for file operations
class FileUtils {
  FileUtils._();

  // ==================== Directory Operations ====================

  /// Get application documents directory
  static Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Get temporary directory
  static Future<Directory> getTempDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Get application support directory
  static Future<Directory> getSupportDirectory() async {
    return await getApplicationSupportDirectory();
  }

  /// Get downloads directory (Android/iOS)
  static Future<Directory?> getDownloadsDirectory() async {
    return await getDownloadsDirectory();
  }

  /// Create directory if it doesn't exist
  static Future<Directory> createDirectory(String dirPath) async {
    final directory = Directory(dirPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  /// Delete directory
  static Future<void> deleteDirectory(String dirPath) async {
    final directory = Directory(dirPath);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  /// Check if directory exists
  static Future<bool> directoryExists(String dirPath) async {
    return await Directory(dirPath).exists();
  }

  /// List files in directory
  static Future<List<File>> listFiles(
    String dirPath, {
    bool recursive = false,
  }) async {
    final directory = Directory(dirPath);
    final files = <File>[];

    if (await directory.exists()) {
      await for (final entity in directory.list(recursive: recursive)) {
        if (entity is File) {
          files.add(entity);
        }
      }
    }

    return files;
  }

  // ==================== File Operations ====================

  /// Read file as string
  static Future<String?> readFileAsString(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Write string to file
  static Future<File?> writeStringToFile(
    String filePath,
    String content,
  ) async {
    try {
      final file = File(filePath);
      return await file.writeAsString(content);
    } catch (e) {
      return null;
    }
  }

  /// Read file as bytes
  static Future<List<int>?> readFileAsBytes(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Write bytes to file
  static Future<File?> writeBytesToFile(
    String filePath,
    List<int> bytes,
  ) async {
    try {
      final file = File(filePath);
      return await file.writeAsBytes(bytes);
    } catch (e) {
      return null;
    }
  }

  /// Copy file
  static Future<File?> copyFile(String sourcePath, String destPath) async {
    try {
      final source = File(sourcePath);
      if (await source.exists()) {
        return await source.copy(destPath);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Move/rename file
  static Future<File?> moveFile(String sourcePath, String destPath) async {
    try {
      final source = File(sourcePath);
      if (await source.exists()) {
        return await source.rename(destPath);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete file
  static Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // File doesn't exist or error deleting
    }
  }

  /// Check if file exists
  static Future<bool> fileExists(String filePath) async {
    return await File(filePath).exists();
  }

  // ==================== File Information ====================

  /// Get file size in bytes
  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  /// Get formatted file size
  static Future<String> getFormattedFileSize(String filePath) async {
    final bytes = await getFileSize(filePath);
    
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Get file last modified time
  static Future<DateTime?> getFileModifiedTime(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.lastModified();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ==================== Path Operations ====================

  /// Get file extension
  static String getExtension(String filePath) {
    return path.extension(filePath);
  }

  /// Get filename without extension
  static String getFilenameWithoutExtension(String filePath) {
    return path.basenameWithoutExtension(filePath);
  }

  /// Get filename with extension
  static String getFilename(String filePath) {
    return path.basename(filePath);
  }

  /// Get directory path
  static String getDirectoryPath(String filePath) {
    return path.dirname(filePath);
  }

  /// Join paths
  static String joinPaths(List<String> paths) {
    return path.joinAll(paths);
  }

  /// Normalize path
  static String normalizePath(String filePath) {
    return path.normalize(filePath);
  }

  /// Check if path is absolute
  static bool isAbsolutePath(String filePath) {
    return path.isAbsolute(filePath);
  }

  // ==================== File Type Detection ====================

  /// Check if file is image
  static bool isImage(String filePath) {
    final ext = getExtension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg']
        .contains(ext);
  }

  /// Check if file is video
  static bool isVideo(String filePath) {
    final ext = getExtension(filePath).toLowerCase();
    return ['.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm']
        .contains(ext);
  }

  /// Check if file is audio
  static bool isAudio(String filePath) {
    final ext = getExtension(filePath).toLowerCase();
    return ['.mp3', '.wav', '.aac', '.flac', '.ogg', '.m4a'].contains(ext);
  }

  /// Check if file is document
  static bool isDocument(String filePath) {
    final ext = getExtension(filePath).toLowerCase();
    return [
      '.pdf',
      '.doc',
      '.docx',
      '.txt',
      '.xls',
      '.xlsx',
      '.ppt',
      '.pptx'
    ].contains(ext);
  }

  /// Check if file is PDF
  static bool isPDF(String filePath) {
    return getExtension(filePath).toLowerCase() == '.pdf';
  }

  /// Get file type
  static FileType getFileType(String filePath) {
    if (isImage(filePath)) return FileType.image;
    if (isVideo(filePath)) return FileType.video;
    if (isAudio(filePath)) return FileType.audio;
    if (isDocument(filePath)) return FileType.document;
    return FileType.other;
  }

  // ==================== Filename Generation ====================

  /// Generate unique filename
  static String generateUniqueFilename({
    String prefix = 'file',
    String extension = '',
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = extension.startsWith('.') ? extension : '.$extension';
    return '${prefix}_$timestamp$ext';
  }

  /// Generate filename with timestamp
  static String addTimestampToFilename(String filename) {
    final ext = path.extension(filename);
    final name = path.basenameWithoutExtension(filename);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${name}_$timestamp$ext';
  }

  // ==================== File Cleanup ====================

  /// Delete old files in directory
  static Future<void> deleteOldFiles(
    String dirPath, {
    required Duration olderThan,
  }) async {
    final directory = Directory(dirPath);
    if (!await directory.exists()) return;

    final cutoffTime = DateTime.now().subtract(olderThan);

    await for (final entity in directory.list()) {
      if (entity is File) {
        final modified = await entity.lastModified();
        if (modified.isBefore(cutoffTime)) {
          await entity.delete();
        }
      }
    }
  }

  /// Get directory size
  static Future<int> getDirectorySize(String dirPath) async {
    final directory = Directory(dirPath);
    if (!await directory.exists()) return 0;

    int totalSize = 0;

    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }

    return totalSize;
  }

  /// Clear directory (delete all files)
  static Future<void> clearDirectory(String dirPath) async {
    final directory = Directory(dirPath);
    if (!await directory.exists()) return;

    await for (final entity in directory.list()) {
      if (entity is File) {
        await entity.delete();
      }
    }
  }
}

/// File Type enum
enum FileType {
  image,
  video,
  audio,
  document,
  other,
}

/// Extension on FileType
extension FileTypeExtension on FileType {
  String get name {
    switch (this) {
      case FileType.image:
        return 'Image';
      case FileType.video:
        return 'Video';
      case FileType.audio:
        return 'Audio';
      case FileType.document:
        return 'Document';
      case FileType.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case FileType.image:
        return '🖼️';
      case FileType.video:
        return '🎥';
      case FileType.audio:
        return '🎵';
      case FileType.document:
        return '📄';
      case FileType.other:
        return '📎';
    }
  }
}
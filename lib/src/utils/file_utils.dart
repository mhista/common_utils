import 'dart:io';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

/// File Utilities
/// Helper methods for file operations including file picking
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
    return formatBytes(bytes);
  }

  /// Format bytes to human-readable size
  static String formatBytes(int bytes) {
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
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg', '.heic']
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

  // ==================== FILE PICKER METHODS ====================

  /// Pick a single file
  /// Returns PickedFileInfo with file details or null if cancelled
  static Future<PickedFileInfo?> pickFile({
    List<String>? allowedExtensions,
    FilePickerType type = FilePickerType.any,
    bool allowCompression = true,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: _convertFilePickerType(type),
        allowedExtensions: allowedExtensions,
        allowCompression: allowCompression,
      );

      if (result != null && result.files.isNotEmpty) {
        return _platformFileToPickedFileInfo(result.files.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Pick multiple files
  /// Returns list of PickedFileInfo or empty list if cancelled
  static Future<List<PickedFileInfo>> pickMultipleFiles({
    List<String>? allowedExtensions,
    FilePickerType type = FilePickerType.any,
    bool allowCompression = true,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: _convertFilePickerType(type),
        allowedExtensions: allowedExtensions,
        allowCompression: allowCompression,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files
            .map((file) => _platformFileToPickedFileInfo(file))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Pick image file
  static Future<PickedFileInfo?> pickImage({
    bool allowCompression = true,
  }) async {
    return await pickFile(
      type: FilePickerType.image,
      allowCompression: allowCompression,
    );
  }

  /// Pick multiple images
  static Future<List<PickedFileInfo>> pickMultipleImages({
    bool allowCompression = true,
  }) async {
    return await pickMultipleFiles(
      type: FilePickerType.image,
      allowCompression: allowCompression,
    );
  }

  /// Pick video file
  static Future<PickedFileInfo?> pickVideo() async {
    return await pickFile(type: FilePickerType.video);
  }

  /// Pick multiple videos
  static Future<List<PickedFileInfo>> pickMultipleVideos() async {
    return await pickMultipleFiles(type: FilePickerType.video);
  }

  /// Pick audio file
  static Future<PickedFileInfo?> pickAudio() async {
    return await pickFile(type: FilePickerType.audio);
  }

  /// Pick multiple audio files
  static Future<List<PickedFileInfo>> pickMultipleAudio() async {
    return await pickMultipleFiles(type: FilePickerType.audio);
  }

  /// Pick document (PDF, DOC, etc.)
  static Future<PickedFileInfo?> pickDocument() async {
    return await pickFile(
      type: FilePickerType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt', 'pptx'],
    );
  }

  /// Pick multiple documents
  static Future<List<PickedFileInfo>> pickMultipleDocuments() async {
    return await pickMultipleFiles(
      type: FilePickerType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt', 'pptx'],
    );
  }

  /// Pick PDF file only
  static Future<PickedFileInfo?> pickPDF() async {
    return await pickFile(
      type: FilePickerType.custom,
      allowedExtensions: ['pdf'],
    );
  }

  /// Pick custom file types
  static Future<PickedFileInfo?> pickCustomFile({
    required List<String> extensions,
    bool allowCompression = true,
  }) async {
    return await pickFile(
      type: FilePickerType.custom,
      allowedExtensions: extensions,
      allowCompression: allowCompression,
    );
  }

  /// Pick multiple custom file types
  static Future<List<PickedFileInfo>> pickMultipleCustomFiles({
    required List<String> extensions,
    bool allowCompression = true,
  }) async {
    return await pickMultipleFiles(
      type: FilePickerType.custom,
      allowedExtensions: extensions,
      allowCompression: allowCompression,
    );
  }

  /// Save file picker - let user choose where to save
  /// Returns the path where file should be saved, or null if cancelled
  static Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    List<String>? allowedExtensions,
    FilePickerType type = FilePickerType.any,
  }) async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: dialogTitle,
        fileName: fileName,
        type: _convertFilePickerType(type),
        allowedExtensions: allowedExtensions,
      );
      return result;
    } catch (e) {
      return null;
    }
  }

  /// Pick directory
  /// Returns directory path or null if cancelled
  static Future<String?> pickDirectory({
    String? dialogTitle,
  }) async {
    try {
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: dialogTitle,
      );
      return result;
    } catch (e) {
      return null;
    }
  }

  /// Clear file picker cache
  static Future<void> clearPickerCache() async {
    try {
      await FilePicker.platform.clearTemporaryFiles();
    } catch (e) {
      // Failed to clear cache
    }
  }

  // ==================== HELPER METHODS ====================

  /// Convert FilePickerType to file_picker's FileType
  static file_picker.FileType _convertFilePickerType(FilePickerType type) {
    switch (type) {
      case FilePickerType.any:
        return file_picker.FileType.any;
      case FilePickerType.media:
        return file_picker.FileType.media;
      case FilePickerType.image:
        return file_picker.FileType.image;
      case FilePickerType.video:
        return file_picker.FileType.video;
      case FilePickerType.audio:
        return file_picker.FileType.audio;
      case FilePickerType.custom:
        return file_picker.FileType.custom;
    }
  }

  /// Convert PlatformFile to PickedFileInfo
  static PickedFileInfo _platformFileToPickedFileInfo(PlatformFile platformFile) {
    return PickedFileInfo(
      path: platformFile.path,
      name: platformFile.name,
      bytes: platformFile.bytes,
      size: platformFile.size,
      extension: platformFile.extension,
      identifier: platformFile.identifier,
    );
  }

  /// Copy picked file to app directory
  static Future<File?> copyPickedFileToAppDirectory(
    PickedFileInfo pickedFile, {
    String? customFileName,
  }) async {
    if (pickedFile.path == null) return null;

    try {
      final appDir = await getDocumentsDirectory();
      final fileName = customFileName ?? pickedFile.name;
      final destPath = path.join(appDir.path, fileName);
      return await copyFile(pickedFile.path!, destPath);
    } catch (e) {
      return null;
    }
  }

  /// Save picked file bytes to app directory
  static Future<File?> savePickedFileBytesToAppDirectory(
    PickedFileInfo pickedFile, {
    String? customFileName,
  }) async {
    if (pickedFile.bytes == null) return null;

    try {
      final appDir = await getDocumentsDirectory();
      final fileName = customFileName ?? pickedFile.name;
      final destPath = path.join(appDir.path, fileName);
      return await writeBytesToFile(destPath, pickedFile.bytes!);
    } catch (e) {
      return null;
    }
  }
}

// ==================== FILE TYPE ENUMS ====================

/// File Type enum for existing file operations
enum FileType {
  image,
  video,
  audio,
  document,
  other,
}

/// File Picker Type enum for file picking operations
enum FilePickerType {
  any,
  media,
  image,
  video,
  audio,
  custom,
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

/// Extension on FilePickerType
extension FilePickerTypeExtension on FilePickerType {
  String get name {
    switch (this) {
      case FilePickerType.any:
        return 'Any';
      case FilePickerType.media:
        return 'Media';
      case FilePickerType.image:
        return 'Image';
      case FilePickerType.video:
        return 'Video';
      case FilePickerType.audio:
        return 'Audio';
      case FilePickerType.custom:
        return 'Custom';
    }
  }
}

// ==================== PICKED FILE INFO ====================

/// Information about a picked file
class PickedFileInfo {
  final String? path;
  final String name;
  final List<int>? bytes;
  final int size;
  final String? extension;
  final String? identifier;

  PickedFileInfo({
    this.path,
    required this.name,
    this.bytes,
    required this.size,
    this.extension,
    this.identifier,
  });

  /// Get file as File object (if path is available)
  File? get file => path != null ? File(path!) : null;

  /// Get formatted file size
  String get formattedSize => FileUtils.formatBytes(size);

  /// Get file type based on extension
  FileType get fileType {
    if (extension == null) return FileType.other;
    final ext = '.$extension';
    return FileUtils.getFileType(ext);
  }

  /// Check if file has path (not just bytes)
  bool get hasPath => path != null && path!.isNotEmpty;

  /// Check if file has bytes (useful for web)
  bool get hasBytes => bytes != null && bytes!.isNotEmpty;

  /// Check if file is image
  bool get isImage => fileType == FileType.image;

  /// Check if file is video
  bool get isVideo => fileType == FileType.video;

  /// Check if file is audio
  bool get isAudio => fileType == FileType.audio;

  /// Check if file is document
  bool get isDocument => fileType == FileType.document;

  @override
  String toString() {
    return 'PickedFileInfo(name: $name, size: $formattedSize, extension: $extension, hasPath: $hasPath, hasBytes: $hasBytes)';
  }

  /// Copy to another PickedFileInfo with different values
  PickedFileInfo copyWith({
    String? path,
    String? name,
    List<int>? bytes,
    int? size,
    String? extension,
    String? identifier,
  }) {
    return PickedFileInfo(
      path: path ?? this.path,
      name: name ?? this.name,
      bytes: bytes ?? this.bytes,
      size: size ?? this.size,
      extension: extension ?? this.extension,
      identifier: identifier ?? this.identifier,
    );
  }
}
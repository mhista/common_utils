
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'download_enum_values.dart';
import 'download_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_state.dart';
part 'download_cubit.freezed.dart';

class DownloadCubit extends Cubit<DownloadState> {
  DownloadCubit() : super(const DownloadState());

  final Dio _dio = Dio();
  final Map<String, CancelToken> _cancelTokens = {};

  // ── Add download ──────────────────────────────────────────────────────────

  Future<String?> addDownload({
    required String url,
    required String fileName,
    DownloadType? type,
  }) async {
    // Check permission
    if (!await _checkPermission()) {
      debugPrint('❌ Storage permission denied');
      return null;
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final downloadType = type ?? _detectType(url);

    final item = DownloadItem(
      id: id,
      url: url,
      fileName: fileName,
      type: downloadType,
    );

    // Add to state
    final downloads = Map<String, DownloadItem>.from(state.downloads)
      ..[id] = item;
    final queue = List<String>.from(state.queue)..add(id);

    emit(state.copyWith(downloads: downloads, queue: queue));

    // Start download if slot available
    _processQueue();

    return id;
  }

  // ── Queue management ──────────────────────────────────────────────────────

  void _processQueue() {
    if (!state.canStartMore || state.queuedDownloads.isEmpty) return;

    final nextItem = state.queuedDownloads.first;
    _startDownload(nextItem.id);
  }

  Future<void> _startDownload(String id) async {
    final item = state.downloads[id];
    if (item == null) return;

    // Get save directory
    final directory = await _getDownloadDirectory(item.type);
    if (directory == null) {
      _updateDownload(
        id,
        item.copyWith(
          status: DownloadStatus.failed,
          errorMessage: 'Failed to get storage directory',
        ),
      );
      return;
    }

    final savePath = '${directory.path}/${item.fileName}';

    // Update status to downloading
    _updateDownload(
      id,
      item.copyWith(
        status: DownloadStatus.downloading,
        savePath: savePath,
        startedAt: DateTime.now(),
      ),
    );

    // Create cancel token
    final cancelToken = CancelToken();
    _cancelTokens[id] = cancelToken;

    try {
      await _dio.download(
        item.url,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            _updateProgress(id, received, total);
          }
        },
      );

      // Success
      final updatedItem = state.downloads[id];
      if (updatedItem != null) {
        _updateDownload(
          id,
          updatedItem.copyWith(
            status: DownloadStatus.completed,
            progress: 1.0,
            completedAt: DateTime.now(),
          ),
        );
      }

      debugPrint('✅ Download completed: ${item.fileName}');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        // User cancelled
        _updateDownload(
          id,
          item.copyWith(status: DownloadStatus.cancelled),
        );
      } else {
        // Network/server error
        _updateDownload(
          id,
          item.copyWith(
            status: DownloadStatus.failed,
            errorMessage: e.message ?? 'Download failed',
          ),
        );
      }
      debugPrint('❌ Download failed: ${item.fileName} - ${e.message}');
    } finally {
      _cancelTokens.remove(id);
      // Process next in queue
      _processQueue();
    }
  }

  void _updateProgress(String id, int received, int total) {
    final item = state.downloads[id];
    if (item == null) return;

    _updateDownload(
      id,
      item.copyWith(
        progress: received / total,
        bytesDownloaded: received,
        totalBytes: total,
      ),
    );
  }

  void _updateDownload(String id, DownloadItem updatedItem) {
    final downloads = Map<String, DownloadItem>.from(state.downloads)
      ..[id] = updatedItem;
    emit(state.copyWith(downloads: downloads));
  }

  // ── Pause/Resume/Cancel ───────────────────────────────────────────────────

  void pauseDownload(String id) {
    final item = state.downloads[id];
    if (item == null || item.status != DownloadStatus.downloading) return;

    _cancelTokens[id]?.cancel('Paused by user');
    _updateDownload(id, item.copyWith(status: DownloadStatus.paused));
  }

  Future<void> resumeDownload(String id) async {
    final item = state.downloads[id];
    if (item == null || item.status != DownloadStatus.paused) return;

    _updateDownload(id, item.copyWith(status: DownloadStatus.queued));
    _processQueue();
  }

  void cancelDownload(String id) {
    final item = state.downloads[id];
    if (item == null) return;

    _cancelTokens[id]?.cancel('Cancelled by user');
    _updateDownload(id, item.copyWith(status: DownloadStatus.cancelled));

    // Delete partial file
    if (item.savePath != null) {
      File(item.savePath!).deleteSync(recursive: false);
    }
  }

  Future<void> retryDownload(String id) async {
    final item = state.downloads[id];
    if (item == null) return;

    _updateDownload(
      id,
      item.copyWith(
        status: DownloadStatus.queued,
        progress: 0,
        bytesDownloaded: 0,
        errorMessage: null,
      ),
    );
    _processQueue();
  }

  // ── Utilities ─────────────────────────────────────────────────────────────

  Future<bool> _checkPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) return true;
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true; // iOS doesn't need storage permission
  }

  Future<Directory?> _getDownloadDirectory(DownloadType type) async {
    try {
      Directory? directory;

      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        if (directory == null) return null;

        // Create subdirectories
        final subDir = {
          DownloadType.video: 'Videos',
          DownloadType.image: 'Images',
          DownloadType.document: 'Documents',
          DownloadType.other: 'Downloads',
        }[type]!;

        final targetDir = Directory('${directory.path}/$subDir');
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }
        return targetDir;
      } else {
        // iOS
        return await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      debugPrint('Error getting download directory: $e');
      return null;
    }
  }

  DownloadType _detectType(String url) {
    final extension = url.split('.').last.toLowerCase();
    if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension)) {
      return DownloadType.video;
    }
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension)) {
      return DownloadType.image;
    }
    if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'].contains(extension)) {
      return DownloadType.document;
    }
    return DownloadType.other;
  }

  // ── Batch operations ──────────────────────────────────────────────────────

  void pauseAll() {
    for (final item in state.activeDownloads) {
      pauseDownload(item.id);
    }
  }

  Future<void> resumeAll() async {
    for (final item in state.downloads.values) {
      if (item.status == DownloadStatus.paused) {
        await resumeDownload(item.id);
      }
    }
  }

  void cancelAll() {
    for (final item in state.downloads.values) {
      if (item.status == DownloadStatus.downloading ||
          item.status == DownloadStatus.queued) {
        cancelDownload(item.id);
      }
    }
  }

  void clearCompleted() {
    final downloads = Map<String, DownloadItem>.from(state.downloads);
    downloads.removeWhere((_, item) => item.status == DownloadStatus.completed);
    emit(state.copyWith(downloads: downloads));
  }

  // ── Storage cleanup ───────────────────────────────────────────────────────

  Future<void> deleteDownload(String id) async {
    final item = state.downloads[id];
    if (item == null) return;

    // Delete file
    if (item.savePath != null && File(item.savePath!).existsSync()) {
      await File(item.savePath!).delete();
    }

    // Remove from state
    final downloads = Map<String, DownloadItem>.from(state.downloads)
      ..remove(id);
    final queue = List<String>.from(state.queue)..remove(id);

    emit(state.copyWith(downloads: downloads, queue: queue));
  }

  Future<int> getTotalDownloadSize() async {
    int total = 0;
    for (final item in state.completedDownloads) {
      if (item.savePath != null && File(item.savePath!).existsSync()) {
        total += await File(item.savePath!).length();
      }
    }
    return total;
  }

  @override
  Future<void> close() {
    // Cancel all active downloads
    for (final token in _cancelTokens.values) {
      token.cancel('Cubit closed');
    }
    return super.close();
  }
}

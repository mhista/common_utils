
import 'package:freezed_annotation/freezed_annotation.dart';

import 'download_enum_values.dart';
part 'download_item.freezed.dart'; 

@freezed
abstract class DownloadItem with _$DownloadItem {
  const factory DownloadItem({
    required String id,
    required String url,
    required String fileName,
    required DownloadType type,
    @Default(DownloadStatus.queued) DownloadStatus status,
    @Default(0.0) double progress,  // 0.0 to 1.0
    @Default(0) int bytesDownloaded,
    @Default(0) int totalBytes,
    String? savePath,
    String? errorMessage,
    DateTime? startedAt,
    DateTime? completedAt,
  }) = _DownloadItem;

  const DownloadItem._();

  /// Human-readable file size
  String get downloadedSize => _formatBytes(bytesDownloaded);
  String get totalSize => _formatBytes(totalBytes);

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Speed calculation
  Duration? get downloadDuration =>
      startedAt != null ? DateTime.now().difference(startedAt!) : null;

  String? get downloadSpeed {
    final duration = downloadDuration;
    if (duration == null || duration.inSeconds == 0) return null;
    final bytesPerSecond = bytesDownloaded / duration.inSeconds;
    return '${_formatBytes(bytesPerSecond.toInt())}/s';
  }

  /// Estimated time remaining
  String? get estimatedTimeRemaining {
    if (progress == 0 || totalBytes == 0) return null;
    final duration = downloadDuration;
    if (duration == null) return null;

    final remainingBytes = totalBytes - bytesDownloaded;
    final bytesPerSecond = bytesDownloaded / duration.inSeconds;
    if (bytesPerSecond == 0) return null;

    final secondsRemaining = remainingBytes / bytesPerSecond;
    if (secondsRemaining < 60) return '${secondsRemaining.toInt()}s';
    if (secondsRemaining < 3600) {
      return '${(secondsRemaining / 60).toInt()}m';
    }
    return '${(secondsRemaining / 3600).toInt()}h';
  }
}

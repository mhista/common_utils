
part of 'download_cubit.dart';

@freezed
abstract class DownloadState with _$DownloadState {
  const factory DownloadState({
    @Default({}) Map<String, DownloadItem> downloads,
    @Default([]) List<String> queue,  // IDs in queue order
    @Default(3) int maxConcurrent,
  }) = _DownloadState;

  const DownloadState._();

  /// Active downloads (currently downloading)
  List<DownloadItem> get activeDownloads => downloads.values
      .where((d) => d.status == DownloadStatus.downloading)
      .toList();

  /// Queued downloads (waiting)
  List<DownloadItem> get queuedDownloads => downloads.values
      .where((d) => d.status == DownloadStatus.queued)
      .toList();

  /// Completed downloads
  List<DownloadItem> get completedDownloads => downloads.values
      .where((d) => d.status == DownloadStatus.completed)
      .toList();

  /// Failed downloads
  List<DownloadItem> get failedDownloads => downloads.values
      .where((d) => d.status == DownloadStatus.failed)
      .toList();

  /// Check if can start more downloads
  bool get canStartMore => activeDownloads.length < maxConcurrent;
}

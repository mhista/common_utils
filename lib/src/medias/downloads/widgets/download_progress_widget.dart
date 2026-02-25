
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../download_cubit.dart';
import '../download_enum_values.dart';

class DownloadProgressWidget extends StatelessWidget {
  final String downloadId;

  const DownloadProgressWidget({super.key, required this.downloadId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadCubit, DownloadState>(
      builder: (context, state) {
        final download = state.downloads[downloadId];
        if (download == null) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // File name
                Text(
                  download.fileName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Progress bar
                if (download.status == DownloadStatus.downloading ||
                    download.status == DownloadStatus.queued)
                  LinearProgressIndicator(value: download.progress),

                const SizedBox(height: 8),

                // Status row
                Row(
                  children: [
                    _buildStatusChip(download.status),
                    const Spacer(),
                    if (download.status == DownloadStatus.downloading) ...[
                      Text(
                        '${download.downloadedSize} / ${download.totalSize}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      if (download.downloadSpeed != null)
                        Text(
                          download.downloadSpeed!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ],
                ),

                // Actions
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (download.status == DownloadStatus.downloading)
                      IconButton(
                        icon: const Icon(Icons.pause),
                        onPressed: () =>
                            context.read<DownloadCubit>().pauseDownload(downloadId),
                      ),
                    if (download.status == DownloadStatus.paused)
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () =>
                            context.read<DownloadCubit>().resumeDownload(downloadId),
                      ),
                    if (download.status == DownloadStatus.failed)
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () =>
                            context.read<DownloadCubit>().retryDownload(downloadId),
                      ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () =>
                          context.read<DownloadCubit>().cancelDownload(downloadId),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(DownloadStatus status) {
    final data = {
      DownloadStatus.queued: ('Queued', Colors.blue),
      DownloadStatus.downloading: ('Downloading', Colors.green),
      DownloadStatus.paused: ('Paused', Colors.orange),
      DownloadStatus.completed: ('Completed', Colors.green),
      DownloadStatus.failed: ('Failed', Colors.red),
      DownloadStatus.cancelled: ('Cancelled', Colors.grey),
    }[status]!;

    return Chip(
      label: Text(data.$1, style: const TextStyle(fontSize: 12)),
      backgroundColor: data.$2.withOpacity(0.2),
      labelStyle: TextStyle(color: data.$2),
    );
  }
}
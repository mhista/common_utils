enum DownloadStatus {
  queued,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

enum DownloadType {
  video,
  image,
  document,
  other,
}



// ─────────────────────────────────────────────────────────────────────────────
// USAGE EXAMPLE
// ─────────────────────────────────────────────────────────────────────────────

/*

// 1. Initialize in main()
void main() {
  runApp(
    BlocProvider(
      create: (_) => DownloadCubit(),
      child: MyApp(),
    ),
  );
}


// 2. Download a video from your feed
void _downloadVideo(PostModel post) async {
  final url = post.content.first.url;
  final fileName = '${post.id}_${DateTime.now().millisecondsSinceEpoch}.mp4';

  final downloadId = await context.read<DownloadCubit>().addDownload(
    url: url,
    fileName: fileName,
    type: DownloadType.video,
  );

  if (downloadId != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Download started: $fileName')),
    );

    // Navigate to downloads page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DownloadsListPage()),
    );
  }
}


// 3. Show download button in your FeedPostListWidget
IconButton(
  icon: const Icon(Icons.download),
  onPressed: () => _downloadVideo(widget.post),
)


// 4. Listen to download completion
BlocListener<DownloadCubit, DownloadState>(
  listener: (context, state) {
    final completed = state.completedDownloads;
    if (completed.isNotEmpty) {
      final latest = completed.last;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded: ${latest.fileName}')),
      );
    }
  },
  child: // your widget
)

*/
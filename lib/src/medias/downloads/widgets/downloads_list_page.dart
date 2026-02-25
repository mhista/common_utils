
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../download_cubit.dart';
import 'download_progress_widget.dart';

class DownloadsListPage extends StatelessWidget {
  const DownloadsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'pause_all', child: Text('Pause All')),
              const PopupMenuItem(value: 'resume_all', child: Text('Resume All')),
              const PopupMenuItem(value: 'cancel_all', child: Text('Cancel All')),
              const PopupMenuItem(
                value: 'clear_completed',
                child: Text('Clear Completed'),
              ),
            ],
            onSelected: (value) {
              final cubit = context.read<DownloadCubit>();
              switch (value) {
                case 'pause_all':
                  cubit.pauseAll();
                  break;
                case 'resume_all':
                  cubit.resumeAll();
                  break;
                case 'cancel_all':
                  cubit.cancelAll();
                  break;
                case 'clear_completed':
                  cubit.clearCompleted();
                  break;
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<DownloadCubit, DownloadState>(
        builder: (context, state) {
          if (state.downloads.isEmpty) {
            return const Center(child: Text('No downloads'));
          }

          return ListView.builder(
            itemCount: state.downloads.length,
            itemBuilder: (context, index) {
              final downloadId = state.downloads.keys.elementAt(index);
              return DownloadProgressWidget(downloadId: downloadId);
            },
          );
        },
      ),
    );
  }
}

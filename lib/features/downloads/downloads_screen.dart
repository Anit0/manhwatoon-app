import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/loaders.dart';
import 'download_manager.dart';

/// Lists the offline download queue with per-chapter progress and actions.
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadsProvider);
    return downloads.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Downloads error',
        message: '$e',
      ),
      data: (tasks) {
        if (tasks.isEmpty) {
          return const EmptyState(
            icon: Icons.download_rounded,
            title: 'No downloads',
            message: 'Download chapters from a manga page to read them offline.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _DownloadTile(task: tasks[index]),
        );
      },
    );
  }
}

class _DownloadTile extends ConsumerWidget {
  const _DownloadTile({required this.task});

  final DownloadTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final progress = task.totalPages > 0 ? task.downloadedPages / task.totalPages : 0.0;

    final (icon, color) = switch (task.state) {
      'completed' => (Icons.download_done_rounded, scheme.primary),
      'downloading' || 'queued' => (Icons.downloading_rounded, scheme.tertiary),
      'paused' => (Icons.pause_circle_rounded, scheme.onSurfaceVariant),
      'error' => (Icons.error_rounded, scheme.error),
      _ => (Icons.download_rounded, scheme.onSurfaceVariant),
    };

    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(task.chapterTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.mangaTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _statusLabel(),
              style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            final manager = ref.read(downloadManagerProvider);
            switch (value) {
              case 'retry':
                manager.retry(task.chapterUrl);
              case 'delete':
                manager.deleteChapter(task.chapterUrl);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'retry', child: Text('Retry')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }

  String _statusLabel() {
    switch (task.state) {
      case 'completed':
        return '${task.downloadedPages} pages • Offline';
      case 'downloading':
        return '${task.downloadedPages}/${task.totalPages} pages';
      case 'queued':
        return 'Queued';
      case 'paused':
        return 'Paused';
      case 'error':
        return task.error ?? 'Failed';
      default:
        return task.state;
    }
  }
}

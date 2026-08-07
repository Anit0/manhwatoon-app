import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/database/app_repository.dart';
import '../../core/network/site_api.dart';
import '../../core/providers/app_providers.dart';
import '../../models/chapter.dart';
import '../../models/manga.dart';

/// Owns the offline download queue.
///
/// Each queued chapter is fetched (page list + images) in the background and
/// written to `{documents}/downloads/{mangaSlug}/{chapterSlug}/page-N.jpg`.
/// Progress is persisted through [AppRepository] so it survives restarts.
class DownloadManager {
  DownloadManager({
    required AppRepository repository,
    required SiteApi api,
  })  : _repository = repository,
        _api = api;

  final AppRepository _repository;
  final SiteApi _api;

  /// Chapter URLs that are currently being processed (prevents duplicates).
  final Set<String> _active = {};
  bool _clearing = false;

  String _slugFromUrl(String url) {
    var u = url.trim();
    if (u.endsWith('/')) u = u.substring(0, u.length - 1);
    final parts = u.split('/');
    final last = parts.last;
    return last.isEmpty ? 'chapter' : last;
  }

  Future<Directory> _downloadRoot() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'downloads'));
    await dir.create(recursive: true);
    return dir;
  }

  Future<String> _dirFor({required Manga manga, required Chapter chapter}) async {
    final root = await _downloadRoot();
    return p.join(root.path, _slugFromUrl(manga.url), _slugFromUrl(chapter.url));
  }

  /// Queues a chapter for background download.
  Future<void> enqueue({required Manga manga, required Chapter chapter}) async {
    final existing = await _repository.getDownloadTask(chapter.url);
    if (existing != null) {
      if (existing.state == 'queued' ||
          existing.state == 'downloading' ||
          existing.state == 'completed') {
        return;
      }
      await _repository.deleteDownload(chapter.url);
    }
    final dirPath = await _dirFor(manga: manga, chapter: chapter);
    await _repository.insertDownload(
      mangaUrl: manga.url,
      mangaTitle: manga.title,
      mangaSlug: _slugFromUrl(manga.url),
      chapterUrl: chapter.url,
      chapterTitle: chapter.title,
      chapterSlug: _slugFromUrl(chapter.url),
      totalPages: 0,
      directory: dirPath,
    );
    unawaited(_process(chapter.url));
  }

  Future<void> _process(String chapterUrl) async {
    if (!_active.add(chapterUrl)) return;
    try {
      final task = await _repository.getDownloadTask(chapterUrl);
      if (task == null) return;
      await _repository.updateDownloadState(chapterUrl, state: 'downloading');

      final pages = await _api.fetchReadingPages(chapterUrl);
      if (pages.isEmpty) {
        await _repository.updateDownloadState(
          chapterUrl,
          state: 'error',
          error: 'No pages found for this chapter',
        );
        return;
      }
      await _repository.updateDownloadState(
        chapterUrl,
        totalPages: pages.length,
      );

      final dir = Directory(task.directory ??
          p.join((await _downloadRoot()).path, task.mangaSlug, task.chapterSlug));
      await dir.create(recursive: true);

      var bytes = 0;
      for (var i = 0; i < pages.length; i++) {
        final page = pages[i];
        final file = File(p.join(dir.path, 'page-${i + 1}.jpg'));
        if (await file.exists()) {
          bytes += await file.length();
        } else {
          final response = await _api.downloadImageBytes(page.imageUrl);
          final data = response.data;
          if (data == null || data.isEmpty) {
            throw StateError('Empty image data for ${page.imageUrl}');
          }
          bytes += data.length;
          await file.writeAsBytes(data, flush: true);
        }
        await _repository.updateDownloadState(
          chapterUrl,
          downloadedPages: i + 1,
          bytesReceived: bytes,
          bytesTotal: bytes,
        );
      }

      await _repository.updateDownloadState(
        chapterUrl,
        state: 'completed',
        downloadedPages: pages.length,
      );
    } catch (e) {
      await _repository.updateDownloadState(chapterUrl, state: 'error', error: '$e');
    } finally {
      _active.remove(chapterUrl);
    }
  }

  /// Returns the folder containing a fully downloaded chapter, or null.
  Future<Directory?> downloadedDirectory(String chapterUrl) async {
    final task = await _repository.getDownloadTask(chapterUrl);
    if (task == null || task.state != 'completed') return null;
    final path = task.directory;
    if (path == null || path.isEmpty) return null;
    final dir = Directory(path);
    if (!await dir.exists()) return null;
    return dir;
  }

  Future<bool> isDownloaded(String chapterUrl) async {
    final dir = await downloadedDirectory(chapterUrl);
    return dir != null;
  }

  Future<void> deleteChapter(String chapterUrl) async {
    final task = await _repository.getDownloadTask(chapterUrl);
    if (task?.directory != null) {
      final dir = Directory(task!.directory!);
      if (await dir.exists()) await dir.delete(recursive: true);
    }
    await _repository.deleteDownload(chapterUrl);
  }

  Future<void> retry(String chapterUrl) async {
    await _repository.updateDownloadState(
      chapterUrl,
      state: 'queued',
      error: null,
      downloadedPages: 0,
      bytesReceived: 0,
    );
    unawaited(_process(chapterUrl));
  }

  /// Deletes all completed downloads (disk + database).
  Future<void> clearCompleted() async {
    if (_clearing) return;
    _clearing = true;
    try {
      final tasks = await _repository.getDownloadTasks();
      for (final t in tasks) {
        if (t.state == 'completed' && t.directory != null) {
          final dir = Directory(t.directory!);
          if (await dir.exists()) await dir.delete(recursive: true);
        }
      }
      await _repository.clearCompletedDownloads();
    } finally {
      _clearing = false;
    }
  }
}

final downloadManagerProvider = Provider<DownloadManager>((ref) {
  return DownloadManager(
    repository: ref.watch(repositoryProvider),
    api: ref.watch(siteApiProvider),
  );
});

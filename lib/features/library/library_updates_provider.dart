import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/sources/source_registry.dart';

/// A library manga that gained at least one new chapter since it was last
/// acknowledged by the user.
class LibraryUpdate {
  const LibraryUpdate({
    required this.item,
    required this.latestChapterTitle,
    required this.latestChapterUrl,
  });

  final LibraryItem item;
  final String? latestChapterTitle;
  final String? latestChapterUrl;
}

/// Scans library items for new chapters (on-device, no backend).
///
/// Each item's site chapter list is fetched opportunistically and compared
/// against the last "seen" latest chapter (stored in SharedPreferences, seeded
/// from the item's stored latest chapter). Items whose newest chapter differs
/// are surfaced as updates. The scan is capped and concurrency-limited so it
/// stays cheap on large libraries.
final libraryUpdatesProvider =
    AsyncNotifierProvider<LibraryUpdatesNotifier, List<LibraryUpdate>>(
  LibraryUpdatesNotifier.new,
);

class LibraryUpdatesNotifier extends AsyncNotifier<List<LibraryUpdate>> {
  static const int maxItems = 20;
  static const int concurrency = 3;

  /// Latest chapter URL seen per manga during the last scan.
  final Map<String, String> _scannedLatest = {};

  @override
  Future<List<LibraryUpdate>> build() async {
    final repo = ref.watch(repositoryProvider);
    final prefs = ref.watch(sharedPreferencesProvider);
    final items = await repo.getLibraryItems();
    final targets = items.take(maxItems).toList();

    return _mapConcurrent(targets, (item) async {
      final source = sourceForUrl(item.mangaUrl);
      final detail = await source.fetchMangaDetail(item.mangaUrl);
      if (detail.chapters.isEmpty) return null;
      final latest = detail.chapters.first; // site lists newest first
      _scannedLatest[item.mangaUrl] = latest.url;

      final acknowledged = prefs?.getString(StorageKeys.ackLatestChapter(item.mangaUrl)) ??
          item.lastChapterUrl;
      if (acknowledged == null || acknowledged == latest.url) return null;
      return LibraryUpdate(
        item: item,
        latestChapterTitle: latest.title,
        latestChapterUrl: latest.url,
      );
    }, limit: concurrency);
  }

  /// Forces a fresh scan.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }

  /// Marks [mangaUrl] as acknowledged up to [latestChapterUrl] (defaults to the
  /// newest chapter seen during the last scan), removing it from the updates.
  Future<void> acknowledge(String mangaUrl, {String? latestChapterUrl}) async {
    final latest = latestChapterUrl ?? _scannedLatest[mangaUrl];
    if (latest == null) return;
    final prefs = ref.read(sharedPreferencesProvider) ??
        await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.ackLatestChapter(mangaUrl), latest);
    _scannedLatest[mangaUrl] = latest;

    final current = state.value ?? const <LibraryUpdate>[];
    final next = current.where((u) => u.item.mangaUrl != mangaUrl).toList();
    if (next.length != current.length) {
      state = AsyncValue.data(next);
    }
  }

  /// Runs [fn] for every item with at most [limit] calls in flight, dropping
  /// any item whose future throws so a single failure never aborts the scan.
  Future<List<R>> _mapConcurrent<T, R>(
    List<T> items,
    Future<R?> Function(T item) fn, {
    required int limit,
  }) async {
    if (items.isEmpty) return const [];
    final results = List<R?>.filled(items.length, null);
    var next = 0;

    Future<void> worker() async {
      while (true) {
        final i = next++;
        if (i >= items.length) return;
        try {
          results[i] = await fn(items[i]);
        } catch (_) {
          results[i] = null;
        }
      }
    }

    final workerCount = limit < 1 ? 1 : (limit > items.length ? items.length : limit);
    await Future.wait([for (var i = 0; i < workerCount; i++) worker()]);
    return results.whereType<R>().toList();
  }
}

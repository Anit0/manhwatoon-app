import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../models/manga.dart';
/// Aggregated payload rendered on the home screen.
class HomeData {
  const HomeData({
    this.trending = const [],
    this.popular = const [],
    this.latest = const [],
    this.hiddenGems = const [],
    this.editorPicks = const [],
    this.dailySuggestions = const [],
  });

  final List<Manga> trending;
  final List<Manga> popular;
  final List<Manga> latest;
  final List<Manga> hiddenGems;
  final List<Manga> editorPicks;
  final List<Manga> dailySuggestions;

  bool get isEmpty =>
      trending.isEmpty &&
      popular.isEmpty &&
      latest.isEmpty &&
      hiddenGems.isEmpty &&
      editorPicks.isEmpty &&
      dailySuggestions.isEmpty;
}

class HomeDataNotifier extends AsyncNotifier<HomeData> {
  @override
  Future<HomeData> build() async {
    return _fetch();
  }

  Future<HomeData> _fetch() async {
    final api = ref.read(activeSourceProvider);
    final hideAdult = ref.read(settingsProvider).hideAdult;

    Future<List<Manga>> guarded(Future<List<Manga>> f) async {
      try {
        final list = await f.timeout(const Duration(seconds: 12));
        if (hideAdult) return list.where((m) => !m.isAdult).toList();
        return list;
      } catch (_) {
        return const [];
      }
    }

    final results = await Future.wait([
      guarded(api.fetchArchive(SortOrder.trending, page: 1)),
      guarded(api.fetchArchive(SortOrder.views, page: 1)),
      guarded(api.fetchHomeLatest()),
      guarded(api.fetchArchive(SortOrder.rating, page: 2)),
      guarded(api.fetchArchive(SortOrder.rating, page: 1)),
    ]).timeout(const Duration(seconds: 30));
    if (results.length < 5) {
      return const HomeData();
    }

    final suggestions = [...results[0], ...results[1], ...results[4]].isEmpty
        ? const <Manga>[]
        : _pickRandom([...results[0], ...results[1], ...results[4]], 10);

    return HomeData(
      trending: results[0],
      popular: results[1],
      latest: results[2],
      hiddenGems: results[3],
      editorPicks: results[4],
      dailySuggestions: suggestions,
    );
  }

  List<Manga> _pickRandom(List<Manga> source, int count) {
    final random = Random();
    final pool = [...source];
    pool.shuffle(random);
    return pool.take(count).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final homeDataProvider =
    AsyncNotifierProvider<HomeDataNotifier, HomeData>(HomeDataNotifier.new);

/// Continue-reading entries derived from local reading history.
class ContinueReading {
  const ContinueReading({
    required this.manga,
    required this.chapterUrl,
    required this.chapterTitle,
    required this.pageIndex,
    required this.totalPages,
  });

  final Manga manga;
  final String chapterUrl;
  final String chapterTitle;
  final int pageIndex;
  final int totalPages;
}

final continueReadingProvider = StreamProvider<List<ContinueReading>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo
      .watchHistory()
      .map((list) => list.map(_toContinueReading).toList());
});

ContinueReading _toContinueReading(ReadingHistoryData h) {
  return ContinueReading(
    manga: Manga(
      url: h.mangaUrl,
      title: h.mangaTitle,
      coverUrl: h.coverUrl,
    ),
    chapterUrl: h.chapterUrl,
    chapterTitle: h.chapterTitle,
    pageIndex: h.pageIndex,
    totalPages: h.totalPages,
  );
}

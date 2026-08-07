import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../models/manga.dart';

class DiscoverData {
  const DiscoverData({
    this.trending = const [],
    this.popular = const [],
    this.highestRated = const [],
    this.newReleases = const [],
    this.recentlyUpdated = const [],
    this.hiddenGems = const [],
    this.randomPick,
  });

  final List<Manga> trending;
  final List<Manga> popular;
  final List<Manga> highestRated;
  final List<Manga> newReleases;
  final List<Manga> recentlyUpdated;
  final List<Manga> hiddenGems;
  final Manga? randomPick;
}

class DiscoverDataNotifier extends AsyncNotifier<DiscoverData> {
  @override
  Future<DiscoverData> build() => _fetch();

  Future<DiscoverData> _fetch() async {
    final api = ref.read(siteApiProvider);
    final hideAdult = ref.read(settingsProvider).hideAdult;

    Future<List<Manga>> guarded(Future<List<Manga>> f) async {
      try {
        final list = await f;
        if (hideAdult) return list.where((m) => !m.isAdult).toList();
        return list;
      } catch (_) {
        return const [];
      }
    }

    final results = await Future.wait([
      guarded(api.fetchArchive(SortOrder.trending, page: 1)),
      guarded(api.fetchArchive(SortOrder.views, page: 1)),
      guarded(api.fetchArchive(SortOrder.rating, page: 1)),
      guarded(api.fetchArchive(SortOrder.newManga, page: 1)),
      guarded(api.fetchArchive(SortOrder.latest, page: 1)),
      guarded(api.fetchArchive(SortOrder.rating, page: 3)),
    ]);

    final pool = [...results[0], ...results[2], ...results[3], ...results[4]];
    final random = Random();
    final randomPick = pool.isEmpty ? null : pool[random.nextInt(pool.length)];

    return DiscoverData(
      trending: results[0],
      popular: results[1],
      highestRated: results[2],
      newReleases: results[3],
      recentlyUpdated: results[4],
      hiddenGems: results[5],
      randomPick: randomPick,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> rerollRandom() async {
    final current = state.valueOrNull;
    if (current == null) return;
    final api = ref.read(siteApiProvider);
    final list = await api.fetchArchive(SortOrder.trending, page: 1);
    if (list.isEmpty) return;
    final random = Random();
    state = AsyncData(DiscoverData(
      trending: current.trending,
      popular: current.popular,
      highestRated: current.highestRated,
      newReleases: current.newReleases,
      recentlyUpdated: current.recentlyUpdated,
      hiddenGems: current.hiddenGems,
      randomPick: list[random.nextInt(list.length)],
    ));
  }
}

final discoverDataProvider =
    AsyncNotifierProvider<DiscoverDataNotifier, DiscoverData>(DiscoverDataNotifier.new);

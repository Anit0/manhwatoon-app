import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/search/search_history_provider.dart';
import '../../models/reader_models.dart';
import '../constants/storage_keys.dart';
import '../database/app_database.dart';
import '../database/app_repository.dart';
import '../sources/manga_source.dart';
import '../sources/source_registry.dart';
import 'settings_provider.dart';

/// The currently selected content source for browsing (persisted).
final activeSourceIdProvider =
    NotifierProvider<ActiveSourceIdNotifier, String>(ActiveSourceIdNotifier.new);

class ActiveSourceIdNotifier extends Notifier<String> {
  @override
  String build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs?.getString(StorageKeys.activeSourceId) ?? manhwaToonSource.id;
  }

  Future<void> select(String id) async {
    final prefs = ref.read(sharedPreferencesProvider) ??
        await SharedPreferences.getInstance();
    state = id;
    await prefs.setString(StorageKeys.activeSourceId, id);
  }
}

/// The active [MangaSource] used by browse/search/home screens.
final activeSourceProvider = Provider<MangaSource>((ref) {
  return sourceById(ref.watch(activeSourceIdProvider));
});

/// Resolves the source that owns a given manga / chapter URL.
final sourceForUrlProvider = Provider.family<MangaSource, String>(
  (ref, url) => sourceForUrl(url),
);

/// The local [AppDatabase].
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

/// High-level local data access.
final repositoryProvider = Provider<AppRepository>((ref) {
  return AppRepository(ref.watch(databaseProvider));
});

/// Streams the user's library items.
final libraryItemsProvider = StreamProvider<List<LibraryItem>>(
  (ref) => ref.watch(repositoryProvider).watchLibraryItems(),
);

/// Streams reading history.
final historyProvider = StreamProvider<List<ReadingHistoryData>>(
  (ref) => ref.watch(repositoryProvider).watchHistory(),
);

/// Streams download tasks.
final downloadsProvider = StreamProvider<List<DownloadTask>>(
  (ref) => ref.watch(repositoryProvider).watchDownloadTasks(),
);

/// Cached list of active-source genres (slug + name).
final genresProvider = FutureProvider<List<Genre>>(
  (ref) => ref.watch(activeSourceProvider).fetchGenres(),
);

/// Recent search history.
final searchHistoryProvider =
    AsyncNotifierProvider<SearchHistoryNotifier, List<SearchHistoryTableData>>(
  SearchHistoryNotifier.new,
);

/// User collections.
final collectionsProvider = FutureProvider<List<Collection>>(
  (ref) => ref.watch(repositoryProvider).getCollections(),
);

/// Items inside a specific collection.
final collectionItemsProvider =
    FutureProvider.family<List<CollectionItem>, int>((ref, id) {
  return ref.watch(repositoryProvider).getCollectionItems(id);
});

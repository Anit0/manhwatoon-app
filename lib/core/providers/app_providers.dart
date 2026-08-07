import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/search/search_history_provider.dart';
import '../../models/reader_models.dart';
import '../database/app_database.dart';
import '../database/app_repository.dart';
import '../network/site_api.dart';

/// Global [SiteApi] client (content source).
final siteApiProvider = Provider<SiteApi>((ref) => SiteApi());

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

/// Cached list of site genres (slug + name).
final genresProvider = FutureProvider<List<Genre>>(
  (ref) => ref.watch(siteApiProvider).fetchGenres(),
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

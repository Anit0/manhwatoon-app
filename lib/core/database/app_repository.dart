import 'package:drift/drift.dart';

import '../../models/manga.dart';
import 'app_database.dart';

/// High-level data access for everything stored locally.
class AppRepository {
  AppRepository(this._db);

  final AppDatabase _db;

  // ---------------------------------------------------------------------
  // Library
  // ---------------------------------------------------------------------

  Future<void> upsertLibraryItem(Manga manga, {LibraryStatus? status}) async {
    final existing = await (_db.select(_db.libraryItems)
          ..where((t) => t.mangaUrl.equals(manga.url)))
        .getSingleOrNull();
    await (_db.libraryItems.insertOnConflictUpdate(
      LibraryItemsCompanion.insert(
        mangaUrl: manga.url,
        title: manga.title,
        coverUrl: Value(manga.coverUrl),
        postId: Value(manga.postId),
        favorite: Value(existing?.favorite ?? false),
        bookmark: Value(existing?.bookmark ?? false),
        status: Value(status?.value ?? existing?.status),
        addedAt: Value(existing?.addedAt ?? DateTime.now()),
        lastReadAt: Value(existing?.lastReadAt),
        lastChapterTitle: Value(manga.latestChapterTitle),
        lastChapterUrl: Value(manga.latestChapterUrl),
        genres: Value(manga.genres.isNotEmpty ? manga.genres.join(',') : null),
        author: Value(manga.authors.isNotEmpty ? manga.authors.join(', ') : null),
        type: Value(manga.type),
        releaseYear: Value(manga.releaseYear),
        isAdult: Value(manga.isAdult),
      ),
    ));
  }

  Future<void> updateLibraryChapterProgress(String mangaUrl, Manga manga) async {
    await (_db.libraryItems.update()..where((t) => t.mangaUrl.equals(mangaUrl)))
        .write(
      LibraryItemsCompanion(
        lastChapterTitle: Value(manga.latestChapterTitle),
        lastChapterUrl: Value(manga.latestChapterUrl),
        lastReadAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setLibraryFlag(String mangaUrl, {bool? favorite, bool? bookmark}) async {
    await (_db.libraryItems.update()..where((t) => t.mangaUrl.equals(mangaUrl)))
        .write(LibraryItemsCompanion(
      favorite: favorite != null ? Value(favorite) : const Value.absent(),
      bookmark: bookmark != null ? Value(bookmark) : const Value.absent(),
    ));
  }

  Future<void> setLibraryStatus(String mangaUrl, LibraryStatus? status) async {
    await (_db.libraryItems.update()..where((t) => t.mangaUrl.equals(mangaUrl)))
        .write(LibraryItemsCompanion(
      status: Value(status?.value),
      lastReadAt: Value(DateTime.now()),
    ));
  }

  Future<void> removeFromLibrary(String mangaUrl) async {
    await (_db.delete(_db.libraryItems)..where((t) => t.mangaUrl.equals(mangaUrl)))
        .go();
  }

  Future<List<LibraryItem>> getLibraryItems() =>
      (_db.select(_db.libraryItems)
            ..orderBy([(t) => OrderingTerm(expression: t.addedAt, mode: OrderingMode.desc)]))
          .get();

  Future<LibraryItem?> getLibraryItem(String mangaUrl) =>
      (_db.select(_db.libraryItems)..where((t) => t.mangaUrl.equals(mangaUrl)))
          .getSingleOrNull();

  Stream<List<LibraryItem>> watchLibraryItems() =>
      (_db.select(_db.libraryItems)..orderBy([(t) => OrderingTerm(expression: t.addedAt, mode: OrderingMode.desc)]))
          .watch();

  // ---------------------------------------------------------------------
  // Collections
  // ---------------------------------------------------------------------

  Future<int> createCollection(String name, {String? description}) {
    return _db
        .into(_db.collections)
        .insert(CollectionsCompanion.insert(
          name: name,
          description: Value(description),
        ));
  }

  Future<void> renameCollection(int id, String name) async {
    await (_db.collections.update()..where((t) => t.id.equals(id)))
        .write(CollectionsCompanion(name: Value(name)));
  }

  Future<void> deleteCollection(int id) async {
    await (_db.delete(_db.collectionItems)..where((t) => t.collectionId.equals(id)))
        .go();
    await (_db.delete(_db.collections)..where((t) => t.id.equals(id))).go();
  }

  Future<List<Collection>> getCollections() =>
      (_db.select(_db.collections)..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();

  Future<bool> isInCollection(int collectionId, String mangaUrl) async {
    final row = await (_db.select(_db.collectionItems)
          ..where((t) =>
              t.collectionId.equals(collectionId) & t.mangaUrl.equals(mangaUrl)))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> addToCollection(int collectionId, Manga manga) async {
    await (_db.collectionItems.insertOnConflictUpdate(
      CollectionItemsCompanion.insert(
        collectionId: collectionId,
        mangaUrl: manga.url,
        title: manga.title,
        coverUrl: Value(manga.coverUrl),
      ),
    ));
  }

  Future<void> removeFromCollection(int collectionId, String mangaUrl) async {
    await (_db.delete(_db.collectionItems)
          ..where((t) =>
              t.collectionId.equals(collectionId) & t.mangaUrl.equals(mangaUrl)))
        .go();
  }

  Future<List<CollectionItem>> getCollectionItems(int collectionId) =>
      (_db.select(_db.collectionItems)..where((t) => t.collectionId.equals(collectionId)))
          .get();

  // ---------------------------------------------------------------------
  // Tags
  // ---------------------------------------------------------------------

  Future<int> createTag(String name, {String? color}) {
    return _db.into(_db.tags).insert(TagsCompanion.insert(name: name, color: Value(color)));
  }

  Future<void> deleteTag(int id) async {
    await (_db.delete(_db.mangaTags)..where((t) => t.tagId.equals(id))).go();
    await (_db.delete(_db.tags)..where((t) => t.id.equals(id))).go();
  }

  Future<List<Tag>> getTags() => _db.select(_db.tags).get();

  Future<List<MangaTag>> getMangaTags(String mangaUrl) =>
      (_db.select(_db.mangaTags)..where((t) => t.mangaUrl.equals(mangaUrl))).get();

  Future<void> tagManga(int tagId, String mangaUrl) async {
    await _db.into(_db.mangaTags).insert(
          MangaTagsCompanion.insert(tagId: tagId, mangaUrl: mangaUrl),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> untagManga(int tagId, String mangaUrl) async {
    await (_db.delete(_db.mangaTags)
          ..where((t) => t.tagId.equals(tagId) & t.mangaUrl.equals(mangaUrl)))
        .go();
  }

  // ---------------------------------------------------------------------
  // Reading history
  // ---------------------------------------------------------------------

  Future<void> recordReadingProgress({
    required String mangaUrl,
    required String mangaTitle,
    String? coverUrl,
    required String chapterUrl,
    required String chapterTitle,
    required int pageIndex,
    required int totalPages,
  }) async {
    await (_db.readingHistory.insertOnConflictUpdate(
      ReadingHistoryCompanion.insert(
        mangaUrl: mangaUrl,
        mangaTitle: mangaTitle,
        coverUrl: Value(coverUrl),
        chapterUrl: chapterUrl,
        chapterTitle: chapterTitle,
        pageIndex: Value(pageIndex),
        totalPages: Value(totalPages),
        readAt: Value(DateTime.now()),
      ),
    ));
  }

  Future<void> recordReadingSession({
    required String mangaUrl,
    required String chapterUrl,
    required DateTime sessionDate,
    required int durationSeconds,
    required int pagesRead,
    required int pagesTotal,
  }) async {
    await _db.into(_db.readingSessions).insert(
          ReadingSessionsCompanion.insert(
            mangaUrl: mangaUrl,
            chapterUrl: chapterUrl,
            sessionDate: sessionDate,
            durationSeconds: Value(durationSeconds),
            pagesRead: Value(pagesRead),
            pagesTotal: Value(pagesTotal),
          ),
        );
  }

  Future<List<ReadingHistoryData>> getHistory({int limit = 100}) async {
    final query = _db.select(_db.readingHistory)
      ..orderBy([(t) => OrderingTerm(expression: t.readAt, mode: OrderingMode.desc)])
      ..limit(limit);
    return query.get();
  }

  Stream<List<ReadingHistoryData>> watchHistory() {
    final query = _db.select(_db.readingHistory)
      ..orderBy([(t) => OrderingTerm(expression: t.readAt, mode: OrderingMode.desc)]);
    return query.watch();
  }

  Future<void> clearHistory() => _db.delete(_db.readingHistory).go();

  // ---------------------------------------------------------------------
  // Downloads
  // ---------------------------------------------------------------------

  Future<int> insertDownload({
    required String mangaUrl,
    required String mangaTitle,
    required String mangaSlug,
    required String chapterUrl,
    required String chapterTitle,
    required String chapterSlug,
    required int totalPages,
    bool autoNext = false,
    String? directory,
  }) {
    return _db.into(_db.downloadTasks).insert(
          DownloadTasksCompanion.insert(
            mangaUrl: mangaUrl,
            mangaTitle: mangaTitle,
            mangaSlug: mangaSlug,
            chapterUrl: chapterUrl,
            chapterTitle: chapterTitle,
            chapterSlug: chapterSlug,
            totalPages: Value(totalPages),
            state: 'queued',
            autoNext: Value(autoNext),
            directory: Value(directory),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<DownloadTask?> getDownloadTask(String chapterUrl) =>
      (_db.select(_db.downloadTasks)..where((t) => t.chapterUrl.equals(chapterUrl)))
          .getSingleOrNull();

  Future<List<DownloadTask>> getDownloadTasks() =>
      (_db.select(_db.downloadTasks)..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
          .get();

  Stream<List<DownloadTask>> watchDownloadTasks() {
    final query = _db.select(_db.downloadTasks)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]);
    return query.watch();
  }

  Future<void> updateDownloadState(
    String chapterUrl, {
    String? state,
    int? downloadedPages,
    int? bytesReceived,
    int? bytesTotal,
    int? totalPages,
    String? error,
    String? directory,
  }) async {
    await (_db.downloadTasks.update()..where((t) => t.chapterUrl.equals(chapterUrl)))
        .write(DownloadTasksCompanion(
      state: state != null ? Value(state) : const Value.absent(),
      downloadedPages:
          downloadedPages != null ? Value(downloadedPages) : const Value.absent(),
      bytesReceived: bytesReceived != null ? Value(bytesReceived) : const Value.absent(),
      bytesTotal: bytesTotal != null ? Value(bytesTotal) : const Value.absent(),
      totalPages: totalPages != null ? Value(totalPages) : const Value.absent(),
      error: error != null ? Value(error) : const Value.absent(),
      directory: directory != null ? Value(directory) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> deleteDownload(String chapterUrl) async {
    await (_db.delete(_db.downloadTasks)..where((t) => t.chapterUrl.equals(chapterUrl)))
        .go();
  }

  Future<void> clearCompletedDownloads() async {
    await (_db.delete(_db.downloadTasks)..where((t) => t.state.equals('completed')))
        .go();
  }

  /// Total bytes downloaded across all tasks (approximate storage usage).
  Future<int> totalDownloadedBytes() async {
    final rows = await _db.select(_db.downloadTasks).get();
    var total = 0;
    for (final r in rows) {
      if (r.state == 'completed') total += r.bytesReceived;
    }
    return total;
  }

  // ---------------------------------------------------------------------
  // Search history
  // ---------------------------------------------------------------------

  Future<void> addSearchTerm(String term) async {
    final t = term.trim();
    if (t.isEmpty) return;
    await _db.into(_db.searchHistoryTable).insert(
          SearchHistoryTableCompanion.insert(term: t),
        );
  }

  Future<List<SearchHistoryTableData>> getRecentSearches({int limit = 20}) {
    final query = _db.select(_db.searchHistoryTable)
      ..orderBy([(t) => OrderingTerm(expression: t.searchedAt, mode: OrderingMode.desc)])
      ..limit(limit);
    return query.get();
  }

  Future<List<SearchHistoryTableData>> getTrendingSearches({int limit = 10}) async {
    final rows = await _db.select(_db.searchHistoryTable).get();
    final counts = <String, int>{};
    for (final r in rows) {
      counts[r.term] = (counts[r.term] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted
        .take(limit)
        .map((e) => SearchHistoryTableData(
              id: 0,
              term: e.key,
              searchedAt: DateTime.now(),
            ))
        .toList();
  }

  Future<void> clearSearchHistory() => _db.delete(_db.searchHistoryTable).go();

  // ---------------------------------------------------------------------
  // Statistics
  // ---------------------------------------------------------------------

  Future<List<ReadingSession>> getReadingSessions({
    DateTime? from,
    DateTime? to,
  }) {
    final query = _db.select(_db.readingSessions);
    if (from != null) query.where((t) => t.sessionDate.isBiggerOrEqualValue(from));
    if (to != null) query.where((t) => t.sessionDate.isSmallerThanValue(to));
    return query.get();
  }

  Future<List<ReadingSession>> getReadingSessionsForManga(String mangaUrl) =>
      (_db.select(_db.readingSessions)..where((t) => t.mangaUrl.equals(mangaUrl)))
          .get();
}

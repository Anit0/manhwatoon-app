import 'dart:convert';

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

  // ---------------------------------------------------------------------
  // Library backup / restore
  // ---------------------------------------------------------------------

  /// Serializes library + collections + history + tags into a JSON document
  /// that can be re-imported on this or another device.
  Future<String> exportLibraryJson() async {
    final library = await (_db.select(_db.libraryItems)).get();
    final collections = await (_db.select(_db.collections)).get();
    final history = await (_db.select(_db.readingHistory)).get();
    final tags = await (_db.select(_db.tags)).get();
    final mangaTags = await (_db.select(_db.mangaTags)).get();

    final collectionItems = <Map<String, dynamic>>[];
    for (final c in collections) {
      final items = await (_db.select(_db.collectionItems)
            ..where((t) => t.collectionId.equals(c.id)))
          .get();
      collectionItems.add({
        'collectionId': c.id,
        'items': [
          for (final i in items)
            {
              'mangaUrl': i.mangaUrl,
              'title': i.title,
              'coverUrl': i.coverUrl,
              'addedAt': i.addedAt.toIso8601String(),
            },
        ],
      });
    }

    String? iso(DateTime? d) => d?.toIso8601String();

    return jsonEncode({
      'app': 'ManhwaToon',
      'format': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'library': [
        for (final l in library)
          {
            'mangaUrl': l.mangaUrl,
            'title': l.title,
            'coverUrl': l.coverUrl,
            'postId': l.postId,
            'favorite': l.favorite,
            'bookmark': l.bookmark,
            'status': l.status,
            'addedAt': iso(l.addedAt),
            'lastReadAt': iso(l.lastReadAt),
            'lastChapterTitle': l.lastChapterTitle,
            'lastChapterUrl': l.lastChapterUrl,
            'genres': l.genres,
            'author': l.author,
            'type': l.type,
            'releaseYear': l.releaseYear,
            'isAdult': l.isAdult,
          },
      ],
      'collections': [
        for (final c in collections)
          {
            'id': c.id,
            'name': c.name,
            'description': c.description,
            'createdAt': iso(c.createdAt),
            'sortOrder': c.sortOrder,
          },
      ],
      'collectionItems': collectionItems,
      'history': [
        for (final h in history)
          {
            'mangaUrl': h.mangaUrl,
            'mangaTitle': h.mangaTitle,
            'coverUrl': h.coverUrl,
            'chapterUrl': h.chapterUrl,
            'chapterTitle': h.chapterTitle,
            'pageIndex': h.pageIndex,
            'totalPages': h.totalPages,
            'readAt': iso(h.readAt),
          },
      ],
      'tags': [
        for (final t in tags)
          {
            'id': t.id,
            'name': t.name,
            'color': t.color,
            'mangaUrls': [
              for (final mt in mangaTags.where((mt) => mt.tagId == t.id)) mt.mangaUrl,
            ],
          },
      ],
    });
  }

  /// Imports a backup produced by [exportLibraryJson].
  ///
  /// Library items and history are upserted (existing entries are updated, not
  /// duplicated). Collections and tags are recreated under new ids.
  Future<LibraryImportResult> importLibraryJson(String json) async {
    final decoded = jsonDecode(json);
    if (decoded is! Map) {
      throw const FormatException('Backup file is not a valid object');
    }

    var libraryCount = 0;
    var collectionCount = 0;
    var collectionItemCount = 0;
    var historyCount = 0;
    var tagCount = 0;

    await _db.transaction(() async {
      final libraryRaw = decoded['library'];
      if (libraryRaw is List) {
        for (final raw in libraryRaw) {
          if (raw is! Map) continue;
          final mangaUrl = raw['mangaUrl'];
          final title = raw['title'];
          if (mangaUrl is! String || title is! String) continue;
          final existing = await (_db.select(_db.libraryItems)
                ..where((t) => t.mangaUrl.equals(mangaUrl)))
              .getSingleOrNull();
          await _db.libraryItems.insertOnConflictUpdate(
            LibraryItemsCompanion.insert(
              mangaUrl: mangaUrl,
              title: title,
              coverUrl: Value(raw['coverUrl'] as String?),
              postId: Value(raw['postId'] as int?),
              favorite: Value(raw['favorite'] as bool? ?? existing?.favorite ?? false),
              bookmark: Value(raw['bookmark'] as bool? ?? existing?.bookmark ?? false),
              status: Value(raw['status'] as String?),
              addedAt: Value(DateTime.tryParse(raw['addedAt'] as String? ?? '') ??
                  DateTime.now()),
              lastReadAt: Value(DateTime.tryParse(raw['lastReadAt'] as String? ?? '')),
              lastChapterTitle: Value(raw['lastChapterTitle'] as String?),
              lastChapterUrl: Value(raw['lastChapterUrl'] as String?),
              genres: Value(raw['genres'] as String?),
              author: Value(raw['author'] as String?),
              type: Value(raw['type'] as String?),
              releaseYear: Value(raw['releaseYear'] as String?),
              isAdult: Value(raw['isAdult'] as bool? ?? false),
            ),
          );
          libraryCount++;
        }
      }

      // Collections are re-created so their auto-increment ids stay valid.
      final idMap = <int, int>{};
      final collectionsRaw = decoded['collections'];
      if (collectionsRaw is List) {
        for (final raw in collectionsRaw) {
          if (raw is! Map) continue;
          final name = raw['name'];
          if (name is! String || name.isEmpty) continue;
          final oldId = raw['id'] as int?;
          final id = await _db.into(_db.collections).insert(
                CollectionsCompanion.insert(
                  name: name,
                  description: Value(raw['description'] as String?),
                  sortOrder: Value(raw['sortOrder'] as int? ?? 0),
                ),
              );
          if (oldId != null) idMap[oldId] = id;
          collectionCount++;
        }
      }

      final itemsRaw = decoded['collectionItems'];
      if (itemsRaw is List) {
        for (final group in itemsRaw) {
          if (group is! Map) continue;
          final oldCollectionId = group['collectionId'] as int?;
          final newCollectionId = oldCollectionId != null ? idMap[oldCollectionId] : null;
          final items = group['items'];
          if (newCollectionId == null || items is! List) continue;
          for (final raw in items) {
            if (raw is! Map) continue;
            final mangaUrl = raw['mangaUrl'];
            final title = raw['title'];
            if (mangaUrl is! String || title is! String) continue;
            await _db.collectionItems.insertOnConflictUpdate(
              CollectionItemsCompanion.insert(
                collectionId: newCollectionId,
                mangaUrl: mangaUrl,
                title: title,
                coverUrl: Value(raw['coverUrl'] as String?),
              ),
            );
            collectionItemCount++;
          }
        }
      }

      final historyRaw = decoded['history'];
      if (historyRaw is List) {
        for (final raw in historyRaw) {
          if (raw is! Map) continue;
          final mangaUrl = raw['mangaUrl'];
          final mangaTitle = raw['mangaTitle'];
          final chapterUrl = raw['chapterUrl'];
          if (mangaUrl is! String ||
              mangaTitle is! String ||
              chapterUrl is! String) {
            continue;
          }
          await _db.readingHistory.insertOnConflictUpdate(
            ReadingHistoryCompanion.insert(
              mangaUrl: mangaUrl,
              mangaTitle: mangaTitle,
              coverUrl: Value(raw['coverUrl'] as String?),
              chapterUrl: chapterUrl,
              chapterTitle: raw['chapterTitle'] as String? ?? '',
              pageIndex: Value(raw['pageIndex'] as int? ?? 0),
              totalPages: Value(raw['totalPages'] as int? ?? 0),
            ),
          );
          historyCount++;
        }
      }

      final tagsRaw = decoded['tags'];
      if (tagsRaw is List) {
        for (final raw in tagsRaw) {
          if (raw is! Map) continue;
          final name = raw['name'];
          if (name is! String || name.isEmpty) continue;
          final existingTag = await (_db.select(_db.tags)
                ..where((t) => t.name.equals(name)))
              .getSingleOrNull();
          final tagId = existingTag?.id ??
              await _db.into(_db.tags).insert(
                    TagsCompanion.insert(
                      name: name,
                      color: Value(raw['color'] as String?),
                    ),
                  );
          final mangaUrls = raw['mangaUrls'];
          if (mangaUrls is List) {
            for (final url in mangaUrls) {
              if (url is! String || url.isEmpty) continue;
              await _db.into(_db.mangaTags).insert(
                MangaTagsCompanion.insert(tagId: tagId, mangaUrl: url),
                mode: InsertMode.insertOrIgnore,
              );
            }
          }
          tagCount++;
        }
      }
    });

    return LibraryImportResult(
      library: libraryCount,
      collections: collectionCount,
      collectionItems: collectionItemCount,
      history: historyCount,
      tags: tagCount,
    );
  }
}

/// Summary of what an [importLibraryJson] actually changed.
class LibraryImportResult {
  const LibraryImportResult({
    required this.library,
    required this.collections,
    required this.collectionItems,
    required this.history,
    required this.tags,
  });

  final int library;
  final int collections;
  final int collectionItems;
  final int history;
  final int tags;
}

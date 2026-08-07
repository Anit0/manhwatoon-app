import 'package:drift/drift.dart';

/// Manga added to the user's library.
class LibraryItems extends Table {
  TextColumn get mangaUrl => text()();
  TextColumn get title => text()();
  TextColumn get coverUrl => text().nullable()();
  IntColumn get postId => integer().nullable()();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  BoolColumn get bookmark => boolean().withDefault(const Constant(false))();

  /// LibraryStatus value (plan/reading/completed/dropped) or null.
  TextColumn get status => text().nullable()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastReadAt => dateTime().nullable()();
  TextColumn get lastChapterTitle => text().nullable()();
  TextColumn get lastChapterUrl => text().nullable()();
  TextColumn get genres => text().nullable()();
  TextColumn get author => text().nullable()();
  TextColumn get type => text().nullable()();
  TextColumn get releaseYear => text().nullable()();
  BoolColumn get isAdult => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {mangaUrl};
}

/// User created collections.
class Collections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Manga belonging to a collection.
class CollectionItems extends Table {
  IntColumn get collectionId => integer().references(Collections, #id)();
  TextColumn get mangaUrl => text()();
  TextColumn get title => text()();
  TextColumn get coverUrl => text().nullable()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {collectionId, mangaUrl};
}

/// User defined tags.
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get color => text().nullable()();
}

/// Manga tagged by the user.
class MangaTags extends Table {
  IntColumn get tagId => integer().references(Tags, #id)();
  TextColumn get mangaUrl => text()();

  @override
  Set<Column> get primaryKey => {tagId, mangaUrl};
}

/// Reading history, one row per manga (latest progress wins).
class ReadingHistory extends Table {
  TextColumn get mangaUrl => text()();
  TextColumn get mangaTitle => text()();
  TextColumn get coverUrl => text().nullable()();
  TextColumn get chapterUrl => text()();
  TextColumn get chapterTitle => text()();
  IntColumn get pageIndex => integer().withDefault(const Constant(0))();
  IntColumn get totalPages => integer().withDefault(const Constant(0))();
  DateTimeColumn get readAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {mangaUrl};
}

/// Individual reading sessions used for statistics.
class ReadingSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mangaUrl => text()();
  TextColumn get chapterUrl => text()();
  DateTimeColumn get sessionDate => dateTime()();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  IntColumn get pagesRead => integer().withDefault(const Constant(0))();
  IntColumn get pagesTotal => integer().withDefault(const Constant(0))();
}

/// Download queue / status, one row per chapter.
class DownloadTasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mangaUrl => text()();
  TextColumn get mangaTitle => text()();
  TextColumn get mangaSlug => text()();
  TextColumn get chapterUrl => text().unique()();
  TextColumn get chapterTitle => text()();
  TextColumn get chapterSlug => text()();
  IntColumn get totalPages => integer().withDefault(const Constant(0))();
  IntColumn get downloadedPages => integer().withDefault(const Constant(0))();

  /// queued | downloading | paused | error | completed | cancelled
  TextColumn get state => text()();
  IntColumn get bytesReceived => integer().withDefault(const Constant(0))();
  IntColumn get bytesTotal => integer().withDefault(const Constant(0))();
  TextColumn get error => text().nullable()();
  TextColumn get directory => text().nullable()();
  BoolColumn get autoNext => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Recent search terms.
class SearchHistoryTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get term => text()();
  DateTimeColumn get searchedAt => dateTime().withDefault(currentDateAndTime)();
}

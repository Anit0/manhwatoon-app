import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// Application database. Owns all locally persisted state: library,
/// collections, tags, history, reading sessions, downloads and searches.
@DriftDatabase(
  tables: [
    LibraryItems,
    Collections,
    CollectionItems,
    Tags,
    MangaTags,
    ReadingHistory,
    ReadingSessions,
    DownloadTasks,
    SearchHistoryTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'manhwa_toon');
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
      );
}

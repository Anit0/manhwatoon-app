import 'package:flutter/material.dart';

import '../../features/detail/manga_detail_screen.dart';
import '../../features/reader/reader_screen.dart';
import '../../models/manga.dart';

/// Central route navigation helper. Uses the plain Navigator API with
/// typed arguments so screens are easy to push from anywhere.
class AppRoutes {
  AppRoutes._();

  /// Pushes the manga detail screen.
  ///
  /// If a details page for the same manga is already on the stack, pops back
  /// to it instead of pushing a duplicate.
  static Future<void> openManga(BuildContext context, Manga manga,
      {String? heroTag}) {
    final navigator = Navigator.of(context);
    var found = false;
    navigator.popUntil((route) {
      final name = route.settings.name;
      if (name == mangaDetailName(manga.url)) {
        found = true;
        return true;
      }
      return route.isFirst;
    });
    if (found) return Future.value();
    return navigator.push(
      MaterialPageRoute(
        settings: RouteSettings(name: mangaDetailName(manga.url)),
        builder: (_) => MangaDetailScreen(manga: manga, heroTag: heroTag),
      ),
    );
  }

  static String mangaDetailName(String mangaUrl) => 'manga:$mangaUrl';

  /// Pushes the reader for a chapter.
  static Future<void> openReader(
    BuildContext context, {
    required Manga manga,
    required String chapterUrl,
    required String chapterTitle,
    String? initialMode,
    int initialPageIndex = 0,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReaderScreen(
          manga: manga,
          chapterUrl: chapterUrl,
          chapterTitle: chapterTitle,
          initialMode: initialMode,
          initialPageIndex: initialPageIndex,
        ),
      ),
    );
  }
}

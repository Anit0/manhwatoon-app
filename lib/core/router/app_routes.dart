import 'package:flutter/material.dart';

import '../../features/detail/manga_detail_screen.dart';
import '../../features/reader/reader_screen.dart';
import '../../models/manga.dart';

/// Central route navigation helper. Uses the plain Navigator API with
/// typed arguments so screens are easy to push from anywhere.
class AppRoutes {
  AppRoutes._();

  /// Pushes the manga detail screen.
  static Future<void> openManga(BuildContext context, Manga manga,
      {String? heroTag}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MangaDetailScreen(manga: manga, heroTag: heroTag),
      ),
    );
  }

  /// Pushes the reader for a chapter.
  static Future<void> openReader(
    BuildContext context, {
    required Manga manga,
    required String chapterUrl,
    required String chapterTitle,
    String? initialMode,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReaderScreen(
          manga: manga,
          chapterUrl: chapterUrl,
          chapterTitle: chapterTitle,
          initialMode: initialMode,
        ),
      ),
    );
  }
}

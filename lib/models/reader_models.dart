/// Domain models shared across the app.
library;

import 'package:flutter/foundation.dart';

import 'chapter.dart';
import 'manga.dart';

/// A single image page of a chapter inside the reader.
@immutable
class MangaPage {
  const MangaPage({
    required this.index,
    required this.imageUrl,
    required this.chapterUrl,
  });

  /// 0-based position within the chapter.
  final int index;
  final String imageUrl;
  final String chapterUrl;
}

/// Lightweight suggestion returned by the site autocomplete API.
@immutable
class SearchSuggestion {
  const SearchSuggestion({
    required this.title,
    required this.url,
    this.type,
  });

  final String title;
  final String url;
  final String? type;
}

/// A genre category with its slug used for filtering.
@immutable
class Genre {
  const Genre({required this.name, required this.slug});

  final String name;
  final String slug;
}

/// Result of fetching a manga detail page.
@immutable
class MangaDetailResult {
  const MangaDetailResult({
    required this.manga,
    required this.chapters,
  });

  final Manga manga;
  final List<Chapter> chapters;
}

/// Reader navigation direction / layout mode.
enum ReaderMode {
  /// Continuous vertical scrolling (webtoon style).
  webtoon('webtoon', 'Webtoon'),

  /// Paginated left-to-right pages.
  ltr('ltr', 'Left to Right'),

  /// Paginated right-to-left pages (manga style).
  rtl('rtl', 'Right to Left');

  const ReaderMode(this.value, this.label);
  final String value;
  final String label;

  static ReaderMode fromValue(String? value) {
    return ReaderMode.values.firstWhere(
      (m) => m.value == value,
      orElse: () => ReaderMode.webtoon,
    );
  }
}

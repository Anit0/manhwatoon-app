import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../models/manga.dart';
import '../../models/reader_models.dart';

/// A content provider the app can read manga from.
///
/// Each source knows how to list, search, open details and stream chapter
/// pages for the manga hosted on its own domain. The rest of the app is
/// source-agnostic: it browses the currently selected source and always
/// resolves details / reader / downloads back to the source that owns a URL.
abstract class MangaSource {
  /// Stable identifier used for persistence, e.g. `manhwatoon`.
  String get id;

  /// Display name, e.g. `ManhwaToon`.
  String get name;

  /// Root URL of the source, e.g. `https://www.manhwatoon.me`.
  String get baseUrl;

  /// Fetches the homepage "hot / popular" slider manga.
  Future<List<Manga>> fetchHomeSlider({bool useCache = true});

  /// Fetches the homepage "latest manga updates" grid.
  Future<List<Manga>> fetchHomeLatest({bool useCache = true});

  /// Fetches the manga archive with the given sort order and page.
  Future<List<Manga>> fetchArchive(
    SortOrder order, {
    int page = 1,
    String? genreSlug,
    bool useCache = true,
  });

  /// Live search suggestions (autocomplete).
  Future<List<SearchSuggestion>> searchSuggestions(String query);

  /// Full text search results with optional genre/status filters.
  Future<List<Manga>> search(
    String query, {
    int page = 1,
    String? genreSlug,
    String? status,
    SortOrder? order,
  });

  /// Fetches full manga detail (metadata + chapter list).
  Future<MangaDetailResult> fetchMangaDetail(String url);

  /// Fetches the ordered page images for a chapter.
  Future<List<MangaPage>> fetchReadingPages(String chapterUrl);

  /// Fetches next / previous chapter links for a chapter page.
  Future<({String? prevUrl, String? nextUrl})> fetchChapterNav(
    String chapterUrl,
  );

  /// Returns the source genre list (slug + display name).
  Future<List<Genre>> fetchGenres();

  /// Downloads raw bytes of an image from the source CDN.
  Future<Response<Uint8List>> downloadImageBytes(String url);

  /// Clears any in-memory caches owned by this source.
  void clearCache();
}

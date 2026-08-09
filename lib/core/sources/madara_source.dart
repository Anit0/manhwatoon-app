import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../models/manga.dart';
import '../../models/reader_models.dart';
import '../constants/app_constants.dart';
import '../network/madara_parser.dart';
import '../network/scraper_health.dart';
import 'manga_source.dart';

/// Thrown when a network call fails.
class SiteApiException implements Exception {
  const SiteApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// A WordPress/Madara-based manga source.
///
/// Most manga/manhwa/manhua sites run the Madara theme, so a single parser
/// plus a configurable base URL is enough to add new sources. Responses are
/// cached in memory for a short TTL so that repeated navigation is fast.
class MadaraSource implements MangaSource {
  MadaraSource({
    required this.id,
    required this.name,
    required this.baseUrl,
    this.genrePathPrefix = '/manhwa-genre/',
    Dio? dio,
  }) : _dio = dio ?? _defaultDio(baseUrl);

  @override
  final String id;

  @override
  final String name;

  @override
  final String baseUrl;

  /// Path prefix used for genre archive URLs, e.g. `/manhwa-genre/` or
  /// `/manga-genre/`. Differs between Madara deployments.
  final String genrePathPrefix;

  final Dio _dio;

  /// In-memory HTML cache (url -> (timestamp, body)).
  final Map<String, ({DateTime at, String body})> _htmlCache = {};

  static Dio _defaultDio(String baseUrl) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'User-Agent': AppConstants.userAgent,
        'Accept-Language': 'en-US,en;q=0.9',
      },
      connectTimeout: AppConstants.networkTimeout,
      receiveTimeout: AppConstants.networkTimeout,
      sendTimeout: AppConstants.networkTimeout,
    ));
    return dio;
  }

  @override
  void clearCache() => _htmlCache.clear();

  Future<String> _getHtml(String url, {bool useCache = true}) async {
    if (useCache) {
      final cached = _htmlCache[url];
      if (cached != null &&
          DateTime.now().difference(cached.at) < AppConstants.htmlCacheTtl) {
        return cached.body;
      }
    }
    try {
      final response = await _dio
          .get<String>(url)
          .timeout(AppConstants.networkTimeout);
      final body = response.data ?? '';
      _htmlCache[url] = (at: DateTime.now(), body: body);
      return body;
    } on DioException catch (e) {
      throw SiteApiException(
        'Failed to load ${_shortUrl(url)}: ${e.message ?? 'network error'}',
        statusCode: e.response?.statusCode,
      );
    } on TimeoutException {
      throw SiteApiException('Timed out loading ${_shortUrl(url)}');
    }
  }

  Future<String> _postForm(
    String url,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio
          .post<String>(
            url,
            data: data,
            options: Options(
              headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            ),
          )
          .timeout(AppConstants.networkTimeout);
      return response.data ?? '';
    } on DioException catch (e) {
      throw SiteApiException(
        'Failed to load ${_shortUrl(url)}: ${e.message ?? 'network error'}',
        statusCode: e.response?.statusCode,
      );
    } on TimeoutException {
      throw SiteApiException('Timed out loading ${_shortUrl(url)}');
    }
  }

  @override
  Future<List<Manga>> fetchHomeSlider({bool useCache = true}) async {
    final html = await _getHtml('/', useCache: useCache);
    final result = MadaraParser.parseSlider(html);
    _warnIfEmpty('homeSlider', result);
    return result;
  }

  @override
  Future<List<Manga>> fetchHomeLatest({bool useCache = true}) async {
    final html = await _getHtml('/', useCache: useCache);
    final result = MadaraParser.parseMangaGrid(html);
    _warnIfEmpty('homeLatest', result);
    return result;
  }

  @override
  Future<List<Manga>> fetchArchive(
    SortOrder order, {
    int page = 1,
    String? genreSlug,
    bool useCache = true,
  }) async {
    final base = genreSlug != null
        ? '$baseUrl$genrePathPrefix$genreSlug/'
        : '$baseUrl/manga/';
    // The site 301-redirects `page=1` (dropping the param), so only add it
    // for subsequent pages to avoid a wasted round trip.
    final pageParam = page > 1 ? '&page=$page' : '';
    final url = '$base?m_orderby=${order.query}$pageParam';
    final html = await _getHtml(url, useCache: useCache);
    final result = MadaraParser.parseMangaGrid(html);
    _warnIfEmpty('archiveGrid', result);
    return result;
  }

  @override
  Future<List<SearchSuggestion>> searchSuggestions(String query) async {
    if (query.trim().isEmpty) return const [];
    final body = await _postForm(
      '$baseUrl/wp-admin/admin-ajax.php',
      {
        'action': 'wp-manga-search-manga',
        'title': query.trim(),
      },
    );
    try {
      final decoded = _jsonDecode(body);
      if (decoded is! Map || decoded['success'] != true) return const [];
      final data = decoded['data'];
      if (data is! List) return const [];
      return data
          .map((e) {
            if (e is! Map) return null;
            return SearchSuggestion(
              title: e['title']?.toString() ?? '',
              url: e['url']?.toString() ?? '',
              type: e['type']?.toString(),
            );
          })
          .whereType<SearchSuggestion>()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<Manga>> search(
    String query, {
    int page = 1,
    String? genreSlug,
    String? status,
    SortOrder? order,
  }) async {
    final uri = Uri.parse('$baseUrl/').replace(queryParameters: {
      's': query,
      'post_type': 'wp-manga',
      'page': '$page',
      if (genreSlug != null && genreSlug.isNotEmpty) 'm_genre': genreSlug,
      if (status != null && status.isNotEmpty) 'm_status': status.toLowerCase(),
      if (order != null) 'm_orderby': order.query,
    });
    final html = await _getHtml(uri.toString());
    final result = MadaraParser.parseSearchResults(html);
    _warnIfEmpty('searchResults', result);
    return result;
  }

  @override
  Future<MangaDetailResult> fetchMangaDetail(String url) async {
    final html = await _getHtml(url);
    final manga = MadaraParser.parseDetail(html);
    if (manga.title.isEmpty) _warnIfEmpty('detail', [manga]);

    // Resolve chapter list.
    final postId = manga.postId;
    if (postId != null) {
      final chapterBody = await _postForm(
        '${url.endsWith('/') ? url : '$url/'}ajax/chapters/',
        {'manga_id': '$postId'},
      );
      final chapters = MadaraParser.parseChapterList(chapterBody);
      _warnIfEmpty('chapterList', chapters);
      return MangaDetailResult(manga: manga, chapters: chapters);
    }
    return MangaDetailResult(manga: manga, chapters: const []);
  }

  @override
  Future<List<MangaPage>> fetchReadingPages(String chapterUrl) async {
    final html = await _getHtml(chapterUrl, useCache: false);
    final pages = MadaraParser.parseReadingPages(html, chapterUrl: chapterUrl);
    _warnIfEmpty('readingPages', pages);
    return pages;
  }

  @override
  Future<({String? prevUrl, String? nextUrl})> fetchChapterNav(
      String chapterUrl) async {
    final html = await _getHtml(chapterUrl, useCache: false);
    return MadaraParser.parseChapterNav(html);
  }

  @override
  Future<List<Genre>> fetchGenres() async {
    final html = await _getHtml('$baseUrl/manga/');
    return MadaraParser.parseGenres(html, genrePath: genrePathPrefix);
  }

  @override
  Future<Response<Uint8List>> downloadImageBytes(String url) async {
    final response = await _dio
        .get<List<int>>(
          url,
          options: Options(
            responseType: ResponseType.bytes,
            headers: {'Referer': '$baseUrl/'},
          ),
        )
        .timeout(const Duration(seconds: 30));
    final bytes = response.data == null ? Uint8List(0) : Uint8List.fromList(response.data!);
    return Response<Uint8List>(
      requestOptions: response.requestOptions,
      data: bytes,
      headers: response.headers,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      isRedirect: response.isRedirect,
      redirects: response.redirects,
      extra: response.extra,
    );
  }

  dynamic _jsonDecode(String body) => jsonDecode(body);

  /// Flags a parser that came back empty after a successful HTTP call, so
  /// upstream markup changes surface early instead of as silent empty screens.
  void _warnIfEmpty<T>(String kind, List<T> items) {
    if (items.isEmpty) ScraperHealth.report(name, kind);
  }

  String _shortUrl(String url) {
    final uri = Uri.parse(url);
    return uri.path.isEmpty ? url : uri.path;
  }
}

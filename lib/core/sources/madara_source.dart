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
    this.archivePath = '/manga/',
    this.seriesPathPrefix,
    this.liveSearchPath,
    this.coverCdn,
    this.imageHosts = const [],
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

  /// Path prefix used for the manga archive listing, e.g. `/manga/`. Most
  /// Madara sites use `/manga/`, but some expose the archive at a custom
  /// post-type path such as `/manhwa/`.
  final String archivePath;

  /// Path prefix for series pages. Defaults to [archivePath]. TopManhua lists
  /// the archive at `/manga/` but series live under `/manhua/`.
  final String? seriesPathPrefix;

  /// Alternate live-search endpoint (GET) used by forks that do not expose
  /// WordPress `admin-ajax.php`, e.g. TopManhua's `/manga/searching`.
  final String? liveSearchPath;

  /// Origin used to turn relative cover paths from [liveSearchPath] into
  /// absolute image URLs.
  final String? coverCdn;

  @override
  final List<String> imageHosts;

  String get _seriesPrefix {
    final raw = seriesPathPrefix ?? archivePath;
    var value = raw.trim();
    if (value.isEmpty) return '/manga/';
    if (!value.startsWith('/')) value = '/$value';
    if (!value.endsWith('/')) value = '$value/';
    return value;
  }

  final Dio _dio;

  /// In-memory HTML cache (url -> (timestamp, body)).
  final Map<String, ({DateTime at, String body})> _htmlCache = {};

  static Dio _defaultDio(String baseUrl) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'User-Agent': AppConstants.userAgent,
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
        'Referer': '$baseUrl/',
      },
      followRedirects: true,
      maxRedirects: 5,
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

  Future<dynamic> _getJson(String url) async {
    try {
      final response = await _dio
          .get<dynamic>(
            url,
            options: Options(
              responseType: ResponseType.json,
              headers: {
                'Accept': 'application/json, text/javascript, */*;q=0.1',
              },
            ),
          )
          .timeout(AppConstants.networkTimeout);
      final data = response.data;
      if (data is String) return _jsonDecode(data);
      return data;
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
        : '$baseUrl${archivePath.startsWith('/') ? archivePath : '/$archivePath'}';
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
    final livePath = liveSearchPath;
    if (livePath != null && livePath.isNotEmpty) {
      final live = await _liveSearch(query);
      return (live ?? const [])
          .map((m) => SearchSuggestion(title: m.title, url: m.url, type: 'manga'))
          .toList();
    }
    try {
      final body = await _postForm(
        '$baseUrl/wp-admin/admin-ajax.php',
        {
          'action': 'wp-manga-search-manga',
          'title': query.trim(),
        },
      );
      final decoded = _jsonDecode(body);
      return MadaraParser.parseSearchSuggestionApi(
        decoded,
        baseUrl: baseUrl,
        seriesPathPrefix: _seriesPrefix,
      );
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
    final term = query.trim();
    final params = <String, String>{
      's': term,
      'post_type': 'wp-manga',
      if (genreSlug != null && genreSlug.isNotEmpty) 'm_genre': genreSlug,
      if (status != null && status.isNotEmpty) 'm_status': status.toLowerCase(),
      if (order != null) 'm_orderby': order.query,
    };
    final path = page > 1 ? '$baseUrl/page/$page/' : '$baseUrl/';
    final uri = Uri.parse(path).replace(queryParameters: params);
    List<Manga> result = const [];
    SiteApiException? htmlError;
    try {
      final html = await _getHtml(uri.toString());
      result = MadaraParser.parseSearchResults(html);
    } on SiteApiException catch (e) {
      htmlError = e;
    }
    if (result.isEmpty && page == 1 && term.isNotEmpty) {
      final live = await _liveSearch(term);
      if (live != null && live.isNotEmpty) {
        result = live;
      } else if (htmlError != null && live == null) {
        throw htmlError;
      }
    }
    _warnIfEmpty('searchResults', result);
    return result;
  }

  /// Hits the source-specific live-search API when [liveSearchPath] is set.
  /// Returns `null` when the endpoint is unused or unavailable so callers can
  /// fall back to WordPress search.
  Future<List<Manga>?> _liveSearch(String query) async {
    final path = liveSearchPath;
    if (path == null || path.isEmpty) return null;
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: {'title': query.trim()},
    );
    try {
      final decoded = await _getJson(uri.toString());
      if (decoded is! Map || decoded['success'] != true) return const [];
      return MadaraParser.parseSearchApi(
        decoded,
        baseUrl: baseUrl,
        seriesPathPrefix: _seriesPrefix,
        coverCdn: coverCdn ??
            (imageHosts.isNotEmpty ? 'https://${imageHosts.first}' : null),
      );
    } on SiteApiException {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<MangaDetailResult> fetchMangaDetail(String url) async {
    final html = await _getHtml(url);
    final manga = MadaraParser.parseDetail(html);
    if (manga.title.isEmpty) _warnIfEmpty('detail', [manga]);

    // Some Madara forks (e.g. TopManhua) embed the full chapter list on the
    // detail page as `.wp-manga-chapter` and do not expose `/ajax/chapters/`.
    var chapters = MadaraParser.parseChapterList(html);
    if (chapters.isEmpty && manga.postId != null) {
      try {
        final chapterBody = await _postForm(
          '${url.endsWith('/') ? url : '$url/'}ajax/chapters/',
          {'manga_id': '${manga.postId}'},
        );
        chapters = MadaraParser.parseChapterList(chapterBody);
      } on SiteApiException {
        chapters = const [];
      }
    }
    _warnIfEmpty('chapterList', chapters);
    return MangaDetailResult(manga: manga, chapters: chapters);
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
    final html = await _getHtml(
      '$baseUrl${archivePath.startsWith('/') ? archivePath : '/$archivePath'}',
    );
    return MadaraParser.parseGenres(html, genrePath: genrePathPrefix);
  }

  @override
  Future<Response<Uint8List>> downloadImageBytes(String url) async {
    final response = await _dio
        .get<List<int>>(
          url,
          options: Options(
            responseType: ResponseType.bytes,
            headers: {
              'Referer': '$baseUrl/',
              'referer': '$baseUrl/',
              'User-Agent': AppConstants.userAgent,
            },
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

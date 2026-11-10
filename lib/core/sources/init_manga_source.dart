import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;

import '../../models/chapter.dart';
import '../../models/manga.dart';
import '../../models/reader_models.dart';
import '../constants/app_constants.dart';
import '../network/scraper_health.dart';
import 'madara_source.dart';
import 'manga_source.dart';

/// Init Manga / UIkit WordPress theme (mgread.io, formerly mangayy.org).
class InitMangaSource implements MangaSource {
  InitMangaSource({
    required this.id,
    required this.name,
    required this.baseUrl,
    this.imageHosts = const [],
    Dio? dio,
  }) : _dio = dio ?? _defaultDio(baseUrl);

  @override
  final String id;
  @override
  final String name;
  @override
  final String baseUrl;
  @override
  final List<String> imageHosts;

  @override
  bool get adultCatalog => false;

  final Dio _dio;

  static Dio _defaultDio(String baseUrl) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConstants.networkTimeout,
        receiveTimeout: AppConstants.networkTimeout,
        followRedirects: true,
        validateStatus: (code) => code != null && code >= 200 && code < 400,
        headers: {
          'User-Agent': AppConstants.userAgent,
          'Accept': 'application/json, text/html;q=0.8',
          'Referer': '$baseUrl/',
        },
      ),
    );
  }

  @override
  Future<List<Manga>> fetchHomeSlider({bool useCache = true}) =>
      fetchArchive(SortOrder.trending);

  @override
  Future<List<Manga>> fetchHomeLatest({bool useCache = true}) =>
      fetchArchive(SortOrder.latest);

  @override
  Future<List<Manga>> fetchArchive(
    SortOrder order, {
    int page = 1,
    String? genreSlug,
    bool useCache = true,
  }) async {
    final params = <String, dynamic>{
      'per_page': 20,
      'page': page,
      'order': order == SortOrder.alphabet ? 'asc' : 'desc',
      'orderby': switch (order) {
        SortOrder.alphabet => 'title',
        SortOrder.newManga => 'date',
        SortOrder.latest || SortOrder.trending => 'modified',
        _ => 'date',
      },
    };
    if (genreSlug != null && genreSlug.isNotEmpty) {
      params['genre'] = genreSlug;
    }
    List<dynamic> list = const [];
    try {
      list = await _getJsonList('/wp-json/wp/v2/manga', {
        ...params,
        '_embed': '1',
      });
    } on SiteApiException {
      list = const [];
    }
    if (list.isEmpty) {
      try {
        list = await _getJsonList('/wp-json/wp/v2/manga', {
          ...params,
          'orderby': 'date',
        });
      } on SiteApiException {
        list = const [];
      }
    }
    var result = list.map(_mangaFromRest).whereType<Manga>().toList();
    if (result.isEmpty) {
      result = await _listingFromHtml(page: page);
    }
    if (result.isEmpty) ScraperHealth.report(name, 'archiveGrid');
    return result;
  }

  Future<List<Manga>> _listingFromHtml({int page = 1}) async {
    final path = page > 1 ? '/manga/page/$page/' : '/manga/';
    try {
      final html = await _getHtml(path);
      final doc = html_parser.parse(html);
      final result = <Manga>[];
      final seen = <String>{};
      for (final a in doc.querySelectorAll('a[href]')) {
        final href = a.attributes['href'] ?? '';
        final uri = Uri.tryParse(href);
        if (uri == null) continue;
        final segs = uri.pathSegments.where((s) => s.isNotEmpty).toList();
        if (segs.length != 2 || segs.first != 'manga') continue;
        final url = href.split('#').first;
        if (!seen.add(url)) continue;
        final title = a.text.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (title.isEmpty || title.length > 200) continue;
        final img = a.querySelector('img') ?? a.parent?.querySelector('img');
        String? cover = img?.attributes['data-src'] ?? img?.attributes['src'];
        result.add(Manga(url: url, title: title, coverUrl: cover));
      }
      return result;
    } on SiteApiException {
      return const [];
    }
  }

  @override
  Future<List<SearchSuggestion>> searchSuggestions(String query) async {
    final manga = await search(query);
    return manga
        .map((m) => SearchSuggestion(title: m.title, url: m.url, type: 'manga'))
        .toList();
  }

  @override
  Future<List<Manga>> search(
    String query, {
    int page = 1,
    String? genreSlug,
    String? status,
    SortOrder? order,
  }) async {
    if (query.trim().isEmpty) return const [];
    final params = <String, dynamic>{
      'search': query.trim(),
      'per_page': 20,
      'page': page,
      '_embed': '1',
    };
    if (genreSlug != null && genreSlug.isNotEmpty) {
      params['genre'] = genreSlug;
    }
    final list = await _getJsonList('/wp-json/wp/v2/manga', params);
    return list.map(_mangaFromRest).whereType<Manga>().toList();
  }

  @override
  void clearCache() {}

  @override
  Future<MangaDetailResult> fetchMangaDetail(String mangaUrl) async {
    final slug = _slugFromUrl(mangaUrl);
    final list = await _getJsonList('/wp-json/wp/v2/manga', {
      'slug': slug,
      '_embed': '1',
    });
    if (list.isEmpty) {
      throw SiteApiException('Series not found');
    }
    final raw = list.first;
    final manga = _mangaFromRest(raw);
    if (manga == null) {
      throw SiteApiException('Series not found');
    }
    final id = raw['id'];
    var chapters = const <Chapter>[];
    if (id is int) {
      chapters = await _fetchChapters(id, manga.url);
    }
    return MangaDetailResult(manga: manga, chapters: chapters);
  }

  Future<List<Chapter>> _fetchChapters(int mangaId, String mangaUrl) async {
    try {
      final data = await _getJson('/wp-json/initmanga/v1/chapters', {
        'manga_id': mangaId,
      });
      final items = data is Map ? data['items'] : null;
      if (items is! List) return const [];
      final chapters = <Chapter>[];
      for (final item in items) {
        if (item is! Map) continue;
        final slug = item['slug']?.toString() ?? '';
        final number = item['number'];
        final titleRaw = item['title']?.toString() ?? '';
        final title = titleRaw.isNotEmpty
            ? titleRaw
            : 'Chapter ${number ?? slug}';
        final url = slug.isEmpty
            ? mangaUrl
            : '${mangaUrl.endsWith('/') ? mangaUrl : '$mangaUrl/'}$slug/';
        DateTime? date;
        final created = item['created_at']?.toString();
        if (created != null) date = DateTime.tryParse(created);
        chapters.add(Chapter(url: url, title: title, date: date));
      }
      return chapters;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<MangaPage>> fetchReadingPages(String chapterUrl) async {
    try {
      final html = await _getHtml(chapterUrl);
      final pages = <MangaPage>[];
      final imgRe = RegExp(
        r'''(?:src|data-src|data-lazy-src)=["'](https?://[^"']+\.(?:jpg|jpeg|png|webp))["']''',
        caseSensitive: false,
      );
      final seen = <String>{};
      for (final match in imgRe.allMatches(html)) {
        final src = match.group(1)!;
        if (src.contains('avatar') || src.contains('logo') || !seen.add(src)) {
          continue;
        }
        pages.add(MangaPage(
          index: pages.length,
          imageUrl: src,
          chapterUrl: chapterUrl,
        ));
      }
      if (pages.isEmpty) ScraperHealth.report(name, 'readingPages');
      return pages;
    } on SiteApiException {
      return const [];
    }
  }

  @override
  Future<({String? prevUrl, String? nextUrl})> fetchChapterNav(
      String chapterUrl) async {
    return (prevUrl: null, nextUrl: null);
  }

  @override
  Future<List<Genre>> fetchGenres() async {
    final list = await _getJsonList('/wp-json/wp/v2/genre', {
      'per_page': 100,
    });
    return [
      for (final item in list)
        if (item is Map && item['id'] != null && item['name'] != null)
          Genre(
            name: _stripHtml(item['name'].toString()),
            slug: '${item['id']}',
          ),
    ];
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
              'User-Agent': AppConstants.userAgent,
            },
          ),
        )
        .timeout(const Duration(seconds: 30));
    final bytes =
        response.data == null ? Uint8List(0) : Uint8List.fromList(response.data!);
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

  Manga? _mangaFromRest(dynamic raw) {
    if (raw is! Map) return null;
    final link = raw['link']?.toString();
    if (link == null || link.isEmpty) return null;
    final titleMap = raw['title'];
    final title = titleMap is Map
        ? _stripHtml(titleMap['rendered']?.toString() ?? '')
        : _stripHtml(raw['title']?.toString() ?? '');
    String? cover;
    final embedded = raw['_embedded'];
    if (embedded is Map) {
      final media = embedded['wp:featuredmedia'];
      if (media is List && media.isNotEmpty && media.first is Map) {
        cover = media.first['source_url']?.toString();
      }
    }
    final content = raw['content'];
    final summary = content is Map
        ? _stripHtml(content['rendered']?.toString() ?? '')
        : null;
    return Manga(
      url: link,
      title: title,
      coverUrl: cover,
      summary: summary,
      postId: raw['id'] is int ? raw['id'] as int : int.tryParse('${raw['id']}'),
    );
  }

  Future<String> _getHtml(String url) async {
    try {
      final response = await _dio
          .get<String>(
            url,
            options: Options(
              responseType: ResponseType.plain,
              headers: {
                'Accept':
                    'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
              },
            ),
          )
          .timeout(AppConstants.networkTimeout);
      return response.data ?? '';
    } on DioException catch (e) {
      throw SiteApiException(
        e.message ?? 'network error',
        statusCode: e.response?.statusCode,
      );
    } on TimeoutException {
      throw SiteApiException('Timed out');
    }
  }

  Future<dynamic> _getJson(String path, [Map<String, dynamic>? query]) async {
    try {
      final response = await _dio
          .get<dynamic>(
            path,
            queryParameters: query,
            options: Options(responseType: ResponseType.json),
          )
          .timeout(AppConstants.networkTimeout);
      final data = response.data;
      if (data is String) return jsonDecode(data);
      return data;
    } on DioException catch (e) {
      throw SiteApiException(
        e.message ?? 'network error',
        statusCode: e.response?.statusCode,
      );
    } on TimeoutException {
      throw SiteApiException('Timed out');
    }
  }

  Future<List<dynamic>> _getJsonList(
    String path,
    Map<String, dynamic> query,
  ) async {
    final data = await _getJson(path, query);
    if (data is List) return data;
    return const [];
  }

  String _slugFromUrl(String url) {
    final uri = Uri.parse(url);
    final parts = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2 && parts.first == 'manga') return parts[1];
    return parts.isEmpty ? '' : parts.last;
  }

  String _stripHtml(String raw) =>
      raw.replaceAll(RegExp(r'<[^>]+>'), ' ').replaceAll('&nbsp;', ' ').trim();
}

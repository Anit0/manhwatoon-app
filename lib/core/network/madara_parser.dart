import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import '../../models/chapter.dart';
import '../../models/manga.dart';
import '../../models/reader_models.dart';

/// Parses HTML documents served by the ManhwaToon (WordPress Madara) site
/// into typed domain models.
///
/// All parsing is defensive: missing or malformed nodes never throw, they
/// simply yield null / empty values.
class MadaraParser {
  MadaraParser._();

  /// Parses a listing grid (archive, genre, home "latest updates").
  static List<Manga> parseMangaGrid(String html) {
    final doc = html_parser.parse(html);
    final items = doc.querySelectorAll('.page-item-detail');
    final result = <Manga>[];
    for (final el in items) {
      final manga = _mangaFromDetailElement(el);
      if (manga != null) result.add(manga);
    }
    // Fallback: home "hot slider" items use a different container.
    if (result.isEmpty) {
      for (final el in doc.querySelectorAll('.slider__item')) {
        final manga = _mangaFromSliderElement(el);
        if (manga != null) result.add(manga);
      }
    }
    return result;
  }

  /// Parses the homepage "hot / popular" slider cards.
  static List<Manga> parseSlider(String html) {
    final doc = html_parser.parse(html);
    final result = <Manga>[];
    for (final el in doc.querySelectorAll('.slider__item')) {
      final manga = _mangaFromSliderElement(el);
      if (manga != null) result.add(manga);
    }
    return result;
  }

  /// Parses search result cards (`c-tabs-item__content` blocks).
  static List<Manga> parseSearchResults(String html) {
    final doc = html_parser.parse(html);
    final result = <Manga>[];
    for (final el in doc.querySelectorAll('.c-tabs-item__content')) {
      final manga = _mangaFromSearchElement(el);
      if (manga != null) result.add(manga);
    }
    return result;
  }

  static Manga? _mangaFromDetailElement(Element el) {
    final thumb = el.querySelector('.item-thumb, .tab-thumb');
    final link = thumb?.querySelector('a');
    final url = link?.attributes['href'];
    if (url == null) return null;
    final img = thumb?.querySelector('img');
    final title = link?.attributes['title'] ??
        _cleanText(el.querySelector('.post-title')?.text) ??
        '';
    final postId = int.tryParse(el.attributes['data-post-id'] ?? '');

    final rating = _parseRating(el.querySelector('.score.font-meta.total_votes'));

    final chapterLink = el.querySelector('.chapter-item .chapter a, .latest-chap .chapter a');
    final latestTitle = _cleanText(chapterLink?.text);
    final latestUrl = chapterLink?.attributes['href'];
    final timeTitle = el.querySelector('.post-on a')?.attributes['title'];
    final chapterTime = parseRelativeTime(timeTitle);

    return Manga(
      url: url,
      title: title,
      coverUrl: _imageUrl(img),
      rating: rating,
      latestChapterTitle: latestTitle,
      latestChapterUrl: latestUrl,
      latestChapterTime: chapterTime,
      isAdult: _isAdult(el),
      postId: postId,
    );
  }

  static Manga? _mangaFromSliderElement(Element el) {
    final link = el.querySelector('.slider__thumb_item a');
    final url = link?.attributes['href'];
    if (link == null || url == null) return null;
    final titleLink = el.querySelector('.slider__content_item .post-title a');
    final title = _cleanText(titleLink?.text) ?? link.attributes['title'] ?? '';
    final img = el.querySelector('.slider__thumb_item img');
    final chapterLink = el.querySelector('.slider__content_item .chapter-item a');
    return Manga(
      url: url,
      title: title,
      coverUrl: _imageUrl(img),
      latestChapterTitle: _cleanText(chapterLink?.text),
      latestChapterUrl: chapterLink?.attributes['href'],
      isAdult: _isAdult(el),
    );
  }

  static Manga? _mangaFromSearchElement(Element el) {
    final link = el.querySelector('.tab-thumb a, .post-title a');
    final url = link?.attributes['href'];
    if (link == null || url == null) return null;
    final title = _cleanText(link.text) ?? link.attributes['title'] ?? '';
    final img = el.querySelector('.tab-thumb img');
    final rating = _parseRating(el.querySelector('.post-total-rating .score'));

    final genres = el
            .querySelector('.mg_genres .summary-content')
            ?.querySelectorAll('a')
            .map((a) => _cleanText(a.text))
            .whereType<String>()
            .toList() ??
        const <String>[];

    final status = _cleanText(el.querySelector('.mg_status .summary-content')?.text);
    final release = _cleanText(el.querySelector('.mg_release .summary-content')?.text);
    final author = _cleanText(el.querySelector('.mg_author .summary-content')?.text);
    final latestUrl = el.querySelector('.latest-chap .chapter a')?.attributes['href'];
    final latestTitle = _cleanText(el.querySelector('.latest-chap .chapter a')?.text);
    final dateText = el.querySelector('.meta-item.post-on')?.text;
    final time = _parseAbsoluteDate(dateText);

    return Manga(
      url: url,
      title: title,
      coverUrl: _imageUrl(img),
      rating: rating,
      latestChapterTitle: latestTitle,
      latestChapterUrl: latestUrl,
      latestChapterTime: time,
      status: status,
      genres: genres,
      releaseYear: release?.isNotEmpty == true ? release : null,
      authors: author != null && author.isNotEmpty ? [author] : const [],
      views: _parseViews(el.text),
      isAdult: _isAdult(el),
    );
  }

  /// Parses a manga detail page into a [Manga] with full metadata.
  static Manga parseDetail(String html) {
    final doc = html_parser.parse(html);
    final profile = doc.querySelector('.profile-manga');

    String? title;
    String? cover;
    bool isAdult = false;
    if (profile != null) {
      final titleEl = profile.querySelector('.post-title h1');
      title = _cleanText(titleEl?.text);
      isAdult = profile.querySelector('.post-title .manga-title-badges')?.text.contains('18+') == true;
      cover = _imageUrl(profile.querySelector('.summary_image img'));
    }

    final meta = <String, String>{};
    for (final item in doc.querySelectorAll('.post-content_item')) {
      final heading = _cleanText(item.querySelector('.summary-heading h5')?.text);
      final content = _cleanText(item.querySelector('.summary-content')?.text);
      if (heading != null && content != null && heading.isNotEmpty) {
        meta[heading.toLowerCase()] = content;
      }
    }

    final genres = _splitList(meta['genre(s)']);
    final authors = _splitList(meta['author(s)']);
    final artists = _splitList(meta['artist(s)']);
    final alternativeNames = _splitList(meta['alternative']);

    final postId = int.tryParse(
        doc.querySelector('.rating-post-id')?.attributes['value'] ?? '');

    final summaryEl = doc.querySelector('.summary__content');
    final summary = _cleanText(summaryEl?.text);

    final views = _parseViews(meta['rank'] ?? '');

    final ratingEl = doc.querySelector('.post-total-rating .score');
    final rating = _parseRating(ratingEl);

    final status = meta['status'];
    final type = meta['type'];
    final release = meta['release'];

    return Manga(
      url: _canonicalUrl(doc) ?? '',
      title: title ?? '',
      coverUrl: cover,
      rating: rating,
      status: status,
      genres: genres,
      type: type,
      releaseYear: release,
      authors: authors,
      artists: artists,
      alternativeNames: alternativeNames,
      summary: summary,
      views: views,
      postId: postId,
      isAdult: isAdult,
    );
  }

  /// Parses the chapter list HTML returned by the `/ajax/chapters/` endpoint.
  static List<Chapter> parseChapterList(String html) {
    final doc = html_parser.parse(html);
    final result = <Chapter>[];
    for (final li in doc.querySelectorAll('li.wp-manga-chapter')) {
      final link = li.querySelector('a');
      final url = link?.attributes['href'];
      if (url == null) continue;
      final title = _cleanText(link?.text);
      final dateAttr = li.querySelector('.chapter-release-date a')?.attributes['title'];
      result.add(Chapter(
        url: url,
        title: title ?? '',
        date: parseRelativeTime(dateAttr),
      ));
    }
    return result;
  }

  /// Parses the reader page HTML, returning the ordered page images.
  static List<MangaPage> parseReadingPages(String html, {required String chapterUrl}) {
    final doc = html_parser.parse(html);
    final reader = doc.querySelector('#readerarea, .reading-content');
    final images = reader?.querySelectorAll('img') ?? [];
    final result = <MangaPage>[];
    for (var i = 0; i < images.length; i++) {
      final img = images[i];
      final src = (img.attributes['data-src'] ?? img.attributes['src'] ?? '')
          .trim();
      if (src.isEmpty || src.contains('dflazy') || src.contains('1x1')) continue;
      result.add(MangaPage(index: result.length, imageUrl: src, chapterUrl: chapterUrl));
    }
    // Keep stable numbering even if lazy-placeholders are interleaved.
    return result;
  }

  /// Parses next/previous chapter links from a reader page.
  static ({String? prevUrl, String? nextUrl}) parseChapterNav(String html) {
    final doc = html_parser.parse(html);
    String? prevUrl;
    String? nextUrl;
    for (final el in doc.querySelectorAll('.nav-previous a, .nav-next a')) {
      final href = el.attributes['href'];
      if (href == null || href.isEmpty) continue;
      if (el.className.contains('prev')) {
        prevUrl = href;
      } else if (el.className.contains('next')) {
        nextUrl = href;
      }
    }
    return (prevUrl: prevUrl, nextUrl: nextUrl);
  }

  /// Extracts genre links (slug, name) from a page containing genre menus.
  static List<Genre> parseGenres(String html) {
    final doc = html_parser.parse(html);
    final result = <Genre>[];
    final seen = <String>{};
    for (final a in doc.querySelectorAll('a[href*="/manhwa-genre/"]')) {
      final href = a.attributes['href'] ?? '';
      final name = _cleanText(a.text) ?? '';
      final match = RegExp(r'/manhwa-genre/([^/]+)/').firstMatch(href);
      final slug = match?.group(1);
      if (name.isEmpty || slug == null || seen.contains(slug)) continue;
      seen.add(slug);
      result.add(Genre(name: name, slug: slug));
    }
    return result;
  }

  static String? _canonicalUrl(Document doc) {
    final canonical = doc.querySelector('link[rel="canonical"]');
    return canonical?.attributes['href'];
  }

  static String? _imageUrl(Element? img) {
    if (img == null) return null;
    final src =
        (img.attributes['data-src'] ?? img.attributes['src'] ?? '').trim();
    if (src.isEmpty || src.contains('dflazy')) return null;
    return src;
  }

  static double? _parseRating(Element? el) {
    if (el == null) return null;
    final text = _cleanText(el.text);
    if (text == null) return null;
    return double.tryParse(text);
  }

  static int? _parseViews(String text) {
    final match = RegExp(r'([\d,]+)\s*views', caseSensitive: false).firstMatch(text);
    if (match == null) return null;
    return int.tryParse(match.group(1)!.replaceAll(',', ''));
  }

  static List<String> _splitList(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    return raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.toLowerCase() != 'n/a')
        .toList();
  }

  static bool _isAdult(Element el) {
    return el.text.contains('18+') ||
        (el.querySelector('.manga-title-badges')?.text ?? '').contains('18+');
  }

  static String? _cleanText(String? raw) {
    if (raw == null) return null;
    final cleaned = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned.isEmpty ? null : cleaned;
  }

  static DateTime? _parseAbsoluteDate(String? raw) {
    if (raw == null) return null;
    final match =
        RegExp(r'(\d{4})-(\d{2})-(\d{2})[ T](\d{2}):(\d{2}):?(\d{2})?').firstMatch(raw);
    if (match == null) return null;
    final parts = match.groups([1, 2, 3, 4, 5, 6]);
    return DateTime.tryParse(
      '${parts[0]}-${parts[1]}-${parts[2]} ${parts[3]}:${parts[4]}:${parts[5] ?? '00'}',
    );
  }

  /// Parses relative human time strings such as "2 days ago", "13 minutes ago".
  static DateTime? parseRelativeTime(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final text = raw.toLowerCase().trim();
    final match =
        RegExp(r'(\d+)\s*(second|minute|hour|day|week|month|year)s?\s+ago')
            .firstMatch(text);
    if (match == null) return null;
    final amount = int.tryParse(match.group(1)!);
    if (amount == null) return null;
    final unit = match.group(2)!;
    final now = DateTime.now();
    return switch (unit) {
      'second' => now.subtract(Duration(seconds: amount)),
      'minute' => now.subtract(Duration(minutes: amount)),
      'hour' => now.subtract(Duration(hours: amount)),
      'day' => now.subtract(Duration(days: amount)),
      'week' => now.subtract(Duration(days: amount * 7)),
      'month' => now.subtract(Duration(days: amount * 30)),
      'year' => now.subtract(Duration(days: amount * 365)),
      _ => null,
    };
  }
}

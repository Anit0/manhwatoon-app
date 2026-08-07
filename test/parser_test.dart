import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:manhwa_toon/core/network/madara_parser.dart';

void main() {
  String fixture(String name) => File('test/fixtures/$name').readAsStringSync();

  test('parses archive grid items', () {
    final html = fixture('archive.html');
    final manga = MadaraParser.parseMangaGrid(html);
    expect(manga.length, greaterThanOrEqualTo(10));
    final first = manga.first;
    expect(first.title, isNotEmpty);
    expect(first.url, contains('manhwa'));
    expect(first.coverUrl, startsWith('https://'));
    expect(first.latestChapterTitle, isNotNull);
    expect(first.latestChapterUrl, isNotNull);
    expect(first.rating, isA<double>());
  });

  test('parses home latest updates grid and slider', () {
    final html = fixture('home.html');
    final grid = MadaraParser.parseMangaGrid(html);
    expect(grid.length, greaterThanOrEqualTo(10));

    final slider = MadaraParser.parseSlider(html);
    expect(slider.length, greaterThanOrEqualTo(3));
    expect(slider.first.title, isNotEmpty);
    // Adult badge detection works.
    expect(slider.any((m) => m.isAdult), isTrue);
  });

  test('parses search results with full metadata', () {
    final html = fixture('searchpage.html');
    final manga = MadaraParser.parseSearchResults(html);
    expect(manga.length, greaterThanOrEqualTo(5));
    final m = manga.first;
    expect(m.title, isNotEmpty);
    expect(m.url, contains('manhwa'));
    expect(m.genres, isNotEmpty);
    expect(m.status, isNotEmpty);
  });

  test('parses manga detail metadata', () {
    final html = fixture('manga.html');
    final manga = MadaraParser.parseDetail(html);
    expect(manga.title, isNotEmpty);
    expect(manga.summary, isNotEmpty);
    expect(manga.genres, contains('Comedy'));
    expect(manga.status, contains('OnGoing'));
    expect(manga.releaseYear, '2021');
    expect(manga.authors, isNotEmpty);
    expect(manga.isAdult, isTrue);
    expect(manga.postId, 6045);
  });

  test('parses chapter list', () {
    final html = fixture('chapters.html');
    final chapters = MadaraParser.parseChapterList(html);
    expect(chapters.length, 3);
    expect(chapters.first.title, contains('Chapter'));
    expect(chapters.first.url, contains('manhwa'));
    expect(chapters.first.date, isNotNull);
  });

  test('parses reading page images', () {
    final html = fixture('chapter.html');
    final pages = MadaraParser.parseReadingPages(html, chapterUrl: 'test');
    expect(pages.length, 12);
    expect(pages.first.imageUrl, contains('WP-manga/data'));
    // URLs must be cleanly trimmed (site embeds leading tabs/newlines).
    expect(pages.first.imageUrl, startsWith('https://'));
    // Zero-based, ordered indices.
    for (var i = 0; i < pages.length; i++) {
      expect(pages[i].index, i);
    }
  });

  test('parses chapter navigation', () {
    final html = fixture('chapter.html');
    final nav = MadaraParser.parseChapterNav(html);
    // Chapter 4 is the latest, so only the previous link is present.
    expect(nav.prevUrl, contains('chapter-3'));
    expect(nav.nextUrl, isNull);
  });

  test('parses genre links', () {
    final html = fixture('home.html');
    final genres = MadaraParser.parseGenres(html);
    expect(genres.length, greaterThanOrEqualTo(20));
    expect(genres.map((g) => g.name), contains('Action'));
  });

  test('parses relative time', () {
    final dt = MadaraParser.parseRelativeTime('2 days ago');
    expect(dt, isNotNull);
    expect(DateTime.now().difference(dt!).inDays, 2);
    final min = MadaraParser.parseRelativeTime('13 minutes ago');
    expect(DateTime.now().difference(min!).inMinutes, 13);
    expect(MadaraParser.parseRelativeTime('gibberish'), isNull);
  });
}

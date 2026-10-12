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

  test('search parser falls back to archive grid markup', () {
    final html = fixture('archive.html');
    final manga = MadaraParser.parseSearchResults(html);
    expect(manga.length, greaterThanOrEqualTo(10));
    expect(manga.first.title, isNotEmpty);
    expect(manga.first.url, contains('manhwa'));
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

  test('parses TopManhua-style div chapter list', () {
    const html = '''
      <div class="wp-manga-chapter" chapter-id="365710">
        <span>
          <a href="https://www.topmanhua.fan/manhua/x/chapter-250" data-id="365710">Chapter 250</a>
        </span>
        <span class="chapter-release-date"><i>10/12/2026</i></span>
      </div>
      <div class="wp-manga-chapter" chapter-id="365709">
        <a href="https://www.topmanhua.fan/manhua/x/chapter-249">Chapter 249</a>
      </div>
    ''';
    final chapters = MadaraParser.parseChapterList(html);
    expect(chapters.length, 2);
    expect(chapters.first.title, 'Chapter 250');
    expect(chapters.first.url, contains('chapter-250'));
    expect(chapters.first.date, DateTime(2026, 10, 12));
  });

  test('parses reading page images', () {
    final html = fixture('chapter.html');
    final pages = MadaraParser.parseReadingPages(html, chapterUrl: 'test');
    expect(pages.length, 12);
    expect(pages.first.imageUrl, contains('WP-manga/data'));
    // URLs must be cleanly trimmed (site embeds leading tabs/newlines).
    expect(pages.first.imageUrl, startsWith('https://'));
    expect(pages.first.imageUrl, isNot(contains('\n')));
    expect(pages.first.imageUrl, isNot(contains('\t')));
    expect(pages.first.imageUrl, endsWith('/1-1723.jpg'));
    expect(pages.last.imageUrl, endsWith('/12-1723.jpg'));
    // Zero-based, ordered indices.
    for (var i = 0; i < pages.length; i++) {
      expect(pages[i].index, i);
    }
  });

  test('orders chapter images by image-N id even if markup is shuffled', () {
    const html = '''
    <div class="reading-content">
      <img id="image-2" class="wp-manga-chapter-img" data-src="https://cdn.example/3.jpg">
      <img id="image-0" class="wp-manga-chapter-img" data-src="https://cdn.example/1.jpg">
      <img id="image-1" class="wp-manga-chapter-img" data-src="https://cdn.example/2.jpg">
    </div>
    ''';
    final pages = MadaraParser.parseReadingPages(html, chapterUrl: 'ch');
    expect(pages.map((p) => p.imageUrl).toList(), [
      'https://cdn.example/1.jpg',
      'https://cdn.example/2.jpg',
      'https://cdn.example/3.jpg',
    ]);
  });

  test('normalizes lazy-load URLs with whitespace', () {
    expect(
      MadaraParser.normalizeImageUrl('\n\t  https://cdn.example/1.jpg  '),
      'https://cdn.example/1.jpg',
    );
    expect(MadaraParser.normalizeImageUrl('data:image/gif;base64,xx'), isNull);
    expect(MadaraParser.normalizeImageUrl('https://x/dflazy.jpg'), isNull);
    expect(
      MadaraParser.normalizeImageUrl('//cdn.example/page.jpg'),
      'https://cdn.example/page.jpg',
    );
  });

  test('parses chapter navigation', () {
    final html = fixture('chapter.html');
    final nav = MadaraParser.parseChapterNav(html);
    // Chapter 4 is the latest, so only the previous link is present.
    expect(nav.prevUrl, contains('chapter-3'));
    expect(nav.nextUrl, isNull);
  });

  test('chapter nav ignores manga-info back links and finds next_page', () {
    const html = '''
    <div class="nav-links">
      <div class="nav-previous">
        <a href="https://example.com/ch-1/" class="btn prev_page">Prev</a>
      </div>
      <div class="nav-next">
        <a href="https://example.com/series/" class="btn back">Manga Info</a>
      </div>
    </div>
    <div class="nav-links">
      <a href="https://example.com/ch-3/" class="btn next_page">Next</a>
    </div>
    ''';
    final nav = MadaraParser.parseChapterNav(html);
    expect(nav.prevUrl, contains('ch-1'));
    expect(nav.nextUrl, contains('ch-3'));
  });

  test('parses genre links', () {
    final html = fixture('home.html');
    final genres = MadaraParser.parseGenres(html);
    expect(genres.length, greaterThanOrEqualTo(20));
    expect(genres.map((g) => g.name), contains('Action'));
  });

  test('parses genre links with custom genre path (mangayy style)', () {
    const html = '''
    <a href="https://mangayy.org/manga-genre/action/">Action</a>
    <a href="https://mangayy.org/manga-genre/comedy/">Comedy</a>
    <a href="https://mangayy.org/manga-genre/romance/">Romance</a>
    <a href="https://mangayy.org/other/thing/">Ignored</a>
    ''';
    final genres =
        MadaraParser.parseGenres(html, genrePath: '/manga-genre/');
    expect(genres.length, 3);
    expect(genres.map((g) => g.name), containsAll(['Action', 'Comedy']));
    expect(genres.map((g) => g.slug), contains('romance'));
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

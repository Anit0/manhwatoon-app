import 'package:flutter_test/flutter_test.dart';
import 'package:manhwa_toon/features/reader/reader_controller.dart';

void main() {
  ReaderPage net(String chapter, int index, {int count = 3}) {
    return ReaderPage.network(
      'https://cdn.example/$chapter/${index + 1}.jpg',
      headers: const {'referer': 'https://example.com/'},
      chapterUrl: 'https://example.com/$chapter/',
      chapterTitle: chapter,
      pageIndex: index,
      chapterPageCount: count,
    );
  }

  test('page identity is unique per chapter and index', () {
    final a = net('ch1', 0);
    final b = net('ch1', 1);
    final c = net('ch2', 0);
    expect(a.identity, isNot(b.identity));
    expect(a.identity, isNot(c.identity));
    expect(a.cacheKey, 'https://cdn.example/ch1/1.jpg');
  });

  test('continuous reader items keep chapter order and unique keys', () {
    final ch1 = LoadedChapter(
      url: 'https://example.com/ch1/',
      title: 'Chapter 1',
      pages: [net('ch1', 0), net('ch1', 1), net('ch1', 2)],
      nextUrl: 'https://example.com/ch2/',
    );
    final ch2 = LoadedChapter(
      url: 'https://example.com/ch2/',
      title: 'Chapter 2',
      pages: [net('ch2', 0), net('ch2', 1), net('ch2', 2)],
      prevUrl: 'https://example.com/ch1/',
    );

    final items = <ReaderItem>[
      ReaderItem.header(chapterUrl: ch1.url, chapterTitle: ch1.title),
      for (final p in ch1.pages) ReaderItem.page(p),
      ReaderItem.header(chapterUrl: ch2.url, chapterTitle: ch2.title),
      for (final p in ch2.pages) ReaderItem.page(p),
    ];

    expect(items.where((i) => i.kind == ReaderItemKind.header).length, 2);
    expect(items.where((i) => i.kind == ReaderItemKind.page).length, 6);
    expect(items.map((i) => i.key).toSet().length, items.length);

    final pageUrls = [
      for (final i in items)
        if (i.page != null) i.page!.imageUrl,
    ];
    expect(pageUrls, [
      'https://cdn.example/ch1/1.jpg',
      'https://cdn.example/ch1/2.jpg',
      'https://cdn.example/ch1/3.jpg',
      'https://cdn.example/ch2/1.jpg',
      'https://cdn.example/ch2/2.jpg',
      'https://cdn.example/ch2/3.jpg',
    ]);
  });

  test('chapter titles that already include a number stay intact', () {
    expect(RegExp(r'chapter\s*\d', caseSensitive: false).hasMatch('Chapter 12'),
        isTrue);
    expect(RegExp(r'chapter\s*\d', caseSensitive: false).hasMatch('Ch 3.5'),
        isFalse);
    final fromUrl = RegExp(
      r'(?:chapter|ch)[-_ ]?(\d+(?:\.\d+)?)',
      caseSensitive: false,
    ).firstMatch('https://site.com/manga/solo-leveling/chapter-142/')?.group(1);
    expect(fromUrl, '142');
  });

  test('manual chapter targets use next and previous urls', () {
    final chapter = LoadedChapter(
      url: 'https://example.com/ch2/',
      title: 'Chapter 2',
      pages: [net('ch2', 0)],
      prevUrl: 'https://example.com/ch1/',
      nextUrl: 'https://example.com/ch3/',
    );
    expect(chapter.prevUrl, contains('ch1'));
    expect(chapter.nextUrl, contains('ch3'));
  });
}

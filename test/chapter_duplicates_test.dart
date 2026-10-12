import 'package:flutter_test/flutter_test.dart';
import 'package:manhwa_toon/core/library/chapter_duplicates.dart';
import 'package:manhwa_toon/models/chapter.dart';

void main() {
  const chapters = [
    Chapter(url: 'https://ex.com/ch-12/', title: 'Chapter 12'),
    Chapter(url: 'https://ex.com/ch-12-official/', title: 'Chapter 12 Official'),
    Chapter(url: 'https://ex.com/ch-13/', title: 'Chapter 13'),
    Chapter(url: 'https://ex.com/prologue/', title: 'Prologue'),
  ];

  test('disabled only returns the source url', () {
    expect(
      ChapterDuplicates.matchingUrls(
        chapters: chapters,
        chapterUrl: 'https://ex.com/ch-12/',
        enabled: false,
      ),
      ['https://ex.com/ch-12/'],
    );
  });

  test('enabled marks same chapter number as duplicates', () {
    expect(
      ChapterDuplicates.matchingUrls(
        chapters: chapters,
        chapterUrl: 'https://ex.com/ch-12/',
        enabled: true,
      ),
      [
        'https://ex.com/ch-12/',
        'https://ex.com/ch-12-official/',
      ],
    );
  });

  test('unknown url returns itself', () {
    expect(
      ChapterDuplicates.matchingUrls(
        chapters: chapters,
        chapterUrl: 'https://ex.com/missing/',
        enabled: true,
      ),
      ['https://ex.com/missing/'],
    );
  });

  test('chapters without a number stay unique', () {
    expect(
      ChapterDuplicates.matchingUrls(
        chapters: chapters,
        chapterUrl: 'https://ex.com/prologue/',
        enabled: true,
      ),
      ['https://ex.com/prologue/'],
    );
  });
}

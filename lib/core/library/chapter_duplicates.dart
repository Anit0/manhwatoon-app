import '../../models/chapter.dart';

/// Mihon-style duplicate chapter matching by extracted chapter number.
class ChapterDuplicates {
  ChapterDuplicates._();

  static List<String> matchingUrls({
    required List<Chapter> chapters,
    required String chapterUrl,
    required bool enabled,
  }) {
    if (!enabled) return [chapterUrl];
    Chapter? source;
    for (final c in chapters) {
      if (c.url == chapterUrl) {
        source = c;
        break;
      }
    }
    if (source == null) return [chapterUrl];
    final n = source.chapterNumber;
    if (n == null) return [chapterUrl];
    return [
      for (final c in chapters)
        if (c.chapterNumber == n) c.url,
    ];
  }
}

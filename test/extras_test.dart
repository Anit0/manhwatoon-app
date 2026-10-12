import 'package:flutter_test/flutter_test.dart';
import 'package:manhwa_toon/core/providers/extras_provider.dart';

void main() {
  test('extras json roundtrip preserves notes bookmarks and read marks', () {
    const extras = UserExtras(
      notes: {'https://ex.com/solo': 'reread arc 2'},
      bookmarkedChapters: {'https://ex.com/ch-12/'},
      readChapters: {'https://ex.com/ch-1/', 'https://ex.com/ch-2/'},
    );
    final restored = UserExtras.fromJson(extras.toJson());
    expect(restored.noteFor('https://ex.com/solo'), 'reread arc 2');
    expect(restored.isChapterBookmarked('https://ex.com/ch-12/'), isTrue);
    expect(restored.isChapterRead('https://ex.com/ch-1/'), isTrue);
    expect(restored.isChapterRead('https://ex.com/ch-99/'), isFalse);
  });

  test('chapter progress roundtrip and label', () {
    const extras = UserExtras(
      chapterProgress: {
        'https://ex.com/ch-3/': ChapterPageProgress(
          pageIndex: 59,
          totalPages: 100,
        ),
      },
    );
    final restored = UserExtras.fromJson(extras.toJson());
    final progress = restored.progressFor('https://ex.com/ch-3/')!;
    expect(progress.label, '60/100');
    expect(progress.completed, isFalse);
  });

  test('fromJson ignores malformed values', () {
    final extras = UserExtras.fromJson({
      'notes': {'ok': 1, 'good': 'yes'},
      'bookmarkedChapters': [1, 'https://ex.com/ch/'],
      'readChapters': 'nope',
    });
    expect(extras.notes, {'good': 'yes'});
    expect(extras.bookmarkedChapters, {'https://ex.com/ch/'});
    expect(extras.readChapters, isEmpty);
  });
}

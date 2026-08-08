import 'package:flutter_test/flutter_test.dart';
import 'package:manhwa_toon/core/sources/madara_source.dart';
import 'package:manhwa_toon/core/sources/source_registry.dart';

void main() {
  test('registry exposes manhwatoon and mangayy sources', () {
    expect(availableSources.length, 2);
    expect(availableSources.map((s) => s.id), containsAll(['manhwatoon', 'mangayy']));
  });

  test('mangayy uses the manga-genre path prefix', () {
    final mangayy = availableSources.firstWhere((s) => s.id == 'mangayy');
    expect(mangayy, isA<MadaraSource>());
    expect((mangayy as MadaraSource).genrePathPrefix, '/manga-genre/');
    final manhwatoon = availableSources.firstWhere((s) => s.id == 'manhwatoon');
    expect((manhwatoon as MadaraSource).genrePathPrefix, '/manhwa-genre/');
  });

  test('sourceForUrl resolves by host and falls back to manhwatoon', () {
    expect(sourceForUrl('https://mangayy.org/manga/some-title/').id, 'mangayy');
    expect(sourceForUrl('https://www.manhwatoon.me/manhwa/some-title/').id, 'manhwatoon');
    expect(sourceForUrl('https://unknown.example.com/manga/x/').id, 'manhwatoon');
  });

  test('sourceById falls back to manhwatoon for unknown ids', () {
    expect(sourceById('mangayy').id, 'mangayy');
    expect(sourceById('manhwatoon').id, 'manhwatoon');
    expect(sourceById('nope').id, 'manhwatoon');
  });
}

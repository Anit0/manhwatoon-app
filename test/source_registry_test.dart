import 'package:flutter_test/flutter_test.dart';
import 'package:manhwa_toon/core/sources/madara_source.dart';
import 'package:manhwa_toon/core/sources/source_registry.dart';

void main() {
  test('registry exposes all bundled sources', () {
    expect(availableSources.length, 5);
    expect(availableSources.first.id, 'topmanhua');
    expect(
      availableSources.map((s) => s.name).toList(),
      ['Source 1', 'Source 2', 'Source 3', 'Source 4', 'Source 5'],
    );
    expect(
      availableSources.map((s) => s.id),
      containsAll([
        'manhwatoon',
        'mangayy',
        'manhwatoons',
        'doujinhq',
        'topmanhua',
      ]),
    );
  });

  test('mangayy uses the manga-genre path prefix', () {
    final mangayy = availableSources.firstWhere((s) => s.id == 'mangayy');
    expect(mangayy, isA<MadaraSource>());
    expect((mangayy as MadaraSource).genrePathPrefix, '/manga-genre/');
    final manhwatoon = availableSources.firstWhere((s) => s.id == 'manhwatoon');
    expect((manhwatoon as MadaraSource).genrePathPrefix, '/manhwa-genre/');
  });

  test('manhwatoons uses the manhwa archive path', () {
    final source = availableSources.firstWhere((s) => s.id == 'manhwatoons');
    expect((source as MadaraSource).archivePath, '/manhwa/');
    expect(source.baseUrl, 'https://www.manhwatoons.com');
  });

  test('doujinhq uses manga archive and dj-tag genres', () {
    final source = availableSources.firstWhere((s) => s.id == 'doujinhq');
    expect(source, isA<MadaraSource>());
    expect((source as MadaraSource).archivePath, '/manga/');
    expect(source.genrePathPrefix, '/dj-tag/');
    expect(source.baseUrl, 'https://www.doujinhq.club');
    expect(source.imageHosts, containsAll(['cdn.doujinhq.club', 'doujinhq.club']));
  });

  test('topmanhua uses manga archive and manhua-genre path', () {
    final source = availableSources.firstWhere((s) => s.id == 'topmanhua');
    expect(source, isA<MadaraSource>());
    expect((source as MadaraSource).archivePath, '/manga/');
    expect(source.genrePathPrefix, '/manhua-genre/');
    expect(source.baseUrl, 'https://www.topmanhua.fan');
    expect(
      source.imageHosts,
      containsAll(['cdn.zinmanga1.com', 'img-r1.2xstorage.com']),
    );
  });

  test('sourceForUrl resolves by host, image host and falls back', () {
    expect(sourceForUrl('https://mangayy.org/manga/some-title/').id, 'mangayy');
    expect(sourceForUrl('https://www.manhwatoon.me/manhwa/some-title/').id, 'manhwatoon');
    expect(sourceForUrl('https://www.manhwatoons.com/manhwa/some-title/').id, 'manhwatoons');
    expect(sourceForUrl('https://cdn.manhwatoons.com/cover.jpg').id, 'manhwatoons');
    expect(sourceForUrl('https://cdn.manhwatoon.me/x.jpg').id, 'manhwatoon');
    expect(sourceForUrl('https://like.mgread.io/manga/x.jpg').id, 'mangayy');
    expect(sourceForUrl('https://www.doujinhq.club/dj/some-title/').id, 'doujinhq');
    expect(sourceForUrl('https://doujinhq.club/manga/').id, 'doujinhq');
    expect(sourceForUrl('https://cdn.doujinhq.club/cover.jpg').id, 'doujinhq');
    expect(sourceForUrl('https://www.topmanhua.fan/manhua/some-title/').id, 'topmanhua');
    expect(sourceForUrl('https://cdn.zinmanga1.com/thumb/x.webp').id, 'topmanhua');
    expect(sourceForUrl('https://img-r1.2xstorage.com/thumb/x.webp').id, 'topmanhua');
    expect(sourceForUrl('https://unknown.example.com/manga/x/').id, 'topmanhua');
  });

  test('sourceById falls back to topmanhua for unknown ids', () {
    expect(sourceById('mangayy').id, 'mangayy');
    expect(sourceById('manhwatoon').id, 'manhwatoon');
    expect(sourceById('manhwatoons').id, 'manhwatoons');
    expect(sourceById('doujinhq').id, 'doujinhq');
    expect(sourceById('topmanhua').id, 'topmanhua');
    expect(sourceById('nope').id, 'topmanhua');
  });

  test('sourceImageHeaders include referer and user agent', () {
    final headers = sourceImageHeaders('https://like.mgread.io/page.jpg');
    expect(headers['referer'], 'https://mangayy.org/');
    expect(headers['Referer'], 'https://mangayy.org/');
    expect(headers['User-Agent'], isNotEmpty);
    expect(headers['Accept'], contains('image/'));
  });
}

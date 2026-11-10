import 'package:flutter_test/flutter_test.dart';
import 'package:manhwa_toon/core/sources/madara_source.dart';
import 'package:manhwa_toon/core/sources/source_registry.dart';

void main() {
  test('registry exposes all bundled sources', () {
    expect(availableSources.length, 8);
    expect(availableSources.first.id, 'topmanhua');
    expect(
      availableSources.map((s) => s.name).toList(),
      [
        'Source 1',
        'Source 2',
        'Source 3',
        'Source 4',
        'Source 5',
        'Source 6',
        'Source 7',
        'Source 8',
      ],
    );
    expect(
      availableSources.map((s) => s.id),
      containsAll([
        'manhwatoon',
        'aquareader',
        'manhwatoons',
        'doujinhq',
        'topmanhua',
        'zazamanga',
        'lilymanga',
        'mangaread',
      ]),
    );
  });

  test('source 3 is Aqua Reader', () {
    final aqua = availableSources.firstWhere((s) => s.id == 'aquareader');
    expect(aqua, isA<MadaraSource>());
    expect(aqua.baseUrl, 'https://aquareader.org');
    expect((aqua as MadaraSource).archivePath, '/manga/');
    expect(aqua.seriesPathPrefix, '/manga/');
    final manhwatoon = availableSources.firstWhere((s) => s.id == 'manhwatoon');
    expect((manhwatoon as MadaraSource).genrePathPrefix, '/manhwa-genre/');
    expect(manhwatoon.seriesPathPrefix, '/manhwa/');
  });

  test('manhwatoons uses the webtoon archive path', () {
    final source = availableSources.firstWhere((s) => s.id == 'manhwatoons');
    expect((source as MadaraSource).archivePath, '/webtoon/');
    expect(source.seriesPathPrefix, '/webtoon/');
    expect(source.genrePathPrefix, '/webtoon-genre/');
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
    expect(source.seriesPathPrefix, '/manhua/');
    expect(source.liveSearchPath, '/manga/searching');
    expect(source.coverCdn, 'https://img-r1.2xstorage.com');
    expect(source.baseUrl, 'https://www.topmanhua.fan');
    expect(
      source.imageHosts,
      containsAll(['cdn.zinmanga1.com', 'img-r1.2xstorage.com']),
    );
  });

  test('sourceForUrl resolves by host, image host and falls back', () {
    expect(sourceForUrl('https://aquareader.org/manga/some-title/').id, 'aquareader');
    expect(sourceForUrl('https://www.manhwatoon.me/manhwa/some-title/').id, 'manhwatoon');
    expect(sourceForUrl('https://www.manhwatoons.com/manhwa/some-title/').id, 'manhwatoons');
    expect(sourceForUrl('https://cdn.manhwatoons.com/cover.jpg').id, 'manhwatoons');
    expect(sourceForUrl('https://cdn.manhwatoon.me/x.jpg').id, 'manhwatoon');
    expect(sourceForUrl('https://aquareader.org/wp-content/uploads/x.jpg').id, 'aquareader');
    expect(sourceForUrl('https://www.doujinhq.club/dj/some-title/').id, 'doujinhq');
    expect(sourceForUrl('https://doujinhq.club/manga/').id, 'doujinhq');
    expect(sourceForUrl('https://cdn.doujinhq.club/cover.jpg').id, 'doujinhq');
    expect(sourceForUrl('https://www.topmanhua.fan/manhua/some-title/').id, 'topmanhua');
    expect(sourceForUrl('https://cdn.zinmanga1.com/thumb/x.webp').id, 'topmanhua');
    expect(sourceForUrl('https://img-r1.2xstorage.com/thumb/x.webp').id, 'topmanhua');
    expect(sourceForUrl('https://unknown.example.com/manga/x/').id, 'topmanhua');
    expect(sourceForUrl('https://www.zazamanga.com/manga/solo-leveling/').id, 'zazamanga');
    expect(sourceForUrl('https://zazamanga.com/manga/solo-leveling/').id, 'zazamanga');
    expect(sourceForUrl('https://lilymanga.net/gl/falling/').id, 'lilymanga');
    expect(sourceForUrl('https://www.lilymanga.net/ys/').id, 'lilymanga');
    expect(sourceForUrl('https://www.mangaread.org/manga/solo-swordmaster/').id, 'mangaread');
    expect(sourceForUrl('https://mangaread.org/manga/solo-swordmaster/').id, 'mangaread');
  });

  test('sourceById falls back to topmanhua for unknown ids', () {
    expect(sourceById('aquareader').id, 'aquareader');
    expect(sourceById('mangayy').id, 'aquareader');
    expect(sourceById('manhwatoon').id, 'manhwatoon');
    expect(sourceById('manhwatoons').id, 'manhwatoons');
    expect(sourceById('doujinhq').id, 'doujinhq');
    expect(sourceById('topmanhua').id, 'topmanhua');
    expect(sourceById('zazamanga').id, 'zazamanga');
    expect(sourceById('lilymanga').id, 'lilymanga');
    expect(sourceById('mangaread').id, 'mangaread');
    expect(sourceById('nope').id, 'topmanhua');
  });

  test('zazamanga uses manga archive and live search', () {
    final source = availableSources.firstWhere((s) => s.id == 'zazamanga');
    expect(source, isA<MadaraSource>());
    expect(source.baseUrl, 'https://www.zazamanga.com');
    expect((source as MadaraSource).archivePath, '/manga/');
    expect(source.seriesPathPrefix, '/manga/');
    expect(source.genrePathPrefix, '/manga-genre/');
    expect(source.liveSearchPath, '/manga/searching');
    expect(source.coverCdn, 'https://img-r1.2xstorage.com');
  });

  test('lilymanga uses ys archive and gl series path', () {
    final source = availableSources.firstWhere((s) => s.id == 'lilymanga');
    expect(source, isA<MadaraSource>());
    expect(source.baseUrl, 'https://lilymanga.net');
    expect((source as MadaraSource).archivePath, '/ys/');
    expect(source.seriesPathPrefix, '/gl/');
    expect(source.genrePathPrefix, '/gl-genre/');
  });

  test('mangaread uses manga archive and genres path', () {
    final source = availableSources.firstWhere((s) => s.id == 'mangaread');
    expect(source, isA<MadaraSource>());
    expect(source.baseUrl, 'https://www.mangaread.org');
    expect((source as MadaraSource).archivePath, '/manga/');
    expect(source.seriesPathPrefix, '/manga/');
    expect(source.genrePathPrefix, '/genres/');
  });

  test('sourceImageHeaders include referer and user agent', () {
    final headers = sourceImageHeaders('https://aquareader.org/wp-content/uploads/page.jpg');
    expect(headers['referer'], 'https://aquareader.org/');
    expect(headers['Referer'], 'https://aquareader.org/');
    expect(headers['User-Agent'], isNotEmpty);
    expect(headers['Accept'], contains('image/'));
  });
}

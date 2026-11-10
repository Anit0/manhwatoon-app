import '../constants/app_constants.dart';
import 'madara_source.dart';
import 'manga_source.dart';

/// Display names are numbered so the real site names stay off the UI.
final MadaraSource topManhuaSource = MadaraSource(
  id: 'topmanhua',
  name: 'Source 1',
  baseUrl: 'https://www.topmanhua.fan',
  genrePathPrefix: '/manhua-genre/',
  archivePath: '/manga/',
  seriesPathPrefix: '/manhua/',
  liveSearchPath: '/manga/searching',
  coverCdn: 'https://img-r1.2xstorage.com',
  imageHosts: ['cdn.zinmanga1.com', 'img-r1.2xstorage.com'],
);

final MadaraSource manhwaToonSource = MadaraSource(
  id: 'manhwatoon',
  name: 'Source 2',
  baseUrl: 'https://www.manhwatoon.me',
  genrePathPrefix: '/manhwa-genre/',
  seriesPathPrefix: '/manhwa/',
  imageHosts: ['cdn.manhwatoon.me', 'manhwatoon.me'],
);

final MadaraSource aquaReaderSource = MadaraSource(
  id: 'aquareader',
  name: 'Source 3',
  baseUrl: 'https://aquareader.org',
  genrePathPrefix: '/manga/',
  archivePath: '/manga/',
  seriesPathPrefix: '/manga/',
  imageHosts: const ['aquareader.org'],
);

final MadaraSource manhwaToonsSource = MadaraSource(
  id: 'manhwatoons',
  name: 'Source 4',
  baseUrl: 'https://www.manhwatoons.com',
  genrePathPrefix: '/webtoon-genre/',
  archivePath: '/webtoon/',
  seriesPathPrefix: '/webtoon/',
  imageHosts: ['cdn.manhwatoons.com', 'manhwatoons.com'],
);

final MadaraSource doujinHqSource = MadaraSource(
  id: 'doujinhq',
  name: 'Source 5',
  baseUrl: 'https://www.doujinhq.club',
  genrePathPrefix: '/dj-tag/',
  archivePath: '/manga/',
  seriesPathPrefix: '/dj/',
  adultCatalog: true,
  imageHosts: ['cdn.doujinhq.club', 'doujinhq.club'],
);

final MadaraSource zazaMangaSource = MadaraSource(
  id: 'zazamanga',
  name: 'Source 6',
  baseUrl: 'https://www.zazamanga.com',
  genrePathPrefix: '/manga-genre/',
  archivePath: '/manga/',
  seriesPathPrefix: '/manga/',
  liveSearchPath: '/manga/searching',
  coverCdn: 'https://img-r1.2xstorage.com',
  imageHosts: [
    'zazamanga.com',
    'cdn.zinmanga1.com',
    'cdn2.zinmanga1.com',
    'cdn3.zinmanga1.com',
    'cdn4.zinmanga1.com',
    'img-r1.2xstorage.com',
  ],
);

final MadaraSource lilyMangaSource = MadaraSource(
  id: 'lilymanga',
  name: 'Source 7',
  baseUrl: 'https://lilymanga.net',
  genrePathPrefix: '/gl-genre/',
  archivePath: '/ys/',
  seriesPathPrefix: '/gl/',
  imageHosts: const ['lilymanga.net', 'www.lilymanga.net'],
);

final MadaraSource mangaReadSource = MadaraSource(
  id: 'mangaread',
  name: 'Source 8',
  baseUrl: 'https://www.mangaread.org',
  genrePathPrefix: '/genres/',
  archivePath: '/manga/',
  seriesPathPrefix: '/manga/',
  imageHosts: const ['mangaread.org', 'www.mangaread.org'],
);

/// All sources bundled with the app. First entry is the default.
final List<MangaSource> availableSources = [
  topManhuaSource,
  manhwaToonSource,
  aquaReaderSource,
  manhwaToonsSource,
  doujinHqSource,
  zazaMangaSource,
  lilyMangaSource,
  mangaReadSource,
];

/// Default source used on first launch.
final MangaSource primarySource = topManhuaSource;

/// Returns the source that hosts [url], falling back to the primary source.
MangaSource sourceForUrl(String url) {
  final host = _hostOf(url);
  if (host != null) {
    for (final source in availableSources) {
      final baseHost = _hostOf(source.baseUrl);
      if (baseHost != null && (host == baseHost || source.imageHosts.contains(host))) {
        return source;
      }
    }
  }
  return availableSources.firstWhere(
    (s) => url.startsWith(s.baseUrl),
    orElse: () => primarySource,
  );
}

String? _hostOf(String url) {
  try {
    var host = Uri.parse(url).host.toLowerCase();
    if (host.startsWith('www.')) host = host.substring(4);
    return host;
  } catch (_) {
    return null;
  }
}

/// Returns the source with the given [id], falling back to the primary one.
MangaSource sourceById(String? id) {
  if (id == 'mangayy') return aquaReaderSource;
  return availableSources.firstWhere(
    (s) => s.id == id,
    orElse: () => primarySource,
  );
}

/// HTTP headers required to fetch an image hosted by a source.
///
/// Some Madara deployments (e.g. MangaYY) serve covers and chapter images
/// from domains that return 403 unless a `Referer` header for the site is sent.
Map<String, String> sourceImageHeaders(String url) {
  final source = sourceForUrl(url);
  return {
    'referer': '${source.baseUrl}/',
    'Referer': '${source.baseUrl}/',
    'User-Agent': AppConstants.userAgent,
    'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
  };
}

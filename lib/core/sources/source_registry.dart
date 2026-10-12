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
  imageHosts: ['cdn.zinmanga1.com', 'img-r1.2xstorage.com'],
);

final MadaraSource manhwaToonSource = MadaraSource(
  id: 'manhwatoon',
  name: 'Source 2',
  baseUrl: 'https://www.manhwatoon.me',
  genrePathPrefix: '/manhwa-genre/',
  imageHosts: ['cdn.manhwatoon.me'],
);

final MadaraSource mangaYYSource = MadaraSource(
  id: 'mangayy',
  name: 'Source 3',
  baseUrl: 'https://mangayy.org',
  genrePathPrefix: '/manga-genre/',
  imageHosts: ['like.mgread.io'],
);

final MadaraSource manhwaToonsSource = MadaraSource(
  id: 'manhwatoons',
  name: 'Source 4',
  baseUrl: 'https://www.manhwatoons.com',
  genrePathPrefix: '/manhwa-genre/',
  archivePath: '/manhwa/',
  imageHosts: ['cdn.manhwatoons.com'],
);

final MadaraSource doujinHqSource = MadaraSource(
  id: 'doujinhq',
  name: 'Source 5',
  baseUrl: 'https://www.doujinhq.club',
  genrePathPrefix: '/dj-tag/',
  archivePath: '/manga/',
  imageHosts: ['cdn.doujinhq.club', 'doujinhq.club'],
);

/// All sources bundled with the app. First entry is the default.
final List<MangaSource> availableSources = [
  topManhuaSource,
  manhwaToonSource,
  mangaYYSource,
  manhwaToonsSource,
  doujinHqSource,
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
    return Uri.parse(url).host.toLowerCase();
  } catch (_) {
    return null;
  }
}

/// Returns the source with the given [id], falling back to the primary one.
MangaSource sourceById(String? id) {
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

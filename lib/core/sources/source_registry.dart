import 'madara_source.dart';
import 'manga_source.dart';

/// The ManhwaToon source (primary / default).
final MadaraSource manhwaToonSource = MadaraSource(
  id: 'manhwatoon',
  name: 'ManhwaToon',
  baseUrl: 'https://www.manhwatoon.me',
  genrePathPrefix: '/manhwa-genre/',
);

/// A secondary Madara-based source providing additional manga / manhwa.
final MadaraSource mangaYYSource = MadaraSource(
  id: 'mangayy',
  name: 'MangaYY',
  baseUrl: 'https://mangayy.org',
  genrePathPrefix: '/manga-genre/',
);

/// All sources bundled with the app.
final List<MangaSource> availableSources = [manhwaToonSource, mangaYYSource];

/// Returns the source that hosts [url], falling back to the primary source.
MangaSource sourceForUrl(String url) {
  return availableSources.firstWhere(
    (s) => url.startsWith(s.baseUrl),
    orElse: () => manhwaToonSource,
  );
}

/// Returns the source with the given [id], falling back to the primary one.
MangaSource sourceById(String? id) {
  return availableSources.firstWhere(
    (s) => s.id == id,
    orElse: () => manhwaToonSource,
  );
}

/// HTTP headers required to fetch an image hosted by a source.
///
/// Some Madara deployments (e.g. MangaYY) serve covers and chapter images
/// from domains that return 403 unless a `Referer` header for the site is sent.
Map<String, String> sourceImageHeaders(String url) {
  return {'referer': '${sourceForUrl(url).baseUrl}/'};
}

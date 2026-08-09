/// Application-wide constants for the content source and configuration.
library;

class AppConstants {
  AppConstants._();

  /// Base URL of the content source (WordPress / Madara manga site).
  static const String siteBaseUrl = 'https://www.manhwatoon.me';

  /// User agent used for all outgoing requests.
  static const String userAgent =
      'ManhwaToonApp/1.0 (Android; like Gecko) Chrome/120.0 Safari/537.36';

  /// Number of items rendered per listing page by the site.
  static const int perPage = 24;

  /// Maximum number of chapters queued at once for "download all".
  static const int maxConcurrentChapters = 2;

  /// In-memory HTML cache TTL (milliseconds).
  static const Duration htmlCacheTtl = Duration(minutes: 10);

  /// Hard cap for a single HTML/API request. The server can hang (e.g. while
  /// stalling on a redirect) without triggering Dio's receive-timeout, so we
  /// enforce an explicit deadline on every call.
  static const Duration networkTimeout = Duration(seconds: 15);

  /// App name.
  static const String appName = 'ManhwaToon';

  /// Organization / package identifier prefix.
  static const String appPackage = 'com.manhwa.toon';
}

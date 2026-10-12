/// Application-wide constants for the content source and configuration.
library;

class AppConstants {
  AppConstants._();

  /// Base URL of the content source (WordPress / Madara manga site).
  static const String siteBaseUrl = 'https://www.manhwatoon.me';

  /// Browser-like UA. Custom app UAs are often blocked by Cloudflare/WAF.
  static const String userAgent =
      'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.6778.135 Mobile Safari/537.36';

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

  /// How long to wait after launch (or after the last ad) before the next
  /// genuine tap opens the promotional URL.
  ///
  /// Production: `Duration(minutes: 10)`
  /// Testing:    `Duration(seconds: 10)`
  static const Duration adInterval = Duration(minutes: 10);

  /// Promotional URL opened in the external browser.
  static const String adUrl =
      'https://disintegratespeck.com/c95vrpujs6?key=0fbdadf5039224e7a9cbc1d47bb6206d';
}

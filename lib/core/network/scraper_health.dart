import 'package:flutter/foundation.dart';

/// Tracks scraper sanity warnings.
///
/// All parsing is CSS-selector based against the upstream Madara WordPress
/// theme. If a site tweaks its markup, selectors silently return empty lists —
/// the typical cause of "nothing loads" point-fix releases. When a parse that
/// is expected to return items returns 0 despite a successful HTTP call,
/// [report] records it so the breakage is caught (local log + debug banner in
/// dev builds) before users hit it.
class ScraperHealth {
  ScraperHealth._();

  /// Most recent warning, exposed to a debug-only banner in the app shell.
  static final ValueNotifier<String?> lastWarning = ValueNotifier<String?>(null);

  /// Total warnings recorded during this process lifetime.
  static int warningCount = 0;

  static void report(String sourceName, String kind) {
    final message =
        '[$sourceName] "$kind" returned 0 items (parser may be out of date)';
    warningCount++;
    lastWarning.value = message;
    if (kDebugMode) {
      debugPrint('[scraper-health] $message');
    }
  }

  static void clear() {
    warningCount = 0;
    lastWarning.value = null;
  }
}

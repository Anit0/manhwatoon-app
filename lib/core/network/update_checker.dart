import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Metadata for an available app update.
class AppUpdate {
  const AppUpdate({
    required this.version,
    required this.url,
    this.notes,
    this.publishedAt,
  });

  final String version;
  final String url;
  final String? notes;
  final DateTime? publishedAt;
}

/// Checks the GitHub releases feed for a newer version of the app.
class UpdateChecker {
  UpdateChecker({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              headers: const {'User-Agent': 'ManhwaToonApp/1.0'},
            ));

  static const String repo = 'Anit0/manhwatoon-app';

  final Dio _dio;

  /// Returns the latest release if it is newer than the running version,
  /// otherwise `null`. Network / parse failures also yield `null` (callers
  /// treat that as "could not check").
  Future<AppUpdate?> check({String? currentVersion}) async {
    final current = currentVersion ?? await _currentVersion();
    try {
      final response = await _dio.get<String>(
        'https://api.github.com/repos/$repo/releases/latest',
      );
      final data = jsonDecode(response.data ?? '') as Map<String, dynamic>;
      final name = data['name']?.toString() ?? '';
      final tag = data['tag_name']?.toString() ?? '';
      final latest = extractVersion('$name $tag');
      if (latest == null || !isNewerVersion(latest, current)) return null;
      return AppUpdate(
        version: latest,
        notes: data['body']?.toString(),
        url: data['html_url']?.toString() ??
            'https://github.com/$repo/releases/latest',
        publishedAt: DateTime.tryParse(data['published_at']?.toString() ?? ''),
      );
    } catch (_) {
      return null;
    }
  }

  /// Extracts a semver-like version (e.g. `1.2.3`) from a release name/tag.
  static String? extractVersion(String raw) {
    final match = RegExp(r'v?(\d+\.\d+(\.\d+)?)').firstMatch(raw);
    return match?.group(1);
  }

  /// True when [latest] is a higher version than [current].
  static bool isNewerVersion(String latest, String current) {
    final a = _parts(latest);
    final b = _parts(current);
    for (var i = 0; i < 3; i++) {
      final x = i < a.length ? a[i] : 0;
      final y = i < b.length ? b[i] : 0;
      if (x != y) return x > y;
    }
    return false;
  }

  static List<int> _parts(String version) =>
      version.split('.').map(int.tryParse).whereType<int>().toList();

  static Future<String> _currentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }
}

/// Domain model for a chapter of a manga series.
library;

import 'package:flutter/foundation.dart';

@immutable
class Chapter {
  const Chapter({
    required this.url,
    required this.title,
    this.name,
    this.date,
    this.volume,
    this.postId,
    this.pageCount,
  });

  final String url;
  final String title;

  /// Chapter slug without the manga prefix, e.g. "chapter-4".
  final String? name;

  final DateTime? date;
  final String? volume;
  final int? postId;
  final int? pageCount;

  /// Relative URL, e.g. "/manhwa/slug/chapter-4/".
  String get relativeUrl {
    final base = Uri.parse(url);
    return '${base.path}${base.hasQuery ? '?${base.query}' : ''}';
  }

  Chapter copyWith({String? title, int? pageCount}) {
    return Chapter(
      url: url,
      title: title ?? this.title,
      name: name,
      date: date,
      volume: volume,
      postId: postId,
      pageCount: pageCount ?? this.pageCount,
    );
  }

  /// Extracts a chapter number for sorting, or null if none found.
  int? get chapterNumber {
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(title);
    if (match == null) return null;
    return double.tryParse(match.group(1)!)?.round();
  }
}

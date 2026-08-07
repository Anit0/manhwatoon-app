/// Domain model for a manga series.
library;

import 'package:flutter/foundation.dart';

/// Library status a user can assign to a series.
enum LibraryStatus {
  planToRead('plan', 'Plan to Read'),
  reading('reading', 'Reading'),
  completed('completed', 'Completed'),
  dropped('dropped', 'Dropped');

  const LibraryStatus(this.value, this.label);
  final String value;
  final String label;

  static LibraryStatus? fromValue(String? value) {
    for (final s in LibraryStatus.values) {
      if (s.value == value) return s;
    }
    return null;
  }
}

/// Sort orderings supported by the content source archive.
enum SortOrder {
  latest('latest', 'Latest', 'Latest Updates'),
  rating('rating', 'Rating', 'Highest Rated'),
  trending('trending', 'Trending', 'Trending'),
  views('views', 'Most Views', 'Most Viewed'),
  alphabet('alphabet', 'A-Z', 'Alphabetical'),
  newManga('new-manga', 'New', 'New Releases');

  const SortOrder(this.query, this.label, this.title);
  final String query;
  final String label;
  final String title;
}

@immutable
class Manga {
  const Manga({
    required this.url,
    required this.title,
    this.coverUrl,
    this.rating,
    this.latestChapterTitle,
    this.latestChapterUrl,
    this.latestChapterTime,
    this.status,
    this.genres = const [],
    this.type,
    this.releaseYear,
    this.authors = const [],
    this.artists = const [],
    this.alternativeNames = const [],
    this.summary,
    this.views,
    this.postId,
    this.isAdult = false,
  });

  /// Canonical page URL, e.g. https://www.manhwatoon.me/manhwa/slug/
  final String url;

  final String title;
  final String? coverUrl;
  final double? rating;
  final String? latestChapterTitle;
  final String? latestChapterUrl;
  final DateTime? latestChapterTime;

  /// Site status: "OnGoing", "Completed", ...
  final String? status;

  final List<String> genres;
  final String? type;
  final String? releaseYear;
  final List<String> authors;
  final List<String> artists;
  final List<String> alternativeNames;
  final String? summary;
  final int? views;
  final int? postId;
  final bool isAdult;

  /// The URL slug used to build chapter-list / download paths.
  String get slug {
    final trimmed = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    final parts = trimmed.split('/');
    return parts.isNotEmpty ? parts.last : '';
  }

  String get statusLabel => status ?? 'Unknown';

  Manga copyWith({
    String? title,
    String? coverUrl,
    double? rating,
    String? latestChapterTitle,
    String? latestChapterUrl,
    DateTime? latestChapterTime,
    String? status,
    List<String>? genres,
    String? type,
    String? releaseYear,
    List<String>? authors,
    List<String>? artists,
    List<String>? alternativeNames,
    String? summary,
    int? views,
    int? postId,
    bool? isAdult,
  }) {
    return Manga(
      url: url,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      rating: rating ?? this.rating,
      latestChapterTitle: latestChapterTitle ?? this.latestChapterTitle,
      latestChapterUrl: latestChapterUrl ?? this.latestChapterUrl,
      latestChapterTime: latestChapterTime ?? this.latestChapterTime,
      status: status ?? this.status,
      genres: genres ?? this.genres,
      type: type ?? this.type,
      releaseYear: releaseYear ?? this.releaseYear,
      authors: authors ?? this.authors,
      artists: artists ?? this.artists,
      alternativeNames: alternativeNames ?? this.alternativeNames,
      summary: summary ?? this.summary,
      views: views ?? this.views,
      postId: postId ?? this.postId,
      isAdult: isAdult ?? this.isAdult,
    );
  }
}

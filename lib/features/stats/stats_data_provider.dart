import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';

/// Aggregated reading statistics.
class ReadingStats {
  const ReadingStats({
    this.chaptersRead = 0,
    this.pagesRead = 0,
    this.totalDuration = Duration.zero,
    this.completedManga = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalReadDays = 0,
    this.favoriteGenre,
    this.favoriteAuthor,
    this.calendar = const {},
    this.monthlyPages = 0,
    this.monthlyDuration = Duration.zero,
  });

  final int chaptersRead;
  final int pagesRead;
  final Duration totalDuration;
  final int completedManga;
  final int currentStreak;
  final int longestStreak;
  final int totalReadDays;
  final String? favoriteGenre;
  final String? favoriteAuthor;

  /// day -> pages read, for the last ~12 weeks.
  final Map<DateTime, int> calendar;
  final int monthlyPages;
  final Duration monthlyDuration;
}

final statsProvider = FutureProvider<ReadingStats>((ref) async {
  final repo = ref.watch(repositoryProvider);

  final sessions = await repo.getReadingSessions();
  final history = await repo.getHistory(limit: 5000);
  final library = await repo.getLibraryItems();

  var pagesRead = 0;
  var chaptersRead = 0;
  var duration = Duration.zero;
  final dayPages = <DateTime, int>{};

  for (final s in sessions) {
    pagesRead += s.pagesRead;
    chaptersRead += 1;
    duration += Duration(seconds: s.durationSeconds);
    final day = DateTime(s.sessionDate.year, s.sessionDate.month, s.sessionDate.day);
    dayPages[day] = (dayPages[day] ?? 0) + s.pagesRead;
  }

  if (history.isNotEmpty) {
    for (final h in history) {
      if (!dayPages.containsKey(DateTime(h.readAt.year, h.readAt.month, h.readAt.day))) {
        chaptersRead += 1;
      }
    }
  }

  final completedManga = library.where((l) => l.status == 'completed').length;

  final streak = _computeStreaks(dayPages.keys.toList());
  final totalReadDays = dayPages.length;

  // Favorite genre & author from library.
  final genreCounts = <String, int>{};
  final authorCounts = <String, int>{};
  for (final item in library) {
    if (item.genres != null) {
      for (final g in item.genres!.split(',')) {
        final name = g.trim();
        if (name.isNotEmpty) genreCounts[name] = (genreCounts[name] ?? 0) + 1;
      }
    }
    if (item.author != null) {
      for (final a in item.author!.split(',')) {
        final name = a.trim();
        if (name.isNotEmpty) authorCounts[name] = (authorCounts[name] ?? 0) + 1;
      }
    }
  }
  String? favoriteGenre = _topKey(genreCounts);
  String? favoriteAuthor = _topKey(authorCounts);

  // Monthly totals.
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month);
  var monthlyPages = 0;
  var monthlyDuration = Duration.zero;
  for (final s in sessions) {
    if (!s.sessionDate.isBefore(monthStart)) {
      monthlyPages += s.pagesRead;
      monthlyDuration += Duration(seconds: s.durationSeconds);
    }
  }

  return ReadingStats(
    chaptersRead: chaptersRead,
    pagesRead: pagesRead,
    totalDuration: duration,
    completedManga: completedManga,
    currentStreak: streak.$1,
    longestStreak: streak.$2,
    totalReadDays: totalReadDays,
    favoriteGenre: favoriteGenre,
    favoriteAuthor: favoriteAuthor,
    calendar: dayPages,
    monthlyPages: monthlyPages,
    monthlyDuration: monthlyDuration,
  );
});

String? _topKey(Map<String, int> counts) {
  if (counts.isEmpty) return null;
  final entry = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
  return entry.value > 0 ? entry.key : null;
}

(int, int) _computeStreaks(List<DateTime> days) {
  if (days.isEmpty) return (0, 0);
  final sorted = days.toSet().toList()..sort();
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);

  var current = 0;
  var pointer = todayDate;
  if (!sorted.contains(pointer)) pointer = pointer.subtract(const Duration(days: 1));
  while (sorted.contains(pointer)) {
    current++;
    pointer = pointer.subtract(const Duration(days: 1));
  }

  var longest = 0;
  var run = 1;
  for (var i = 1; i < sorted.length; i++) {
    if (sorted[i].difference(sorted[i - 1]).inDays == 1) {
      run++;
      if (run > longest) longest = run;
    } else {
      run = 1;
    }
  }
  if (sorted.length == 1) longest = 1;
  return (current, longest);
}

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';
import 'settings_provider.dart';

/// Pages reached in a chapter (`pageIndex` is 0-based).
class ChapterPageProgress {
  const ChapterPageProgress({
    required this.pageIndex,
    required this.totalPages,
  });

  final int pageIndex;
  final int totalPages;

  int get pageNumber =>
      totalPages <= 0 ? 0 : (pageIndex + 1).clamp(1, totalPages);

  bool get completed => totalPages > 0 && pageNumber >= totalPages;

  String get label => totalPages > 0 ? '$pageNumber/$totalPages' : '';

  Map<String, int> toJson() => {
        'pageIndex': pageIndex,
        'totalPages': totalPages,
      };

  factory ChapterPageProgress.fromJson(Map<String, dynamic> json) {
    return ChapterPageProgress(
      pageIndex: (json['pageIndex'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Local extras that do not live in Drift: notes, chapter bookmarks, read marks.
class UserExtras {
  const UserExtras({
    this.notes = const {},
    this.bookmarkedChapters = const {},
    this.readChapters = const {},
    this.chapterProgress = const {},
  });

  final Map<String, String> notes;
  final Set<String> bookmarkedChapters;
  final Set<String> readChapters;
  final Map<String, ChapterPageProgress> chapterProgress;

  String noteFor(String mangaUrl) => notes[mangaUrl] ?? '';

  bool isChapterBookmarked(String chapterUrl) =>
      bookmarkedChapters.contains(chapterUrl);

  bool isChapterRead(String chapterUrl) => readChapters.contains(chapterUrl);

  ChapterPageProgress? progressFor(String chapterUrl) =>
      chapterProgress[chapterUrl];

  UserExtras copyWith({
    Map<String, String>? notes,
    Set<String>? bookmarkedChapters,
    Set<String>? readChapters,
    Map<String, ChapterPageProgress>? chapterProgress,
  }) {
    return UserExtras(
      notes: notes ?? this.notes,
      bookmarkedChapters: bookmarkedChapters ?? this.bookmarkedChapters,
      readChapters: readChapters ?? this.readChapters,
      chapterProgress: chapterProgress ?? this.chapterProgress,
    );
  }

  Map<String, dynamic> toJson() => {
        'notes': notes,
        'bookmarkedChapters': bookmarkedChapters.toList(),
        'readChapters': readChapters.toList(),
        'chapterProgress': {
          for (final e in chapterProgress.entries) e.key: e.value.toJson(),
        },
      };

  factory UserExtras.fromJson(Map<String, dynamic> json) {
    Map<String, String> notes = {};
    final notesRaw = json['notes'];
    if (notesRaw is Map) {
      notes = {
        for (final e in notesRaw.entries)
          if (e.key is String && e.value is String) e.key as String: e.value as String,
      };
    }
    Set<String> bookmarks = {};
    final bmRaw = json['bookmarkedChapters'];
    if (bmRaw is List) {
      bookmarks = {for (final v in bmRaw) if (v is String) v};
    }
    Set<String> read = {};
    final readRaw = json['readChapters'];
    if (readRaw is List) {
      read = {for (final v in readRaw) if (v is String) v};
    }
    Map<String, ChapterPageProgress> progress = {};
    final progressRaw = json['chapterProgress'];
    if (progressRaw is Map) {
      for (final e in progressRaw.entries) {
        if (e.key is! String || e.value is! Map) continue;
        progress[e.key as String] = ChapterPageProgress.fromJson(
          Map<String, dynamic>.from(e.value as Map),
        );
      }
    }
    return UserExtras(
      notes: notes,
      bookmarkedChapters: bookmarks,
      readChapters: read,
      chapterProgress: progress,
    );
  }
}

class ExtrasNotifier extends Notifier<UserExtras> {
  @override
  UserExtras build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    if (prefs == null) return const UserExtras();
    return _fromPrefs(prefs);
  }

  UserExtras _fromPrefs(SharedPreferences prefs) {
    Map<String, String> notes = {};
    final notesRaw = prefs.getString(StorageKeys.mangaNotes);
    if (notesRaw != null) {
      final decoded = jsonDecode(notesRaw);
      if (decoded is Map) {
        notes = {
          for (final e in decoded.entries)
            if (e.key is String && e.value is String) e.key as String: e.value as String,
        };
      }
    }
    Set<String> bookmarks = {};
    final bmRaw = prefs.getString(StorageKeys.bookmarkedChapters);
    if (bmRaw != null) {
      final decoded = jsonDecode(bmRaw);
      if (decoded is List) {
        bookmarks = {for (final v in decoded) if (v is String) v};
      }
    }
    Set<String> read = {};
    final readRaw = prefs.getString(StorageKeys.readChapters);
    if (readRaw != null) {
      final decoded = jsonDecode(readRaw);
      if (decoded is List) {
        read = {for (final v in decoded) if (v is String) v};
      }
    }
    Map<String, ChapterPageProgress> progress = {};
    final progressRaw = prefs.getString(StorageKeys.chapterProgress);
    if (progressRaw != null) {
      final decoded = jsonDecode(progressRaw);
      if (decoded is Map) {
        for (final e in decoded.entries) {
          if (e.key is! String || e.value is! Map) continue;
          progress[e.key as String] = ChapterPageProgress.fromJson(
            Map<String, dynamic>.from(e.value as Map),
          );
        }
      }
    }
    return UserExtras(
      notes: notes,
      bookmarkedChapters: bookmarks,
      readChapters: read,
      chapterProgress: progress,
    );
  }

  Future<void> _persist(UserExtras next) async {
    final prefs = ref.read(sharedPreferencesProvider) ??
        await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.mangaNotes, jsonEncode(next.notes));
    await prefs.setString(
      StorageKeys.bookmarkedChapters,
      jsonEncode(next.bookmarkedChapters.toList()),
    );
    await prefs.setString(
      StorageKeys.readChapters,
      jsonEncode(next.readChapters.toList()),
    );
    await prefs.setString(
      StorageKeys.chapterProgress,
      jsonEncode({
        for (final e in next.chapterProgress.entries) e.key: e.value.toJson(),
      }),
    );
    state = next;
  }

  Future<void> setNote(String mangaUrl, String note) async {
    final next = Map<String, String>.from(state.notes);
    if (note.trim().isEmpty) {
      next.remove(mangaUrl);
    } else {
      next[mangaUrl] = note.trim();
    }
    await _persist(state.copyWith(notes: next));
  }

  Future<void> toggleChapterBookmark(String chapterUrl) async {
    final next = {...state.bookmarkedChapters};
    if (!next.add(chapterUrl)) next.remove(chapterUrl);
    await _persist(state.copyWith(bookmarkedChapters: next));
  }

  Future<void> markChaptersRead(Iterable<String> urls, {bool read = true}) async {
    final next = {...state.readChapters};
    final progress = Map<String, ChapterPageProgress>.from(state.chapterProgress);
    if (read) {
      next.addAll(urls);
      for (final url in urls) {
        final existing = progress[url];
        if (existing != null && existing.totalPages > 0) {
          progress[url] = ChapterPageProgress(
            pageIndex: existing.totalPages - 1,
            totalPages: existing.totalPages,
          );
        }
      }
    } else {
      next.removeAll(urls);
      for (final url in urls) {
        progress.remove(url);
      }
    }
    await _persist(state.copyWith(readChapters: next, chapterProgress: progress));
  }

  Future<void> toggleChapterRead(String chapterUrl) async {
    final markRead = !state.readChapters.contains(chapterUrl);
    await markChaptersRead([chapterUrl], read: markRead);
  }

  Future<void> setChapterProgress(
    String chapterUrl, {
    required int pageIndex,
    required int totalPages,
  }) async {
    if (chapterUrl.isEmpty || totalPages <= 0) return;
    final progress = Map<String, ChapterPageProgress>.from(state.chapterProgress);
    progress[chapterUrl] = ChapterPageProgress(
      pageIndex: pageIndex,
      totalPages: totalPages,
    );
    final read = {...state.readChapters};
    if (pageIndex + 1 >= totalPages) {
      read.add(chapterUrl);
    }
    await _persist(state.copyWith(chapterProgress: progress, readChapters: read));
  }

  Future<void> mergeFromJson(dynamic raw) async {
    if (raw is! Map) return;
    final incoming = UserExtras.fromJson(Map<String, dynamic>.from(raw));
    await _persist(UserExtras(
      notes: {...state.notes, ...incoming.notes},
      bookmarkedChapters: {
        ...state.bookmarkedChapters,
        ...incoming.bookmarkedChapters,
      },
      readChapters: {...state.readChapters, ...incoming.readChapters},
      chapterProgress: {
        ...state.chapterProgress,
        ...incoming.chapterProgress,
      },
    ));
  }
}

final extrasProvider =
    NotifierProvider<ExtrasNotifier, UserExtras>(ExtrasNotifier.new);

import '../../core/database/app_database.dart';

/// Mihon-style library search.
///
/// Supports field prefixes, comparison operators, and boolean combinators:
/// `title:solo author:kim genre:action unread:>0 status:reading`
/// `&&` / implicit AND, `||` OR, `-term` negation.
class LibrarySearch {
  LibrarySearch._();

  static bool matches(
    LibraryItem item,
    String rawQuery, {
    String notes = '',
    int unreadCount = 0,
    int totalChapters = 0,
    bool downloaded = false,
  }) {
    final query = rawQuery.trim();
    if (query.isEmpty) return true;
    final orGroups = query.split(RegExp(r'\s*\|\|\s*'));
    return orGroups.any((group) => _matchesAndGroup(
          item,
          group,
          notes: notes,
          unreadCount: unreadCount,
          totalChapters: totalChapters,
          downloaded: downloaded,
        ));
  }

  static bool _matchesAndGroup(
    LibraryItem item,
    String group, {
    required String notes,
    required int unreadCount,
    required int totalChapters,
    required bool downloaded,
  }) {
    final tokens = group
        .split(RegExp(r'\s+&&\s+|\s+'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty);
    for (final token in tokens) {
      final negated = token.startsWith('-') && token.length > 1;
      final term = negated ? token.substring(1) : token;
      final hit = _matchesTerm(
        item,
        term,
        notes: notes,
        unreadCount: unreadCount,
        totalChapters: totalChapters,
        downloaded: downloaded,
      );
      if (negated ? hit : !hit) return false;
    }
    return true;
  }

  static bool _matchesTerm(
    LibraryItem item,
    String term, {
    required String notes,
    required int unreadCount,
    required int totalChapters,
    required bool downloaded,
  }) {
    final split = term.indexOf(':');
    if (split > 0 && split < term.length - 1) {
      final prefix = term.substring(0, split).toLowerCase();
      final value = term.substring(split + 1).trim();
      return _matchesPrefix(
        item,
        prefix,
        value,
        notes: notes,
        unreadCount: unreadCount,
        totalChapters: totalChapters,
        downloaded: downloaded,
      );
    }
    return _haystack(item, notes).contains(term.toLowerCase());
  }

  static bool _matchesPrefix(
    LibraryItem item,
    String prefix,
    String value, {
    required String notes,
    required int unreadCount,
    required int totalChapters,
    required bool downloaded,
  }) {
    final v = value.toLowerCase();
    final empty = v == '""' || v == "''";
    switch (prefix) {
      case 'title':
        return empty
            ? item.title.trim().isEmpty
            : item.title.toLowerCase().contains(v);
      case 'author':
      case 'artist':
        final author = (item.author ?? '').toLowerCase();
        return empty ? author.isEmpty : author.contains(v);
      case 'genre':
      case 'tag':
        final genres = (item.genres ?? '').toLowerCase();
        return empty ? genres.isEmpty : genres.contains(v);
      case 'notes':
      case 'note':
        return empty ? notes.trim().isEmpty : notes.toLowerCase().contains(v);
      case 'status':
        return (item.status ?? '').toLowerCase() == v ||
            (item.status ?? '').toLowerCase().contains(v);
      case 'source':
      case 'src':
        return item.mangaUrl.toLowerCase().contains(v);
      case 'unread':
        return _compareNumber(unreadCount, value);
      case 'read':
        return _compareNumber(totalChapters - unreadCount, value);
      case 'total':
        return _compareNumber(totalChapters, value);
      case 'downloaded':
      case 'dl':
        return downloaded == (v == '1' || v == 'true' || v == 'yes');
      default:
        return _haystack(item, notes).contains('$prefix:$v');
    }
  }

  static bool _compareNumber(int actual, String raw) {
    final trimmed = raw.trim();
    final match = RegExp(r'^(>=|<=|>|<|=)?\s*(-?\d+)$').firstMatch(trimmed);
    if (match == null) return actual.toString() == trimmed;
    final op = match.group(1) ?? '=';
    final n = int.parse(match.group(2)!);
    return switch (op) {
      '>' => actual > n,
      '>=' => actual >= n,
      '<' => actual < n,
      '<=' => actual <= n,
      _ => actual == n,
    };
  }

  static String _haystack(LibraryItem item, String notes) {
    return [
      item.title,
      item.author ?? '',
      item.genres ?? '',
      item.status ?? '',
      item.type ?? '',
      notes,
    ].join(' ').toLowerCase();
  }
}

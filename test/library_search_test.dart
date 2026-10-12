import 'package:flutter_test/flutter_test.dart';
import 'package:manhwa_toon/core/database/app_database.dart';
import 'package:manhwa_toon/core/library/library_search.dart';

LibraryItem item({
  String title = 'Solo Leveling',
  String? author = 'Chugong',
  String? genres = 'Action,Fantasy',
  String? status = 'reading',
}) {
  return LibraryItem(
    mangaUrl: 'https://example.com/${title.toLowerCase().replaceAll(' ', '-')}',
    title: title,
    favorite: false,
    bookmark: false,
    status: status,
    addedAt: DateTime(2024, 1, 1),
    author: author,
    genres: genres,
    isAdult: false,
  );
}

void main() {
  test('empty query matches everything', () {
    expect(LibrarySearch.matches(item(), ''), isTrue);
    expect(LibrarySearch.matches(item(), '   '), isTrue);
  });

  test('plain text searches title author and genres', () {
    expect(LibrarySearch.matches(item(), 'solo'), isTrue);
    expect(LibrarySearch.matches(item(), 'chugong'), isTrue);
    expect(LibrarySearch.matches(item(), 'action'), isTrue);
    expect(LibrarySearch.matches(item(), 'romance'), isFalse);
  });

  test('field prefixes filter the matching column', () {
    expect(LibrarySearch.matches(item(), 'title:solo'), isTrue);
    expect(LibrarySearch.matches(item(), 'title:tower'), isFalse);
    expect(LibrarySearch.matches(item(), 'author:kim'), isFalse);
    expect(LibrarySearch.matches(item(), 'author:chugong'), isTrue);
    expect(LibrarySearch.matches(item(), 'genre:fantasy'), isTrue);
    expect(LibrarySearch.matches(item(), 'status:reading'), isTrue);
  });

  test('unread comparison operators', () {
    expect(
      LibrarySearch.matches(item(), 'unread:>0', unreadCount: 3),
      isTrue,
    );
    expect(
      LibrarySearch.matches(item(), 'unread:>0', unreadCount: 0),
      isFalse,
    );
    expect(
      LibrarySearch.matches(item(), 'unread:>=2', unreadCount: 2),
      isTrue,
    );
  });

  test('|| is OR and implicit tokens are AND', () {
    expect(LibrarySearch.matches(item(), 'title:solo || title:tower'), isTrue);
    expect(LibrarySearch.matches(item(), 'title:solo genre:romance'), isFalse);
    expect(LibrarySearch.matches(item(), 'title:solo genre:action'), isTrue);
  });

  test('-term negates a match', () {
    expect(LibrarySearch.matches(item(), '-romance'), isTrue);
    expect(LibrarySearch.matches(item(), '-action'), isFalse);
    expect(LibrarySearch.matches(item(), 'title:solo -genre:romance'), isTrue);
  });

  test('notes prefix uses extras notes', () {
    expect(
      LibrarySearch.matches(item(), 'notes:reread', notes: 'Need to reread'),
      isTrue,
    );
    expect(
      LibrarySearch.matches(item(), 'notes:reread', notes: ''),
      isFalse,
    );
  });
}

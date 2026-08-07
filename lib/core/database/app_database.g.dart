// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LibraryItemsTable extends LibraryItems
    with TableInfo<$LibraryItemsTable, LibraryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mangaUrlMeta = const VerificationMeta(
    'mangaUrl',
  );
  @override
  late final GeneratedColumn<String> mangaUrl = GeneratedColumn<String>(
    'manga_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _postIdMeta = const VerificationMeta('postId');
  @override
  late final GeneratedColumn<int> postId = GeneratedColumn<int>(
    'post_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _favoriteMeta = const VerificationMeta(
    'favorite',
  );
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
    'favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _bookmarkMeta = const VerificationMeta(
    'bookmark',
  );
  @override
  late final GeneratedColumn<bool> bookmark = GeneratedColumn<bool>(
    'bookmark',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("bookmark" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastReadAtMeta = const VerificationMeta(
    'lastReadAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReadAt = GeneratedColumn<DateTime>(
    'last_read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastChapterTitleMeta = const VerificationMeta(
    'lastChapterTitle',
  );
  @override
  late final GeneratedColumn<String> lastChapterTitle = GeneratedColumn<String>(
    'last_chapter_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastChapterUrlMeta = const VerificationMeta(
    'lastChapterUrl',
  );
  @override
  late final GeneratedColumn<String> lastChapterUrl = GeneratedColumn<String>(
    'last_chapter_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genresMeta = const VerificationMeta('genres');
  @override
  late final GeneratedColumn<String> genres = GeneratedColumn<String>(
    'genres',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _releaseYearMeta = const VerificationMeta(
    'releaseYear',
  );
  @override
  late final GeneratedColumn<String> releaseYear = GeneratedColumn<String>(
    'release_year',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isAdultMeta = const VerificationMeta(
    'isAdult',
  );
  @override
  late final GeneratedColumn<bool> isAdult = GeneratedColumn<bool>(
    'is_adult',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_adult" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    mangaUrl,
    title,
    coverUrl,
    postId,
    favorite,
    bookmark,
    status,
    addedAt,
    lastReadAt,
    lastChapterTitle,
    lastChapterUrl,
    genres,
    author,
    type,
    releaseYear,
    isAdult,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('manga_url')) {
      context.handle(
        _mangaUrlMeta,
        mangaUrl.isAcceptableOrUnknown(data['manga_url']!, _mangaUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_mangaUrlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('post_id')) {
      context.handle(
        _postIdMeta,
        postId.isAcceptableOrUnknown(data['post_id']!, _postIdMeta),
      );
    }
    if (data.containsKey('favorite')) {
      context.handle(
        _favoriteMeta,
        favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta),
      );
    }
    if (data.containsKey('bookmark')) {
      context.handle(
        _bookmarkMeta,
        bookmark.isAcceptableOrUnknown(data['bookmark']!, _bookmarkMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    if (data.containsKey('last_read_at')) {
      context.handle(
        _lastReadAtMeta,
        lastReadAt.isAcceptableOrUnknown(
          data['last_read_at']!,
          _lastReadAtMeta,
        ),
      );
    }
    if (data.containsKey('last_chapter_title')) {
      context.handle(
        _lastChapterTitleMeta,
        lastChapterTitle.isAcceptableOrUnknown(
          data['last_chapter_title']!,
          _lastChapterTitleMeta,
        ),
      );
    }
    if (data.containsKey('last_chapter_url')) {
      context.handle(
        _lastChapterUrlMeta,
        lastChapterUrl.isAcceptableOrUnknown(
          data['last_chapter_url']!,
          _lastChapterUrlMeta,
        ),
      );
    }
    if (data.containsKey('genres')) {
      context.handle(
        _genresMeta,
        genres.isAcceptableOrUnknown(data['genres']!, _genresMeta),
      );
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('release_year')) {
      context.handle(
        _releaseYearMeta,
        releaseYear.isAcceptableOrUnknown(
          data['release_year']!,
          _releaseYearMeta,
        ),
      );
    }
    if (data.containsKey('is_adult')) {
      context.handle(
        _isAdultMeta,
        isAdult.isAcceptableOrUnknown(data['is_adult']!, _isAdultMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mangaUrl};
  @override
  LibraryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryItem(
      mangaUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manga_url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      postId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}post_id'],
      ),
      favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorite'],
      )!,
      bookmark: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}bookmark'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      lastReadAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_read_at'],
      ),
      lastChapterTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_chapter_title'],
      ),
      lastChapterUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_chapter_url'],
      ),
      genres: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genres'],
      ),
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      ),
      releaseYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}release_year'],
      ),
      isAdult: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_adult'],
      )!,
    );
  }

  @override
  $LibraryItemsTable createAlias(String alias) {
    return $LibraryItemsTable(attachedDatabase, alias);
  }
}

class LibraryItem extends DataClass implements Insertable<LibraryItem> {
  final String mangaUrl;
  final String title;
  final String? coverUrl;
  final int? postId;
  final bool favorite;
  final bool bookmark;

  /// LibraryStatus value (plan/reading/completed/dropped) or null.
  final String? status;
  final DateTime addedAt;
  final DateTime? lastReadAt;
  final String? lastChapterTitle;
  final String? lastChapterUrl;
  final String? genres;
  final String? author;
  final String? type;
  final String? releaseYear;
  final bool isAdult;
  const LibraryItem({
    required this.mangaUrl,
    required this.title,
    this.coverUrl,
    this.postId,
    required this.favorite,
    required this.bookmark,
    this.status,
    required this.addedAt,
    this.lastReadAt,
    this.lastChapterTitle,
    this.lastChapterUrl,
    this.genres,
    this.author,
    this.type,
    this.releaseYear,
    required this.isAdult,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['manga_url'] = Variable<String>(mangaUrl);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || postId != null) {
      map['post_id'] = Variable<int>(postId);
    }
    map['favorite'] = Variable<bool>(favorite);
    map['bookmark'] = Variable<bool>(bookmark);
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    if (!nullToAbsent || lastReadAt != null) {
      map['last_read_at'] = Variable<DateTime>(lastReadAt);
    }
    if (!nullToAbsent || lastChapterTitle != null) {
      map['last_chapter_title'] = Variable<String>(lastChapterTitle);
    }
    if (!nullToAbsent || lastChapterUrl != null) {
      map['last_chapter_url'] = Variable<String>(lastChapterUrl);
    }
    if (!nullToAbsent || genres != null) {
      map['genres'] = Variable<String>(genres);
    }
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    if (!nullToAbsent || releaseYear != null) {
      map['release_year'] = Variable<String>(releaseYear);
    }
    map['is_adult'] = Variable<bool>(isAdult);
    return map;
  }

  LibraryItemsCompanion toCompanion(bool nullToAbsent) {
    return LibraryItemsCompanion(
      mangaUrl: Value(mangaUrl),
      title: Value(title),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      postId: postId == null && nullToAbsent
          ? const Value.absent()
          : Value(postId),
      favorite: Value(favorite),
      bookmark: Value(bookmark),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      addedAt: Value(addedAt),
      lastReadAt: lastReadAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReadAt),
      lastChapterTitle: lastChapterTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(lastChapterTitle),
      lastChapterUrl: lastChapterUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(lastChapterUrl),
      genres: genres == null && nullToAbsent
          ? const Value.absent()
          : Value(genres),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      releaseYear: releaseYear == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseYear),
      isAdult: Value(isAdult),
    );
  }

  factory LibraryItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryItem(
      mangaUrl: serializer.fromJson<String>(json['mangaUrl']),
      title: serializer.fromJson<String>(json['title']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      postId: serializer.fromJson<int?>(json['postId']),
      favorite: serializer.fromJson<bool>(json['favorite']),
      bookmark: serializer.fromJson<bool>(json['bookmark']),
      status: serializer.fromJson<String?>(json['status']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      lastReadAt: serializer.fromJson<DateTime?>(json['lastReadAt']),
      lastChapterTitle: serializer.fromJson<String?>(json['lastChapterTitle']),
      lastChapterUrl: serializer.fromJson<String?>(json['lastChapterUrl']),
      genres: serializer.fromJson<String?>(json['genres']),
      author: serializer.fromJson<String?>(json['author']),
      type: serializer.fromJson<String?>(json['type']),
      releaseYear: serializer.fromJson<String?>(json['releaseYear']),
      isAdult: serializer.fromJson<bool>(json['isAdult']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mangaUrl': serializer.toJson<String>(mangaUrl),
      'title': serializer.toJson<String>(title),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'postId': serializer.toJson<int?>(postId),
      'favorite': serializer.toJson<bool>(favorite),
      'bookmark': serializer.toJson<bool>(bookmark),
      'status': serializer.toJson<String?>(status),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'lastReadAt': serializer.toJson<DateTime?>(lastReadAt),
      'lastChapterTitle': serializer.toJson<String?>(lastChapterTitle),
      'lastChapterUrl': serializer.toJson<String?>(lastChapterUrl),
      'genres': serializer.toJson<String?>(genres),
      'author': serializer.toJson<String?>(author),
      'type': serializer.toJson<String?>(type),
      'releaseYear': serializer.toJson<String?>(releaseYear),
      'isAdult': serializer.toJson<bool>(isAdult),
    };
  }

  LibraryItem copyWith({
    String? mangaUrl,
    String? title,
    Value<String?> coverUrl = const Value.absent(),
    Value<int?> postId = const Value.absent(),
    bool? favorite,
    bool? bookmark,
    Value<String?> status = const Value.absent(),
    DateTime? addedAt,
    Value<DateTime?> lastReadAt = const Value.absent(),
    Value<String?> lastChapterTitle = const Value.absent(),
    Value<String?> lastChapterUrl = const Value.absent(),
    Value<String?> genres = const Value.absent(),
    Value<String?> author = const Value.absent(),
    Value<String?> type = const Value.absent(),
    Value<String?> releaseYear = const Value.absent(),
    bool? isAdult,
  }) => LibraryItem(
    mangaUrl: mangaUrl ?? this.mangaUrl,
    title: title ?? this.title,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    postId: postId.present ? postId.value : this.postId,
    favorite: favorite ?? this.favorite,
    bookmark: bookmark ?? this.bookmark,
    status: status.present ? status.value : this.status,
    addedAt: addedAt ?? this.addedAt,
    lastReadAt: lastReadAt.present ? lastReadAt.value : this.lastReadAt,
    lastChapterTitle: lastChapterTitle.present
        ? lastChapterTitle.value
        : this.lastChapterTitle,
    lastChapterUrl: lastChapterUrl.present
        ? lastChapterUrl.value
        : this.lastChapterUrl,
    genres: genres.present ? genres.value : this.genres,
    author: author.present ? author.value : this.author,
    type: type.present ? type.value : this.type,
    releaseYear: releaseYear.present ? releaseYear.value : this.releaseYear,
    isAdult: isAdult ?? this.isAdult,
  );
  LibraryItem copyWithCompanion(LibraryItemsCompanion data) {
    return LibraryItem(
      mangaUrl: data.mangaUrl.present ? data.mangaUrl.value : this.mangaUrl,
      title: data.title.present ? data.title.value : this.title,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      postId: data.postId.present ? data.postId.value : this.postId,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
      bookmark: data.bookmark.present ? data.bookmark.value : this.bookmark,
      status: data.status.present ? data.status.value : this.status,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      lastReadAt: data.lastReadAt.present
          ? data.lastReadAt.value
          : this.lastReadAt,
      lastChapterTitle: data.lastChapterTitle.present
          ? data.lastChapterTitle.value
          : this.lastChapterTitle,
      lastChapterUrl: data.lastChapterUrl.present
          ? data.lastChapterUrl.value
          : this.lastChapterUrl,
      genres: data.genres.present ? data.genres.value : this.genres,
      author: data.author.present ? data.author.value : this.author,
      type: data.type.present ? data.type.value : this.type,
      releaseYear: data.releaseYear.present
          ? data.releaseYear.value
          : this.releaseYear,
      isAdult: data.isAdult.present ? data.isAdult.value : this.isAdult,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryItem(')
          ..write('mangaUrl: $mangaUrl, ')
          ..write('title: $title, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('postId: $postId, ')
          ..write('favorite: $favorite, ')
          ..write('bookmark: $bookmark, ')
          ..write('status: $status, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastReadAt: $lastReadAt, ')
          ..write('lastChapterTitle: $lastChapterTitle, ')
          ..write('lastChapterUrl: $lastChapterUrl, ')
          ..write('genres: $genres, ')
          ..write('author: $author, ')
          ..write('type: $type, ')
          ..write('releaseYear: $releaseYear, ')
          ..write('isAdult: $isAdult')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    mangaUrl,
    title,
    coverUrl,
    postId,
    favorite,
    bookmark,
    status,
    addedAt,
    lastReadAt,
    lastChapterTitle,
    lastChapterUrl,
    genres,
    author,
    type,
    releaseYear,
    isAdult,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryItem &&
          other.mangaUrl == this.mangaUrl &&
          other.title == this.title &&
          other.coverUrl == this.coverUrl &&
          other.postId == this.postId &&
          other.favorite == this.favorite &&
          other.bookmark == this.bookmark &&
          other.status == this.status &&
          other.addedAt == this.addedAt &&
          other.lastReadAt == this.lastReadAt &&
          other.lastChapterTitle == this.lastChapterTitle &&
          other.lastChapterUrl == this.lastChapterUrl &&
          other.genres == this.genres &&
          other.author == this.author &&
          other.type == this.type &&
          other.releaseYear == this.releaseYear &&
          other.isAdult == this.isAdult);
}

class LibraryItemsCompanion extends UpdateCompanion<LibraryItem> {
  final Value<String> mangaUrl;
  final Value<String> title;
  final Value<String?> coverUrl;
  final Value<int?> postId;
  final Value<bool> favorite;
  final Value<bool> bookmark;
  final Value<String?> status;
  final Value<DateTime> addedAt;
  final Value<DateTime?> lastReadAt;
  final Value<String?> lastChapterTitle;
  final Value<String?> lastChapterUrl;
  final Value<String?> genres;
  final Value<String?> author;
  final Value<String?> type;
  final Value<String?> releaseYear;
  final Value<bool> isAdult;
  final Value<int> rowid;
  const LibraryItemsCompanion({
    this.mangaUrl = const Value.absent(),
    this.title = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.postId = const Value.absent(),
    this.favorite = const Value.absent(),
    this.bookmark = const Value.absent(),
    this.status = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.lastReadAt = const Value.absent(),
    this.lastChapterTitle = const Value.absent(),
    this.lastChapterUrl = const Value.absent(),
    this.genres = const Value.absent(),
    this.author = const Value.absent(),
    this.type = const Value.absent(),
    this.releaseYear = const Value.absent(),
    this.isAdult = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryItemsCompanion.insert({
    required String mangaUrl,
    required String title,
    this.coverUrl = const Value.absent(),
    this.postId = const Value.absent(),
    this.favorite = const Value.absent(),
    this.bookmark = const Value.absent(),
    this.status = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.lastReadAt = const Value.absent(),
    this.lastChapterTitle = const Value.absent(),
    this.lastChapterUrl = const Value.absent(),
    this.genres = const Value.absent(),
    this.author = const Value.absent(),
    this.type = const Value.absent(),
    this.releaseYear = const Value.absent(),
    this.isAdult = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : mangaUrl = Value(mangaUrl),
       title = Value(title);
  static Insertable<LibraryItem> custom({
    Expression<String>? mangaUrl,
    Expression<String>? title,
    Expression<String>? coverUrl,
    Expression<int>? postId,
    Expression<bool>? favorite,
    Expression<bool>? bookmark,
    Expression<String>? status,
    Expression<DateTime>? addedAt,
    Expression<DateTime>? lastReadAt,
    Expression<String>? lastChapterTitle,
    Expression<String>? lastChapterUrl,
    Expression<String>? genres,
    Expression<String>? author,
    Expression<String>? type,
    Expression<String>? releaseYear,
    Expression<bool>? isAdult,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mangaUrl != null) 'manga_url': mangaUrl,
      if (title != null) 'title': title,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (postId != null) 'post_id': postId,
      if (favorite != null) 'favorite': favorite,
      if (bookmark != null) 'bookmark': bookmark,
      if (status != null) 'status': status,
      if (addedAt != null) 'added_at': addedAt,
      if (lastReadAt != null) 'last_read_at': lastReadAt,
      if (lastChapterTitle != null) 'last_chapter_title': lastChapterTitle,
      if (lastChapterUrl != null) 'last_chapter_url': lastChapterUrl,
      if (genres != null) 'genres': genres,
      if (author != null) 'author': author,
      if (type != null) 'type': type,
      if (releaseYear != null) 'release_year': releaseYear,
      if (isAdult != null) 'is_adult': isAdult,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryItemsCompanion copyWith({
    Value<String>? mangaUrl,
    Value<String>? title,
    Value<String?>? coverUrl,
    Value<int?>? postId,
    Value<bool>? favorite,
    Value<bool>? bookmark,
    Value<String?>? status,
    Value<DateTime>? addedAt,
    Value<DateTime?>? lastReadAt,
    Value<String?>? lastChapterTitle,
    Value<String?>? lastChapterUrl,
    Value<String?>? genres,
    Value<String?>? author,
    Value<String?>? type,
    Value<String?>? releaseYear,
    Value<bool>? isAdult,
    Value<int>? rowid,
  }) {
    return LibraryItemsCompanion(
      mangaUrl: mangaUrl ?? this.mangaUrl,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      postId: postId ?? this.postId,
      favorite: favorite ?? this.favorite,
      bookmark: bookmark ?? this.bookmark,
      status: status ?? this.status,
      addedAt: addedAt ?? this.addedAt,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      lastChapterTitle: lastChapterTitle ?? this.lastChapterTitle,
      lastChapterUrl: lastChapterUrl ?? this.lastChapterUrl,
      genres: genres ?? this.genres,
      author: author ?? this.author,
      type: type ?? this.type,
      releaseYear: releaseYear ?? this.releaseYear,
      isAdult: isAdult ?? this.isAdult,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mangaUrl.present) {
      map['manga_url'] = Variable<String>(mangaUrl.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (postId.present) {
      map['post_id'] = Variable<int>(postId.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (bookmark.present) {
      map['bookmark'] = Variable<bool>(bookmark.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (lastReadAt.present) {
      map['last_read_at'] = Variable<DateTime>(lastReadAt.value);
    }
    if (lastChapterTitle.present) {
      map['last_chapter_title'] = Variable<String>(lastChapterTitle.value);
    }
    if (lastChapterUrl.present) {
      map['last_chapter_url'] = Variable<String>(lastChapterUrl.value);
    }
    if (genres.present) {
      map['genres'] = Variable<String>(genres.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (releaseYear.present) {
      map['release_year'] = Variable<String>(releaseYear.value);
    }
    if (isAdult.present) {
      map['is_adult'] = Variable<bool>(isAdult.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryItemsCompanion(')
          ..write('mangaUrl: $mangaUrl, ')
          ..write('title: $title, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('postId: $postId, ')
          ..write('favorite: $favorite, ')
          ..write('bookmark: $bookmark, ')
          ..write('status: $status, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastReadAt: $lastReadAt, ')
          ..write('lastChapterTitle: $lastChapterTitle, ')
          ..write('lastChapterUrl: $lastChapterUrl, ')
          ..write('genres: $genres, ')
          ..write('author: $author, ')
          ..write('type: $type, ')
          ..write('releaseYear: $releaseYear, ')
          ..write('isAdult: $isAdult, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, Collection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    createdAt,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Collection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Collection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Collection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class Collection extends DataClass implements Insertable<Collection> {
  final int id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final int sortOrder;
  const Collection({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      sortOrder: Value(sortOrder),
    );
  }

  factory Collection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Collection(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Collection copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
    int? sortOrder,
  }) => Collection(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Collection copyWithCompanion(CollectionsCompanion data) {
    return Collection(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Collection(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, createdAt, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Collection &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.sortOrder == this.sortOrder);
}

class CollectionsCompanion extends UpdateCompanion<Collection> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<int> sortOrder;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  CollectionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Collection> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  CollectionsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<int>? sortOrder,
  }) {
    return CollectionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $CollectionItemsTable extends CollectionItems
    with TableInfo<$CollectionItemsTable, CollectionItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<int> collectionId = GeneratedColumn<int>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collections (id)',
    ),
  );
  static const VerificationMeta _mangaUrlMeta = const VerificationMeta(
    'mangaUrl',
  );
  @override
  late final GeneratedColumn<String> mangaUrl = GeneratedColumn<String>(
    'manga_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    collectionId,
    mangaUrl,
    title,
    coverUrl,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collection_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('manga_url')) {
      context.handle(
        _mangaUrlMeta,
        mangaUrl.isAcceptableOrUnknown(data['manga_url']!, _mangaUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_mangaUrlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {collectionId, mangaUrl};
  @override
  CollectionItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionItem(
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}collection_id'],
      )!,
      mangaUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manga_url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $CollectionItemsTable createAlias(String alias) {
    return $CollectionItemsTable(attachedDatabase, alias);
  }
}

class CollectionItem extends DataClass implements Insertable<CollectionItem> {
  final int collectionId;
  final String mangaUrl;
  final String title;
  final String? coverUrl;
  final DateTime addedAt;
  const CollectionItem({
    required this.collectionId,
    required this.mangaUrl,
    required this.title,
    this.coverUrl,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['collection_id'] = Variable<int>(collectionId);
    map['manga_url'] = Variable<String>(mangaUrl);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  CollectionItemsCompanion toCompanion(bool nullToAbsent) {
    return CollectionItemsCompanion(
      collectionId: Value(collectionId),
      mangaUrl: Value(mangaUrl),
      title: Value(title),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      addedAt: Value(addedAt),
    );
  }

  factory CollectionItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionItem(
      collectionId: serializer.fromJson<int>(json['collectionId']),
      mangaUrl: serializer.fromJson<String>(json['mangaUrl']),
      title: serializer.fromJson<String>(json['title']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'collectionId': serializer.toJson<int>(collectionId),
      'mangaUrl': serializer.toJson<String>(mangaUrl),
      'title': serializer.toJson<String>(title),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  CollectionItem copyWith({
    int? collectionId,
    String? mangaUrl,
    String? title,
    Value<String?> coverUrl = const Value.absent(),
    DateTime? addedAt,
  }) => CollectionItem(
    collectionId: collectionId ?? this.collectionId,
    mangaUrl: mangaUrl ?? this.mangaUrl,
    title: title ?? this.title,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    addedAt: addedAt ?? this.addedAt,
  );
  CollectionItem copyWithCompanion(CollectionItemsCompanion data) {
    return CollectionItem(
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      mangaUrl: data.mangaUrl.present ? data.mangaUrl.value : this.mangaUrl,
      title: data.title.present ? data.title.value : this.title,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionItem(')
          ..write('collectionId: $collectionId, ')
          ..write('mangaUrl: $mangaUrl, ')
          ..write('title: $title, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(collectionId, mangaUrl, title, coverUrl, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionItem &&
          other.collectionId == this.collectionId &&
          other.mangaUrl == this.mangaUrl &&
          other.title == this.title &&
          other.coverUrl == this.coverUrl &&
          other.addedAt == this.addedAt);
}

class CollectionItemsCompanion extends UpdateCompanion<CollectionItem> {
  final Value<int> collectionId;
  final Value<String> mangaUrl;
  final Value<String> title;
  final Value<String?> coverUrl;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const CollectionItemsCompanion({
    this.collectionId = const Value.absent(),
    this.mangaUrl = const Value.absent(),
    this.title = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionItemsCompanion.insert({
    required int collectionId,
    required String mangaUrl,
    required String title,
    this.coverUrl = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : collectionId = Value(collectionId),
       mangaUrl = Value(mangaUrl),
       title = Value(title);
  static Insertable<CollectionItem> custom({
    Expression<int>? collectionId,
    Expression<String>? mangaUrl,
    Expression<String>? title,
    Expression<String>? coverUrl,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (collectionId != null) 'collection_id': collectionId,
      if (mangaUrl != null) 'manga_url': mangaUrl,
      if (title != null) 'title': title,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionItemsCompanion copyWith({
    Value<int>? collectionId,
    Value<String>? mangaUrl,
    Value<String>? title,
    Value<String?>? coverUrl,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return CollectionItemsCompanion(
      collectionId: collectionId ?? this.collectionId,
      mangaUrl: mangaUrl ?? this.mangaUrl,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (collectionId.present) {
      map['collection_id'] = Variable<int>(collectionId.value);
    }
    if (mangaUrl.present) {
      map['manga_url'] = Variable<String>(mangaUrl.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionItemsCompanion(')
          ..write('collectionId: $collectionId, ')
          ..write('mangaUrl: $mangaUrl, ')
          ..write('title: $title, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, color];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String name;
  final String? color;
  const Tag({required this.id, required this.name, this.color});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String?>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String?>(color),
    };
  }

  Tag copyWith({
    int? id,
    String? name,
    Value<String?> color = const Value.absent(),
  }) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color.present ? color.value : this.color,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> color;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.color = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? color,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
    });
  }

  TagsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? color,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }
}

class $MangaTagsTable extends MangaTags
    with TableInfo<$MangaTagsTable, MangaTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MangaTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id)',
    ),
  );
  static const VerificationMeta _mangaUrlMeta = const VerificationMeta(
    'mangaUrl',
  );
  @override
  late final GeneratedColumn<String> mangaUrl = GeneratedColumn<String>(
    'manga_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [tagId, mangaUrl];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manga_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<MangaTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    if (data.containsKey('manga_url')) {
      context.handle(
        _mangaUrlMeta,
        mangaUrl.isAcceptableOrUnknown(data['manga_url']!, _mangaUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_mangaUrlMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tagId, mangaUrl};
  @override
  MangaTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MangaTag(
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
      mangaUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manga_url'],
      )!,
    );
  }

  @override
  $MangaTagsTable createAlias(String alias) {
    return $MangaTagsTable(attachedDatabase, alias);
  }
}

class MangaTag extends DataClass implements Insertable<MangaTag> {
  final int tagId;
  final String mangaUrl;
  const MangaTag({required this.tagId, required this.mangaUrl});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tag_id'] = Variable<int>(tagId);
    map['manga_url'] = Variable<String>(mangaUrl);
    return map;
  }

  MangaTagsCompanion toCompanion(bool nullToAbsent) {
    return MangaTagsCompanion(tagId: Value(tagId), mangaUrl: Value(mangaUrl));
  }

  factory MangaTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MangaTag(
      tagId: serializer.fromJson<int>(json['tagId']),
      mangaUrl: serializer.fromJson<String>(json['mangaUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tagId': serializer.toJson<int>(tagId),
      'mangaUrl': serializer.toJson<String>(mangaUrl),
    };
  }

  MangaTag copyWith({int? tagId, String? mangaUrl}) =>
      MangaTag(tagId: tagId ?? this.tagId, mangaUrl: mangaUrl ?? this.mangaUrl);
  MangaTag copyWithCompanion(MangaTagsCompanion data) {
    return MangaTag(
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      mangaUrl: data.mangaUrl.present ? data.mangaUrl.value : this.mangaUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MangaTag(')
          ..write('tagId: $tagId, ')
          ..write('mangaUrl: $mangaUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tagId, mangaUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MangaTag &&
          other.tagId == this.tagId &&
          other.mangaUrl == this.mangaUrl);
}

class MangaTagsCompanion extends UpdateCompanion<MangaTag> {
  final Value<int> tagId;
  final Value<String> mangaUrl;
  final Value<int> rowid;
  const MangaTagsCompanion({
    this.tagId = const Value.absent(),
    this.mangaUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MangaTagsCompanion.insert({
    required int tagId,
    required String mangaUrl,
    this.rowid = const Value.absent(),
  }) : tagId = Value(tagId),
       mangaUrl = Value(mangaUrl);
  static Insertable<MangaTag> custom({
    Expression<int>? tagId,
    Expression<String>? mangaUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tagId != null) 'tag_id': tagId,
      if (mangaUrl != null) 'manga_url': mangaUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MangaTagsCompanion copyWith({
    Value<int>? tagId,
    Value<String>? mangaUrl,
    Value<int>? rowid,
  }) {
    return MangaTagsCompanion(
      tagId: tagId ?? this.tagId,
      mangaUrl: mangaUrl ?? this.mangaUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (mangaUrl.present) {
      map['manga_url'] = Variable<String>(mangaUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MangaTagsCompanion(')
          ..write('tagId: $tagId, ')
          ..write('mangaUrl: $mangaUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingHistoryTable extends ReadingHistory
    with TableInfo<$ReadingHistoryTable, ReadingHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mangaUrlMeta = const VerificationMeta(
    'mangaUrl',
  );
  @override
  late final GeneratedColumn<String> mangaUrl = GeneratedColumn<String>(
    'manga_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mangaTitleMeta = const VerificationMeta(
    'mangaTitle',
  );
  @override
  late final GeneratedColumn<String> mangaTitle = GeneratedColumn<String>(
    'manga_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chapterUrlMeta = const VerificationMeta(
    'chapterUrl',
  );
  @override
  late final GeneratedColumn<String> chapterUrl = GeneratedColumn<String>(
    'chapter_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterTitleMeta = const VerificationMeta(
    'chapterTitle',
  );
  @override
  late final GeneratedColumn<String> chapterTitle = GeneratedColumn<String>(
    'chapter_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageIndexMeta = const VerificationMeta(
    'pageIndex',
  );
  @override
  late final GeneratedColumn<int> pageIndex = GeneratedColumn<int>(
    'page_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalPagesMeta = const VerificationMeta(
    'totalPages',
  );
  @override
  late final GeneratedColumn<int> totalPages = GeneratedColumn<int>(
    'total_pages',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    mangaUrl,
    mangaTitle,
    coverUrl,
    chapterUrl,
    chapterTitle,
    pageIndex,
    totalPages,
    readAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('manga_url')) {
      context.handle(
        _mangaUrlMeta,
        mangaUrl.isAcceptableOrUnknown(data['manga_url']!, _mangaUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_mangaUrlMeta);
    }
    if (data.containsKey('manga_title')) {
      context.handle(
        _mangaTitleMeta,
        mangaTitle.isAcceptableOrUnknown(data['manga_title']!, _mangaTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_mangaTitleMeta);
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('chapter_url')) {
      context.handle(
        _chapterUrlMeta,
        chapterUrl.isAcceptableOrUnknown(data['chapter_url']!, _chapterUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterUrlMeta);
    }
    if (data.containsKey('chapter_title')) {
      context.handle(
        _chapterTitleMeta,
        chapterTitle.isAcceptableOrUnknown(
          data['chapter_title']!,
          _chapterTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterTitleMeta);
    }
    if (data.containsKey('page_index')) {
      context.handle(
        _pageIndexMeta,
        pageIndex.isAcceptableOrUnknown(data['page_index']!, _pageIndexMeta),
      );
    }
    if (data.containsKey('total_pages')) {
      context.handle(
        _totalPagesMeta,
        totalPages.isAcceptableOrUnknown(data['total_pages']!, _totalPagesMeta),
      );
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mangaUrl};
  @override
  ReadingHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingHistoryData(
      mangaUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manga_url'],
      )!,
      mangaTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manga_title'],
      )!,
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      chapterUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_url'],
      )!,
      chapterTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_title'],
      )!,
      pageIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_index'],
      )!,
      totalPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_pages'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      )!,
    );
  }

  @override
  $ReadingHistoryTable createAlias(String alias) {
    return $ReadingHistoryTable(attachedDatabase, alias);
  }
}

class ReadingHistoryData extends DataClass
    implements Insertable<ReadingHistoryData> {
  final String mangaUrl;
  final String mangaTitle;
  final String? coverUrl;
  final String chapterUrl;
  final String chapterTitle;
  final int pageIndex;
  final int totalPages;
  final DateTime readAt;
  const ReadingHistoryData({
    required this.mangaUrl,
    required this.mangaTitle,
    this.coverUrl,
    required this.chapterUrl,
    required this.chapterTitle,
    required this.pageIndex,
    required this.totalPages,
    required this.readAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['manga_url'] = Variable<String>(mangaUrl);
    map['manga_title'] = Variable<String>(mangaTitle);
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    map['chapter_url'] = Variable<String>(chapterUrl);
    map['chapter_title'] = Variable<String>(chapterTitle);
    map['page_index'] = Variable<int>(pageIndex);
    map['total_pages'] = Variable<int>(totalPages);
    map['read_at'] = Variable<DateTime>(readAt);
    return map;
  }

  ReadingHistoryCompanion toCompanion(bool nullToAbsent) {
    return ReadingHistoryCompanion(
      mangaUrl: Value(mangaUrl),
      mangaTitle: Value(mangaTitle),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      chapterUrl: Value(chapterUrl),
      chapterTitle: Value(chapterTitle),
      pageIndex: Value(pageIndex),
      totalPages: Value(totalPages),
      readAt: Value(readAt),
    );
  }

  factory ReadingHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingHistoryData(
      mangaUrl: serializer.fromJson<String>(json['mangaUrl']),
      mangaTitle: serializer.fromJson<String>(json['mangaTitle']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      chapterUrl: serializer.fromJson<String>(json['chapterUrl']),
      chapterTitle: serializer.fromJson<String>(json['chapterTitle']),
      pageIndex: serializer.fromJson<int>(json['pageIndex']),
      totalPages: serializer.fromJson<int>(json['totalPages']),
      readAt: serializer.fromJson<DateTime>(json['readAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mangaUrl': serializer.toJson<String>(mangaUrl),
      'mangaTitle': serializer.toJson<String>(mangaTitle),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'chapterUrl': serializer.toJson<String>(chapterUrl),
      'chapterTitle': serializer.toJson<String>(chapterTitle),
      'pageIndex': serializer.toJson<int>(pageIndex),
      'totalPages': serializer.toJson<int>(totalPages),
      'readAt': serializer.toJson<DateTime>(readAt),
    };
  }

  ReadingHistoryData copyWith({
    String? mangaUrl,
    String? mangaTitle,
    Value<String?> coverUrl = const Value.absent(),
    String? chapterUrl,
    String? chapterTitle,
    int? pageIndex,
    int? totalPages,
    DateTime? readAt,
  }) => ReadingHistoryData(
    mangaUrl: mangaUrl ?? this.mangaUrl,
    mangaTitle: mangaTitle ?? this.mangaTitle,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    chapterUrl: chapterUrl ?? this.chapterUrl,
    chapterTitle: chapterTitle ?? this.chapterTitle,
    pageIndex: pageIndex ?? this.pageIndex,
    totalPages: totalPages ?? this.totalPages,
    readAt: readAt ?? this.readAt,
  );
  ReadingHistoryData copyWithCompanion(ReadingHistoryCompanion data) {
    return ReadingHistoryData(
      mangaUrl: data.mangaUrl.present ? data.mangaUrl.value : this.mangaUrl,
      mangaTitle: data.mangaTitle.present
          ? data.mangaTitle.value
          : this.mangaTitle,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      chapterUrl: data.chapterUrl.present
          ? data.chapterUrl.value
          : this.chapterUrl,
      chapterTitle: data.chapterTitle.present
          ? data.chapterTitle.value
          : this.chapterTitle,
      pageIndex: data.pageIndex.present ? data.pageIndex.value : this.pageIndex,
      totalPages: data.totalPages.present
          ? data.totalPages.value
          : this.totalPages,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingHistoryData(')
          ..write('mangaUrl: $mangaUrl, ')
          ..write('mangaTitle: $mangaTitle, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('chapterUrl: $chapterUrl, ')
          ..write('chapterTitle: $chapterTitle, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('totalPages: $totalPages, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    mangaUrl,
    mangaTitle,
    coverUrl,
    chapterUrl,
    chapterTitle,
    pageIndex,
    totalPages,
    readAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingHistoryData &&
          other.mangaUrl == this.mangaUrl &&
          other.mangaTitle == this.mangaTitle &&
          other.coverUrl == this.coverUrl &&
          other.chapterUrl == this.chapterUrl &&
          other.chapterTitle == this.chapterTitle &&
          other.pageIndex == this.pageIndex &&
          other.totalPages == this.totalPages &&
          other.readAt == this.readAt);
}

class ReadingHistoryCompanion extends UpdateCompanion<ReadingHistoryData> {
  final Value<String> mangaUrl;
  final Value<String> mangaTitle;
  final Value<String?> coverUrl;
  final Value<String> chapterUrl;
  final Value<String> chapterTitle;
  final Value<int> pageIndex;
  final Value<int> totalPages;
  final Value<DateTime> readAt;
  final Value<int> rowid;
  const ReadingHistoryCompanion({
    this.mangaUrl = const Value.absent(),
    this.mangaTitle = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.chapterUrl = const Value.absent(),
    this.chapterTitle = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingHistoryCompanion.insert({
    required String mangaUrl,
    required String mangaTitle,
    this.coverUrl = const Value.absent(),
    required String chapterUrl,
    required String chapterTitle,
    this.pageIndex = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : mangaUrl = Value(mangaUrl),
       mangaTitle = Value(mangaTitle),
       chapterUrl = Value(chapterUrl),
       chapterTitle = Value(chapterTitle);
  static Insertable<ReadingHistoryData> custom({
    Expression<String>? mangaUrl,
    Expression<String>? mangaTitle,
    Expression<String>? coverUrl,
    Expression<String>? chapterUrl,
    Expression<String>? chapterTitle,
    Expression<int>? pageIndex,
    Expression<int>? totalPages,
    Expression<DateTime>? readAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mangaUrl != null) 'manga_url': mangaUrl,
      if (mangaTitle != null) 'manga_title': mangaTitle,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (chapterUrl != null) 'chapter_url': chapterUrl,
      if (chapterTitle != null) 'chapter_title': chapterTitle,
      if (pageIndex != null) 'page_index': pageIndex,
      if (totalPages != null) 'total_pages': totalPages,
      if (readAt != null) 'read_at': readAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingHistoryCompanion copyWith({
    Value<String>? mangaUrl,
    Value<String>? mangaTitle,
    Value<String?>? coverUrl,
    Value<String>? chapterUrl,
    Value<String>? chapterTitle,
    Value<int>? pageIndex,
    Value<int>? totalPages,
    Value<DateTime>? readAt,
    Value<int>? rowid,
  }) {
    return ReadingHistoryCompanion(
      mangaUrl: mangaUrl ?? this.mangaUrl,
      mangaTitle: mangaTitle ?? this.mangaTitle,
      coverUrl: coverUrl ?? this.coverUrl,
      chapterUrl: chapterUrl ?? this.chapterUrl,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      pageIndex: pageIndex ?? this.pageIndex,
      totalPages: totalPages ?? this.totalPages,
      readAt: readAt ?? this.readAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mangaUrl.present) {
      map['manga_url'] = Variable<String>(mangaUrl.value);
    }
    if (mangaTitle.present) {
      map['manga_title'] = Variable<String>(mangaTitle.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (chapterUrl.present) {
      map['chapter_url'] = Variable<String>(chapterUrl.value);
    }
    if (chapterTitle.present) {
      map['chapter_title'] = Variable<String>(chapterTitle.value);
    }
    if (pageIndex.present) {
      map['page_index'] = Variable<int>(pageIndex.value);
    }
    if (totalPages.present) {
      map['total_pages'] = Variable<int>(totalPages.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingHistoryCompanion(')
          ..write('mangaUrl: $mangaUrl, ')
          ..write('mangaTitle: $mangaTitle, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('chapterUrl: $chapterUrl, ')
          ..write('chapterTitle: $chapterTitle, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('totalPages: $totalPages, ')
          ..write('readAt: $readAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingSessionsTable extends ReadingSessions
    with TableInfo<$ReadingSessionsTable, ReadingSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _mangaUrlMeta = const VerificationMeta(
    'mangaUrl',
  );
  @override
  late final GeneratedColumn<String> mangaUrl = GeneratedColumn<String>(
    'manga_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterUrlMeta = const VerificationMeta(
    'chapterUrl',
  );
  @override
  late final GeneratedColumn<String> chapterUrl = GeneratedColumn<String>(
    'chapter_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionDateMeta = const VerificationMeta(
    'sessionDate',
  );
  @override
  late final GeneratedColumn<DateTime> sessionDate = GeneratedColumn<DateTime>(
    'session_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pagesReadMeta = const VerificationMeta(
    'pagesRead',
  );
  @override
  late final GeneratedColumn<int> pagesRead = GeneratedColumn<int>(
    'pages_read',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pagesTotalMeta = const VerificationMeta(
    'pagesTotal',
  );
  @override
  late final GeneratedColumn<int> pagesTotal = GeneratedColumn<int>(
    'pages_total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mangaUrl,
    chapterUrl,
    sessionDate,
    durationSeconds,
    pagesRead,
    pagesTotal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('manga_url')) {
      context.handle(
        _mangaUrlMeta,
        mangaUrl.isAcceptableOrUnknown(data['manga_url']!, _mangaUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_mangaUrlMeta);
    }
    if (data.containsKey('chapter_url')) {
      context.handle(
        _chapterUrlMeta,
        chapterUrl.isAcceptableOrUnknown(data['chapter_url']!, _chapterUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterUrlMeta);
    }
    if (data.containsKey('session_date')) {
      context.handle(
        _sessionDateMeta,
        sessionDate.isAcceptableOrUnknown(
          data['session_date']!,
          _sessionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionDateMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('pages_read')) {
      context.handle(
        _pagesReadMeta,
        pagesRead.isAcceptableOrUnknown(data['pages_read']!, _pagesReadMeta),
      );
    }
    if (data.containsKey('pages_total')) {
      context.handle(
        _pagesTotalMeta,
        pagesTotal.isAcceptableOrUnknown(data['pages_total']!, _pagesTotalMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mangaUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manga_url'],
      )!,
      chapterUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_url'],
      )!,
      sessionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}session_date'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      pagesRead: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pages_read'],
      )!,
      pagesTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pages_total'],
      )!,
    );
  }

  @override
  $ReadingSessionsTable createAlias(String alias) {
    return $ReadingSessionsTable(attachedDatabase, alias);
  }
}

class ReadingSession extends DataClass implements Insertable<ReadingSession> {
  final int id;
  final String mangaUrl;
  final String chapterUrl;
  final DateTime sessionDate;
  final int durationSeconds;
  final int pagesRead;
  final int pagesTotal;
  const ReadingSession({
    required this.id,
    required this.mangaUrl,
    required this.chapterUrl,
    required this.sessionDate,
    required this.durationSeconds,
    required this.pagesRead,
    required this.pagesTotal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['manga_url'] = Variable<String>(mangaUrl);
    map['chapter_url'] = Variable<String>(chapterUrl);
    map['session_date'] = Variable<DateTime>(sessionDate);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['pages_read'] = Variable<int>(pagesRead);
    map['pages_total'] = Variable<int>(pagesTotal);
    return map;
  }

  ReadingSessionsCompanion toCompanion(bool nullToAbsent) {
    return ReadingSessionsCompanion(
      id: Value(id),
      mangaUrl: Value(mangaUrl),
      chapterUrl: Value(chapterUrl),
      sessionDate: Value(sessionDate),
      durationSeconds: Value(durationSeconds),
      pagesRead: Value(pagesRead),
      pagesTotal: Value(pagesTotal),
    );
  }

  factory ReadingSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingSession(
      id: serializer.fromJson<int>(json['id']),
      mangaUrl: serializer.fromJson<String>(json['mangaUrl']),
      chapterUrl: serializer.fromJson<String>(json['chapterUrl']),
      sessionDate: serializer.fromJson<DateTime>(json['sessionDate']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      pagesRead: serializer.fromJson<int>(json['pagesRead']),
      pagesTotal: serializer.fromJson<int>(json['pagesTotal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mangaUrl': serializer.toJson<String>(mangaUrl),
      'chapterUrl': serializer.toJson<String>(chapterUrl),
      'sessionDate': serializer.toJson<DateTime>(sessionDate),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'pagesRead': serializer.toJson<int>(pagesRead),
      'pagesTotal': serializer.toJson<int>(pagesTotal),
    };
  }

  ReadingSession copyWith({
    int? id,
    String? mangaUrl,
    String? chapterUrl,
    DateTime? sessionDate,
    int? durationSeconds,
    int? pagesRead,
    int? pagesTotal,
  }) => ReadingSession(
    id: id ?? this.id,
    mangaUrl: mangaUrl ?? this.mangaUrl,
    chapterUrl: chapterUrl ?? this.chapterUrl,
    sessionDate: sessionDate ?? this.sessionDate,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    pagesRead: pagesRead ?? this.pagesRead,
    pagesTotal: pagesTotal ?? this.pagesTotal,
  );
  ReadingSession copyWithCompanion(ReadingSessionsCompanion data) {
    return ReadingSession(
      id: data.id.present ? data.id.value : this.id,
      mangaUrl: data.mangaUrl.present ? data.mangaUrl.value : this.mangaUrl,
      chapterUrl: data.chapterUrl.present
          ? data.chapterUrl.value
          : this.chapterUrl,
      sessionDate: data.sessionDate.present
          ? data.sessionDate.value
          : this.sessionDate,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      pagesRead: data.pagesRead.present ? data.pagesRead.value : this.pagesRead,
      pagesTotal: data.pagesTotal.present
          ? data.pagesTotal.value
          : this.pagesTotal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSession(')
          ..write('id: $id, ')
          ..write('mangaUrl: $mangaUrl, ')
          ..write('chapterUrl: $chapterUrl, ')
          ..write('sessionDate: $sessionDate, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('pagesRead: $pagesRead, ')
          ..write('pagesTotal: $pagesTotal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mangaUrl,
    chapterUrl,
    sessionDate,
    durationSeconds,
    pagesRead,
    pagesTotal,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingSession &&
          other.id == this.id &&
          other.mangaUrl == this.mangaUrl &&
          other.chapterUrl == this.chapterUrl &&
          other.sessionDate == this.sessionDate &&
          other.durationSeconds == this.durationSeconds &&
          other.pagesRead == this.pagesRead &&
          other.pagesTotal == this.pagesTotal);
}

class ReadingSessionsCompanion extends UpdateCompanion<ReadingSession> {
  final Value<int> id;
  final Value<String> mangaUrl;
  final Value<String> chapterUrl;
  final Value<DateTime> sessionDate;
  final Value<int> durationSeconds;
  final Value<int> pagesRead;
  final Value<int> pagesTotal;
  const ReadingSessionsCompanion({
    this.id = const Value.absent(),
    this.mangaUrl = const Value.absent(),
    this.chapterUrl = const Value.absent(),
    this.sessionDate = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.pagesRead = const Value.absent(),
    this.pagesTotal = const Value.absent(),
  });
  ReadingSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String mangaUrl,
    required String chapterUrl,
    required DateTime sessionDate,
    this.durationSeconds = const Value.absent(),
    this.pagesRead = const Value.absent(),
    this.pagesTotal = const Value.absent(),
  }) : mangaUrl = Value(mangaUrl),
       chapterUrl = Value(chapterUrl),
       sessionDate = Value(sessionDate);
  static Insertable<ReadingSession> custom({
    Expression<int>? id,
    Expression<String>? mangaUrl,
    Expression<String>? chapterUrl,
    Expression<DateTime>? sessionDate,
    Expression<int>? durationSeconds,
    Expression<int>? pagesRead,
    Expression<int>? pagesTotal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mangaUrl != null) 'manga_url': mangaUrl,
      if (chapterUrl != null) 'chapter_url': chapterUrl,
      if (sessionDate != null) 'session_date': sessionDate,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (pagesRead != null) 'pages_read': pagesRead,
      if (pagesTotal != null) 'pages_total': pagesTotal,
    });
  }

  ReadingSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? mangaUrl,
    Value<String>? chapterUrl,
    Value<DateTime>? sessionDate,
    Value<int>? durationSeconds,
    Value<int>? pagesRead,
    Value<int>? pagesTotal,
  }) {
    return ReadingSessionsCompanion(
      id: id ?? this.id,
      mangaUrl: mangaUrl ?? this.mangaUrl,
      chapterUrl: chapterUrl ?? this.chapterUrl,
      sessionDate: sessionDate ?? this.sessionDate,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      pagesRead: pagesRead ?? this.pagesRead,
      pagesTotal: pagesTotal ?? this.pagesTotal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mangaUrl.present) {
      map['manga_url'] = Variable<String>(mangaUrl.value);
    }
    if (chapterUrl.present) {
      map['chapter_url'] = Variable<String>(chapterUrl.value);
    }
    if (sessionDate.present) {
      map['session_date'] = Variable<DateTime>(sessionDate.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (pagesRead.present) {
      map['pages_read'] = Variable<int>(pagesRead.value);
    }
    if (pagesTotal.present) {
      map['pages_total'] = Variable<int>(pagesTotal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSessionsCompanion(')
          ..write('id: $id, ')
          ..write('mangaUrl: $mangaUrl, ')
          ..write('chapterUrl: $chapterUrl, ')
          ..write('sessionDate: $sessionDate, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('pagesRead: $pagesRead, ')
          ..write('pagesTotal: $pagesTotal')
          ..write(')'))
        .toString();
  }
}

class $DownloadTasksTable extends DownloadTasks
    with TableInfo<$DownloadTasksTable, DownloadTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _mangaUrlMeta = const VerificationMeta(
    'mangaUrl',
  );
  @override
  late final GeneratedColumn<String> mangaUrl = GeneratedColumn<String>(
    'manga_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mangaTitleMeta = const VerificationMeta(
    'mangaTitle',
  );
  @override
  late final GeneratedColumn<String> mangaTitle = GeneratedColumn<String>(
    'manga_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mangaSlugMeta = const VerificationMeta(
    'mangaSlug',
  );
  @override
  late final GeneratedColumn<String> mangaSlug = GeneratedColumn<String>(
    'manga_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterUrlMeta = const VerificationMeta(
    'chapterUrl',
  );
  @override
  late final GeneratedColumn<String> chapterUrl = GeneratedColumn<String>(
    'chapter_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _chapterTitleMeta = const VerificationMeta(
    'chapterTitle',
  );
  @override
  late final GeneratedColumn<String> chapterTitle = GeneratedColumn<String>(
    'chapter_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterSlugMeta = const VerificationMeta(
    'chapterSlug',
  );
  @override
  late final GeneratedColumn<String> chapterSlug = GeneratedColumn<String>(
    'chapter_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalPagesMeta = const VerificationMeta(
    'totalPages',
  );
  @override
  late final GeneratedColumn<int> totalPages = GeneratedColumn<int>(
    'total_pages',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _downloadedPagesMeta = const VerificationMeta(
    'downloadedPages',
  );
  @override
  late final GeneratedColumn<int> downloadedPages = GeneratedColumn<int>(
    'downloaded_pages',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesReceivedMeta = const VerificationMeta(
    'bytesReceived',
  );
  @override
  late final GeneratedColumn<int> bytesReceived = GeneratedColumn<int>(
    'bytes_received',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bytesTotalMeta = const VerificationMeta(
    'bytesTotal',
  );
  @override
  late final GeneratedColumn<int> bytesTotal = GeneratedColumn<int>(
    'bytes_total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _directoryMeta = const VerificationMeta(
    'directory',
  );
  @override
  late final GeneratedColumn<String> directory = GeneratedColumn<String>(
    'directory',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _autoNextMeta = const VerificationMeta(
    'autoNext',
  );
  @override
  late final GeneratedColumn<bool> autoNext = GeneratedColumn<bool>(
    'auto_next',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_next" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mangaUrl,
    mangaTitle,
    mangaSlug,
    chapterUrl,
    chapterTitle,
    chapterSlug,
    totalPages,
    downloadedPages,
    state,
    bytesReceived,
    bytesTotal,
    error,
    directory,
    autoNext,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('manga_url')) {
      context.handle(
        _mangaUrlMeta,
        mangaUrl.isAcceptableOrUnknown(data['manga_url']!, _mangaUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_mangaUrlMeta);
    }
    if (data.containsKey('manga_title')) {
      context.handle(
        _mangaTitleMeta,
        mangaTitle.isAcceptableOrUnknown(data['manga_title']!, _mangaTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_mangaTitleMeta);
    }
    if (data.containsKey('manga_slug')) {
      context.handle(
        _mangaSlugMeta,
        mangaSlug.isAcceptableOrUnknown(data['manga_slug']!, _mangaSlugMeta),
      );
    } else if (isInserting) {
      context.missing(_mangaSlugMeta);
    }
    if (data.containsKey('chapter_url')) {
      context.handle(
        _chapterUrlMeta,
        chapterUrl.isAcceptableOrUnknown(data['chapter_url']!, _chapterUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterUrlMeta);
    }
    if (data.containsKey('chapter_title')) {
      context.handle(
        _chapterTitleMeta,
        chapterTitle.isAcceptableOrUnknown(
          data['chapter_title']!,
          _chapterTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterTitleMeta);
    }
    if (data.containsKey('chapter_slug')) {
      context.handle(
        _chapterSlugMeta,
        chapterSlug.isAcceptableOrUnknown(
          data['chapter_slug']!,
          _chapterSlugMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterSlugMeta);
    }
    if (data.containsKey('total_pages')) {
      context.handle(
        _totalPagesMeta,
        totalPages.isAcceptableOrUnknown(data['total_pages']!, _totalPagesMeta),
      );
    }
    if (data.containsKey('downloaded_pages')) {
      context.handle(
        _downloadedPagesMeta,
        downloadedPages.isAcceptableOrUnknown(
          data['downloaded_pages']!,
          _downloadedPagesMeta,
        ),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('bytes_received')) {
      context.handle(
        _bytesReceivedMeta,
        bytesReceived.isAcceptableOrUnknown(
          data['bytes_received']!,
          _bytesReceivedMeta,
        ),
      );
    }
    if (data.containsKey('bytes_total')) {
      context.handle(
        _bytesTotalMeta,
        bytesTotal.isAcceptableOrUnknown(data['bytes_total']!, _bytesTotalMeta),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('directory')) {
      context.handle(
        _directoryMeta,
        directory.isAcceptableOrUnknown(data['directory']!, _directoryMeta),
      );
    }
    if (data.containsKey('auto_next')) {
      context.handle(
        _autoNextMeta,
        autoNext.isAcceptableOrUnknown(data['auto_next']!, _autoNextMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadTask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mangaUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manga_url'],
      )!,
      mangaTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manga_title'],
      )!,
      mangaSlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manga_slug'],
      )!,
      chapterUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_url'],
      )!,
      chapterTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_title'],
      )!,
      chapterSlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_slug'],
      )!,
      totalPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_pages'],
      )!,
      downloadedPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}downloaded_pages'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      bytesReceived: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes_received'],
      )!,
      bytesTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes_total'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      directory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}directory'],
      ),
      autoNext: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_next'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DownloadTasksTable createAlias(String alias) {
    return $DownloadTasksTable(attachedDatabase, alias);
  }
}

class DownloadTask extends DataClass implements Insertable<DownloadTask> {
  final int id;
  final String mangaUrl;
  final String mangaTitle;
  final String mangaSlug;
  final String chapterUrl;
  final String chapterTitle;
  final String chapterSlug;
  final int totalPages;
  final int downloadedPages;

  /// queued | downloading | paused | error | completed | cancelled
  final String state;
  final int bytesReceived;
  final int bytesTotal;
  final String? error;
  final String? directory;
  final bool autoNext;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DownloadTask({
    required this.id,
    required this.mangaUrl,
    required this.mangaTitle,
    required this.mangaSlug,
    required this.chapterUrl,
    required this.chapterTitle,
    required this.chapterSlug,
    required this.totalPages,
    required this.downloadedPages,
    required this.state,
    required this.bytesReceived,
    required this.bytesTotal,
    this.error,
    this.directory,
    required this.autoNext,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['manga_url'] = Variable<String>(mangaUrl);
    map['manga_title'] = Variable<String>(mangaTitle);
    map['manga_slug'] = Variable<String>(mangaSlug);
    map['chapter_url'] = Variable<String>(chapterUrl);
    map['chapter_title'] = Variable<String>(chapterTitle);
    map['chapter_slug'] = Variable<String>(chapterSlug);
    map['total_pages'] = Variable<int>(totalPages);
    map['downloaded_pages'] = Variable<int>(downloadedPages);
    map['state'] = Variable<String>(state);
    map['bytes_received'] = Variable<int>(bytesReceived);
    map['bytes_total'] = Variable<int>(bytesTotal);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    if (!nullToAbsent || directory != null) {
      map['directory'] = Variable<String>(directory);
    }
    map['auto_next'] = Variable<bool>(autoNext);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DownloadTasksCompanion toCompanion(bool nullToAbsent) {
    return DownloadTasksCompanion(
      id: Value(id),
      mangaUrl: Value(mangaUrl),
      mangaTitle: Value(mangaTitle),
      mangaSlug: Value(mangaSlug),
      chapterUrl: Value(chapterUrl),
      chapterTitle: Value(chapterTitle),
      chapterSlug: Value(chapterSlug),
      totalPages: Value(totalPages),
      downloadedPages: Value(downloadedPages),
      state: Value(state),
      bytesReceived: Value(bytesReceived),
      bytesTotal: Value(bytesTotal),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      directory: directory == null && nullToAbsent
          ? const Value.absent()
          : Value(directory),
      autoNext: Value(autoNext),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DownloadTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadTask(
      id: serializer.fromJson<int>(json['id']),
      mangaUrl: serializer.fromJson<String>(json['mangaUrl']),
      mangaTitle: serializer.fromJson<String>(json['mangaTitle']),
      mangaSlug: serializer.fromJson<String>(json['mangaSlug']),
      chapterUrl: serializer.fromJson<String>(json['chapterUrl']),
      chapterTitle: serializer.fromJson<String>(json['chapterTitle']),
      chapterSlug: serializer.fromJson<String>(json['chapterSlug']),
      totalPages: serializer.fromJson<int>(json['totalPages']),
      downloadedPages: serializer.fromJson<int>(json['downloadedPages']),
      state: serializer.fromJson<String>(json['state']),
      bytesReceived: serializer.fromJson<int>(json['bytesReceived']),
      bytesTotal: serializer.fromJson<int>(json['bytesTotal']),
      error: serializer.fromJson<String?>(json['error']),
      directory: serializer.fromJson<String?>(json['directory']),
      autoNext: serializer.fromJson<bool>(json['autoNext']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mangaUrl': serializer.toJson<String>(mangaUrl),
      'mangaTitle': serializer.toJson<String>(mangaTitle),
      'mangaSlug': serializer.toJson<String>(mangaSlug),
      'chapterUrl': serializer.toJson<String>(chapterUrl),
      'chapterTitle': serializer.toJson<String>(chapterTitle),
      'chapterSlug': serializer.toJson<String>(chapterSlug),
      'totalPages': serializer.toJson<int>(totalPages),
      'downloadedPages': serializer.toJson<int>(downloadedPages),
      'state': serializer.toJson<String>(state),
      'bytesReceived': serializer.toJson<int>(bytesReceived),
      'bytesTotal': serializer.toJson<int>(bytesTotal),
      'error': serializer.toJson<String?>(error),
      'directory': serializer.toJson<String?>(directory),
      'autoNext': serializer.toJson<bool>(autoNext),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DownloadTask copyWith({
    int? id,
    String? mangaUrl,
    String? mangaTitle,
    String? mangaSlug,
    String? chapterUrl,
    String? chapterTitle,
    String? chapterSlug,
    int? totalPages,
    int? downloadedPages,
    String? state,
    int? bytesReceived,
    int? bytesTotal,
    Value<String?> error = const Value.absent(),
    Value<String?> directory = const Value.absent(),
    bool? autoNext,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DownloadTask(
    id: id ?? this.id,
    mangaUrl: mangaUrl ?? this.mangaUrl,
    mangaTitle: mangaTitle ?? this.mangaTitle,
    mangaSlug: mangaSlug ?? this.mangaSlug,
    chapterUrl: chapterUrl ?? this.chapterUrl,
    chapterTitle: chapterTitle ?? this.chapterTitle,
    chapterSlug: chapterSlug ?? this.chapterSlug,
    totalPages: totalPages ?? this.totalPages,
    downloadedPages: downloadedPages ?? this.downloadedPages,
    state: state ?? this.state,
    bytesReceived: bytesReceived ?? this.bytesReceived,
    bytesTotal: bytesTotal ?? this.bytesTotal,
    error: error.present ? error.value : this.error,
    directory: directory.present ? directory.value : this.directory,
    autoNext: autoNext ?? this.autoNext,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DownloadTask copyWithCompanion(DownloadTasksCompanion data) {
    return DownloadTask(
      id: data.id.present ? data.id.value : this.id,
      mangaUrl: data.mangaUrl.present ? data.mangaUrl.value : this.mangaUrl,
      mangaTitle: data.mangaTitle.present
          ? data.mangaTitle.value
          : this.mangaTitle,
      mangaSlug: data.mangaSlug.present ? data.mangaSlug.value : this.mangaSlug,
      chapterUrl: data.chapterUrl.present
          ? data.chapterUrl.value
          : this.chapterUrl,
      chapterTitle: data.chapterTitle.present
          ? data.chapterTitle.value
          : this.chapterTitle,
      chapterSlug: data.chapterSlug.present
          ? data.chapterSlug.value
          : this.chapterSlug,
      totalPages: data.totalPages.present
          ? data.totalPages.value
          : this.totalPages,
      downloadedPages: data.downloadedPages.present
          ? data.downloadedPages.value
          : this.downloadedPages,
      state: data.state.present ? data.state.value : this.state,
      bytesReceived: data.bytesReceived.present
          ? data.bytesReceived.value
          : this.bytesReceived,
      bytesTotal: data.bytesTotal.present
          ? data.bytesTotal.value
          : this.bytesTotal,
      error: data.error.present ? data.error.value : this.error,
      directory: data.directory.present ? data.directory.value : this.directory,
      autoNext: data.autoNext.present ? data.autoNext.value : this.autoNext,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTask(')
          ..write('id: $id, ')
          ..write('mangaUrl: $mangaUrl, ')
          ..write('mangaTitle: $mangaTitle, ')
          ..write('mangaSlug: $mangaSlug, ')
          ..write('chapterUrl: $chapterUrl, ')
          ..write('chapterTitle: $chapterTitle, ')
          ..write('chapterSlug: $chapterSlug, ')
          ..write('totalPages: $totalPages, ')
          ..write('downloadedPages: $downloadedPages, ')
          ..write('state: $state, ')
          ..write('bytesReceived: $bytesReceived, ')
          ..write('bytesTotal: $bytesTotal, ')
          ..write('error: $error, ')
          ..write('directory: $directory, ')
          ..write('autoNext: $autoNext, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mangaUrl,
    mangaTitle,
    mangaSlug,
    chapterUrl,
    chapterTitle,
    chapterSlug,
    totalPages,
    downloadedPages,
    state,
    bytesReceived,
    bytesTotal,
    error,
    directory,
    autoNext,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadTask &&
          other.id == this.id &&
          other.mangaUrl == this.mangaUrl &&
          other.mangaTitle == this.mangaTitle &&
          other.mangaSlug == this.mangaSlug &&
          other.chapterUrl == this.chapterUrl &&
          other.chapterTitle == this.chapterTitle &&
          other.chapterSlug == this.chapterSlug &&
          other.totalPages == this.totalPages &&
          other.downloadedPages == this.downloadedPages &&
          other.state == this.state &&
          other.bytesReceived == this.bytesReceived &&
          other.bytesTotal == this.bytesTotal &&
          other.error == this.error &&
          other.directory == this.directory &&
          other.autoNext == this.autoNext &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DownloadTasksCompanion extends UpdateCompanion<DownloadTask> {
  final Value<int> id;
  final Value<String> mangaUrl;
  final Value<String> mangaTitle;
  final Value<String> mangaSlug;
  final Value<String> chapterUrl;
  final Value<String> chapterTitle;
  final Value<String> chapterSlug;
  final Value<int> totalPages;
  final Value<int> downloadedPages;
  final Value<String> state;
  final Value<int> bytesReceived;
  final Value<int> bytesTotal;
  final Value<String?> error;
  final Value<String?> directory;
  final Value<bool> autoNext;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DownloadTasksCompanion({
    this.id = const Value.absent(),
    this.mangaUrl = const Value.absent(),
    this.mangaTitle = const Value.absent(),
    this.mangaSlug = const Value.absent(),
    this.chapterUrl = const Value.absent(),
    this.chapterTitle = const Value.absent(),
    this.chapterSlug = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.downloadedPages = const Value.absent(),
    this.state = const Value.absent(),
    this.bytesReceived = const Value.absent(),
    this.bytesTotal = const Value.absent(),
    this.error = const Value.absent(),
    this.directory = const Value.absent(),
    this.autoNext = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DownloadTasksCompanion.insert({
    this.id = const Value.absent(),
    required String mangaUrl,
    required String mangaTitle,
    required String mangaSlug,
    required String chapterUrl,
    required String chapterTitle,
    required String chapterSlug,
    this.totalPages = const Value.absent(),
    this.downloadedPages = const Value.absent(),
    required String state,
    this.bytesReceived = const Value.absent(),
    this.bytesTotal = const Value.absent(),
    this.error = const Value.absent(),
    this.directory = const Value.absent(),
    this.autoNext = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : mangaUrl = Value(mangaUrl),
       mangaTitle = Value(mangaTitle),
       mangaSlug = Value(mangaSlug),
       chapterUrl = Value(chapterUrl),
       chapterTitle = Value(chapterTitle),
       chapterSlug = Value(chapterSlug),
       state = Value(state);
  static Insertable<DownloadTask> custom({
    Expression<int>? id,
    Expression<String>? mangaUrl,
    Expression<String>? mangaTitle,
    Expression<String>? mangaSlug,
    Expression<String>? chapterUrl,
    Expression<String>? chapterTitle,
    Expression<String>? chapterSlug,
    Expression<int>? totalPages,
    Expression<int>? downloadedPages,
    Expression<String>? state,
    Expression<int>? bytesReceived,
    Expression<int>? bytesTotal,
    Expression<String>? error,
    Expression<String>? directory,
    Expression<bool>? autoNext,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mangaUrl != null) 'manga_url': mangaUrl,
      if (mangaTitle != null) 'manga_title': mangaTitle,
      if (mangaSlug != null) 'manga_slug': mangaSlug,
      if (chapterUrl != null) 'chapter_url': chapterUrl,
      if (chapterTitle != null) 'chapter_title': chapterTitle,
      if (chapterSlug != null) 'chapter_slug': chapterSlug,
      if (totalPages != null) 'total_pages': totalPages,
      if (downloadedPages != null) 'downloaded_pages': downloadedPages,
      if (state != null) 'state': state,
      if (bytesReceived != null) 'bytes_received': bytesReceived,
      if (bytesTotal != null) 'bytes_total': bytesTotal,
      if (error != null) 'error': error,
      if (directory != null) 'directory': directory,
      if (autoNext != null) 'auto_next': autoNext,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DownloadTasksCompanion copyWith({
    Value<int>? id,
    Value<String>? mangaUrl,
    Value<String>? mangaTitle,
    Value<String>? mangaSlug,
    Value<String>? chapterUrl,
    Value<String>? chapterTitle,
    Value<String>? chapterSlug,
    Value<int>? totalPages,
    Value<int>? downloadedPages,
    Value<String>? state,
    Value<int>? bytesReceived,
    Value<int>? bytesTotal,
    Value<String?>? error,
    Value<String?>? directory,
    Value<bool>? autoNext,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return DownloadTasksCompanion(
      id: id ?? this.id,
      mangaUrl: mangaUrl ?? this.mangaUrl,
      mangaTitle: mangaTitle ?? this.mangaTitle,
      mangaSlug: mangaSlug ?? this.mangaSlug,
      chapterUrl: chapterUrl ?? this.chapterUrl,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      chapterSlug: chapterSlug ?? this.chapterSlug,
      totalPages: totalPages ?? this.totalPages,
      downloadedPages: downloadedPages ?? this.downloadedPages,
      state: state ?? this.state,
      bytesReceived: bytesReceived ?? this.bytesReceived,
      bytesTotal: bytesTotal ?? this.bytesTotal,
      error: error ?? this.error,
      directory: directory ?? this.directory,
      autoNext: autoNext ?? this.autoNext,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mangaUrl.present) {
      map['manga_url'] = Variable<String>(mangaUrl.value);
    }
    if (mangaTitle.present) {
      map['manga_title'] = Variable<String>(mangaTitle.value);
    }
    if (mangaSlug.present) {
      map['manga_slug'] = Variable<String>(mangaSlug.value);
    }
    if (chapterUrl.present) {
      map['chapter_url'] = Variable<String>(chapterUrl.value);
    }
    if (chapterTitle.present) {
      map['chapter_title'] = Variable<String>(chapterTitle.value);
    }
    if (chapterSlug.present) {
      map['chapter_slug'] = Variable<String>(chapterSlug.value);
    }
    if (totalPages.present) {
      map['total_pages'] = Variable<int>(totalPages.value);
    }
    if (downloadedPages.present) {
      map['downloaded_pages'] = Variable<int>(downloadedPages.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (bytesReceived.present) {
      map['bytes_received'] = Variable<int>(bytesReceived.value);
    }
    if (bytesTotal.present) {
      map['bytes_total'] = Variable<int>(bytesTotal.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (directory.present) {
      map['directory'] = Variable<String>(directory.value);
    }
    if (autoNext.present) {
      map['auto_next'] = Variable<bool>(autoNext.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTasksCompanion(')
          ..write('id: $id, ')
          ..write('mangaUrl: $mangaUrl, ')
          ..write('mangaTitle: $mangaTitle, ')
          ..write('mangaSlug: $mangaSlug, ')
          ..write('chapterUrl: $chapterUrl, ')
          ..write('chapterTitle: $chapterTitle, ')
          ..write('chapterSlug: $chapterSlug, ')
          ..write('totalPages: $totalPages, ')
          ..write('downloadedPages: $downloadedPages, ')
          ..write('state: $state, ')
          ..write('bytesReceived: $bytesReceived, ')
          ..write('bytesTotal: $bytesTotal, ')
          ..write('error: $error, ')
          ..write('directory: $directory, ')
          ..write('autoNext: $autoNext, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SearchHistoryTableTable extends SearchHistoryTable
    with TableInfo<$SearchHistoryTableTable, SearchHistoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _termMeta = const VerificationMeta('term');
  @override
  late final GeneratedColumn<String> term = GeneratedColumn<String>(
    'term',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchedAtMeta = const VerificationMeta(
    'searchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> searchedAt = GeneratedColumn<DateTime>(
    'searched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, term, searchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_history_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SearchHistoryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('term')) {
      context.handle(
        _termMeta,
        term.isAcceptableOrUnknown(data['term']!, _termMeta),
      );
    } else if (isInserting) {
      context.missing(_termMeta);
    }
    if (data.containsKey('searched_at')) {
      context.handle(
        _searchedAtMeta,
        searchedAt.isAcceptableOrUnknown(data['searched_at']!, _searchedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SearchHistoryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchHistoryTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      term: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term'],
      )!,
      searchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}searched_at'],
      )!,
    );
  }

  @override
  $SearchHistoryTableTable createAlias(String alias) {
    return $SearchHistoryTableTable(attachedDatabase, alias);
  }
}

class SearchHistoryTableData extends DataClass
    implements Insertable<SearchHistoryTableData> {
  final int id;
  final String term;
  final DateTime searchedAt;
  const SearchHistoryTableData({
    required this.id,
    required this.term,
    required this.searchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['term'] = Variable<String>(term);
    map['searched_at'] = Variable<DateTime>(searchedAt);
    return map;
  }

  SearchHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return SearchHistoryTableCompanion(
      id: Value(id),
      term: Value(term),
      searchedAt: Value(searchedAt),
    );
  }

  factory SearchHistoryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchHistoryTableData(
      id: serializer.fromJson<int>(json['id']),
      term: serializer.fromJson<String>(json['term']),
      searchedAt: serializer.fromJson<DateTime>(json['searchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'term': serializer.toJson<String>(term),
      'searchedAt': serializer.toJson<DateTime>(searchedAt),
    };
  }

  SearchHistoryTableData copyWith({
    int? id,
    String? term,
    DateTime? searchedAt,
  }) => SearchHistoryTableData(
    id: id ?? this.id,
    term: term ?? this.term,
    searchedAt: searchedAt ?? this.searchedAt,
  );
  SearchHistoryTableData copyWithCompanion(SearchHistoryTableCompanion data) {
    return SearchHistoryTableData(
      id: data.id.present ? data.id.value : this.id,
      term: data.term.present ? data.term.value : this.term,
      searchedAt: data.searchedAt.present
          ? data.searchedAt.value
          : this.searchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryTableData(')
          ..write('id: $id, ')
          ..write('term: $term, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, term, searchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchHistoryTableData &&
          other.id == this.id &&
          other.term == this.term &&
          other.searchedAt == this.searchedAt);
}

class SearchHistoryTableCompanion
    extends UpdateCompanion<SearchHistoryTableData> {
  final Value<int> id;
  final Value<String> term;
  final Value<DateTime> searchedAt;
  const SearchHistoryTableCompanion({
    this.id = const Value.absent(),
    this.term = const Value.absent(),
    this.searchedAt = const Value.absent(),
  });
  SearchHistoryTableCompanion.insert({
    this.id = const Value.absent(),
    required String term,
    this.searchedAt = const Value.absent(),
  }) : term = Value(term);
  static Insertable<SearchHistoryTableData> custom({
    Expression<int>? id,
    Expression<String>? term,
    Expression<DateTime>? searchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (term != null) 'term': term,
      if (searchedAt != null) 'searched_at': searchedAt,
    });
  }

  SearchHistoryTableCompanion copyWith({
    Value<int>? id,
    Value<String>? term,
    Value<DateTime>? searchedAt,
  }) {
    return SearchHistoryTableCompanion(
      id: id ?? this.id,
      term: term ?? this.term,
      searchedAt: searchedAt ?? this.searchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (term.present) {
      map['term'] = Variable<String>(term.value);
    }
    if (searchedAt.present) {
      map['searched_at'] = Variable<DateTime>(searchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('term: $term, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LibraryItemsTable libraryItems = $LibraryItemsTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $CollectionItemsTable collectionItems = $CollectionItemsTable(
    this,
  );
  late final $TagsTable tags = $TagsTable(this);
  late final $MangaTagsTable mangaTags = $MangaTagsTable(this);
  late final $ReadingHistoryTable readingHistory = $ReadingHistoryTable(this);
  late final $ReadingSessionsTable readingSessions = $ReadingSessionsTable(
    this,
  );
  late final $DownloadTasksTable downloadTasks = $DownloadTasksTable(this);
  late final $SearchHistoryTableTable searchHistoryTable =
      $SearchHistoryTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    libraryItems,
    collections,
    collectionItems,
    tags,
    mangaTags,
    readingHistory,
    readingSessions,
    downloadTasks,
    searchHistoryTable,
  ];
}

typedef $$LibraryItemsTableCreateCompanionBuilder =
    LibraryItemsCompanion Function({
      required String mangaUrl,
      required String title,
      Value<String?> coverUrl,
      Value<int?> postId,
      Value<bool> favorite,
      Value<bool> bookmark,
      Value<String?> status,
      Value<DateTime> addedAt,
      Value<DateTime?> lastReadAt,
      Value<String?> lastChapterTitle,
      Value<String?> lastChapterUrl,
      Value<String?> genres,
      Value<String?> author,
      Value<String?> type,
      Value<String?> releaseYear,
      Value<bool> isAdult,
      Value<int> rowid,
    });
typedef $$LibraryItemsTableUpdateCompanionBuilder =
    LibraryItemsCompanion Function({
      Value<String> mangaUrl,
      Value<String> title,
      Value<String?> coverUrl,
      Value<int?> postId,
      Value<bool> favorite,
      Value<bool> bookmark,
      Value<String?> status,
      Value<DateTime> addedAt,
      Value<DateTime?> lastReadAt,
      Value<String?> lastChapterTitle,
      Value<String?> lastChapterUrl,
      Value<String?> genres,
      Value<String?> author,
      Value<String?> type,
      Value<String?> releaseYear,
      Value<bool> isAdult,
      Value<int> rowid,
    });

class $$LibraryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryItemsTable> {
  $$LibraryItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get mangaUrl => $composableBuilder(
    column: $table.mangaUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get postId => $composableBuilder(
    column: $table.postId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get bookmark => $composableBuilder(
    column: $table.bookmark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReadAt => $composableBuilder(
    column: $table.lastReadAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastChapterTitle => $composableBuilder(
    column: $table.lastChapterTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastChapterUrl => $composableBuilder(
    column: $table.lastChapterUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAdult => $composableBuilder(
    column: $table.isAdult,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LibraryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryItemsTable> {
  $$LibraryItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get mangaUrl => $composableBuilder(
    column: $table.mangaUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get postId => $composableBuilder(
    column: $table.postId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get bookmark => $composableBuilder(
    column: $table.bookmark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReadAt => $composableBuilder(
    column: $table.lastReadAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastChapterTitle => $composableBuilder(
    column: $table.lastChapterTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastChapterUrl => $composableBuilder(
    column: $table.lastChapterUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAdult => $composableBuilder(
    column: $table.isAdult,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibraryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryItemsTable> {
  $$LibraryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get mangaUrl =>
      $composableBuilder(column: $table.mangaUrl, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<int> get postId =>
      $composableBuilder(column: $table.postId, builder: (column) => column);

  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  GeneratedColumn<bool> get bookmark =>
      $composableBuilder(column: $table.bookmark, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReadAt => $composableBuilder(
    column: $table.lastReadAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastChapterTitle => $composableBuilder(
    column: $table.lastChapterTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastChapterUrl => $composableBuilder(
    column: $table.lastChapterUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genres =>
      $composableBuilder(column: $table.genres, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAdult =>
      $composableBuilder(column: $table.isAdult, builder: (column) => column);
}

class $$LibraryItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibraryItemsTable,
          LibraryItem,
          $$LibraryItemsTableFilterComposer,
          $$LibraryItemsTableOrderingComposer,
          $$LibraryItemsTableAnnotationComposer,
          $$LibraryItemsTableCreateCompanionBuilder,
          $$LibraryItemsTableUpdateCompanionBuilder,
          (
            LibraryItem,
            BaseReferences<_$AppDatabase, $LibraryItemsTable, LibraryItem>,
          ),
          LibraryItem,
          PrefetchHooks Function()
        > {
  $$LibraryItemsTableTableManager(_$AppDatabase db, $LibraryItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> mangaUrl = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<int?> postId = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<bool> bookmark = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<DateTime?> lastReadAt = const Value.absent(),
                Value<String?> lastChapterTitle = const Value.absent(),
                Value<String?> lastChapterUrl = const Value.absent(),
                Value<String?> genres = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<String?> releaseYear = const Value.absent(),
                Value<bool> isAdult = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryItemsCompanion(
                mangaUrl: mangaUrl,
                title: title,
                coverUrl: coverUrl,
                postId: postId,
                favorite: favorite,
                bookmark: bookmark,
                status: status,
                addedAt: addedAt,
                lastReadAt: lastReadAt,
                lastChapterTitle: lastChapterTitle,
                lastChapterUrl: lastChapterUrl,
                genres: genres,
                author: author,
                type: type,
                releaseYear: releaseYear,
                isAdult: isAdult,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String mangaUrl,
                required String title,
                Value<String?> coverUrl = const Value.absent(),
                Value<int?> postId = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<bool> bookmark = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<DateTime?> lastReadAt = const Value.absent(),
                Value<String?> lastChapterTitle = const Value.absent(),
                Value<String?> lastChapterUrl = const Value.absent(),
                Value<String?> genres = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<String?> releaseYear = const Value.absent(),
                Value<bool> isAdult = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryItemsCompanion.insert(
                mangaUrl: mangaUrl,
                title: title,
                coverUrl: coverUrl,
                postId: postId,
                favorite: favorite,
                bookmark: bookmark,
                status: status,
                addedAt: addedAt,
                lastReadAt: lastReadAt,
                lastChapterTitle: lastChapterTitle,
                lastChapterUrl: lastChapterUrl,
                genres: genres,
                author: author,
                type: type,
                releaseYear: releaseYear,
                isAdult: isAdult,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LibraryItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibraryItemsTable,
      LibraryItem,
      $$LibraryItemsTableFilterComposer,
      $$LibraryItemsTableOrderingComposer,
      $$LibraryItemsTableAnnotationComposer,
      $$LibraryItemsTableCreateCompanionBuilder,
      $$LibraryItemsTableUpdateCompanionBuilder,
      (
        LibraryItem,
        BaseReferences<_$AppDatabase, $LibraryItemsTable, LibraryItem>,
      ),
      LibraryItem,
      PrefetchHooks Function()
    >;
typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<int> sortOrder,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<int> sortOrder,
    });

final class $$CollectionsTableReferences
    extends BaseReferences<_$AppDatabase, $CollectionsTable, Collection> {
  $$CollectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CollectionItemsTable, List<CollectionItem>>
  _collectionItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.collectionItems,
    aliasName: $_aliasNameGenerator(
      db.collections.id,
      db.collectionItems.collectionId,
    ),
  );

  $$CollectionItemsTableProcessedTableManager get collectionItemsRefs {
    final manager = $$CollectionItemsTableTableManager(
      $_db,
      $_db.collectionItems,
    ).filter((f) => f.collectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _collectionItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> collectionItemsRefs(
    Expression<bool> Function($$CollectionItemsTableFilterComposer f) f,
  ) {
    final $$CollectionItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionItems,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionItemsTableFilterComposer(
            $db: $db,
            $table: $db.collectionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> collectionItemsRefs<T extends Object>(
    Expression<T> Function($$CollectionItemsTableAnnotationComposer a) f,
  ) {
    final $$CollectionItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionItems,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.collectionItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionsTable,
          Collection,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (Collection, $$CollectionsTableReferences),
          Collection,
          PrefetchHooks Function({bool collectionItemsRefs})
        > {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CollectionsCompanion(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CollectionsCompanion.insert(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CollectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({collectionItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (collectionItemsRefs) db.collectionItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (collectionItemsRefs)
                    await $_getPrefetchedData<
                      Collection,
                      $CollectionsTable,
                      CollectionItem
                    >(
                      currentTable: table,
                      referencedTable: $$CollectionsTableReferences
                          ._collectionItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CollectionsTableReferences(
                            db,
                            table,
                            p0,
                          ).collectionItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.collectionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionsTable,
      Collection,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (Collection, $$CollectionsTableReferences),
      Collection,
      PrefetchHooks Function({bool collectionItemsRefs})
    >;
typedef $$CollectionItemsTableCreateCompanionBuilder =
    CollectionItemsCompanion Function({
      required int collectionId,
      required String mangaUrl,
      required String title,
      Value<String?> coverUrl,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });
typedef $$CollectionItemsTableUpdateCompanionBuilder =
    CollectionItemsCompanion Function({
      Value<int> collectionId,
      Value<String> mangaUrl,
      Value<String> title,
      Value<String?> coverUrl,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

final class $$CollectionItemsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CollectionItemsTable, CollectionItem> {
  $$CollectionItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CollectionsTable _collectionIdTable(_$AppDatabase db) =>
      db.collections.createAlias(
        $_aliasNameGenerator(
          db.collectionItems.collectionId,
          db.collections.id,
        ),
      );

  $$CollectionsTableProcessedTableManager get collectionId {
    final $_column = $_itemColumn<int>('collection_id')!;

    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CollectionItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionItemsTable> {
  $$CollectionItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get mangaUrl => $composableBuilder(
    column: $table.mangaUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionItemsTable> {
  $$CollectionItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get mangaUrl => $composableBuilder(
    column: $table.mangaUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionItemsTable> {
  $$CollectionItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get mangaUrl =>
      $composableBuilder(column: $table.mangaUrl, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionItemsTable,
          CollectionItem,
          $$CollectionItemsTableFilterComposer,
          $$CollectionItemsTableOrderingComposer,
          $$CollectionItemsTableAnnotationComposer,
          $$CollectionItemsTableCreateCompanionBuilder,
          $$CollectionItemsTableUpdateCompanionBuilder,
          (CollectionItem, $$CollectionItemsTableReferences),
          CollectionItem,
          PrefetchHooks Function({bool collectionId})
        > {
  $$CollectionItemsTableTableManager(
    _$AppDatabase db,
    $CollectionItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> collectionId = const Value.absent(),
                Value<String> mangaUrl = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionItemsCompanion(
                collectionId: collectionId,
                mangaUrl: mangaUrl,
                title: title,
                coverUrl: coverUrl,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int collectionId,
                required String mangaUrl,
                required String title,
                Value<String?> coverUrl = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionItemsCompanion.insert(
                collectionId: collectionId,
                mangaUrl: mangaUrl,
                title: title,
                coverUrl: coverUrl,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CollectionItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({collectionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (collectionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.collectionId,
                                referencedTable:
                                    $$CollectionItemsTableReferences
                                        ._collectionIdTable(db),
                                referencedColumn:
                                    $$CollectionItemsTableReferences
                                        ._collectionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CollectionItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionItemsTable,
      CollectionItem,
      $$CollectionItemsTableFilterComposer,
      $$CollectionItemsTableOrderingComposer,
      $$CollectionItemsTableAnnotationComposer,
      $$CollectionItemsTableCreateCompanionBuilder,
      $$CollectionItemsTableUpdateCompanionBuilder,
      (CollectionItem, $$CollectionItemsTableReferences),
      CollectionItem,
      PrefetchHooks Function({bool collectionId})
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> color,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> color,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MangaTagsTable, List<MangaTag>>
  _mangaTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mangaTags,
    aliasName: $_aliasNameGenerator(db.tags.id, db.mangaTags.tagId),
  );

  $$MangaTagsTableProcessedTableManager get mangaTagsRefs {
    final manager = $$MangaTagsTableTableManager(
      $_db,
      $_db.mangaTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_mangaTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> mangaTagsRefs(
    Expression<bool> Function($$MangaTagsTableFilterComposer f) f,
  ) {
    final $$MangaTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mangaTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MangaTagsTableFilterComposer(
            $db: $db,
            $table: $db.mangaTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  Expression<T> mangaTagsRefs<T extends Object>(
    Expression<T> Function($$MangaTagsTableAnnotationComposer a) f,
  ) {
    final $$MangaTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mangaTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MangaTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.mangaTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool mangaTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> color = const Value.absent(),
              }) => TagsCompanion(id: id, name: name, color: color),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> color = const Value.absent(),
              }) => TagsCompanion.insert(id: id, name: name, color: color),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({mangaTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (mangaTagsRefs) db.mangaTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (mangaTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, MangaTag>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences
                          ._mangaTagsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).mangaTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool mangaTagsRefs})
    >;
typedef $$MangaTagsTableCreateCompanionBuilder =
    MangaTagsCompanion Function({
      required int tagId,
      required String mangaUrl,
      Value<int> rowid,
    });
typedef $$MangaTagsTableUpdateCompanionBuilder =
    MangaTagsCompanion Function({
      Value<int> tagId,
      Value<String> mangaUrl,
      Value<int> rowid,
    });

final class $$MangaTagsTableReferences
    extends BaseReferences<_$AppDatabase, $MangaTagsTable, MangaTag> {
  $$MangaTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias($_aliasNameGenerator(db.mangaTags.tagId, db.tags.id));

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MangaTagsTableFilterComposer
    extends Composer<_$AppDatabase, $MangaTagsTable> {
  $$MangaTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get mangaUrl => $composableBuilder(
    column: $table.mangaUrl,
    builder: (column) => ColumnFilters(column),
  );

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MangaTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $MangaTagsTable> {
  $$MangaTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get mangaUrl => $composableBuilder(
    column: $table.mangaUrl,
    builder: (column) => ColumnOrderings(column),
  );

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MangaTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MangaTagsTable> {
  $$MangaTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get mangaUrl =>
      $composableBuilder(column: $table.mangaUrl, builder: (column) => column);

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MangaTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MangaTagsTable,
          MangaTag,
          $$MangaTagsTableFilterComposer,
          $$MangaTagsTableOrderingComposer,
          $$MangaTagsTableAnnotationComposer,
          $$MangaTagsTableCreateCompanionBuilder,
          $$MangaTagsTableUpdateCompanionBuilder,
          (MangaTag, $$MangaTagsTableReferences),
          MangaTag,
          PrefetchHooks Function({bool tagId})
        > {
  $$MangaTagsTableTableManager(_$AppDatabase db, $MangaTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MangaTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MangaTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MangaTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> tagId = const Value.absent(),
                Value<String> mangaUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MangaTagsCompanion(
                tagId: tagId,
                mangaUrl: mangaUrl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int tagId,
                required String mangaUrl,
                Value<int> rowid = const Value.absent(),
              }) => MangaTagsCompanion.insert(
                tagId: tagId,
                mangaUrl: mangaUrl,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MangaTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$MangaTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$MangaTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MangaTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MangaTagsTable,
      MangaTag,
      $$MangaTagsTableFilterComposer,
      $$MangaTagsTableOrderingComposer,
      $$MangaTagsTableAnnotationComposer,
      $$MangaTagsTableCreateCompanionBuilder,
      $$MangaTagsTableUpdateCompanionBuilder,
      (MangaTag, $$MangaTagsTableReferences),
      MangaTag,
      PrefetchHooks Function({bool tagId})
    >;
typedef $$ReadingHistoryTableCreateCompanionBuilder =
    ReadingHistoryCompanion Function({
      required String mangaUrl,
      required String mangaTitle,
      Value<String?> coverUrl,
      required String chapterUrl,
      required String chapterTitle,
      Value<int> pageIndex,
      Value<int> totalPages,
      Value<DateTime> readAt,
      Value<int> rowid,
    });
typedef $$ReadingHistoryTableUpdateCompanionBuilder =
    ReadingHistoryCompanion Function({
      Value<String> mangaUrl,
      Value<String> mangaTitle,
      Value<String?> coverUrl,
      Value<String> chapterUrl,
      Value<String> chapterTitle,
      Value<int> pageIndex,
      Value<int> totalPages,
      Value<DateTime> readAt,
      Value<int> rowid,
    });

class $$ReadingHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingHistoryTable> {
  $$ReadingHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get mangaUrl => $composableBuilder(
    column: $table.mangaUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mangaTitle => $composableBuilder(
    column: $table.mangaTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterUrl => $composableBuilder(
    column: $table.chapterUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterTitle => $composableBuilder(
    column: $table.chapterTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageIndex => $composableBuilder(
    column: $table.pageIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingHistoryTable> {
  $$ReadingHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get mangaUrl => $composableBuilder(
    column: $table.mangaUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mangaTitle => $composableBuilder(
    column: $table.mangaTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterUrl => $composableBuilder(
    column: $table.chapterUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterTitle => $composableBuilder(
    column: $table.chapterTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageIndex => $composableBuilder(
    column: $table.pageIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingHistoryTable> {
  $$ReadingHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get mangaUrl =>
      $composableBuilder(column: $table.mangaUrl, builder: (column) => column);

  GeneratedColumn<String> get mangaTitle => $composableBuilder(
    column: $table.mangaTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get chapterUrl => $composableBuilder(
    column: $table.chapterUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chapterTitle => $composableBuilder(
    column: $table.chapterTitle,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pageIndex =>
      $composableBuilder(column: $table.pageIndex, builder: (column) => column);

  GeneratedColumn<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);
}

class $$ReadingHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingHistoryTable,
          ReadingHistoryData,
          $$ReadingHistoryTableFilterComposer,
          $$ReadingHistoryTableOrderingComposer,
          $$ReadingHistoryTableAnnotationComposer,
          $$ReadingHistoryTableCreateCompanionBuilder,
          $$ReadingHistoryTableUpdateCompanionBuilder,
          (
            ReadingHistoryData,
            BaseReferences<
              _$AppDatabase,
              $ReadingHistoryTable,
              ReadingHistoryData
            >,
          ),
          ReadingHistoryData,
          PrefetchHooks Function()
        > {
  $$ReadingHistoryTableTableManager(
    _$AppDatabase db,
    $ReadingHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> mangaUrl = const Value.absent(),
                Value<String> mangaTitle = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String> chapterUrl = const Value.absent(),
                Value<String> chapterTitle = const Value.absent(),
                Value<int> pageIndex = const Value.absent(),
                Value<int> totalPages = const Value.absent(),
                Value<DateTime> readAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingHistoryCompanion(
                mangaUrl: mangaUrl,
                mangaTitle: mangaTitle,
                coverUrl: coverUrl,
                chapterUrl: chapterUrl,
                chapterTitle: chapterTitle,
                pageIndex: pageIndex,
                totalPages: totalPages,
                readAt: readAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String mangaUrl,
                required String mangaTitle,
                Value<String?> coverUrl = const Value.absent(),
                required String chapterUrl,
                required String chapterTitle,
                Value<int> pageIndex = const Value.absent(),
                Value<int> totalPages = const Value.absent(),
                Value<DateTime> readAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingHistoryCompanion.insert(
                mangaUrl: mangaUrl,
                mangaTitle: mangaTitle,
                coverUrl: coverUrl,
                chapterUrl: chapterUrl,
                chapterTitle: chapterTitle,
                pageIndex: pageIndex,
                totalPages: totalPages,
                readAt: readAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingHistoryTable,
      ReadingHistoryData,
      $$ReadingHistoryTableFilterComposer,
      $$ReadingHistoryTableOrderingComposer,
      $$ReadingHistoryTableAnnotationComposer,
      $$ReadingHistoryTableCreateCompanionBuilder,
      $$ReadingHistoryTableUpdateCompanionBuilder,
      (
        ReadingHistoryData,
        BaseReferences<_$AppDatabase, $ReadingHistoryTable, ReadingHistoryData>,
      ),
      ReadingHistoryData,
      PrefetchHooks Function()
    >;
typedef $$ReadingSessionsTableCreateCompanionBuilder =
    ReadingSessionsCompanion Function({
      Value<int> id,
      required String mangaUrl,
      required String chapterUrl,
      required DateTime sessionDate,
      Value<int> durationSeconds,
      Value<int> pagesRead,
      Value<int> pagesTotal,
    });
typedef $$ReadingSessionsTableUpdateCompanionBuilder =
    ReadingSessionsCompanion Function({
      Value<int> id,
      Value<String> mangaUrl,
      Value<String> chapterUrl,
      Value<DateTime> sessionDate,
      Value<int> durationSeconds,
      Value<int> pagesRead,
      Value<int> pagesTotal,
    });

class $$ReadingSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mangaUrl => $composableBuilder(
    column: $table.mangaUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterUrl => $composableBuilder(
    column: $table.chapterUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sessionDate => $composableBuilder(
    column: $table.sessionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pagesRead => $composableBuilder(
    column: $table.pagesRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pagesTotal => $composableBuilder(
    column: $table.pagesTotal,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mangaUrl => $composableBuilder(
    column: $table.mangaUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterUrl => $composableBuilder(
    column: $table.chapterUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sessionDate => $composableBuilder(
    column: $table.sessionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pagesRead => $composableBuilder(
    column: $table.pagesRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pagesTotal => $composableBuilder(
    column: $table.pagesTotal,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mangaUrl =>
      $composableBuilder(column: $table.mangaUrl, builder: (column) => column);

  GeneratedColumn<String> get chapterUrl => $composableBuilder(
    column: $table.chapterUrl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get sessionDate => $composableBuilder(
    column: $table.sessionDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pagesRead =>
      $composableBuilder(column: $table.pagesRead, builder: (column) => column);

  GeneratedColumn<int> get pagesTotal => $composableBuilder(
    column: $table.pagesTotal,
    builder: (column) => column,
  );
}

class $$ReadingSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingSessionsTable,
          ReadingSession,
          $$ReadingSessionsTableFilterComposer,
          $$ReadingSessionsTableOrderingComposer,
          $$ReadingSessionsTableAnnotationComposer,
          $$ReadingSessionsTableCreateCompanionBuilder,
          $$ReadingSessionsTableUpdateCompanionBuilder,
          (
            ReadingSession,
            BaseReferences<
              _$AppDatabase,
              $ReadingSessionsTable,
              ReadingSession
            >,
          ),
          ReadingSession,
          PrefetchHooks Function()
        > {
  $$ReadingSessionsTableTableManager(
    _$AppDatabase db,
    $ReadingSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> mangaUrl = const Value.absent(),
                Value<String> chapterUrl = const Value.absent(),
                Value<DateTime> sessionDate = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> pagesRead = const Value.absent(),
                Value<int> pagesTotal = const Value.absent(),
              }) => ReadingSessionsCompanion(
                id: id,
                mangaUrl: mangaUrl,
                chapterUrl: chapterUrl,
                sessionDate: sessionDate,
                durationSeconds: durationSeconds,
                pagesRead: pagesRead,
                pagesTotal: pagesTotal,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String mangaUrl,
                required String chapterUrl,
                required DateTime sessionDate,
                Value<int> durationSeconds = const Value.absent(),
                Value<int> pagesRead = const Value.absent(),
                Value<int> pagesTotal = const Value.absent(),
              }) => ReadingSessionsCompanion.insert(
                id: id,
                mangaUrl: mangaUrl,
                chapterUrl: chapterUrl,
                sessionDate: sessionDate,
                durationSeconds: durationSeconds,
                pagesRead: pagesRead,
                pagesTotal: pagesTotal,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingSessionsTable,
      ReadingSession,
      $$ReadingSessionsTableFilterComposer,
      $$ReadingSessionsTableOrderingComposer,
      $$ReadingSessionsTableAnnotationComposer,
      $$ReadingSessionsTableCreateCompanionBuilder,
      $$ReadingSessionsTableUpdateCompanionBuilder,
      (
        ReadingSession,
        BaseReferences<_$AppDatabase, $ReadingSessionsTable, ReadingSession>,
      ),
      ReadingSession,
      PrefetchHooks Function()
    >;
typedef $$DownloadTasksTableCreateCompanionBuilder =
    DownloadTasksCompanion Function({
      Value<int> id,
      required String mangaUrl,
      required String mangaTitle,
      required String mangaSlug,
      required String chapterUrl,
      required String chapterTitle,
      required String chapterSlug,
      Value<int> totalPages,
      Value<int> downloadedPages,
      required String state,
      Value<int> bytesReceived,
      Value<int> bytesTotal,
      Value<String?> error,
      Value<String?> directory,
      Value<bool> autoNext,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$DownloadTasksTableUpdateCompanionBuilder =
    DownloadTasksCompanion Function({
      Value<int> id,
      Value<String> mangaUrl,
      Value<String> mangaTitle,
      Value<String> mangaSlug,
      Value<String> chapterUrl,
      Value<String> chapterTitle,
      Value<String> chapterSlug,
      Value<int> totalPages,
      Value<int> downloadedPages,
      Value<String> state,
      Value<int> bytesReceived,
      Value<int> bytesTotal,
      Value<String?> error,
      Value<String?> directory,
      Value<bool> autoNext,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$DownloadTasksTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadTasksTable> {
  $$DownloadTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mangaUrl => $composableBuilder(
    column: $table.mangaUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mangaTitle => $composableBuilder(
    column: $table.mangaTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mangaSlug => $composableBuilder(
    column: $table.mangaSlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterUrl => $composableBuilder(
    column: $table.chapterUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterTitle => $composableBuilder(
    column: $table.chapterTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterSlug => $composableBuilder(
    column: $table.chapterSlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadedPages => $composableBuilder(
    column: $table.downloadedPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytesReceived => $composableBuilder(
    column: $table.bytesReceived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytesTotal => $composableBuilder(
    column: $table.bytesTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get directory => $composableBuilder(
    column: $table.directory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoNext => $composableBuilder(
    column: $table.autoNext,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadTasksTable> {
  $$DownloadTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mangaUrl => $composableBuilder(
    column: $table.mangaUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mangaTitle => $composableBuilder(
    column: $table.mangaTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mangaSlug => $composableBuilder(
    column: $table.mangaSlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterUrl => $composableBuilder(
    column: $table.chapterUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterTitle => $composableBuilder(
    column: $table.chapterTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterSlug => $composableBuilder(
    column: $table.chapterSlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadedPages => $composableBuilder(
    column: $table.downloadedPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytesReceived => $composableBuilder(
    column: $table.bytesReceived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytesTotal => $composableBuilder(
    column: $table.bytesTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get directory => $composableBuilder(
    column: $table.directory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoNext => $composableBuilder(
    column: $table.autoNext,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadTasksTable> {
  $$DownloadTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mangaUrl =>
      $composableBuilder(column: $table.mangaUrl, builder: (column) => column);

  GeneratedColumn<String> get mangaTitle => $composableBuilder(
    column: $table.mangaTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mangaSlug =>
      $composableBuilder(column: $table.mangaSlug, builder: (column) => column);

  GeneratedColumn<String> get chapterUrl => $composableBuilder(
    column: $table.chapterUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chapterTitle => $composableBuilder(
    column: $table.chapterTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chapterSlug => $composableBuilder(
    column: $table.chapterSlug,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => column,
  );

  GeneratedColumn<int> get downloadedPages => $composableBuilder(
    column: $table.downloadedPages,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get bytesReceived => $composableBuilder(
    column: $table.bytesReceived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bytesTotal => $composableBuilder(
    column: $table.bytesTotal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<String> get directory =>
      $composableBuilder(column: $table.directory, builder: (column) => column);

  GeneratedColumn<bool> get autoNext =>
      $composableBuilder(column: $table.autoNext, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DownloadTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadTasksTable,
          DownloadTask,
          $$DownloadTasksTableFilterComposer,
          $$DownloadTasksTableOrderingComposer,
          $$DownloadTasksTableAnnotationComposer,
          $$DownloadTasksTableCreateCompanionBuilder,
          $$DownloadTasksTableUpdateCompanionBuilder,
          (
            DownloadTask,
            BaseReferences<_$AppDatabase, $DownloadTasksTable, DownloadTask>,
          ),
          DownloadTask,
          PrefetchHooks Function()
        > {
  $$DownloadTasksTableTableManager(_$AppDatabase db, $DownloadTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> mangaUrl = const Value.absent(),
                Value<String> mangaTitle = const Value.absent(),
                Value<String> mangaSlug = const Value.absent(),
                Value<String> chapterUrl = const Value.absent(),
                Value<String> chapterTitle = const Value.absent(),
                Value<String> chapterSlug = const Value.absent(),
                Value<int> totalPages = const Value.absent(),
                Value<int> downloadedPages = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> bytesReceived = const Value.absent(),
                Value<int> bytesTotal = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<String?> directory = const Value.absent(),
                Value<bool> autoNext = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DownloadTasksCompanion(
                id: id,
                mangaUrl: mangaUrl,
                mangaTitle: mangaTitle,
                mangaSlug: mangaSlug,
                chapterUrl: chapterUrl,
                chapterTitle: chapterTitle,
                chapterSlug: chapterSlug,
                totalPages: totalPages,
                downloadedPages: downloadedPages,
                state: state,
                bytesReceived: bytesReceived,
                bytesTotal: bytesTotal,
                error: error,
                directory: directory,
                autoNext: autoNext,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String mangaUrl,
                required String mangaTitle,
                required String mangaSlug,
                required String chapterUrl,
                required String chapterTitle,
                required String chapterSlug,
                Value<int> totalPages = const Value.absent(),
                Value<int> downloadedPages = const Value.absent(),
                required String state,
                Value<int> bytesReceived = const Value.absent(),
                Value<int> bytesTotal = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<String?> directory = const Value.absent(),
                Value<bool> autoNext = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DownloadTasksCompanion.insert(
                id: id,
                mangaUrl: mangaUrl,
                mangaTitle: mangaTitle,
                mangaSlug: mangaSlug,
                chapterUrl: chapterUrl,
                chapterTitle: chapterTitle,
                chapterSlug: chapterSlug,
                totalPages: totalPages,
                downloadedPages: downloadedPages,
                state: state,
                bytesReceived: bytesReceived,
                bytesTotal: bytesTotal,
                error: error,
                directory: directory,
                autoNext: autoNext,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadTasksTable,
      DownloadTask,
      $$DownloadTasksTableFilterComposer,
      $$DownloadTasksTableOrderingComposer,
      $$DownloadTasksTableAnnotationComposer,
      $$DownloadTasksTableCreateCompanionBuilder,
      $$DownloadTasksTableUpdateCompanionBuilder,
      (
        DownloadTask,
        BaseReferences<_$AppDatabase, $DownloadTasksTable, DownloadTask>,
      ),
      DownloadTask,
      PrefetchHooks Function()
    >;
typedef $$SearchHistoryTableTableCreateCompanionBuilder =
    SearchHistoryTableCompanion Function({
      Value<int> id,
      required String term,
      Value<DateTime> searchedAt,
    });
typedef $$SearchHistoryTableTableUpdateCompanionBuilder =
    SearchHistoryTableCompanion Function({
      Value<int> id,
      Value<String> term,
      Value<DateTime> searchedAt,
    });

class $$SearchHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $SearchHistoryTableTable> {
  $$SearchHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SearchHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchHistoryTableTable> {
  $$SearchHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SearchHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchHistoryTableTable> {
  $$SearchHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get term =>
      $composableBuilder(column: $table.term, builder: (column) => column);

  GeneratedColumn<DateTime> get searchedAt => $composableBuilder(
    column: $table.searchedAt,
    builder: (column) => column,
  );
}

class $$SearchHistoryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SearchHistoryTableTable,
          SearchHistoryTableData,
          $$SearchHistoryTableTableFilterComposer,
          $$SearchHistoryTableTableOrderingComposer,
          $$SearchHistoryTableTableAnnotationComposer,
          $$SearchHistoryTableTableCreateCompanionBuilder,
          $$SearchHistoryTableTableUpdateCompanionBuilder,
          (
            SearchHistoryTableData,
            BaseReferences<
              _$AppDatabase,
              $SearchHistoryTableTable,
              SearchHistoryTableData
            >,
          ),
          SearchHistoryTableData,
          PrefetchHooks Function()
        > {
  $$SearchHistoryTableTableTableManager(
    _$AppDatabase db,
    $SearchHistoryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchHistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchHistoryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchHistoryTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> term = const Value.absent(),
                Value<DateTime> searchedAt = const Value.absent(),
              }) => SearchHistoryTableCompanion(
                id: id,
                term: term,
                searchedAt: searchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String term,
                Value<DateTime> searchedAt = const Value.absent(),
              }) => SearchHistoryTableCompanion.insert(
                id: id,
                term: term,
                searchedAt: searchedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SearchHistoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SearchHistoryTableTable,
      SearchHistoryTableData,
      $$SearchHistoryTableTableFilterComposer,
      $$SearchHistoryTableTableOrderingComposer,
      $$SearchHistoryTableTableAnnotationComposer,
      $$SearchHistoryTableTableCreateCompanionBuilder,
      $$SearchHistoryTableTableUpdateCompanionBuilder,
      (
        SearchHistoryTableData,
        BaseReferences<
          _$AppDatabase,
          $SearchHistoryTableTable,
          SearchHistoryTableData
        >,
      ),
      SearchHistoryTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LibraryItemsTableTableManager get libraryItems =>
      $$LibraryItemsTableTableManager(_db, _db.libraryItems);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$CollectionItemsTableTableManager get collectionItems =>
      $$CollectionItemsTableTableManager(_db, _db.collectionItems);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$MangaTagsTableTableManager get mangaTags =>
      $$MangaTagsTableTableManager(_db, _db.mangaTags);
  $$ReadingHistoryTableTableManager get readingHistory =>
      $$ReadingHistoryTableTableManager(_db, _db.readingHistory);
  $$ReadingSessionsTableTableManager get readingSessions =>
      $$ReadingSessionsTableTableManager(_db, _db.readingSessions);
  $$DownloadTasksTableTableManager get downloadTasks =>
      $$DownloadTasksTableTableManager(_db, _db.downloadTasks);
  $$SearchHistoryTableTableTableManager get searchHistoryTable =>
      $$SearchHistoryTableTableTableManager(_db, _db.searchHistoryTable);
}

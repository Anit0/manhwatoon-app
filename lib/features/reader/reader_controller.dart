import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../core/database/app_repository.dart';
import '../../core/sources/manga_source.dart';
import '../../core/sources/source_registry.dart';
import '../../models/chapter.dart';
import '../../models/manga.dart';
import '../../models/reader_models.dart';
import '../downloads/download_manager.dart';

/// A single page source resolved to either a network URL or a local file.
class ReaderPage {
  const ReaderPage.network(
    this.imageUrl, {
    this.headers,
    required this.chapterUrl,
    required this.chapterTitle,
    required this.pageIndex,
    required this.chapterPageCount,
  })  : filePath = null,
        isLocal = false;

  const ReaderPage.local(
    this.filePath, {
    required this.chapterUrl,
    required this.chapterTitle,
    required this.pageIndex,
    required this.chapterPageCount,
  })  : imageUrl = null,
        isLocal = true,
        headers = null;

  final String? imageUrl;
  final String? filePath;
  final Map<String, String>? headers;
  final bool isLocal;
  final String chapterUrl;
  final String chapterTitle;
  final int pageIndex;
  final int chapterPageCount;

  String get cacheKey {
    if (isLocal && filePath != null) return 'local:$filePath';
    return imageUrl ?? '';
  }

  String get identity => '$chapterUrl#$pageIndex';

  ImageProvider resolve() {
    if (isLocal && filePath != null) return FileImage(File(filePath!));
    return CachedNetworkImageProvider(
      imageUrl ?? '',
      headers: headers,
      cacheKey: cacheKey,
    );
  }
}

class LoadedChapter {
  LoadedChapter({
    required this.url,
    required this.title,
    required this.pages,
    this.prevUrl,
    this.nextUrl,
  });

  final String url;
  final String title;
  final List<ReaderPage> pages;
  final String? prevUrl;
  final String? nextUrl;
}

enum ReaderItemKind { header, page, loading, end }

/// Flattened row in the continuous reader list.
class ReaderItem {
  const ReaderItem.header({required this.chapterUrl, required this.chapterTitle})
      : kind = ReaderItemKind.header,
        page = null,
        loadingLabel = null;

  const ReaderItem.page(this.page)
      : kind = ReaderItemKind.page,
        chapterUrl = null,
        chapterTitle = null,
        loadingLabel = null;

  const ReaderItem.loading(this.loadingLabel)
      : kind = ReaderItemKind.loading,
        page = null,
        chapterUrl = null,
        chapterTitle = null;

  const ReaderItem.end()
      : kind = ReaderItemKind.end,
        page = null,
        chapterUrl = null,
        chapterTitle = null,
        loadingLabel = null;

  final ReaderItemKind kind;
  final ReaderPage? page;
  final String? chapterUrl;
  final String? chapterTitle;
  final String? loadingLabel;

  String get key {
    switch (kind) {
      case ReaderItemKind.header:
        return 'header:$chapterUrl';
      case ReaderItemKind.page:
        return 'page:${page!.identity}';
      case ReaderItemKind.loading:
        return 'loading:$loadingLabel';
      case ReaderItemKind.end:
        return 'end';
    }
  }
}

enum ReaderLoadState { loading, ready, error }

/// State controller for the manga reader.
class ReaderController extends ChangeNotifier {
  ReaderController({
    required this.manga,
    required this.chapterUrl,
    required this.chapterTitle,
    required ReaderMode initialMode,
    required AppRepository repository,
    required MangaSource api,
    required DownloadManager downloads,
    this.initialPageIndex = 0,
    this.incognito = false,
    this.onChapterProgress,
  })  : _mode = initialMode,
        _repository = repository,
        _api = api,
        _downloads = downloads {
    _start = DateTime.now();
    _loadInitial();
  }

  final Manga manga;
  final bool incognito;
  final void Function(String chapterUrl, int pageIndex, int totalPages)?
      onChapterProgress;
  final String chapterUrl;
  final String chapterTitle;
  final int initialPageIndex;
  final AppRepository _repository;
  final MangaSource _api;
  final DownloadManager _downloads;

  ReaderMode _mode;
  ReaderMode get mode => _mode;
  set mode(ReaderMode value) {
    if (_mode == value) return;
    _mode = value;
    notifyListeners();
  }

  bool get webtoon => _mode == ReaderMode.webtoon;

  ReaderLoadState _state = ReaderLoadState.loading;
  ReaderLoadState get state => _state;

  String? _error;
  String? get error => _error;

  final List<LoadedChapter> _chapters = [];
  List<LoadedChapter> get chapters => List.unmodifiable(_chapters);

  List<ReaderPage> get pages => [
        for (final c in _chapters) ...c.pages,
      ];

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  LoadedChapter? get currentChapter {
    if (_chapters.isEmpty) return null;
    final page = _pageAt(_currentIndex);
    if (page != null) {
      for (final c in _chapters) {
        if (c.url == page.chapterUrl) return c;
      }
    }
    return _chapters.first;
  }

  String get currentChapterTitle =>
      currentChapter?.title ?? chapterTitle;

  String get currentChapterLabel {
    final title = currentChapterTitle.trim();
    if (title.isEmpty) return 'Chapter';
    if (RegExp(r'chapter\s*\d', caseSensitive: false).hasMatch(title)) {
      return title;
    }
    final fromUrl = _chapterNumberFromUrl(currentChapterUrl);
    if (fromUrl != null) return 'Chapter $fromUrl';
    return title;
  }

  String get currentChapterUrl =>
      currentChapter?.url ?? chapterUrl;

  int get currentPageInChapter {
    final page = _pageAt(_currentIndex);
    return page?.pageIndex ?? 0;
  }

  int get currentChapterPageCount {
    final page = _pageAt(_currentIndex);
    return page?.chapterPageCount ?? pages.length;
  }

  ReaderPage? _pageAt(int globalIndex) {
    final all = pages;
    if (globalIndex < 0 || globalIndex >= all.length) return null;
    return all[globalIndex];
  }

  double _brightness = 1.0;
  double get brightness => _brightness;
  set brightness(double v) {
    _brightness = v.clamp(0.2, 1.0);
    notifyListeners();
  }

  bool _keepScreenOn = true;
  bool get keepScreenOn => _keepScreenOn;
  set keepScreenOn(bool v) {
    _keepScreenOn = v;
    notifyListeners();
  }

  bool _autoScroll = false;
  bool get autoScroll => _autoScroll;
  set autoScroll(bool v) {
    _autoScroll = v;
    notifyListeners();
  }

  double _autoScrollSpeed = 1.0;
  double get autoScrollSpeed => _autoScrollSpeed;
  set autoScrollSpeed(double v) {
    _autoScrollSpeed = v.clamp(0.2, 3.0);
    notifyListeners();
  }

  bool _invertImages = false;
  bool get invertImages => _invertImages;
  set invertImages(bool v) {
    _invertImages = v;
    notifyListeners();
  }

  String? get prevChapterUrl => currentChapter?.prevUrl;
  String? get nextChapterUrl => currentChapter?.nextUrl;

  bool _loadingNext = false;
  bool _loadingPrev = false;
  bool get loadingNext => _loadingNext;
  bool get loadingPrev => _loadingPrev;
  DateTime? _nextRetryAfter;
  DateTime? _prevRetryAfter;

  bool _reachedEnd = false;
  bool get reachedEnd => _reachedEnd;

  /// One-shot request for the view to scroll to an item key.
  String? _pendingScrollKey;
  String? takePendingScrollKey() {
    final key = _pendingScrollKey;
    _pendingScrollKey = null;
    return key;
  }

  /// True when the next chapter was prepended (view should keep pixels).
  bool _didPrepend = false;
  bool takeDidPrepend() {
    final v = _didPrepend;
    _didPrepend = false;
    return v;
  }

  final Map<String, Size> pageSizes = {};

  void rememberPageSize(String identity, Size size) {
    final prev = pageSizes[identity];
    if (prev == size) return;
    pageSizes[identity] = size;
  }

  DateTime? _start;
  Timer? _elapsedTimer;
  Duration _elapsed = Duration.zero;
  Duration get elapsed => _elapsed;

  List<ReaderItem> buildItems() {
    if (_chapters.isEmpty) return const [];
    final items = <ReaderItem>[];
    if (_loadingPrev) {
      items.add(const ReaderItem.loading('Loading previous chapter…'));
    }
    for (final chapter in _chapters) {
      items.add(ReaderItem.header(
        chapterUrl: chapter.url,
        chapterTitle: chapter.title,
      ));
      for (final page in chapter.pages) {
        items.add(ReaderItem.page(page));
      }
    }
    if (_loadingNext) {
      items.add(const ReaderItem.loading('Loading next chapter…'));
    } else if (_reachedEnd ||
        (_chapters.isNotEmpty && _chapters.last.nextUrl == null)) {
      items.add(const ReaderItem.end());
    }
    return items;
  }

  Future<void> _loadInitial() async {
    _state = ReaderLoadState.loading;
    notifyListeners();
    try {
      final loaded = await _fetchChapter(chapterUrl, fallbackTitle: chapterTitle);
      _chapters
        ..clear()
        ..add(loaded);
      final resume = initialPageIndex.clamp(0, loaded.pages.length - 1);
      _currentIndex = resume;
      if (resume > 0) {
        _pendingScrollKey = loaded.pages[resume].identity;
      }
      _state = ReaderLoadState.ready;
      _reachedEnd = loaded.nextUrl == null;
      notifyListeners();
      unawaited(_prefetchAdjacent());
    } catch (e) {
      _error = '$e';
      _state = ReaderLoadState.error;
      notifyListeners();
    }
  }

  Future<void> retry() => _loadInitial();

  Future<LoadedChapter> _fetchChapter(
    String url, {
    required String fallbackTitle,
  }) async {
    final dir = await _downloads.downloadedDirectory(url);
    List<ReaderPage> pages = [];
    if (dir != null) {
      pages = await _pagesFromDownload(
        dir,
        url,
        _titleFromUrl(url, fallbackTitle),
      );
    }
    if (pages.isEmpty) {
      final fetched = await _api.fetchReadingPages(url);
      final headers = sourceImageHeaders(url);
      final title = _titleFromUrl(url, fallbackTitle);
      pages = [
        for (var i = 0; i < fetched.length; i++)
          ReaderPage.network(
            fetched[i].imageUrl,
            headers: headers,
            chapterUrl: url,
            chapterTitle: title,
            pageIndex: i,
            chapterPageCount: fetched.length,
          ),
      ];
    }
    if (pages.isEmpty) {
      throw StateError('No pages found for this chapter');
    }
    String? prevUrl;
    String? nextUrl;
    try {
      final nav = await _api.fetchChapterNav(url);
      prevUrl = nav.prevUrl;
      nextUrl = nav.nextUrl;
    } catch (_) {}
    return LoadedChapter(
      url: url,
      title: pages.first.chapterTitle,
      pages: pages,
      prevUrl: prevUrl,
      nextUrl: nextUrl,
    );
  }

  String _titleFromUrl(String url, String fallback) {
    if (fallback.trim().isNotEmpty &&
        fallback.toLowerCase() != 'next chapter' &&
        fallback.toLowerCase() != 'previous chapter') {
      return fallback.trim();
    }
    final number = _chapterNumberFromUrl(url);
    if (number != null) return 'Chapter $number';
    var trimmed = url.trim();
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    final slug = trimmed.split('/').last;
    if (slug.isEmpty) return fallback;
    final pretty = slug.replaceAll('-', ' ').trim();
    return pretty.isEmpty ? fallback : pretty;
  }

  String? _chapterNumberFromUrl(String url) {
    final match = RegExp(
      r'(?:chapter|ch)[-_ ]?(\d+(?:\.\d+)?)',
      caseSensitive: false,
    ).firstMatch(url);
    return match?.group(1);
  }

  Future<List<ReaderPage>> _pagesFromDownload(
    Directory dir,
    String url,
    String title,
  ) async {
    final files = <File>[];
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.last;
      if (RegExp(r'^page-(\d+)\.').hasMatch(name)) {
        files.add(entity);
      }
    }
    files.sort((a, b) {
      int numOf(File f) {
        final m = RegExp(r'page-(\d+)').firstMatch(f.uri.pathSegments.last);
        return int.tryParse(m?.group(1) ?? '') ?? 0;
      }

      return numOf(a).compareTo(numOf(b));
    });
    return [
      for (var i = 0; i < files.length; i++)
        ReaderPage.local(
          files[i].path,
          chapterUrl: url,
          chapterTitle: title,
          pageIndex: i,
          chapterPageCount: files.length,
        ),
    ];
  }

  bool _hasChapter(String url) => _chapters.any((c) => c.url == url);

  Future<void> loadNextChapter({bool scrollToStart = false}) async {
    if (_loadingNext || _chapters.isEmpty) return;
    if (_nextRetryAfter != null && DateTime.now().isBefore(_nextRetryAfter!)) {
      return;
    }
    final last = _chapters.last;
    final next = last.nextUrl;
    if (next == null || next.isEmpty) {
      _reachedEnd = true;
      notifyListeners();
      return;
    }
    if (_hasChapter(next)) {
      if (scrollToStart) {
        _pendingScrollKey = 'header:$next';
        notifyListeners();
      }
      return;
    }
    _loadingNext = true;
    notifyListeners();
    try {
      final loaded = await _fetchChapter(next, fallbackTitle: 'Next chapter');
      if (!_hasChapter(loaded.url)) {
        _chapters.add(loaded);
      }
      _reachedEnd = loaded.nextUrl == null;
      if (scrollToStart) _pendingScrollKey = 'header:${loaded.url}';
      _nextRetryAfter = null;
    } catch (_) {
      _nextRetryAfter = DateTime.now().add(const Duration(seconds: 4));
    } finally {
      _loadingNext = false;
      notifyListeners();
    }
  }

  Future<void> loadPrevChapter({bool scrollToStart = false}) async {
    if (_loadingPrev || _chapters.isEmpty) return;
    if (_prevRetryAfter != null && DateTime.now().isBefore(_prevRetryAfter!)) {
      return;
    }
    final first = _chapters.first;
    final prev = first.prevUrl;
    if (prev == null || prev.isEmpty) return;
    if (_hasChapter(prev)) {
      if (scrollToStart) {
        _pendingScrollKey = 'header:$prev';
        notifyListeners();
      }
      return;
    }
    _loadingPrev = true;
    notifyListeners();
    try {
      final loaded =
          await _fetchChapter(prev, fallbackTitle: 'Previous chapter');
      if (!_hasChapter(loaded.url)) {
        _chapters.insert(0, loaded);
        _didPrepend = true;
        _currentIndex += loaded.pages.length;
      }
      if (scrollToStart) _pendingScrollKey = 'header:${loaded.url}';
      _prevRetryAfter = null;
    } catch (_) {
      _prevRetryAfter = DateTime.now().add(const Duration(seconds: 4));
    } finally {
      _loadingPrev = false;
      notifyListeners();
    }
  }

  /// Manual next-chapter action (button). Scrolls to next if loaded, else loads.
  Future<void> goToNextChapter() async {
    final current = currentChapter;
    if (current == null) return;
    final next = current.nextUrl;
    if (next == null) return;
    final existing = _chapters.where((c) => c.url == next);
    if (existing.isNotEmpty) {
      _pendingScrollKey = 'header:$next';
      final global = _globalIndexFor(next, 0);
      if (global != null) setCurrentIndex(global);
      notifyListeners();
      return;
    }
    await loadNextChapter(scrollToStart: true);
    final global = _globalIndexFor(next, 0);
    if (global != null) setCurrentIndex(global);
  }

  /// Manual previous-chapter action (button).
  Future<void> goToPrevChapter() async {
    final current = currentChapter;
    if (current == null) return;
    final prev = current.prevUrl;
    if (prev == null) return;
    final existing = _chapters.where((c) => c.url == prev);
    if (existing.isNotEmpty) {
      _pendingScrollKey = 'header:$prev';
      final global = _globalIndexFor(prev, 0);
      if (global != null) setCurrentIndex(global);
      notifyListeners();
      return;
    }
    await loadPrevChapter(scrollToStart: true);
    final global = _globalIndexFor(prev, 0);
    if (global != null) setCurrentIndex(global);
  }

  int? _globalIndexFor(String chapterUrl, int pageIndex) {
    var offset = 0;
    for (final c in _chapters) {
      if (c.url == chapterUrl) {
        if (pageIndex < 0 || pageIndex >= c.pages.length) return offset;
        return offset + pageIndex;
      }
      offset += c.pages.length;
    }
    return null;
  }

  Future<void> _prefetchAdjacent() async {
    if (_chapters.isEmpty) return;
    final next = _chapters.last.nextUrl;
    if (next != null && !_hasChapter(next)) {
      await loadNextChapter();
    }
  }

  DateTime? _lastPersistAt;
  Timer? _persistTimer;

  /// Sets the current page index (from scroll or pager).
  void setCurrentIndex(int index) {
    if (index < 0 || index >= pages.length) return;
    if (index == _currentIndex) return;
    _currentIndex = index;
    _schedulePersist();
    notifyListeners();
  }

  void _schedulePersist() {
    _persistTimer?.cancel();
    final now = DateTime.now();
    if (_lastPersistAt == null ||
        now.difference(_lastPersistAt!) >= const Duration(seconds: 2)) {
      _lastPersistAt = now;
      _persistProgress();
      return;
    }
    _persistTimer = Timer(const Duration(milliseconds: 800), () {
      _lastPersistAt = DateTime.now();
      _persistProgress();
    });
  }

  /// Sets the current page from a [ReaderPage] identity.
  void setCurrentPage(ReaderPage page) {
    final idx = pages.indexWhere((p) => p.identity == page.identity);
    if (idx >= 0) setCurrentIndex(idx);
  }

  void _persistProgress() {
    if (incognito) return;
    final page = _pageAt(_currentIndex);
    if (page == null) return;
    _repository.recordReadingProgress(
      mangaUrl: manga.url,
      mangaTitle: manga.title,
      coverUrl: manga.coverUrl,
      chapterUrl: page.chapterUrl,
      chapterTitle: page.chapterTitle,
      pageIndex: page.pageIndex,
      totalPages: page.chapterPageCount,
    );
    onChapterProgress?.call(
      page.chapterUrl,
      page.pageIndex,
      page.chapterPageCount,
    );
  }

  /// Called when the reader closes: persists progress + records session.
  Future<void> finish() async {
    _persistTimer?.cancel();
    _elapsedTimer?.cancel();
    _elapsed = _start != null ? DateTime.now().difference(_start!) : Duration.zero;
    if (incognito) return;
    final page = _pageAt(_currentIndex);
    if (page != null) {
      await _repository.recordReadingProgress(
        mangaUrl: manga.url,
        mangaTitle: manga.title,
        coverUrl: manga.coverUrl,
        chapterUrl: page.chapterUrl,
        chapterTitle: page.chapterTitle,
        pageIndex: page.pageIndex,
        totalPages: page.chapterPageCount,
      );
      onChapterProgress?.call(
        page.chapterUrl,
        page.pageIndex,
        page.chapterPageCount,
      );
    }
    if (_elapsed.inSeconds >= 30 && page != null) {
      await _repository.recordReadingSession(
        mangaUrl: manga.url,
        chapterUrl: page.chapterUrl,
        sessionDate: DateTime.now(),
        durationSeconds: _elapsed.inSeconds,
        pagesRead: page.pageIndex + 1,
        pagesTotal: page.chapterPageCount,
      );
    }
  }

  /// Enqueues the next chapter for auto-download (offline reading).
  Future<void> autoDownloadNext() async {
    final next = nextChapterUrl;
    if (next == null) return;
    final existing = await _downloads.isDownloaded(next);
    if (existing) return;
    await _downloads.enqueue(
      manga: manga,
      chapter: Chapter(
        url: next,
        title: 'Next chapter',
      ),
    );
  }

  @override
  void dispose() {
    _persistTimer?.cancel();
    _elapsedTimer?.cancel();
    super.dispose();
  }
}

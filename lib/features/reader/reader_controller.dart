import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../core/database/app_repository.dart';
import '../../core/network/site_api.dart';
import '../../models/chapter.dart';
import '../../models/manga.dart';
import '../../models/reader_models.dart';
import '../downloads/download_manager.dart';

/// A single page source resolved to either a network URL or a local file.
class ReaderPage {
  const ReaderPage.network(this.imageUrl)
      : filePath = null,
        isLocal = false;
  const ReaderPage.local(this.filePath)
      : imageUrl = null,
        isLocal = true;

  final String? imageUrl;
  final String? filePath;
  final bool isLocal;

  ImageProvider resolve() {
    if (isLocal && filePath != null) return FileImage(File(filePath!));
    return CachedNetworkImageProvider(imageUrl ?? '');
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
    required SiteApi api,
    required DownloadManager downloads,
  })  : _mode = initialMode,
        _repository = repository,
        _api = api,
        _downloads = downloads {
    _start = DateTime.now();
    _load();
  }

  final Manga manga;
  final String chapterUrl;
  final String chapterTitle;
  final AppRepository _repository;
  final SiteApi _api;
  final DownloadManager _downloads;

  ReaderMode _mode;
  ReaderMode get mode => _mode;
  set mode(ReaderMode value) {
    if (_mode == value) return;
    _mode = value;
    notifyListeners();
  }

  ReaderLoadState _state = ReaderLoadState.loading;
  ReaderLoadState get state => _state;

  String? _error;
  String? get error => _error;

  List<ReaderPage> _pages = [];
  List<ReaderPage> get pages => _pages;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

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

  String? _prevChapterUrl;
  String? _nextChapterUrl;
  String? get prevChapterUrl => _prevChapterUrl;
  String? get nextChapterUrl => _nextChapterUrl;

  DateTime? _start;
  Timer? _elapsedTimer;
  Duration _elapsed = Duration.zero;
  Duration get elapsed => _elapsed;

  Future<void> _load() async {
    _state = ReaderLoadState.loading;
    notifyListeners();
    try {
      // Prefer offline files when the chapter is downloaded.
      final dir = await _downloads.downloadedDirectory(chapterUrl);
      if (dir != null) {
        final files = <ReaderPage>[];
        var i = 0;
        while (true) {
          final file = File('${dir.path}${Platform.pathSeparator}page-${i + 1}.jpg');
          if (!await file.exists()) break;
          files.add(ReaderPage.local(file.path));
          i++;
        }
        if (files.isNotEmpty) {
          _pages = files;
          _state = ReaderLoadState.ready;
        }
      }

      if (_pages.isEmpty) {
        final pages = await _api.fetchReadingPages(chapterUrl);
        _pages = [for (final p in pages) ReaderPage.network(p.imageUrl)];
        _state = ReaderLoadState.ready;
      }

      // Load navigation (best-effort).
      try {
        final nav = await _api.fetchChapterNav(chapterUrl);
        _prevChapterUrl = nav.prevUrl;
        _nextChapterUrl = nav.nextUrl;
      } catch (_) {}

      notifyListeners();
    } catch (e) {
      _error = '$e';
      _state = ReaderLoadState.error;
      notifyListeners();
    }
  }

  /// Sets the current page index (from scroll or pager).
  void setCurrentIndex(int index) {
    if (index < 0 || index >= _pages.length) return;
    if (index == _currentIndex) return;
    _currentIndex = index;
    _persistProgress();
    notifyListeners();
  }

  void _persistProgress() {
    if (_pages.isEmpty) return;
    _repository.recordReadingProgress(
      mangaUrl: manga.url,
      mangaTitle: manga.title,
      coverUrl: manga.coverUrl,
      chapterUrl: chapterUrl,
      chapterTitle: chapterTitle,
      pageIndex: _currentIndex,
      totalPages: _pages.length,
    );
  }

  /// Called when the reader closes: persists progress + records session.
  Future<void> finish() async {
    _elapsedTimer?.cancel();
    _elapsed = _start != null ? DateTime.now().difference(_start!) : Duration.zero;
    if (_pages.isNotEmpty) {
      await _repository.recordReadingProgress(
        mangaUrl: manga.url,
        mangaTitle: manga.title,
        coverUrl: manga.coverUrl,
        chapterUrl: chapterUrl,
        chapterTitle: chapterTitle,
        pageIndex: _currentIndex,
        totalPages: _pages.length,
      );
    }
    if (_elapsed.inSeconds >= 30) {
      await _repository.recordReadingSession(
        mangaUrl: manga.url,
        chapterUrl: chapterUrl,
        sessionDate: DateTime.now(),
        durationSeconds: _elapsed.inSeconds,
        pagesRead: _currentIndex + 1,
        pagesTotal: _pages.length,
      );
    }
  }

  /// Enqueues the next chapter for auto-download (offline reading).
  Future<void> autoDownloadNext() async {
    final next = _nextChapterUrl;
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
    _elapsedTimer?.cancel();
    super.dispose();
  }
}

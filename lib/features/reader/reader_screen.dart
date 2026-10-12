import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/providers/app_providers.dart';
import '../../core/providers/extras_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/router/app_routes.dart';
import '../../models/chapter.dart';
import '../../models/manga.dart';
import '../../models/reader_models.dart';
import '../downloads/download_manager.dart';
import 'reader_controller.dart';
import 'reader_settings_sheet.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({
    super.key,
    required this.manga,
    required this.chapterUrl,
    required this.chapterTitle,
    this.initialMode,
    this.initialPageIndex = 0,
  });

  final Manga manga;
  final String chapterUrl;
  final String chapterTitle;
  final String? initialMode;
  final int initialPageIndex;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  late final ReaderController _controller;
  late final PageController _pageController;
  final ScrollController _scrollController = ScrollController();

  final ValueNotifier<bool> _overlayVisible = ValueNotifier(true);
  Timer? _overlayTimer;
  Timer? _autoScrollTimer;
  Timer? _scrollProbeTimer;
  bool _adjustingScroll = false;
  String _contentFingerprint = '';
  String? _resumeKey;
  int _resumeAttempts = 0;

  @override
  void initState() {
    super.initState();
    final mode = ReaderMode.fromValue(
        widget.initialMode ?? ref.read(settingsProvider).readerMode);
    _pageController = PageController(
      initialPage: widget.initialPageIndex.clamp(0, 1 << 20),
    );
    _controller = ReaderController(
      manga: widget.manga,
      chapterUrl: widget.chapterUrl,
      chapterTitle: widget.chapterTitle,
      initialMode: mode,
      initialPageIndex: widget.initialPageIndex,
      repository: ref.read(repositoryProvider),
      api: ref.read(sourceForUrlProvider(widget.chapterUrl)),
      downloads: ref.read(downloadManagerProvider),
      incognito: ref.read(settingsProvider).incognito,
      onChapterProgress: (chapterUrl, pageIndex, totalPages) {
        ref.read(extrasProvider.notifier).setChapterProgress(
              chapterUrl,
              pageIndex: pageIndex,
              totalPages: totalPages,
            );
      },
    )
      ..brightness = ref.read(settingsProvider).readerBrightness
      ..keepScreenOn = ref.read(settingsProvider).readerKeepScreenOn
      ..autoScroll = ref.read(settingsProvider).readerAutoScroll
      ..autoScrollSpeed = ref.read(settingsProvider).readerAutoScrollSpeed
      ..invertImages = ref.read(settingsProvider).readerInvertImages;
    _controller.addListener(_onControllerChanged);
    _scrollController.addListener(_onScroll);

    if (_controller.keepScreenOn) WakelockPlus.enable();
    final cache = PaintingBinding.instance.imageCache;
    cache.maximumSize = 48;
    cache.maximumSizeBytes = 96 << 20;
    _scheduleOverlayHide();
  }

  @override
  void dispose() {
    final chapterUrl = _controller.currentChapterUrl;
    final nearEnd = _controller.currentChapterPageCount > 0 &&
        _controller.currentPageInChapter + 1 >=
            _controller.currentChapterPageCount;
    if (!_controller.incognito && nearEnd) {
      ref.read(extrasProvider.notifier).markChaptersRead([chapterUrl]);
    }
    _controller.finish();
    _controller.removeListener(_onControllerChanged);
    _overlayTimer?.cancel();
    _autoScrollTimer?.cancel();
    _scrollProbeTimer?.cancel();
    _overlayVisible.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  String _fingerprint() {
    return [
      _controller.state.name,
      _controller.mode.value,
      '${_controller.invertImages}',
      '${_controller.loadingNext}',
      '${_controller.loadingPrev}',
      '${_controller.reachedEnd}',
      ..._controller.pages.map((p) => p.identity),
    ].join('|');
  }

  void _onControllerChanged() {
    if (!mounted) return;
    _syncAutoScroll();
    final pendingKey = _controller.takePendingScrollKey();
    final prepended = _controller.takeDidPrepend();
    if (pendingKey != null) {
      _resumeKey = pendingKey;
      _resumeAttempts = 0;
    }
    final nextFingerprint = _fingerprint();
    final contentChanged = nextFingerprint != _contentFingerprint;
    if (!contentChanged && pendingKey == null && !prepended) return;

    final oldMax = _scrollController.hasClients
        ? _scrollController.position.maxScrollExtent
        : 0.0;
    final oldOffset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;
    _contentFingerprint = nextFingerprint;
    if (contentChanged) setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_resumeKey != null) {
        _jumpToPending(_resumeKey!);
        return;
      }
      if (prepended && _controller.webtoon && _scrollController.hasClients) {
        final delta = _scrollController.position.maxScrollExtent - oldMax;
        if (delta != 0) {
          _adjustingScroll = true;
          final target = (oldOffset + delta).clamp(
            0.0,
            _scrollController.position.maxScrollExtent,
          );
          _scrollController.jumpTo(target);
          _adjustingScroll = false;
        }
      }
      if (!_controller.webtoon &&
          _controller.mode == ReaderMode.rtl &&
          _pageController.hasClients) {
        _pageController.jumpToPage(_pagedIndex(_controller.currentIndex));
      }
    });
  }

  int _pagedIndex(int realIndex) {
    if (_controller.mode != ReaderMode.rtl) return realIndex;
    final last = _controller.pages.length - 1;
    if (last < 0) return 0;
    return last - realIndex;
  }

  void _jumpToPending(String key, {int attempt = 0}) {
    if (_resumeKey != key) return;
    if (_controller.webtoon) {
      if (!_scrollController.hasClients) {
        if (attempt < 12) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _jumpToPending(key, attempt: attempt + 1);
          });
        }
        return;
      }
      final items = _controller.buildItems();
      final width = MediaQuery.sizeOf(context).width;
      var offset = 0.0;
      var found = false;
      for (final item in items) {
        final isTarget = item.key == key ||
            (item.page != null && item.page!.identity == key);
        if (isTarget) {
          found = true;
          break;
        }
        offset += _itemHeight(item, width);
      }
      if (!found) offset = 0;
      final pos = _scrollController.position;
      final target = offset.clamp(0.0, pos.maxScrollExtent);
      _adjustingScroll = true;
      _scrollController.jumpTo(target);
      _adjustingScroll = false;
      _resumeAttempts = attempt + 1;
      if (found && offset > pos.maxScrollExtent + 1 && _resumeAttempts < 12) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _resumeKey == key) {
            _jumpToPending(key, attempt: _resumeAttempts);
          }
        });
      }
      return;
    }
    final pages = _controller.pages;
    var index = -1;
    if (key.startsWith('header:')) {
      index = pages.indexWhere((p) => p.chapterUrl == key.substring(7));
    } else {
      index = pages.indexWhere((p) => p.identity == key);
    }
    if (index < 0) return;
    if (_pageController.hasClients) {
      _pageController.jumpToPage(_pagedIndex(index));
    }
    _resumeKey = null;
  }

  double _itemHeight(ReaderItem item, double width) {
    switch (item.kind) {
      case ReaderItemKind.header:
        return 42;
      case ReaderItemKind.page:
        return _estimatedPageHeight(item.page!, width);
      case ReaderItemKind.loading:
        return 96;
      case ReaderItemKind.end:
        return 72;
    }
  }

  double _estimatedPageHeight(ReaderPage page, double width) {
    final size = _controller.pageSizes[page.identity];
    if (size != null && size.width > 0) {
      return width * size.height / size.width;
    }
    return width * 1.4;
  }

  void _scheduleOverlayHide() {
    _overlayTimer?.cancel();
    _overlayTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_controller.autoScroll) {
        _overlayVisible.value = false;
      }
    });
  }

  void _toggleOverlay() {
    _overlayVisible.value = !_overlayVisible.value;
    if (_overlayVisible.value) _scheduleOverlayHide();
  }

  void _onScroll() {
    if (_adjustingScroll) return;
    _scrollProbeTimer?.cancel();
    _scrollProbeTimer =
        Timer(const Duration(milliseconds: 120), _probeVisiblePage);
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.maxScrollExtent - pos.pixels < 1600) {
      unawaited(_controller.loadNextChapter());
    }
    if (_controller.autoScroll) {
      final step = 6.0 * _controller.autoScrollSpeed;
      if (pos.pixels + step < pos.maxScrollExtent) {
        _scrollController.animateTo(
          pos.pixels + step,
          duration: const Duration(milliseconds: 40),
          curve: Curves.linear,
        );
      } else if (_controller.nextChapterUrl != null) {
        unawaited(_controller.loadNextChapter());
      } else {
        _controller.autoScroll = false;
      }
    }
  }

  void _probeVisiblePage() {
    if (!_controller.webtoon) return;
    if (!_scrollController.hasClients) return;
    final items = _controller.buildItems();
    if (items.isEmpty) return;
    final width = MediaQuery.sizeOf(context).width;
    final viewportCenter =
        _scrollController.offset + _scrollController.position.viewportDimension / 2;
    var cursor = 0.0;
    ReaderPage? bestPage;
    var bestDist = double.infinity;
    for (final item in items) {
      final height = _itemHeight(item, width);
      if (item.kind == ReaderItemKind.page && item.page != null) {
        final center = cursor + height / 2;
        final dist = (center - viewportCenter).abs();
        if (dist < bestDist) {
          bestDist = dist;
          bestPage = item.page;
        }
      }
      cursor += height;
    }
    if (bestPage != null) _controller.setCurrentPage(bestPage);
  }

  void _syncAutoScroll() {
    _autoScrollTimer?.cancel();
    if (_controller.autoScroll) {
      _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 40), (_) {
        if (_scrollController.hasClients) _onScroll();
      });
    }
  }

  void _openSettings() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => ReaderSettingsSheet(controller: _controller),
    );
  }

  void _openMangaDetails() {
    unawaited(_controller.finish());
    AppRoutes.openManga(context, widget.manga);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) return;
        _controller.finish();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleOverlay,
              child: _buildContent(),
            ),
            ListenableBuilder(
              listenable: _controller,
              builder: (context, _) => _buildBrightnessScrim(),
            ),
            AnimatedBuilder(
              animation: Listenable.merge([_controller, _overlayVisible]),
              builder: (context, _) => _buildOverlays(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_controller.state) {
      case ReaderLoadState.loading:
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      case ReaderLoadState.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  color: Colors.white70, size: 40),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  '${_controller.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _controller.retry(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              ),
            ],
          ),
        );
      case ReaderLoadState.ready:
        if (_controller.pages.isEmpty) {
          return const Center(
            child: Text('No pages found',
                style: TextStyle(color: Colors.white)),
          );
        }
        return _controller.webtoon ? _buildWebtoon() : _buildPaged();
    }
  }

  Widget _buildWebtoon() {
    final width = MediaQuery.of(context).size.width;
    final items = _controller.buildItems();
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n is UserScrollNotification &&
            n.direction != ScrollDirection.idle) {
          _resumeKey = null;
        }
        if (n is OverscrollNotification && n.overscroll > 0) {
          unawaited(_controller.loadNextChapter());
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        cacheExtent: 1200,
        itemCount: items.length,
        addAutomaticKeepAlives: false,
        itemBuilder: (context, index) {
          final item = items[index];
          switch (item.kind) {
            case ReaderItemKind.header:
              return _ChapterDivider(
                key: ValueKey(item.key),
                title: item.chapterTitle ?? '',
              );
            case ReaderItemKind.page:
              final page = item.page!;
              return RepaintBoundary(
                key: ValueKey(page.identity),
                child: WebtoonPage(
                  page: page,
                  width: width,
                  invert: _controller.invertImages,
                  estimatedSize: _controller.pageSizes[page.identity],
                  onSize: (size) {
                    _controller.rememberPageSize(page.identity, size);
                    final resume = _resumeKey;
                    if (resume != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && _resumeKey == resume) {
                          _jumpToPending(resume);
                        }
                      });
                    }
                  },
                ),
              );
            case ReaderItemKind.loading:
              return _StatusRow(
                key: ValueKey(item.key),
                label: item.loadingLabel ?? 'Loading…',
                busy: true,
              );
            case ReaderItemKind.end:
              return const _StatusRow(
                key: ValueKey('end'),
                label: 'No more chapters',
              );
          }
        },
      ),
    );
  }

  Widget _buildPaged() {
    final reversed = _controller.mode == ReaderMode.rtl;
    final pages = _controller.pages;
    return PageView.builder(
      controller: _pageController,
      reverse: reversed,
      allowImplicitScrolling: true,
      onPageChanged: (index) {
        final real = reversed ? pages.length - 1 - index : index;
        _controller.setCurrentIndex(real);
        if (real >= pages.length - 2) {
          unawaited(_controller.loadNextChapter());
        }
      },
      itemCount: pages.length,
      itemBuilder: (context, index) {
        final real = reversed ? pages.length - 1 - index : index;
        final page = pages[real];
        return PagedPage(
          key: ValueKey(page.identity),
          page: page,
          invert: _controller.invertImages,
        );
      },
    );
  }

  Widget _buildBrightnessScrim() {
    final opacity = (1.0 - _controller.brightness).clamp(0.0, 1.0);
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 150),
        child: const ColoredBox(color: Colors.black),
      ),
    );
  }

  Widget _buildOverlays() {
    final isWebtoon = _controller.webtoon;
    final total = _controller.currentChapterPageCount;
    final inChapter = _controller.currentPageInChapter + 1;
    final showVerticalNav = ref.watch(
          settingsProvider.select((s) => s.readerVerticalNav),
        ) &&
        isWebtoon;
    return Stack(
      children: [
        Column(
          children: [
            AnimatedSlide(
              offset: _overlayVisible.value ? Offset.zero : const Offset(0, -1),
              duration: const Duration(milliseconds: 220),
              child: _buildTopBar(),
            ),
            const Spacer(),
            AnimatedSlide(
              offset: _overlayVisible.value ? Offset.zero : const Offset(0, 1),
              duration: const Duration(milliseconds: 220),
              child: _buildBottomBar(inChapter, total, isWebtoon),
            ),
          ],
        ),
        if (showVerticalNav && _overlayVisible.value)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _VerticalChapterNav(
                page: inChapter,
                total: total,
                onChanged: (value) {
                  final target = (value - 1).clamp(0, total - 1);
                  _controller.setCurrentIndex(
                    _controller.currentIndex -
                        _controller.currentPageInChapter +
                        target,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Material(
      color: Colors.black.withValues(alpha: 0.8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              color: Colors.white,
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _controller.currentChapterLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    widget.manga.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              color: Colors.white,
              tooltip: 'Bookmark chapter',
              icon: Icon(
                ref.watch(extrasProvider).isChapterBookmarked(
                          _controller.currentChapterUrl,
                        )
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
              ),
              onPressed: () {
                ref
                    .read(extrasProvider.notifier)
                    .toggleChapterBookmark(_controller.currentChapterUrl);
              },
            ),
            IconButton(
              color: Colors.white,
              tooltip: 'Manga details',
              icon: const Icon(Icons.menu_book_rounded),
              onPressed: _openMangaDetails,
            ),
            IconButton(
              color: Colors.white,
              tooltip: 'Reader settings',
              icon: const Icon(Icons.settings_rounded),
              onPressed: _openSettings,
            ),
            IconButton(
              color: Colors.white,
              tooltip: 'Download chapter',
              icon: const Icon(Icons.download_rounded),
              onPressed: () {
                final dm = ref.read(downloadManagerProvider);
                dm.enqueue(
                  manga: widget.manga,
                  chapter: Chapter(
                    url: _controller.currentChapterUrl,
                    title: _controller.currentChapterTitle,
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to downloads')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(int page, int total, bool isWebtoon) {
    final progress = total > 0 ? page / total : 0.0;
    return Material(
      color: Colors.black.withValues(alpha: 0.8),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    color: Colors.white,
                    icon: const Icon(Icons.skip_previous_rounded),
                    tooltip: 'Previous chapter',
                    onPressed: _controller.prevChapterUrl != null
                        ? () => unawaited(_controller.goToPrevChapter())
                        : null,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Text(
                            '${_controller.currentChapterLabel}  ·  $page / $total',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 4,
                              color: Colors.white,
                              backgroundColor: Colors.white24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    color: Colors.white,
                    icon: const Icon(Icons.skip_next_rounded),
                    tooltip: 'Next chapter',
                    onPressed: _controller.nextChapterUrl != null
                        ? () => unawaited(_controller.goToNextChapter())
                        : null,
                  ),
                  IconButton(
                    color: Colors.white,
                    icon: Icon(
                      _controller.autoScroll
                          ? Icons.pause_circle_outline_rounded
                          : Icons.play_circle_outline_rounded,
                    ),
                    tooltip: 'Auto scroll',
                    onPressed: isWebtoon
                        ? () {
                            _controller.autoScroll = !_controller.autoScroll;
                            _syncAutoScroll();
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerticalChapterNav extends StatelessWidget {
  const _VerticalChapterNav({
    required this.page,
    required this.total,
    required this.onChanged,
  });

  final int page;
  final int total;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    if (total <= 1) return const SizedBox.shrink();
    return RotatedBox(
      quarterTurns: 1,
      child: SizedBox(
        width: 180,
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: page.clamp(1, total).toDouble(),
            min: 1,
            max: total.toDouble(),
            divisions: total > 1 ? total - 1 : null,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ),
    );
  }
}

class _ChapterDivider extends StatelessWidget {
  const _ChapterDivider({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF111111),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    super.key,
    required this.label,
    this.busy = false,
  });

  final String label;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          if (busy)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white38,
                  strokeWidth: 2,
                ),
              ),
            ),
          Text(label, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}

class WebtoonPage extends StatefulWidget {
  const WebtoonPage({
    super.key,
    required this.page,
    required this.width,
    this.invert = false,
    this.estimatedSize,
    this.onSize,
  });

  final ReaderPage page;
  final double width;
  final bool invert;
  final Size? estimatedSize;
  final ValueChanged<Size>? onSize;

  @override
  State<WebtoonPage> createState() => _WebtoonPageState();
}

class _WebtoonPageState extends State<WebtoonPage> {
  late Size _size;
  bool _failed = false;
  int _retryToken = 0;

  @override
  void initState() {
    super.initState();
    _size = widget.estimatedSize ?? Size(widget.width, widget.width * 1.4);
  }

  @override
  void didUpdateWidget(covariant WebtoonPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page.identity != widget.page.identity) {
      _failed = false;
      _retryToken = 0;
      _size = widget.estimatedSize ?? Size(widget.width, widget.width * 1.4);
    }
  }

  Future<void> _retry() async {
    final url = widget.page.imageUrl;
    if (url != null && url.isNotEmpty) {
      await CachedNetworkImage.evictFromCache(url);
    }
    if (widget.page.isLocal && widget.page.filePath != null) {
      PaintingBinding.instance.imageCache
          .evict(FileImage(File(widget.page.filePath!)));
    }
    if (!mounted) return;
    setState(() {
      _failed = false;
      _retryToken++;
    });
  }

  void _onDecoded(int width, int height) {
    if (width <= 0) return;
    final size = Size(width.toDouble(), height.toDouble());
    if (_size == size && !_failed) return;
    setState(() {
      _size = size;
      _failed = false;
    });
    widget.onSize?.call(size);
  }

  double get _height {
    if (_size.width <= 0) return widget.width * 1.4;
    return widget.width * _size.height / _size.width;
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return SizedBox(
        width: widget.width,
        height: _height,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.broken_image_outlined,
                  color: Colors.white38, size: 40),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    return SizedBox(
      width: widget.width,
      height: _height,
      child: _ReaderImage(
        page: widget.page,
        invert: widget.invert,
        fit: BoxFit.fill,
        retryToken: _retryToken,
        memCacheWidth:
            (widget.width * MediaQuery.devicePixelRatioOf(context)).round(),
        onRetry: _retry,
        onDecoded: _onDecoded,
        onFailed: () {
          if (mounted) setState(() => _failed = true);
        },
      ),
    );
  }
}

class PagedPage extends StatefulWidget {
  const PagedPage({super.key, required this.page, this.invert = false});

  final ReaderPage page;
  final bool invert;

  @override
  State<PagedPage> createState() => _PagedPageState();
}

class _PagedPageState extends State<PagedPage> {
  final TransformationController _transform = TransformationController();
  bool _zoomed = false;
  int _retryToken = 0;

  @override
  void didUpdateWidget(covariant PagedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page.identity != widget.page.identity) {
      _zoomed = false;
      _transform.value = Matrix4.identity();
      _retryToken = 0;
    }
  }

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  void _toggleZoom(Offset focalPoint) {
    final scale = _zoomed ? 1.0 : 3.0;
    _transform.value = Matrix4.identity()
      ..translate(-focalPoint.dx * (scale - 1), -focalPoint.dy * (scale - 1))
      ..scale(scale);
    _zoomed = !_zoomed;
  }

  Future<void> _retry() async {
    final url = widget.page.imageUrl;
    if (url != null && url.isNotEmpty) {
      await CachedNetworkImage.evictFromCache(url);
    }
    if (!mounted) return;
    setState(() => _retryToken++);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onDoubleTapDown: (d) => _toggleZoom(d.localPosition),
          onDoubleTap: () {},
          child: InteractiveViewer(
            transformationController: _transform,
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: _ReaderImage(
                page: widget.page,
                invert: widget.invert,
                fit: BoxFit.contain,
                retryToken: _retryToken,
                memCacheWidth: (constraints.maxWidth *
                        MediaQuery.devicePixelRatioOf(context))
                    .round(),
                onRetry: _retry,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReaderImage extends StatelessWidget {
  const _ReaderImage({
    required this.page,
    required this.invert,
    required this.fit,
    required this.retryToken,
    required this.onRetry,
    this.memCacheWidth,
    this.onDecoded,
    this.onFailed,
  });

  final ReaderPage page;
  final bool invert;
  final BoxFit fit;
  final int retryToken;
  final VoidCallback onRetry;
  final int? memCacheWidth;
  final void Function(int width, int height)? onDecoded;
  final VoidCallback? onFailed;

  @override
  Widget build(BuildContext context) {
    final color = invert ? const Color(0xFF000000) : null;
    final blend = invert ? BlendMode.difference : null;
    final filter = memCacheWidth != null && memCacheWidth! > 0
        ? FilterQuality.low
        : FilterQuality.medium;
    if (page.isLocal) {
      return _SizedPaintedImage(
        key: ValueKey('local-${page.identity}-$retryToken'),
        provider: ResizeImage.resizeIfNeeded(
          memCacheWidth,
          null,
          FileImage(File(page.filePath!)),
        ),
        fit: fit,
        filter: filter,
        color: color,
        blend: blend,
        onDecoded: onDecoded,
        onFailed: onFailed,
        onRetry: onRetry,
      );
    }
    return CachedNetworkImage(
      key: ValueKey('net-${page.identity}-$retryToken'),
      imageUrl: page.imageUrl ?? '',
      httpHeaders: page.headers,
      cacheKey: page.cacheKey,
      fit: fit,
      width: fit == BoxFit.fill ? double.infinity : null,
      memCacheWidth: memCacheWidth,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      useOldImageOnUrlChange: false,
      filterQuality: filter,
      imageBuilder: (context, provider) {
        return _SizedPaintedImage(
          provider: provider,
          fit: fit,
          filter: filter,
          color: color,
          blend: blend,
          onDecoded: onDecoded,
        );
      },
      placeholder: (_, __) => const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
              color: Colors.white24, strokeWidth: 2),
        ),
      ),
      errorWidget: (_, __, ___) {
        onFailed?.call();
        return _RetryPlaceholder(onRetry: onRetry);
      },
    );
  }
}

class _SizedPaintedImage extends StatefulWidget {
  const _SizedPaintedImage({
    super.key,
    required this.provider,
    required this.fit,
    required this.filter,
    this.color,
    this.blend,
    this.onDecoded,
    this.onFailed,
    this.onRetry,
  });

  final ImageProvider provider;
  final BoxFit fit;
  final FilterQuality filter;
  final Color? color;
  final BlendMode? blend;
  final void Function(int width, int height)? onDecoded;
  final VoidCallback? onFailed;
  final VoidCallback? onRetry;

  @override
  State<_SizedPaintedImage> createState() => _SizedPaintedImageState();
}

class _SizedPaintedImageState extends State<_SizedPaintedImage> {
  ImageStream? _stream;
  late final ImageStreamListener _listener;
  bool _reported = false;

  @override
  void initState() {
    super.initState();
    _listener = ImageStreamListener(
      (info, _) {
        if (_reported) return;
        _reported = true;
        final width = info.image.width;
        final height = info.image.height;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          widget.onDecoded?.call(width, height);
        });
      },
      onError: (error, stack) {
        widget.onFailed?.call();
      },
    );
    _attach(widget.provider);
  }

  @override
  void didUpdateWidget(covariant _SizedPaintedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider != widget.provider) {
      _reported = false;
      _attach(widget.provider);
    }
  }

  void _attach(ImageProvider provider) {
    _stream?.removeListener(_listener);
    _stream = provider.resolve(const ImageConfiguration());
    _stream!.addListener(_listener);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      image: widget.provider,
      fit: widget.fit,
      gaplessPlayback: true,
      filterQuality: widget.filter,
      color: widget.color,
      colorBlendMode: widget.blend,
      errorBuilder: widget.onRetry == null
          ? null
          : (_, __, ___) {
              widget.onFailed?.call();
              return _RetryPlaceholder(onRetry: widget.onRetry!);
            },
    );
  }
}

class _RetryPlaceholder extends StatelessWidget {
  const _RetryPlaceholder({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.broken_image_outlined,
              color: Colors.white38, size: 40),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

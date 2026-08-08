import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/providers/app_providers.dart';
import '../../core/providers/settings_provider.dart';
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
  });

  final Manga manga;
  final String chapterUrl;
  final String chapterTitle;
  final String? initialMode;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  late final ReaderController _controller;
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _pageKeys = [];

  bool _overlayVisible = true;
  Timer? _overlayTimer;
  Timer? _autoScrollTimer;
  Timer? _scrollProbeTimer;

  int _displayPage = 1;

  @override
  void initState() {
    super.initState();
    final mode = ReaderMode.fromValue(widget.initialMode ??
        ref.read(settingsProvider).readerMode);
    _controller = ReaderController(
      manga: widget.manga,
      chapterUrl: widget.chapterUrl,
      chapterTitle: widget.chapterTitle,
      initialMode: mode,
      repository: ref.read(repositoryProvider),
      api: ref.read(sourceForUrlProvider(widget.chapterUrl)),
      downloads: ref.read(downloadManagerProvider),
    )
      ..brightness = ref.read(settingsProvider).readerBrightness
      ..keepScreenOn = ref.read(settingsProvider).readerKeepScreenOn
      ..autoScroll = ref.read(settingsProvider).readerAutoScroll
      ..autoScrollSpeed = ref.read(settingsProvider).readerAutoScrollSpeed
      ..invertImages = ref.read(settingsProvider).readerInvertImages;
    _controller.addListener(_onControllerChanged);
    _scrollController.addListener(_onScroll);

    if (_controller.keepScreenOn) WakelockPlus.enable();
    _scheduleOverlayHide();
  }

  @override
  void dispose() {
    _controller.finish();
    _controller.removeListener(_onControllerChanged);
    _overlayTimer?.cancel();
    _autoScrollTimer?.cancel();
    _scrollProbeTimer?.cancel();
    _pageController.dispose();
    _scrollController.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  void _onControllerChanged() {
    if (_controller.pages.length != _pageKeys.length) {
      _pageKeys
        ..clear()
        ..addAll(List.generate(_controller.pages.length, (_) => GlobalKey()));
    }
    if (!mounted) return;
    setState(() {
      _displayPage = (_controller.pages.isNotEmpty ? _controller.currentIndex : 0) + 1;
    });
    _syncAutoScroll();
  }

  void _scheduleOverlayHide() {
    _overlayTimer?.cancel();
    _overlayTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_controller.autoScroll) {
        setState(() => _overlayVisible = false);
      }
    });
  }

  void _toggleOverlay() {
    setState(() => _overlayVisible = !_overlayVisible);
    if (_overlayVisible) _scheduleOverlayHide();
  }

  void _onScroll() {
    // Probe which page is nearest the viewport center (webtoon mode).
    _scrollProbeTimer?.cancel();
    _scrollProbeTimer = Timer(const Duration(milliseconds: 120), _probeVisiblePage);
    if (_controller.autoScroll && _scrollController.hasClients) {
      final step = 6.0 * _controller.autoScrollSpeed;
      if (_scrollController.position.pixels + step <
          _scrollController.position.maxScrollExtent) {
        _scrollController.animateTo(
          _scrollController.position.pixels + step,
          duration: const Duration(milliseconds: 40),
          curve: Curves.linear,
        );
      } else {
        _controller.autoScroll = false;
      }
    }
  }

  void _probeVisiblePage() {
    if (!_controller.webtoon) return;
    if (!_scrollController.hasClients) return;
    final vpBox =
        _scrollController.position.context.notificationContext?.findRenderObject()
            as RenderBox?;
    if (vpBox == null) return;
    final vpTop = vpBox.localToGlobal(Offset.zero).dy;
    final centerInViewport = vpBox.size.height / 2;
    var bestIndex = 0;
    var bestDist = double.infinity;
    for (var i = 0; i < _pageKeys.length; i++) {
      final ctx = _pageKeys[i].currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final top = box.localToGlobal(Offset.zero).dy - vpTop;
      final itemCenter = top + box.size.height / 2;
      final dist = (itemCenter - centerInViewport).abs();
      if (dist < bestDist) {
        bestDist = dist;
        bestIndex = i;
      }
    }
    _controller.setCurrentIndex(bestIndex);
  }

  void _syncAutoScroll() {
    _autoScrollTimer?.cancel();
    if (_controller.autoScroll) {
      _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 40), (_) {
        if (_scrollController.hasClients) _onScroll();
      });
    }
  }

  void _goToChapter(String url, String title) {
    if (url.isEmpty) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ReaderScreen(
          manga: widget.manga,
          chapterUrl: url,
          chapterTitle: title,
          initialMode: _controller.mode.value,
        ),
      ),
    );
  }

  void _openSettings() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => ReaderSettingsSheet(controller: _controller),
    );
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
            _buildBrightnessScrim(),
            _buildOverlays(),
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
              const Icon(Icons.cloud_off_rounded, color: Colors.white70, size: 40),
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
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              ),
            ],
          ),
        );
      case ReaderLoadState.ready:
        if (_controller.pages.isEmpty) {
          return const Center(
            child: Text('No pages found', style: TextStyle(color: Colors.white)),
          );
        }
        return _controller.webtoon ? _buildWebtoon() : _buildPaged();
    }
  }

  Widget _buildWebtoon() {
    final width = MediaQuery.of(context).size.width;
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      itemCount: _controller.pages.length,
      itemBuilder: (context, index) {
        final page = _controller.pages[index];
        return SizedBox(
          key: _pageKey(index),
          child: WebtoonPage(
            page: page,
            width: width,
            invert: _controller.invertImages,
          ),
        );
      },
    );
  }

  Widget _buildPaged() {
    final reversed = _controller.mode == ReaderMode.rtl;
    return PageView.builder(
      controller: _pageController,
      reverse: reversed,
      onPageChanged: (index) {
        final real = reversed ? _controller.pages.length - 1 - index : index;
        _controller.setCurrentIndex(real);
      },
      itemCount: _controller.pages.length,
      itemBuilder: (context, index) {
        final real = reversed ? _controller.pages.length - 1 - index : index;
        final page = _controller.pages[real];
        return PagedPage(page: page, invert: _controller.invertImages);
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
    final total = _controller.pages.length;
    return Column(
      children: [
        AnimatedSlide(
          offset: _overlayVisible ? Offset.zero : const Offset(0, -1),
          duration: const Duration(milliseconds: 220),
          child: _buildTopBar(),
        ),
        const Spacer(),
        AnimatedSlide(
          offset: _overlayVisible ? Offset.zero : const Offset(0, 1),
          duration: const Duration(milliseconds: 220),
          child: _buildBottomBar(total, isWebtoon),
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
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chapterTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
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
              icon: const Icon(Icons.settings_rounded),
              onPressed: _openSettings,
            ),
            IconButton(
              color: Colors.white,
              icon: const Icon(Icons.download_rounded),
              onPressed: () {
                final dm = ref.read(downloadManagerProvider);
                dm.enqueue(
                  manga: widget.manga,
                  chapter: Chapter(
                    url: widget.chapterUrl,
                    title: widget.chapterTitle,
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

  Widget _buildBottomBar(int total, bool isWebtoon) {
    final progress = total > 0 ? (_controller.currentIndex + 1) / total : 0.0;
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
                        ? () => _goToChapter(
                              _controller.prevChapterUrl!,
                              'Previous chapter',
                            )
                        : null,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Text(
                            isWebtoon
                                ? '$_displayPage / $total'
                                : '${_controller.currentIndex + 1} / $total',
                            style: const TextStyle(color: Colors.white, fontSize: 13),
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
                        ? () => _goToChapter(
                              _controller.nextChapterUrl!,
                              'Next chapter',
                            )
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
                    onPressed: () {
                      _controller.autoScroll = !_controller.autoScroll;
                      _syncAutoScroll();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  GlobalKey _pageKey(int index) {
    while (_pageKeys.length <= index) {
      _pageKeys.add(GlobalKey());
    }
    return _pageKeys[index];
  }
}

/// Webtoon (vertical) page with pinch / double-tap zoom.
class WebtoonPage extends StatefulWidget {
  const WebtoonPage({
    super.key,
    required this.page,
    required this.width,
    this.invert = false,
  });

  final ReaderPage page;
  final double width;
  final bool invert;

  @override
  State<WebtoonPage> createState() => _WebtoonPageState();
}

class _WebtoonPageState extends State<WebtoonPage> {
  Size? _size;
  ImageStream? _stream;
  ImageStreamListener? _listener;
  final TransformationController _transform = TransformationController();
  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    final image = widget.page.resolve();
    _listener = ImageStreamListener(
      (info, _) {
        if (mounted) {
          setState(() {
            _size = Size(
              info.image.width.toDouble(),
              info.image.height.toDouble(),
            );
          });
        }
      },
      onError: (error, stackTrace) {},
    );
    _stream = image.resolve(const ImageConfiguration());
    _stream!.addListener(_listener!);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener!);
    _transform.dispose();
    super.dispose();
  }

  void _toggleZoom() {
    final scale = _zoomed ? 1.0 : 2.5;
    _transform.value = Matrix4.identity()..scale(scale);
    _zoomed = !_zoomed;
  }

  @override
  Widget build(BuildContext context) {
    if (_size == null) {
      return SizedBox(
        width: widget.width,
        height: widget.width * 1.4,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(color: Colors.white24, strokeWidth: 2),
          ),
        ),
      );
    }
    final height = widget.width * _size!.height / _size!.width;
    return GestureDetector(
      onDoubleTap: _toggleZoom,
      child: InteractiveViewer(
        transformationController: _transform,
        minScale: 1,
        maxScale: 4,
        child: SizedBox(
          width: widget.width,
          height: height,
          child: Image(
            image: widget.page.resolve(),
            fit: BoxFit.fill,
            color: widget.invert ? const Color(0xFF000000) : null,
            colorBlendMode: widget.invert ? BlendMode.difference : null,
          ),
        ),
      ),
    );
  }
}

/// Paginated page that fits the viewport and supports zoom.
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

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  void _toggleZoom(Offset focalPoint) {
    final scale = _zoomed ? 1.0 : 3.0;
    _transform.value = Matrix4.identity()..translate(-focalPoint.dx * (scale - 1), -focalPoint.dy * (scale - 1))..scale(scale);
    _zoomed = !_zoomed;
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
              child: Image(
                image: widget.page.resolve(),
                fit: BoxFit.contain,
                color: widget.invert ? const Color(0xFF000000) : null,
                colorBlendMode: widget.invert ? BlendMode.difference : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Placeholder used until the extension property is defined.
extension _ReaderControllerExt on ReaderController {
  bool get webtoon => mode == ReaderMode.webtoon;
}

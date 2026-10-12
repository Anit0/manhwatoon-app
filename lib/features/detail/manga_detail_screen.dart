import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/database/app_database.dart';
import '../../core/library/chapter_duplicates.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/extras_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/router/app_routes.dart';
import '../../core/sources/source_registry.dart';
import '../../core/widgets/loaders.dart';
import '../../core/widgets/manga_cover_image.dart';
import '../../models/chapter.dart';
import '../../models/manga.dart';
import '../downloads/download_manager.dart';
import '../library/collections_screen.dart';
import '../library/library_updates_provider.dart';

class MangaDetailScreen extends ConsumerStatefulWidget {
  const MangaDetailScreen({
    super.key,
    required this.manga,
    this.heroTag,
  });

  final Manga manga;
  final String? heroTag;

  @override
  ConsumerState<MangaDetailScreen> createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends ConsumerState<MangaDetailScreen> {
  Manga? _fullManga;
  List<Chapter> _chapters = const [];

  bool _summaryExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<dynamic> _loadDetail() async {
    final api = ref.read(sourceForUrlProvider(widget.manga.url));
    final result = await api.fetchMangaDetail(widget.manga.url);
    if (mounted) {
      setState(() {
        _fullManga = result.manga;
        _chapters = result.chapters;
      });
    }
    // Seeing the manga's current chapter list clears any "new chapters" flag.
    if (result.chapters.isNotEmpty) {
      ref.read(libraryUpdatesProvider.notifier).acknowledge(
            widget.manga.url,
            latestChapterUrl: result.chapters.first.url,
          );
    }
    return result;
  }

  Manga get _manga => _fullManga ?? widget.manga;

  Future<void> _setLibraryStatus(LibraryStatus? status) async {
    final repo = ref.read(repositoryProvider);
    await repo.upsertLibraryItem(_manga);
    await repo.setLibraryStatus(_manga.url, status);
  }

  Future<void> _toggleFavorite() async {
    final repo = ref.read(repositoryProvider);
    await repo.upsertLibraryItem(_manga);
    final item = await repo.getLibraryItem(_manga.url);
    await repo.setLibraryFlag(_manga.url, favorite: !(item?.favorite ?? false));
  }

  Future<void> _toggleBookmark() async {
    final repo = ref.read(repositoryProvider);
    await repo.upsertLibraryItem(_manga);
    final item = await repo.getLibraryItem(_manga.url);
    await repo.setLibraryFlag(_manga.url, bookmark: !(item?.bookmark ?? false));
  }

  Future<void> _addToCollection() async {
    final repo = ref.read(repositoryProvider);
    if (!mounted) return;
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => _CollectionPicker(manga: _manga),
    );
    if (result != null) {
      await repo.addToCollection(result as int, _manga);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to collection')),
        );
      }
    }
  }

  void _openCollections() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const CollectionsScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final manga = _manga;
    final library = ref.watch(libraryItemsProvider).value ?? const <LibraryItem>[];
    final item = library.where((l) => l.mangaUrl == manga.url).firstOrNull;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 320,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              _IconAction(
                icon: item?.bookmark == true
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                onPressed: _toggleBookmark,
              ),
              _IconAction(
                icon: item?.favorite == true
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: item?.favorite == true ? Colors.redAccent : null,
                onPressed: _toggleFavorite,
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'collection':
                      _openCollections();
                    case 'share':
                      break;
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'collection', child: Text('My collections')),
                  PopupMenuItem(value: 'share', child: Text('Share link')),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (manga.coverUrl != null)
                    Image.network(
                      manga.coverUrl!,
                      headers: sourceImageHeaders(manga.coverUrl!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: theme.colorScheme.surfaceContainerHigh,
                      ),
                    ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Hero(
                          tag: widget.heroTag ?? 'detail-${manga.url}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 110,
                              height: 158,
                              child: MangaCoverImage(manga: manga),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (manga.isAdult)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '18+',
                                    style: TextStyle(
                                      color: theme.colorScheme.onError,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              Text(
                                manga.title,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  shadows: const [Shadow(blurRadius: 6)],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                children: [
                                  _MetaPill(
                                    icon: Icons.star_rounded,
                                    label: manga.rating != null && manga.rating! > 0
                                        ? manga.rating!.toStringAsFixed(1)
                                        : 'New',
                                  ),
                                  if (manga.status != null)
                                    _MetaPill(
                                      icon: manga.status == 'Completed'
                                          ? Icons.check_circle_rounded
                                          : Icons.hourglass_top_rounded,
                                      label: manga.status!,
                                    ),
                                  if (manga.type != null)
                                    _MetaPill(icon: Icons.auto_stories_rounded, label: manga.type!),
                                  if (manga.views != null)
                                    _MetaPill(
                                      icon: Icons.visibility_rounded,
                                      label: _formatViews(manga.views!),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                         child: FilledButton.icon(
                           onPressed: () => _startReading(),
                           icon: const Icon(Icons.play_arrow_rounded),
                           label: Text(_continueLabel()),
                         ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _DetailActionsRow(
                    libraryStatus: item?.status,
                    onLibraryChanged: (status) {
                      if (status == null) {
                        ref
                            .read(repositoryProvider)
                            .removeFromLibrary(_manga.url);
                      } else {
                        _setLibraryStatus(status);
                      }
                    },
                    onCollection: _addToCollection,
                    onDownload: _downloadAll,
                  ),
                ),
                _NotesCard(mangaUrl: manga.url),
                if (manga.summary != null && manga.summary!.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: SectionHeader(
                      title: 'Synopsis',
                      icon: Icons.notes_rounded,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      manga.summary!,
                      maxLines: _summaryExpanded ? null : 4,
                      overflow: _summaryExpanded ? null : TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ),
                  if (!_summaryExpanded && manga.summary!.length > 150)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => setState(() => _summaryExpanded = true),
                        child: const Text('Read more'),
                      ),
                    ),
                ],
                if (manga.genres.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: SectionHeader(
                      title: 'Genres',
                      icon: Icons.tag_rounded,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: manga.genres
                          .map((g) => ActionChip(
                                label: Text(g),
                                onPressed: () {},
                              ))
                          .toList(),
                    ),
                  ),
                ],
                _InfoSection(manga: manga),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Chapters (${_chapters.length})',
              icon: Icons.list_alt_rounded,
              trailing: _chapters.isNotEmpty
                  ? TextButton.icon(
                      onPressed: () => _showChapterOptions(),
                      icon: const Icon(Icons.more_horiz_rounded, size: 18),
                      label: const Text('Options'),
                    )
                  : null,
            ),
          ),
          _chapters.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                )
              : SliverList.builder(
                  itemCount: _chapters.length,
                  itemBuilder: (context, index) => _ChapterTile(
                    manga: manga,
                    chapter: _chapters[index],
                    chapters: _chapters,
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  String _continueLabel() {
    final history = ref.read(historyProvider).value ?? const <ReadingHistoryData>[];
    final existing = history.where((h) => h.mangaUrl == _manga.url).firstOrNull;
    if (existing != null) return 'Continue';
    return 'Start Reading';
  }

  void _startReading() {
    final history = ref.read(historyProvider).value ?? const <ReadingHistoryData>[];
    final existing = history.where((h) => h.mangaUrl == _manga.url).firstOrNull;
    if (existing != null && _chapters.any((c) => c.url == existing.chapterUrl)) {
      AppRoutes.openReader(
        context,
        manga: _manga,
        chapterUrl: existing.chapterUrl,
        chapterTitle: existing.chapterTitle,
        initialPageIndex: existing.pageIndex,
      );
      return;
    }
    if (_chapters.isNotEmpty) {
      // The site lists chapters newest-first, so the first chapter the user
      // has not started is the last entry, not the first.
      final firstChapter = _chapters.last;
      AppRoutes.openReader(
        context,
        manga: _manga,
        chapterUrl: firstChapter.url,
        chapterTitle: firstChapter.title,
      );
    }
  }

  void _downloadAll() {
    if (_chapters.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.download_rounded),
              title: Text('Download chapters'),
              subtitle: Text('Pages will be queued in the background.'),
            ),
            ListTile(
              leading: const Icon(Icons.download_for_offline_rounded),
              title: const Text('All chapters'),
              onTap: () {
                Navigator.pop(ctx);
                _enqueueDownloads(_chapters);
              },
            ),
            ListTile(
              leading: const Icon(Icons.new_releases_rounded),
              title: const Text('Unread chapters'),
              onTap: () {
                Navigator.pop(ctx);
                final extras = ref.read(extrasProvider);
                _enqueueDownloads(_chapters
                    .where((c) => !extras.isChapterRead(c.url))
                    .toList());
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_rounded),
              title: const Text('Bookmarked chapters'),
              onTap: () {
                Navigator.pop(ctx);
                final extras = ref.read(extrasProvider);
                _enqueueDownloads(_chapters
                    .where((c) => extras.isChapterBookmarked(c.url))
                    .toList());
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showChapterOptions() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.import_contacts_rounded),
              title: Text('Sort'),
              subtitle: Text('Newest first'),
            ),
            ListTile(
              leading: const Icon(Icons.download_done_rounded),
              title: const Text('Download all chapters'),
              onTap: () {
                Navigator.pop(ctx);
                _downloadAll();
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_rounded),
              title: const Text('Mark all as read'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(extrasProvider.notifier).markChaptersRead(
                      _chapters.map((c) => c.url),
                    );
              },
            ),
            ListTile(
              leading: const Icon(Icons.radio_button_unchecked_rounded),
              title: const Text('Mark all as unread'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(extrasProvider.notifier).markChaptersRead(
                      _chapters.map((c) => c.url),
                      read: false,
                    );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _enqueueDownloads(List<Chapter> chapters) async {
    if (chapters.isEmpty) return;
    final manager = ref.read(downloadManagerProvider);
    final extras = ref.read(extrasProvider);
    final skipRead = ref.read(settingsProvider).skipDownloadRead;
    var queued = 0;
    for (final c in chapters) {
      if (skipRead && extras.isChapterRead(c.url)) continue;
      await manager.enqueue(
        manga: _manga,
        chapter: c,
      );
      queued++;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $queued chapters to downloads')),
      );
    }
  }

  String _formatViews(int views) {
    if (views >= 1000000) return '${(views / 1000000).toStringAsFixed(1)}M';
    if (views >= 1000) return '${(views / 1000).toStringAsFixed(1)}K';
    return '$views';
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.onPressed, this.color});

  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      color: Colors.white,
      icon: Icon(icon, color: color ?? Colors.white),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.amber.shade200),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _DetailActionsRow extends StatelessWidget {
  const _DetailActionsRow({
    required this.libraryStatus,
    required this.onLibraryChanged,
    required this.onCollection,
    required this.onDownload,
  });

  final String? libraryStatus;
  final ValueChanged<LibraryStatus?> onLibraryChanged;
  final VoidCallback onCollection;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final status = LibraryStatus.fromValue(libraryStatus);
    return Row(
      children: [
        Expanded(
          child: _DetailAction(
            icon: status == null
                ? Icons.library_add_rounded
                : Icons.library_add_check_rounded,
            label: status?.label ?? 'Library',
            selected: status != null,
            onTap: () => _pickLibraryStatus(context, status, onLibraryChanged),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DetailAction(
            icon: Icons.collections_bookmark_outlined,
            label: 'Collect',
            onTap: onCollection,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DetailAction(
            icon: Icons.download_rounded,
            label: 'Download',
            onTap: onDownload,
          ),
        ),
      ],
    );
  }
}

class _DetailAction extends StatelessWidget {
  const _DetailAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = selected
        ? scheme.primaryContainer
        : scheme.surfaceContainerHighest;
    final fg = selected ? scheme.onPrimaryContainer : scheme.onSurface;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: fg),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _pickLibraryStatus(
  BuildContext context,
  LibraryStatus? status,
  ValueChanged<LibraryStatus?> onChanged,
) {
  showModalBottomSheet<Object>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final s in LibraryStatus.values)
            RadioListTile<LibraryStatus>(
              value: s,
              groupValue: status,
              title: Text(s.label),
              onChanged: (v) => Navigator.pop(ctx, v),
            ),
          if (status != null)
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: const Text('Remove from library'),
              onTap: () => Navigator.pop(ctx, const _RemoveFromLibrary()),
            ),
        ],
      ),
    ),
  ).then((v) {
    if (v == null) return;
    if (v is _RemoveFromLibrary) {
      onChanged(null);
    } else if (v is LibraryStatus) {
      onChanged(v);
    }
  });
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.manga});

  final Manga manga;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      if (manga.releaseYear != null) ('Release', manga.releaseYear!),
      if (manga.authors.isNotEmpty) ('Authors', manga.authors.join(', ')),
      if (manga.artists.isNotEmpty) ('Artists', manga.artists.join(', ')),
      if (manga.alternativeNames.isNotEmpty)
        ('Alternative', manga.alternativeNames.take(4).join(' / ')),
      if (manga.views != null) ('Views', '${manga.views}'),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rows
                .map((r) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              r.$1,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              r.$2,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _ChapterTile extends ConsumerWidget {
  const _ChapterTile({
    required this.manga,
    required this.chapter,
    required this.chapters,
  });

  final Manga manga;
  final Chapter chapter;
  final List<Chapter> chapters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final downloads = ref.watch(downloadsProvider).value ?? const <DownloadTask>[];
    final download = downloads
        .where((d) => d.chapterUrl == chapter.url)
        .firstOrNull;
    final history = ref.watch(historyProvider).value ?? const <ReadingHistoryData>[];
    final extras = ref.watch(extrasProvider);
    final historyHit =
        history.where((h) => h.chapterUrl == chapter.url).firstOrNull;
    final progress = extras.progressFor(chapter.url);
    final markedRead = extras.isChapterRead(chapter.url) ||
        (progress?.completed ?? false);
    final bookmarked = extras.isChapterBookmarked(chapter.url);
    final progressLabel = progress?.label.isNotEmpty == true
        ? progress!.label
        : (historyHit != null && historyHit.totalPages > 0
            ? '${historyHit.pageIndex + 1}/${historyHit.totalPages}'
            : null);
    final resumePage = progress != null && !progress.completed
        ? progress.pageIndex
        : (historyHit != null &&
                historyHit.pageIndex + 1 < historyHit.totalPages
            ? historyHit.pageIndex
            : 0);

    IconData? dlIcon;
    Color? dlColor;
    if (download != null) {
      dlIcon = switch (download.state) {
        'completed' => Icons.download_done_rounded,
        'downloading' || 'queued' => Icons.downloading_rounded,
        'paused' => Icons.pause_circle_rounded,
        'error' => Icons.error_rounded,
        _ => Icons.download_rounded,
      };
      dlColor = switch (download.state) {
        'completed' => scheme.primary,
        'error' => scheme.error,
        _ => scheme.onSurfaceVariant,
      };
    }

    return Dismissible(
      key: ValueKey(chapter.url),
      background: Container(
        color: scheme.primaryContainer,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(
          markedRead ? Icons.radio_button_unchecked_rounded : Icons.check_rounded,
          color: scheme.onPrimaryContainer,
        ),
      ),
      secondaryBackground: Container(
        color: scheme.tertiaryContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(
          bookmarked ? Icons.bookmark_remove_rounded : Icons.bookmark_add_rounded,
          color: scheme.onTertiaryContainer,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _toggleRead(ref);
        } else {
          await ref.read(extrasProvider.notifier).toggleChapterBookmark(chapter.url);
        }
        return false;
      },
      child: ListTile(
        onTap: () {
          AppRoutes.openReader(
            context,
            manga: manga,
            chapterUrl: chapter.url,
            chapterTitle: chapter.title,
            initialPageIndex: resumePage,
          );
        },
        onLongPress: () => _chapterSheet(context, ref),
        leading: markedRead
            ? Icon(Icons.check_circle_rounded, color: scheme.outline)
            : Icon(Icons.menu_book_outlined, color: scheme.onSurfaceVariant),
        title: Text(
          chapter.title,
          style: TextStyle(
            fontWeight: markedRead ? FontWeight.w400 : FontWeight.w600,
            color: markedRead ? scheme.outline : scheme.onSurface,
          ),
        ),
        subtitle: _chapterSubtitle(theme, scheme, markedRead: markedRead),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (bookmarked)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.bookmark_rounded, size: 18, color: Colors.amber),
              ),
            if (dlIcon != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(dlIcon, size: 20, color: dlColor),
              ),
            if (progressLabel != null)
              Text(
                progressLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: markedRead ? scheme.outline : scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget? _chapterSubtitle(
    ThemeData theme,
    ColorScheme scheme, {
    required bool markedRead,
  }) {
    if (chapter.date == null) return null;
    return Text(
      timeago.format(chapter.date!, locale: 'en_short'),
      style: theme.textTheme.bodySmall?.copyWith(
        color: markedRead ? scheme.outline : scheme.onSurfaceVariant,
      ),
    );
  }

  Future<void> _chapterSheet(BuildContext context, WidgetRef ref) async {
    final extras = ref.read(extrasProvider);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(extras.isChapterRead(chapter.url)
                  ? Icons.radio_button_unchecked_rounded
                  : Icons.check_circle_rounded),
              title: Text(extras.isChapterRead(chapter.url)
                  ? 'Mark as unread'
                  : 'Mark as read'),
              onTap: () {
                _toggleRead(ref);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Icon(extras.isChapterBookmarked(chapter.url)
                  ? Icons.bookmark_remove_rounded
                  : Icons.bookmark_add_rounded),
              title: Text(extras.isChapterBookmarked(chapter.url)
                  ? 'Remove bookmark'
                  : 'Bookmark chapter'),
              onTap: () {
                ref
                    .read(extrasProvider.notifier)
                    .toggleChapterBookmark(chapter.url);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_rounded),
              title: const Text('Download'),
              onTap: () {
                ref.read(downloadManagerProvider).enqueue(
                      manga: manga,
                      chapter: chapter,
                    );
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleRead(WidgetRef ref) async {
    final enabled = ref.read(settingsProvider).markDuplicateRead;
    final urls = ChapterDuplicates.matchingUrls(
      chapters: chapters,
      chapterUrl: chapter.url,
      enabled: enabled,
    );
    final extras = ref.read(extrasProvider);
    final markRead = !extras.isChapterRead(chapter.url);
    await ref.read(extrasProvider.notifier).markChaptersRead(urls, read: markRead);
  }
}

class _NotesCard extends ConsumerWidget {
  const _NotesCard({required this.mangaUrl});

  final String mangaUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final note = ref.watch(extrasProvider).noteFor(mangaUrl);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.sticky_note_2_rounded),
          title: Text(note.isEmpty ? 'Add a note' : 'Notes'),
          subtitle: note.isEmpty
              ? const Text('Private notes stay on this device')
              : Text(note, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.edit_rounded),
          onTap: () async {
            final controller = TextEditingController(text: note);
            final next = await showDialog<String>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Manga notes'),
                content: TextField(
                  controller: controller,
                  maxLines: 8,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Anything you want to remember…',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, controller.text),
                    child: const Text('Save'),
                  ),
                ],
              ),
            );
            if (next != null) {
              await ref.read(extrasProvider.notifier).setNote(mangaUrl, next);
            }
          },
        ),
      ),
    );
  }
}

class _CollectionPicker extends ConsumerStatefulWidget {
  const _CollectionPicker({required this.manga});

  final Manga manga;

  @override
  ConsumerState<_CollectionPicker> createState() => _CollectionPickerState();
}

/// Sentinel result used by the status sheet for "Remove from library".
class _RemoveFromLibrary {
  const _RemoveFromLibrary();
}

class _CollectionPickerState extends ConsumerState<_CollectionPicker> {
  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(collectionsProvider).value ?? const <Collection>[];
    return ListView(
      shrinkWrap: true,
      children: [
        const ListTile(title: Text('Add to collection', style: TextStyle(fontWeight: FontWeight.w700))),
        for (final c in collections)
          ListTile(
            leading: const Icon(Icons.collections_bookmark_rounded),
            title: Text(c.name),
            trailing: const Icon(Icons.add_rounded),
            onTap: () => Navigator.pop(context, c.id),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/database/app_database.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_routes.dart';
import '../../core/widgets/loaders.dart';
import '../../core/widgets/manga_cover_image.dart';
import '../../models/chapter.dart';
import '../../models/manga.dart';
import '../downloads/download_manager.dart';
import '../library/collections_screen.dart';

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
    final api = ref.read(siteApiProvider);
    final result = await api.fetchMangaDetail(widget.manga.url);
    if (mounted) {
      setState(() {
        _fullManga = result.manga;
        _chapters = result.chapters;
      });
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
                          label: const Text('Start Reading'),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatusButton(
                          current: item?.status,
                          onChanged: (status) {
                            if (status == null) {
                              ref
                                  .read(repositoryProvider)
                                  .removeFromLibrary(_manga.url);
                            } else {
                              _setLibraryStatus(status);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _addToCollection,
                          icon: const Icon(Icons.collections_bookmark_rounded, size: 18),
                          label: const Text('Collection'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _downloadAll(),
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text('Download'),
                        ),
                      ),
                    ],
                  ),
                ),
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
                  itemBuilder: (context, index) =>
                      _ChapterTile(manga: manga, chapter: _chapters[index]),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
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
      );
      return;
    }
    if (_chapters.isNotEmpty) {
      final first = _chapters.first;
      AppRoutes.openReader(
        context,
        manga: _manga,
        chapterUrl: first.url,
        chapterTitle: first.title,
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
              subtitle: Text('${_chapters.length} available'),
              onTap: () {
                Navigator.pop(ctx);
                _enqueueDownloads(_chapters);
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
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _enqueueDownloads(List<Chapter> chapters) async {
    final manager = ref.read(downloadManagerProvider);
    for (final c in chapters) {
      await manager.enqueue(
        manga: _manga,
        chapter: c,
      );
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${chapters.length} chapters to downloads')),
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

class _StatusButton extends StatelessWidget {
  const _StatusButton({required this.current, required this.onChanged});

  final String? current;
  final ValueChanged<LibraryStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final status = LibraryStatus.fromValue(current);
    return OutlinedButton.icon(
      onPressed: () {
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
      },
      icon: Icon(status == null ? Icons.library_add_rounded : Icons.library_books_rounded),
      label: Text(status?.label ?? 'Add to Library'),
    );
  }
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
  const _ChapterTile({required this.manga, required this.chapter});

  final Manga manga;
  final Chapter chapter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final downloads = ref.watch(downloadsProvider).value ?? const <DownloadTask>[];
    final download = downloads
        .where((d) => d.chapterUrl == chapter.url)
        .firstOrNull;
    final history = ref.watch(historyProvider).value ?? const <ReadingHistoryData>[];
    final read = history.where((h) => h.chapterUrl == chapter.url).firstOrNull;

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

    return ListTile(
      onTap: () {
        AppRoutes.openReader(
          context,
          manga: manga,
          chapterUrl: chapter.url,
          chapterTitle: chapter.title,
        );
      },
      leading: read != null
          ? Icon(read.pageIndex + 1 >= read.totalPages
              ? Icons.check_circle_rounded
              : Icons.menu_book_rounded, color: scheme.primary)
          : Icon(Icons.menu_book_outlined, color: scheme.onSurfaceVariant),
      title: Text(
        chapter.title,
        style: TextStyle(
          fontWeight: read != null ? FontWeight.w700 : FontWeight.w500,
          color: read != null ? scheme.onSurface : scheme.onSurfaceVariant,
        ),
      ),
      subtitle: chapter.date != null
          ? Text('Read ${timeago.format(chapter.date!, locale: 'en_short')}')
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dlIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(dlIcon, size: 20, color: dlColor),
            ),
          if (read != null)
            Text(
              '${read.pageIndex + 1}/${read.totalPages}',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
        ],
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

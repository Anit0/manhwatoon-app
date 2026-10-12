import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/library/library_search.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/extras_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/router/app_routes.dart';
import '../../core/widgets/loaders.dart';
import '../../core/widgets/manga_card.dart';
import '../../core/widgets/manga_cover_image.dart';
import '../../models/manga.dart';
import '../downloads/downloads_screen.dart';
import '../stats/stats_screen.dart';
import 'collections_screen.dart';
import 'library_updates_provider.dart';
import 'upcoming_screen.dart';

enum _LibraryTab {
  all('All'),
  favorites('Favorites'),
  history('History'),
  downloads('Downloads'),
  updates('Updates'),
  upcoming('Upcoming');

  const _LibraryTab(this.label);
  final String label;
}

enum _LibrarySort {
  dateAdded('Date added', Icons.schedule_rounded),
  title('Title A–Z', Icons.sort_by_alpha_rounded),
  lastRead('Last read', Icons.history_rounded),
  unread('Unread', Icons.mark_email_unread_rounded),
  random('Random', Icons.shuffle_rounded);

  const _LibrarySort(this.label, this.icon);
  final String label;
  final IconData icon;
}

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  _LibraryTab _tab = _LibraryTab.all;
  _LibrarySort _sort = _LibrarySort.dateAdded;
  String _query = '';
  String? _statusFilter;
  bool _unreadOnly = false;
  int? _collectionFilter;
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final updates = ref.watch(libraryUpdatesProvider).value ?? const <LibraryUpdate>[];
    final updatesCount = updates.length;
    final viewMode = ref.watch(settingsProvider.select((s) => s.libraryViewMode));
    return Scaffold(
      body: Column(
        children: [
          SliverSafeAreaLike(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Library',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    tooltip: viewMode == 'list' ? 'Grid view' : 'List view',
                    onPressed: () {
                      ref.read(settingsProvider.notifier).setLibraryViewMode(
                            viewMode == 'list' ? 'grid' : 'list',
                          );
                    },
                    icon: Icon(viewMode == 'list'
                        ? Icons.grid_view_rounded
                        : Icons.view_list_rounded),
                  ),
                  IconButton(
                    tooltip: 'Collections',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CollectionsScreen()),
                      );
                    },
                    icon: const Icon(Icons.collections_bookmark_rounded),
                  ),
                  IconButton(
                    tooltip: 'Reading statistics',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const StatsScreen()),
                      );
                    },
                    icon: const Icon(Icons.insights_rounded),
                  ),
                  PopupMenuButton<_LibrarySort>(
                    tooltip: 'Sort library',
                    icon: const Icon(Icons.sort_rounded),
                    initialValue: _sort,
                    onSelected: (s) => setState(() => _sort = s),
                    itemBuilder: (context) => [
                      for (final s in _LibrarySort.values)
                        PopupMenuItem(
                          value: s,
                          child: Row(
                            children: [
                              Icon(s.icon, size: 20),
                              const SizedBox(width: 12),
                              Text(s.label),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search title: author: genre: unread:>0',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear',
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              children: [
                FilterChip(
                  label: const Text('Unread'),
                  selected: _unreadOnly,
                  onSelected: (v) => setState(() => _unreadOnly = v),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(_statusFilter == null
                      ? 'Status'
                      : LibraryStatus.fromValue(_statusFilter)?.label ?? 'Status'),
                  selected: _statusFilter != null,
                  onSelected: (_) => _pickStatus(),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Category'),
                  selected: _collectionFilter != null,
                  onSelected: (_) => _pickCollection(),
                ),
              ],
            ),
          ),
          _TabBar(
            current: _tab,
            updatesCount: updatesCount,
            onChanged: (t) => setState(() => _tab = t),
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Future<void> _pickStatus() async {
    final value = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Any status'),
              onTap: () => Navigator.pop(ctx, ''),
            ),
            for (final s in LibraryStatus.values)
              ListTile(
                title: Text(s.label),
                onTap: () => Navigator.pop(ctx, s.value),
              ),
          ],
        ),
      ),
    );
    if (value == null) return;
    setState(() => _statusFilter = value.isEmpty ? null : value);
  }

  Future<void> _pickCollection() async {
    final collections = await ref.read(repositoryProvider).getCollections();
    if (!mounted) return;
    final value = await showModalBottomSheet<int?>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All categories'),
              onTap: () => Navigator.pop(ctx, -1),
            ),
            for (final c in collections)
              ListTile(
                title: Text(c.name),
                onTap: () => Navigator.pop(ctx, c.id),
              ),
          ],
        ),
      ),
    );
    if (value == null) return;
    setState(() => _collectionFilter = value < 0 ? null : value);
  }

  Widget _buildContent() {
    switch (_tab) {
      case _LibraryTab.all:
        return _LibraryGrid(
          filter: _LibraryFilter.all,
          sort: _sort,
          query: _query,
          unreadOnly: _unreadOnly,
          statusFilter: _statusFilter,
          collectionFilter: _collectionFilter,
        );
      case _LibraryTab.favorites:
        return _LibraryGrid(
          filter: _LibraryFilter.favorites,
          sort: _sort,
          query: _query,
          unreadOnly: _unreadOnly,
          statusFilter: _statusFilter,
          collectionFilter: _collectionFilter,
        );
      case _LibraryTab.history:
        return const _HistoryView();
      case _LibraryTab.downloads:
        return const DownloadsScreen();
      case _LibraryTab.updates:
        return _UpdatesView(collectionFilter: _collectionFilter);
      case _LibraryTab.upcoming:
        return UpcomingScreen(collectionId: _collectionFilter);
    }
  }
}

class SliverSafeAreaLike extends StatelessWidget {
  const SliverSafeAreaLike({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(bottom: false, child: child);
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.current,
    required this.updatesCount,
    required this.onChanged,
  });

  final _LibraryTab current;
  final int updatesCount;
  final ValueChanged<_LibraryTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: _LibraryTab.values.map((tab) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: tab == _LibraryTab.updates
                  ? Badge(
                      isLabelVisible: updatesCount > 0,
                      label: Text('$updatesCount'),
                      child: Text(tab.label),
                    )
                  : Text(tab.label),
              selected: current == tab,
              showCheckmark: false,
              onSelected: (_) => onChanged(tab),
            ),
          );
        }).toList(),
      ),
    );
  }
}

enum _LibraryFilter { all, favorites }

class _LibraryGrid extends ConsumerWidget {
  const _LibraryGrid({
    required this.filter,
    required this.sort,
    required this.query,
    required this.unreadOnly,
    required this.statusFilter,
    required this.collectionFilter,
  });

  final _LibraryFilter filter;
  final _LibrarySort sort;
  final String query;
  final bool unreadOnly;
  final String? statusFilter;
  final int? collectionFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryItemsProvider);
    final extras = ref.watch(extrasProvider);
    final downloads = ref.watch(downloadsProvider).value ?? const <DownloadTask>[];
    final viewMode = ref.watch(settingsProvider.select((s) => s.libraryViewMode));
    final showBadge = ref.watch(settingsProvider.select((s) => s.showUnreadBadge));
    final downloadedOnly = ref.watch(settingsProvider.select((s) => s.downloadedOnly));
    final collectionMembers = collectionFilter == null
        ? const <CollectionItem>[]
        : (ref.watch(collectionItemsProvider(collectionFilter!)).value ??
            const <CollectionItem>[]);
    return library.when(
      loading: () => const MangaGridSkeleton(itemCount: 9),
      error: (e, _) => EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Library error',
        message: '$e',
      ),
      data: (items) {
        final list = _applyFilters(
          items,
          extras: extras,
          downloads: downloads,
          downloadedOnly: downloadedOnly,
          collectionMembers: collectionMembers,
        );
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.collections_bookmark_rounded,
            title: 'No matching titles',
            message: 'Try a different search, or add series from Discover.',
          );
        }
        if (viewMode == 'list') {
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              final manga = _mangaFromLibrary(item);
              final unread = _unreadFor(item, extras);
              return MangaListTile(
                manga: manga,
                subtitle: [
                  if (item.status != null)
                    LibraryStatus.fromValue(item.status)?.label ?? item.status!,
                  if (unread > 0) '$unread unread',
                  if (item.lastChapterTitle != null) item.lastChapterTitle!,
                ].join(' • '),
                onTap: () => AppRoutes.openManga(context, manga),
                onLongPress: () => _showItemSheet(context, ref, item),
              );
            },
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 14,
            crossAxisSpacing: 12,
            childAspectRatio: 0.55,
          ),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            final manga = _mangaFromLibrary(item);
            final unread = _unreadFor(item, extras);
            final downloaded = downloads.any(
                (d) => d.mangaUrl == item.mangaUrl && d.state == 'completed');
            return MangaCard(
              manga: manga,
              unreadCount: showBadge ? unread : null,
              downloaded: downloaded,
              onTap: () => AppRoutes.openManga(context, manga),
              onLongPress: () => _showItemSheet(context, ref, item),
            );
          },
        );
      },
    );
  }

  List<LibraryItem> _applyFilters(
    List<LibraryItem> items, {
    required UserExtras extras,
    required List<DownloadTask> downloads,
    required bool downloadedOnly,
    required List<CollectionItem> collectionMembers,
  }) {
    var list = items;
    if (filter == _LibraryFilter.favorites) {
      list = list.where((i) => i.favorite).toList();
    }
    if (statusFilter != null) {
      list = list.where((i) => i.status == statusFilter).toList();
    }
    if (collectionFilter != null) {
      final urls = {for (final m in collectionMembers) m.mangaUrl};
      list = list.where((i) => urls.contains(i.mangaUrl)).toList();
    }
    if (downloadedOnly) {
      final urls = {
        for (final d in downloads)
          if (d.state == 'completed') d.mangaUrl,
      };
      list = list.where((i) => urls.contains(i.mangaUrl)).toList();
    }
    if (unreadOnly) {
      list = list.where((i) => _unreadFor(i, extras) > 0).toList();
    }
    list = list
        .where((i) => LibrarySearch.matches(
              i,
              query,
              notes: extras.noteFor(i.mangaUrl),
              unreadCount: _unreadFor(i, extras),
              downloaded: downloads.any(
                  (d) => d.mangaUrl == i.mangaUrl && d.state == 'completed'),
            ))
        .toList();
    return _applySort(list, extras);
  }

  int _unreadFor(LibraryItem item, UserExtras extras) {
    if (item.lastChapterUrl == null) return 0;
    return extras.isChapterRead(item.lastChapterUrl!) ? 0 : 1;
  }

  List<LibraryItem> _applySort(List<LibraryItem> items, UserExtras extras) {
    switch (sort) {
      case _LibrarySort.title:
        return [...items]
          ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case _LibrarySort.lastRead:
        return [...items]..sort((a, b) {
            final aRead = a.lastReadAt;
            final bRead = b.lastReadAt;
            if (aRead == null && bRead == null) return 0;
            if (aRead == null) return 1;
            if (bRead == null) return -1;
            return bRead.compareTo(aRead);
          });
      case _LibrarySort.unread:
        return [...items]
          ..sort((a, b) => _unreadFor(b, extras).compareTo(_unreadFor(a, extras)));
      case _LibrarySort.random:
        final copy = [...items]..shuffle();
        return copy;
      case _LibrarySort.dateAdded:
        return items;
    }
  }

  Future<void> _showItemSheet(
      BuildContext context, WidgetRef ref, LibraryItem item) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle_rounded),
              title: const Text('Mark as read'),
              onTap: () async {
                if (item.lastChapterUrl != null) {
                  await ref
                      .read(extrasProvider.notifier)
                      .markChaptersRead([item.lastChapterUrl!]);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.radio_button_unchecked_rounded),
              title: const Text('Mark as unread'),
              onTap: () async {
                if (item.lastChapterUrl != null) {
                  await ref.read(extrasProvider.notifier).markChaptersRead(
                        [item.lastChapterUrl!],
                        read: false,
                      );
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: const Text('Remove from library'),
              onTap: () async {
                await ref.read(repositoryProvider).removeFromLibrary(item.mangaUrl);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

Manga _mangaFromLibrary(LibraryItem item) {
  return Manga(
    url: item.mangaUrl,
    title: item.title,
    coverUrl: item.coverUrl,
    status: item.status,
    latestChapterTitle: item.lastChapterTitle,
    latestChapterUrl: item.lastChapterUrl,
    isAdult: item.isAdult,
  );
}

class _UpdatesView extends ConsumerWidget {
  const _UpdatesView({this.collectionFilter});

  final int? collectionFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updates = ref.watch(libraryUpdatesProvider);
    final members = collectionFilter == null
        ? const <CollectionItem>[]
        : (ref.watch(collectionItemsProvider(collectionFilter!)).value ??
            const <CollectionItem>[]);
    return updates.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Could not check updates',
        message: '$e\nPull down to try again.',
      ),
      data: (list) {
        final urls = {for (final m in members) m.mangaUrl};
        final filtered = collectionFilter == null
            ? list
            : list.where((u) => urls.contains(u.item.mangaUrl)).toList();
        if (filtered.isEmpty) {
          return const EmptyState(
            icon: Icons.update_rounded,
            title: 'No new chapters',
            message: 'Followed manga with new chapters will show up here.',
          );
        }
        return RefreshIndicator(
          onRefresh: () =>
              ref.read(libraryUpdatesProvider.notifier).refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final update = filtered[index];
              final manga = _mangaFromLibrary(update.item);
              return Card(
                child: ListTile(
                  onTap: () => AppRoutes.openManga(context, manga),
                  leading: SizedBox(
                    width: 48,
                    height: 64,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: MangaCoverImage(manga: manga),
                    ),
                  ),
                  title: Text(
                    manga.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'New: ${update.latestChapterTitle ?? 'chapter'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    tooltip: 'Dismiss',
                    icon: const Icon(Icons.check_rounded),
                    onPressed: () {
                      ref.read(libraryUpdatesProvider.notifier).acknowledge(
                            update.item.mangaUrl,
                            latestChapterUrl: update.latestChapterUrl,
                          );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _HistoryView extends ConsumerWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    return history.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'History error',
        message: '$e',
      ),
      data: (items) {
        if (items.isEmpty) {
          return const EmptyState(
            icon: Icons.history_rounded,
            title: 'No reading history',
            message: 'Manga you read will show up here automatically.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final manga = Manga(
              url: item.mangaUrl,
              title: item.mangaTitle,
              coverUrl: item.coverUrl,
            );
            return Card(
              child: ListTile(
                onTap: () => AppRoutes.openReader(
                  context,
                  manga: manga,
                  chapterUrl: item.chapterUrl,
                  chapterTitle: item.chapterTitle,
                  initialPageIndex: item.pageIndex,
                ),
                leading: SizedBox(
                  width: 48,
                  height: 64,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: MangaCoverImage(manga: manga),
                  ),
                ),
                title: Text(item.mangaTitle,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  '${item.chapterTitle} • ${item.pageIndex + 1}/${item.totalPages}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  tooltip: 'Add to library',
                  icon: const Icon(Icons.favorite_border_rounded),
                  onPressed: () async {
                    await ref.read(repositoryProvider).upsertLibraryItem(manga);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to library')),
                      );
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_routes.dart';
import '../../core/widgets/loaders.dart';
import '../../core/widgets/manga_card.dart';
import '../../core/widgets/manga_cover_image.dart';
import '../../models/manga.dart';
import '../downloads/downloads_screen.dart';
import '../stats/stats_screen.dart';
import 'collections_screen.dart';
import 'library_updates_provider.dart';

enum _LibraryTab {
  all('All'),
  favorites('Favorites'),
  history('History'),
  downloads('Downloads'),
  updates('Updates');

  const _LibraryTab(this.label);
  final String label;
}

enum _LibrarySort {
  dateAdded('Date added', Icons.schedule_rounded),
  title('Title A–Z', Icons.sort_by_alpha_rounded),
  lastRead('Last read', Icons.history_rounded);

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

  @override
  Widget build(BuildContext context) {
    final updates = ref.watch(libraryUpdatesProvider).value ?? const <LibraryUpdate>[];
    final updatesCount = updates.length;
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

  Widget _buildContent() {
    switch (_tab) {
      case _LibraryTab.all:
        return _LibraryGrid(
          filter: _LibraryFilter.all,
          sort: _sort,
        );
      case _LibraryTab.favorites:
        return _LibraryGrid(filter: _LibraryFilter.favorites, sort: _sort);
      case _LibraryTab.history:
        return const _HistoryView();
      case _LibraryTab.downloads:
        return const DownloadsScreen();
      case _LibraryTab.updates:
        return const _UpdatesView();
    }
  }
}

/// Simple safe-area-aware wrapper for the header (keeps layout consistent).
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
  const _LibraryGrid({required this.filter, required this.sort});

  final _LibraryFilter filter;
  final _LibrarySort sort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryItemsProvider);
    return library.when(
      loading: () => const MangaGridSkeleton(itemCount: 9),
      error: (e, _) => EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Library error',
        message: '$e',
      ),
      data: (items) {
        var list = items;
        if (filter == _LibraryFilter.favorites) {
          list = items.where((i) => i.favorite).toList();
        }
        list = _applySort(list, sort);
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.collections_bookmark_rounded,
            title: 'Your library is empty',
            message: 'Tap the favorite or library button on any manga to keep it here.',
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
            return MangaCard(
              manga: manga,
              onTap: () => AppRoutes.openManga(context, manga),
            );
          },
        );
      },
    );
  }

  List<LibraryItem> _applySort(List<LibraryItem> items, _LibrarySort sort) {
    switch (sort) {
      case _LibrarySort.title:
        return [...items]
          ..sort((a, b) =>
              a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case _LibrarySort.lastRead:
        return [...items]..sort((a, b) {
            final aRead = a.lastReadAt;
            final bRead = b.lastReadAt;
            if (aRead == null && bRead == null) return 0;
            if (aRead == null) return 1;
            if (bRead == null) return -1;
            return bRead.compareTo(aRead);
          });
      case _LibrarySort.dateAdded:
        // The provider already orders by addedAt (newest first).
        return items;
    }
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

/// Lists library manga that gained new chapters since last acknowledged.
class _UpdatesView extends ConsumerWidget {
  const _UpdatesView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updates = ref.watch(libraryUpdatesProvider);
    return updates.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Could not check updates',
        message: '$e\nPull down to try again.',
      ),
      data: (list) {
        if (list.isEmpty) {
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
            itemCount: list.length,
            itemBuilder: (context, index) {
              final update = list[index];
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
                  trailing: const Icon(Icons.chevron_right_rounded),
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
                ),
                leading: SizedBox(
                  width: 48,
                  height: 64,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: MangaCoverImage(manga: manga),
                  ),
                ),
                title: Text(item.mangaTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  '${item.chapterTitle} • ${item.pageIndex + 1}/${item.totalPages}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            );
          },
        );
      },
    );
  }
}

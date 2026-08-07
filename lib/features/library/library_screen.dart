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

enum _LibraryTab {
  all('All'),
  favorites('Favorites'),
  history('History'),
  downloads('Downloads');

  const _LibraryTab(this.label);
  final String label;
}

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  _LibraryTab _tab = _LibraryTab.all;

  @override
  Widget build(BuildContext context) {
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
                ],
              ),
            ),
          ),
          _TabBar(
            current: _tab,
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
        return const _LibraryGrid(
          filter: _LibraryFilter.all,
        );
      case _LibraryTab.favorites:
        return const _LibraryGrid(filter: _LibraryFilter.favorites);
      case _LibraryTab.history:
        return const _HistoryView();
      case _LibraryTab.downloads:
        return const DownloadsScreen();
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
  const _TabBar({required this.current, required this.onChanged});

  final _LibraryTab current;
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
              label: Text(tab.label),
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
  const _LibraryGrid({required this.filter});

  final _LibraryFilter filter;

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

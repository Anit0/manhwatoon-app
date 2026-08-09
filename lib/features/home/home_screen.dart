import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/settings_provider.dart';
import '../../core/router/app_routes.dart';
import '../../core/widgets/loaders.dart';
import '../../core/widgets/manga_card.dart';
import '../../core/widgets/manga_cover_image.dart';
import '../../models/manga.dart';
import '../browse/browse_screen.dart';
import '../settings/settings_screen.dart';
import 'home_data_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _refresh() async {
    await ref.read(homeDataProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeDataProvider);
    final sections = ref.watch(settingsProvider).homeSections;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              title: const Text('ManhwaToon'),
              actions: [
                IconButton(
                  tooltip: 'Settings',
                  icon: const Icon(Icons.settings_rounded),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _refresh,
                ),
              ],
            ),
            home.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Column(
                    children: [
                      MangaRowSkeleton(itemCount: 5),
                      MangaGridSkeleton(itemCount: 6, columns: 3),
                    ],
                  ),
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Could not load home',
                  message: '$e',
                  actionLabel: 'Retry',
                  onAction: _refresh,
                ),
              ),
              data: (data) {
                final children = <Widget>[];
                if (sections.contains('continueReading')) {
                  children.add(_ContinueReadingSection());
                }
                if (sections.contains('trending') && data.trending.isNotEmpty) {
                  children.add(_MangaRowSection(
                    title: 'Trending Today',
                    icon: Icons.local_fire_department_rounded,
                    mangaList: data.trending,
                    onSeeAll: () => _openBrowse(context, SortOrder.trending),
                  ));
                }
                if (sections.contains('hiddenGems') && data.hiddenGems.isNotEmpty) {
                  children.add(_MangaRowSection(
                    title: 'Hidden Gems',
                    icon: Icons.diamond_rounded,
                    mangaList: data.hiddenGems,
                    onSeeAll: () => _openBrowse(context, SortOrder.rating),
                  ));
                }
                if (sections.contains('popular') && data.popular.isNotEmpty) {
                  children.add(_MangaRowSection(
                    title: 'Most Popular',
                    icon: Icons.trending_up_rounded,
                    mangaList: data.popular,
                    onSeeAll: () => _openBrowse(context, SortOrder.views),
                  ));
                }
                if (sections.contains('dailySuggestions') &&
                    data.dailySuggestions.isNotEmpty) {
                  children.add(_MangaRowSection(
                    title: 'Daily Suggestions',
                    icon: Icons.auto_awesome_rounded,
                    mangaList: data.dailySuggestions,
                  ));
                }
                if (sections.contains('latest') && data.latest.isNotEmpty) {
                  children.add(_LatestGridSection(
                    mangaList: data.latest,
                    onSeeAll: () => _openBrowse(context, SortOrder.latest),
                  ));
                }
                if (children.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.cloud_off_rounded,
                      title: 'Could not load home',
                      message: 'Check your connection and try again.',
                      actionLabel: 'Retry',
                      onAction: _refresh,
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.only(bottom: 32),
                  sliver: SliverList.list(children: children),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openBrowse(BuildContext context, SortOrder order) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BrowseScreen(initialSort: order)),
    );
  }
}

class _ContinueReadingSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final continueReading = ref.watch(continueReadingProvider).value ?? const [];
    if (continueReading.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Continue Reading',
          icon: Icons.play_circle_fill_rounded,
        ),
        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: continueReading.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = continueReading[index];
              return SizedBox(
                width: 250,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      AppRoutes.openReader(
                        context,
                        manga: item.manga,
                        chapterUrl: item.chapterUrl,
                        chapterTitle: item.chapterTitle,
                      );
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: 84,
                          height: double.infinity,
                          child: MangaCoverImage(manga: item.manga),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item.manga.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.chapterTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: theme.colorScheme.primary),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: item.totalPages > 0
                                      ? (item.pageIndex + 1) / item.totalPages
                                      : 0,
                                  borderRadius: BorderRadius.circular(4),
                                  minHeight: 5,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${item.pageIndex + 1}/${item.totalPages} pages',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MangaRowSection extends StatelessWidget {
  const _MangaRowSection({
    required this.title,
    required this.icon,
    required this.mangaList,
    this.onSeeAll,
  });

  final String title;
  final IconData icon;
  final List<Manga> mangaList;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, icon: icon, onSeeAll: onSeeAll),
        SizedBox(
          height: 218,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: mangaList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final manga = mangaList[index];
              return SizedBox(
                width: 124,
                child: MangaCard(
                  manga: manga,
                  heroTag: 'home-$title-${manga.url}',
                  onTap: () =>
                      AppRoutes.openManga(context, manga, heroTag: 'home-$title-${manga.url}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LatestGridSection extends ConsumerWidget {
  const _LatestGridSection({required this.mangaList, this.onSeeAll});

  final List<Manga> mangaList;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns = _columnsFor(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Latest Updates',
          icon: Icons.new_releases_rounded,
          onSeeAll: onSeeAll,
          trailing: Text(
            '${mangaList.length}+',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 14,
              crossAxisSpacing: 12,
              childAspectRatio: 0.55,
            ),
            itemCount: mangaList.length,
            itemBuilder: (context, index) {
              final manga = mangaList[index];
              return MangaCard(
                manga: manga,
                onTap: () => AppRoutes.openManga(context, manga),
              );
            },
          ),
        ),
      ],
    );
  }

  int _columnsFor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return 6;
    if (width >= 600) return 4;
    return 3;
  }
}

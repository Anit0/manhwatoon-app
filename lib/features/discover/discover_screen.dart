import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/app_routes.dart';
import '../../core/widgets/loaders.dart';
import '../../core/widgets/manga_card.dart';
import '../../core/widgets/manga_cover_image.dart';
import '../../models/manga.dart';
import '../browse/browse_screen.dart';
import 'discover_data_provider.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  Future<void> _refresh() async {
    await ref.read(discoverDataProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final discover = ref.watch(discoverDataProvider);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverAppBar(
              floating: true,
              title: Text('Discover'),
            ),
            discover.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: MangaGridSkeleton(itemCount: 9),
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Could not load discover',
                  message: '$e',
                  actionLabel: 'Retry',
                  onAction: _refresh,
                ),
              ),
              data: (data) {
                final children = <Widget>[];
                if (data.randomPick != null) {
                  children.add(_RandomPickCard(
                    manga: data.randomPick!,
                    onReroll: () =>
                        ref.read(discoverDataProvider.notifier).rerollRandom(),
                  ));
                }
                children.add(_Section(
                  title: 'Trending Now',
                  icon: Icons.local_fire_department_rounded,
                  mangaList: data.trending,
                  order: SortOrder.trending,
                ));
                children.add(_Section(
                  title: 'Most Popular',
                  icon: Icons.trending_up_rounded,
                  mangaList: data.popular,
                  order: SortOrder.views,
                ));
                children.add(_Section(
                  title: 'Highest Rated',
                  icon: Icons.star_rounded,
                  mangaList: data.highestRated,
                  order: SortOrder.rating,
                ));
                children.add(_Section(
                  title: 'New Releases',
                  icon: Icons.auto_awesome_rounded,
                  mangaList: data.newReleases,
                  order: SortOrder.newManga,
                ));
                children.add(_Section(
                  title: 'Hidden Gems',
                  icon: Icons.diamond_rounded,
                  mangaList: data.hiddenGems,
                  order: SortOrder.rating,
                ));
                children.add(_Section(
                  title: 'Recently Updated',
                  icon: Icons.update_rounded,
                  mangaList: data.recentlyUpdated,
                  order: SortOrder.latest,
                ));
                if (data.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.cloud_off_rounded,
                      title: 'Could not load discover',
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
}

class _RandomPickCard extends ConsumerWidget {
  const _RandomPickCard({required this.manga, required this.onReroll});

  final Manga manga;
  final VoidCallback onReroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => AppRoutes.openManga(context, manga),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  height: 128,
                  child: MangaCoverImage(manga: manga),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Random Recommendation',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        manga.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        manga.genres.take(4).join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 10),
                      IconButton(
                        tooltip: 'Give me another one',
                        onPressed: onReroll,
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.mangaList,
    required this.order,
  });

  final String title;
  final IconData icon;
  final List<Manga> mangaList;
  final SortOrder order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          icon: icon,
          onSeeAll: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => BrowseScreen(initialSort: order)),
            );
          },
        ),
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
                  onTap: () => AppRoutes.openManga(context, manga),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

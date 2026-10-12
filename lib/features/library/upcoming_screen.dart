import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_routes.dart';
import '../../core/widgets/loaders.dart';
import '../../core/widgets/manga_cover_image.dart';
import '../../models/manga.dart';

class UpcomingScreen extends ConsumerWidget {
  const UpcomingScreen({super.key, this.collectionId});

  final int? collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryItemsProvider);
    final collections = ref.watch(collectionsProvider).value ?? const <Collection>[];
    return library.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Could not load',
        message: '$e',
      ),
      data: (items) {
        return _UpcomingBody(
          items: items,
          collections: collections,
          initialCollectionId: collectionId,
        );
      },
    );
  }
}

class _UpcomingBody extends ConsumerStatefulWidget {
  const _UpcomingBody({
    required this.items,
    required this.collections,
    this.initialCollectionId,
  });

  final List<LibraryItem> items;
  final List<Collection> collections;
  final int? initialCollectionId;

  @override
  ConsumerState<_UpcomingBody> createState() => _UpcomingBodyState();
}

class _UpcomingBodyState extends ConsumerState<_UpcomingBody> {
  int? _collectionId;

  @override
  void initState() {
    super.initState();
    _collectionId = widget.initialCollectionId;
  }

  @override
  void didUpdateWidget(covariant _UpcomingBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCollectionId != widget.initialCollectionId) {
      _collectionId = widget.initialCollectionId;
    }
  }

  @override
  Widget build(BuildContext context) {
    var items = widget.items;
    if (_collectionId != null) {
      final members =
          ref.watch(collectionItemsProvider(_collectionId!)).value;
      if (members != null) {
        final urls = {for (final m in members) m.mangaUrl};
        items = items.where((i) => urls.contains(i.mangaUrl)).toList();
      }
    }
    final grouped = _groupByExpectedDate(items);
    return Column(
      children: [
        if (widget.collections.isNotEmpty)
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _collectionId == null,
                  onSelected: (_) => setState(() => _collectionId = null),
                ),
                const SizedBox(width: 8),
                for (final c in widget.collections) ...[
                  ChoiceChip(
                    label: Text(c.name),
                    selected: _collectionId == c.id,
                    onSelected: (_) => setState(() => _collectionId = c.id),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        Expanded(
          child: grouped.isEmpty
              ? const EmptyState(
                  icon: Icons.event_available_rounded,
                  title: 'Nothing upcoming',
                  message: 'Followed series with a predicted next chapter appear here.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final entry = grouped.entries.elementAt(index);
                    return _DayGroup(date: entry.key, items: entry.value);
                  },
                ),
        ),
      ],
    );
  }

  Map<DateTime, List<LibraryItem>> _groupByExpectedDate(List<LibraryItem> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final map = <DateTime, List<LibraryItem>>{};
    for (final item in items) {
      final expected = _expectedDate(item);
      if (expected == null) continue;
      if (expected.isBefore(today)) continue;
      map.putIfAbsent(expected, () => []).add(item);
    }
    final keys = map.keys.toList()..sort();
    return {for (final k in keys) k: map[k]!};
  }

  DateTime? _expectedDate(LibraryItem item) {
    final last = item.lastReadAt;
    if (last == null) return null;
    final interval = const Duration(days: 7);
    final next = last.add(interval);
    return DateTime(next.year, next.month, next.day);
  }
}

class _DayGroup extends StatelessWidget {
  const _DayGroup({required this.date, required this.items});

  final DateTime date;
  final List<LibraryItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = DateFormat.yMMMEd().format(date);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 8),
              Badge(label: Text('${items.length}')),
            ],
          ),
          const SizedBox(height: 8),
          for (final item in items)
            Card(
              child: ListTile(
                onTap: () {
                  final manga = Manga(
                    url: item.mangaUrl,
                    title: item.title,
                    coverUrl: item.coverUrl,
                    latestChapterTitle: item.lastChapterTitle,
                    latestChapterUrl: item.lastChapterUrl,
                    isAdult: item.isAdult,
                  );
                  AppRoutes.openManga(context, manga);
                },
                leading: SizedBox(
                  width: 44,
                  height: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: MangaCoverImage(
                      manga: Manga(
                        url: item.mangaUrl,
                        title: item.title,
                        coverUrl: item.coverUrl,
                      ),
                    ),
                  ),
                ),
                title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(item.lastChapterTitle ?? 'Next chapter expected'),
              ),
            ),
        ],
      ),
    );
  }
}

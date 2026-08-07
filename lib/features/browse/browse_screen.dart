import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/router/app_routes.dart';
import '../../core/widgets/loaders.dart';
import '../../core/widgets/manga_card.dart';
import '../../models/manga.dart';
import '../../models/reader_models.dart';

/// Manga archive / browse screen with sort orders, optional genre filter and
/// infinite scrolling.
class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({
    super.key,
    this.initialSort = SortOrder.latest,
    this.initialGenre,
    this.title,
  });

  final SortOrder initialSort;
  final Genre? initialGenre;
  final String? title;

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  late SortOrder _sort;
  Genre? _genre;

  final List<Manga> _items = [];
  int _page = 0;
  bool _loading = false;
  bool _hasMore = true;
  Object? _error;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _sort = widget.initialSort;
    _genre = widget.initialGenre;
    _scrollController.addListener(_onScroll);
    _loadMore(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      _loadMore();
    }
  }

  Future<void> _loadMore({bool reset = false}) async {
    if (_loading) return;
    if (!reset && !_hasMore) return;
    setState(() {
      if (reset) {
        _page = 0;
        _items.clear();
        _error = null;
      }
      _loading = true;
    });
    try {
      final api = ref.read(siteApiProvider);
      final nextPage = _page + 1;
      final results = await api.fetchArchive(
        _sort,
        page: nextPage,
        genreSlug: _genre?.slug,
      );
      final hideAdult = ref.read(settingsProvider).hideAdult;
      final filtered = hideAdult ? results.where((m) => !m.isAdult).toList() : results;
      if (!mounted) return;
      setState(() {
        _items.addAll(filtered);
        _hasMore = results.isNotEmpty;
        _page = nextPage;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _changeSort(SortOrder order) {
    if (_sort == order) return;
    setState(() => _sort = order);
    _loadMore(reset: true);
  }

  void _selectGenre(Genre? genre) {
    setState(() => _genre = genre);
    _loadMore(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = widget.title ?? (_genre?.name ?? _sort.title);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          _SortBar(current: _sort, onChanged: _changeSort),
          if (_genre != null)
            _ActiveGenreChip(genre: _genre!, onClear: () => _selectGenre(null)),
          Expanded(
            child: _items.isEmpty && _error == null
                ? const MangaGridSkeleton(itemCount: 9)
                : RefreshIndicator(
                    onRefresh: () => _loadMore(reset: true),
                    child: _buildGrid(theme),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openGenrePicker(context),
        icon: const Icon(Icons.category_rounded),
        label: const Text('Genres'),
      ),
    );
  }

  Widget _buildGrid(ThemeData theme) {
    if (_items.isEmpty && _error != null) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Could not load',
        message: '$_error',
        actionLabel: 'Retry',
        onAction: () => _loadMore(reset: true),
      );
    }
    final columns = _columnsFor(context);
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 14,
        crossAxisSpacing: 12,
        childAspectRatio: 0.55,
      ),
      itemCount: _items.length + (_hasMore || _loading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          );
        }
        final manga = _items[index];
        return MangaCard(
          manga: manga,
          onTap: () => AppRoutes.openManga(context, manga),
        );
      },
    );
  }

  void _openGenrePicker(BuildContext context) {
    showModalBottomSheet<Genre>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => const FractionallySizedBox(
        heightFactor: 0.75,
        child: _GenrePickerSheet(),
      ),
    ).then((genre) {
      if (genre != null) _selectGenre(genre);
    });
  }

  int _columnsFor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return 6;
    if (width >= 600) return 4;
    return 3;
  }
}

class _SortBar extends StatelessWidget {
  const _SortBar({required this.current, required this.onChanged});

  final SortOrder current;
  final ValueChanged<SortOrder> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: SortOrder.values.map((order) {
          final selected = order == current;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(order.label),
              selected: selected,
              onSelected: (_) => onChanged(order),
              selectedColor: scheme.primaryContainer,
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ActiveGenreChip extends StatelessWidget {
  const _ActiveGenreChip({required this.genre, required this.onClear});

  final Genre genre;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Row(
        children: [
          Chip(
            avatar: const Icon(Icons.category_rounded, size: 16),
            label: Text(genre.name),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: onClear,
          ),
        ],
      ),
    );
  }
}

class _GenrePickerSheet extends ConsumerStatefulWidget {
  const _GenrePickerSheet();

  @override
  ConsumerState<_GenrePickerSheet> createState() => _GenrePickerSheetState();
}

class _GenrePickerSheetState extends ConsumerState<_GenrePickerSheet> {
  late Future<List<Genre>> _genresFuture;

  @override
  void initState() {
    super.initState();
    _genresFuture = ref.read(siteApiProvider).fetchGenres();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Genre>>(
      future: _genresFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final genres = snapshot.data!;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 180,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.4,
          ),
          itemCount: genres.length,
          itemBuilder: (context, index) {
            final genre = genres[index];
            return OutlinedButton(
              onPressed: () => Navigator.of(context).pop(genre),
              child: Text(genre.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            );
          },
        );
      },
    );
  }
}

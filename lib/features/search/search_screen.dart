import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/router/app_routes.dart';
import '../../core/widgets/loaders.dart';
import '../../core/widgets/manga_card.dart';
import '../../models/manga.dart';
import '../../models/reader_models.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _debounce;
  String _query = '';
  bool _typing = false;
  List<SearchSuggestion> _suggestions = const [];
  bool _submitted = false;
  bool _loadingResults = false;
  List<Manga> _results = [];
  int _page = 0;
  bool _hasMore = true;
  Object? _error;
  final ScrollController _scrollController = ScrollController();

  Genre? _genreFilter;
  String? _statusFilter;
  SortOrder? _orderFilter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String text) {
    setState(() {
      _query = text.trim();
      _typing = _query.isNotEmpty;
      _submitted = false;
    });
    _debounce?.cancel();
    if (_query.isEmpty) {
      setState(() => _suggestions = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      final api = ref.read(activeSourceProvider);
      final suggestions = await api.searchSuggestions(_query);
      if (!mounted) return;
      setState(() => _suggestions = suggestions);
    });
  }

  Future<void> _submit(String query) async {
    final term = query.trim();
    if (term.isEmpty) return;
    _controller.text = term;
    _controller.selection = TextSelection.collapsed(offset: term.length);
    _focusNode.unfocus();
    setState(() {
      _query = term;
      _typing = false;
      _submitted = true;
      _page = 0;
      _results = [];
      _hasMore = true;
      _error = null;
      _loadingResults = true;
    });
    await ref.read(repositoryProvider).addSearchTerm(term);
    await _search(term, reset: true);
  }

  Future<void> _search(String term, {required bool reset}) async {
    if (_loadingResults) return;
    if (!reset && !_hasMore) return;
    setState(() {
      if (reset) _results = [];
      _loadingResults = true;
    });
    try {
      final api = ref.read(activeSourceProvider);
      final page = reset ? 1 : _page + 1;
      final results = await api.search(
        term,
        page: page,
        genreSlug: _genreFilter?.slug,
        status: _statusFilter,
        order: _orderFilter,
      );
      final hideAdult = ref.read(settingsProvider).hideAdult;
      final filtered = hideAdult ? results.where((m) => !m.isAdult).toList() : results;
      if (!mounted) return;
      setState(() {
        _results.addAll(filtered);
        _hasMore = results.isNotEmpty;
        _page = page;
        _loadingResults = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loadingResults = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _search(_query, reset: false);
    }
  }

  void _applyFilters({Genre? genre, String? status, SortOrder? order}) {
    setState(() {
      _genreFilter = genre;
      _statusFilter = status;
      _orderFilter = order;
    });
    if (_submitted) _search(_query, reset: true);
  }

  void _openFilters() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => _SearchFilterSheet(
        genre: _genreFilter,
        status: _statusFilter,
        order: _orderFilter,
        onApply: _applyFilters,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _SearchField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onQueryChanged,
          onSubmitted: _submit,
          onClear: () {
            _controller.clear();
            _onQueryChanged('');
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Filters',
            onPressed: _openFilters,
            icon: Badge(
              isLabelVisible: _genreFilter != null ||
                  _statusFilter != null ||
                  _orderFilter != null,
              child: const Icon(Icons.tune_rounded),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_typing) {
      return _buildSuggestions();
    }
    if (_submitted) {
      return _buildResults();
    }
    return _buildIdle();
  }

  Widget _buildIdle() {
    return Consumer(
      builder: (context, ref, _) {
        final history = ref.watch(searchHistoryProvider).value ?? const [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(title: 'Recent Searches', icon: Icons.history_rounded),
            if (history.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('No recent searches yet'),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: history
                    .take(12)
                    .map((h) => InputChip(
                          label: Text(h.term),
                          avatar: const Icon(Icons.history_rounded, size: 16),
                          onPressed: () => _submit(h.term),
                          onDeleted: () => ref
                              .read(searchHistoryProvider.notifier)
                              .clearHistory(),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 8),
            const SectionHeader(
              title: 'Browse Genres',
              icon: Icons.category_rounded,
            ),
            _GenreCloud(
              onSelected: (genre) {
                _applyFilters(genre: genre);
                _submit(_query.isEmpty ? '' : _query);
              },
            ),
            const SizedBox(height: 8),
            const SectionHeader(title: 'Smart Search', icon: Icons.auto_awesome_rounded),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.mic_none_rounded),
                  title: const Text('Search by voice'),
                  subtitle: const Text('Coming soon'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Voice search coming soon')),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSuggestions() {
    if (_suggestions.isEmpty) {
      return const Center(child: Text('Type to search'));
    }
    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: _suggestions.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
      itemBuilder: (context, index) {
        final s = _suggestions[index];
        return ListTile(
          leading: const Icon(Icons.search_rounded),
          title: Text(s.title),
          subtitle: s.type != null && s.type != 'manga' ? Text(s.type!) : null,
          trailing: const Icon(Icons.north_west_rounded, size: 16),
          onTap: () => _submit(s.title),
        );
      },
    );
  }

  Widget _buildResults() {
    if (_loadingResults && _results.isEmpty) {
      return const MangaGridSkeleton(itemCount: 9);
    }
    if (_results.isEmpty && _error != null) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Search failed',
        message: '$_error',
        actionLabel: 'Retry',
        onAction: () => _search(_query, reset: true),
      );
    }
    if (_results.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No results',
        message: 'Try different keywords or remove filters.',
      );
    }
    return Column(
      children: [
        if (_genreFilter != null || _statusFilter != null || _orderFilter != null)
          _ActiveFilters(
            genre: _genreFilter,
            status: _statusFilter,
            order: _orderFilter,
            onClear: (field) {
              _applyFilters(
                genre: field == 'genre' ? null : _genreFilter,
                status: field == 'status' ? null : _statusFilter,
                order: field == 'order' ? null : _orderFilter,
              );
            },
          ),
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 14,
              crossAxisSpacing: 12,
              childAspectRatio: 0.55,
            ),
            itemCount: _results.length + ((_hasMore || _loadingResults) ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= _results.length) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                );
              }
              final manga = _results[index];
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
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search manga...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(icon: const Icon(Icons.close_rounded), onPressed: onClear),
      ),
    );
  }
}

class _GenreCloud extends ConsumerWidget {
  const _GenreCloud({required this.onSelected});

  final ValueChanged<Genre> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genres = ref.watch(genresProvider).value ?? const <Genre>[];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: genres.take(20).map((g) {
          return ActionChip(
            label: Text(g.name),
            onPressed: () => onSelected(g),
          );
        }).toList(),
      ),
    );
  }
}

class _ActiveFilters extends StatelessWidget {
  const _ActiveFilters({
    required this.genre,
    required this.status,
    required this.order,
    required this.onClear,
  });

  final Genre? genre;
  final String? status;
  final SortOrder? order;
  final ValueChanged<String> onClear;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    if (genre != null) {
      chips.add(Chip(
        label: Text(genre!.name),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: () => onClear('genre'),
      ));
    }
    if (status != null) {
      chips.add(Chip(
        label: Text(status!),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: () => onClear('status'),
      ));
    }
    if (order != null) {
      chips.add(Chip(
        label: Text(order!.label),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: () => onClear('order'),
      ));
    }
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: chips,
      ),
    );
  }
}

class _SearchFilterSheet extends StatefulWidget {
  const _SearchFilterSheet({
    required this.genre,
    required this.status,
    required this.order,
    required this.onApply,
  });

  final Genre? genre;
  final String? status;
  final SortOrder? order;
  final Function({Genre? genre, String? status, SortOrder? order}) onApply;

  @override
  State<_SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<_SearchFilterSheet> {
  late Genre? _genre = widget.genre;
  late String? _status = widget.status;
  late SortOrder? _order = widget.order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Filters', style: theme.textTheme.titleLarge),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Status', style: theme.textTheme.titleSmall),
          ),
          Wrap(
            spacing: 8,
            children: ['Ongoing', 'Completed', 'OnHold', 'Canceled']
                .map((s) => ChoiceChip(
                      label: Text(s),
                      selected: _status == s,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _status = s),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Sort by', style: theme.textTheme.titleSmall),
          ),
          Wrap(
            spacing: 8,
            children: SortOrder.values
                .map((o) => ChoiceChip(
                      label: Text(o.label),
                      selected: _order == o,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _order = o),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Genre', style: theme.textTheme.titleSmall),
          ),
          Consumer(
            builder: (context, ref, _) {
              final genres = ref.watch(genresProvider).value ?? const <Genre>[];
              return SizedBox(
                height: 120,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.6,
                  ),
                  itemCount: genres.length,
                  itemBuilder: (context, index) {
                    final g = genres[index];
                    return ChoiceChip(
                      label: Text(g.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      selected: _genre?.slug == g.slug,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _genre = g),
                    );
                  },
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _genre = null;
                        _status = null;
                        _order = null;
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onApply(
                        genre: _genre,
                        status: _status,
                        order: _order,
                      );
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

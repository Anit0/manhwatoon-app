import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/app_providers.dart';

/// Owns recent search history.
class SearchHistoryNotifier extends AsyncNotifier<List<SearchHistoryTableData>> {
  @override
  Future<List<SearchHistoryTableData>> build() async {
    return ref.watch(repositoryProvider).getRecentSearches();
  }

  Future<void> add(String term) async {
    await ref.read(repositoryProvider).addSearchTerm(term);
    state = await AsyncValue.guard(() async {
      return ref.read(repositoryProvider).getRecentSearches();
    });
  }

  Future<void> clearHistory() async {
    await ref.read(repositoryProvider).clearSearchHistory();
    state = const AsyncData([]);
  }
}

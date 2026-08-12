import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../models/search_result.dart';

final searchProvider =
    AsyncNotifierProvider<SearchNotifier, SearchResult?>(
  SearchNotifier.new,
);

class SearchNotifier extends AsyncNotifier<SearchResult?> {
  @override
  Future<SearchResult?> build() async {
    return null;
  }

  Future<void> search(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      state = const AsyncData(null);
      return;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final api = ref.read(tmdbApiProvider);

      return api.searchMulti(trimmedQuery);
    });
  }

  void clear() {
    state = const AsyncData(null);
  }
}
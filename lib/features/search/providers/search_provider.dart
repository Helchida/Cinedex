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
    return _getRecommendations();
  }

  Future<SearchResult> _getRecommendations() async {
    final api = ref.read(tmdbApiProvider);

    final results = await Future.wait([
      api.getPopularMovies(),
      api.getPopularTvShows(),
    ]);

    return SearchResult(
      movies: results[0].cast(),
      tvShows: results[1].cast(),
    );
  }

  Future<void> search(String query) async {
    final trimmedQuery = query.trim();

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final api = ref.read(tmdbApiProvider);

      if (trimmedQuery.isEmpty) {
        return _getRecommendations();
      }

      return api.searchMulti(trimmedQuery);
    });
  }

  void clear() {
    search('');
  }
}
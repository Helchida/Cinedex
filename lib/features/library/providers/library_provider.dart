import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'library_repository_provider.dart';

final librarySeriesProvider =
    FutureProvider<List<Map<String, dynamic>>>(
  (ref) async {
    final repository = ref.read(
      libraryRepositoryProvider,
    );

    return repository.getSeries();
  },
);

final libraryMoviesProvider =
    FutureProvider<List<Map<String, dynamic>>>(
  (ref) async {
    final repository = ref.read(
      libraryRepositoryProvider,
    );

    return repository.getMovies();
  },
);
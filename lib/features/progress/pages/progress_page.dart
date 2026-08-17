import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../library/providers/library_provider.dart';
import '../../watchlist/providers/watch_progress_provider.dart';
import '../widgets/progress_series_progress_card.dart';
import '../widgets/progress_empty_library.dart';
import '../widgets/progress_movie_watchlist_card.dart';

class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final seriesAsync = ref.watch(
      librarySeriesProvider,
    );

    final watchProgress = ref.watch(
      watchProgressProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma progression'),
      ),
      body: seriesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Impossible de charger votre progression.\n\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (series) {
          final moviesToWatch = watchProgress.watchlistMovies
            .where(
              (movie) =>
                  !watchProgress.movies.containsKey(
                    movie['tmdb_id'] as int,
                  ),
            )
            .toList();

          if (series.isEmpty && moviesToWatch.isEmpty) {
            return const EmptyLibrary();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                librarySeriesProvider,
              );

              await ref.read(
                librarySeriesProvider.future,
              );
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (series.isNotEmpty) ...[
                  Text(
                    'Continuer à regarder',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  ...series.map(
                    (series) => SeriesProgressCard(
                      tvShowId: series['tmdb_id'] as int,
                      name: series['name'] as String,
                      posterPath: series['poster_path'] as String?,
                    ),
                  ),
                ],

                if (moviesToWatch.isNotEmpty) ...[
                  if (series.isNotEmpty)
                    const SizedBox(height: 16),

                  Text(
                    'Films à voir',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 16),

                  ...moviesToWatch.map(
                    (movie) => MovieWatchlistCard(
                      movieId: movie['tmdb_id'] as int,
                      title: movie['title'] as String,
                      posterPath: movie['poster_path'] as String?,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}






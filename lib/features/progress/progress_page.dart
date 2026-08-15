import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../library/providers/library_provider.dart';
import '../library/providers/next_episode_provider.dart';
import '../details/pages/season_episodes_page.dart';
import '../watchlist/providers/watch_progress_provider.dart';

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
            return const _EmptyLibrary();
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
                    (series) => _SeriesProgressCard(
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
                    (movie) => _MovieWatchlistCard(
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

class _SeriesProgressCard extends ConsumerWidget {
  const _SeriesProgressCard({
    required this.tvShowId,
    required this.name,
    required this.posterPath,
  });

  final int tvShowId;
  final String name;
  final String? posterPath;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final nextEpisodeAsync = ref.watch(
      nextEpisodeProvider(tvShowId),
    );

    return nextEpisodeAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stackTrace) =>
          const SizedBox.shrink(),
      data: (nextEpisode) {
        if (nextEpisode == null) {
          return const SizedBox.shrink();
        }

        final episode = nextEpisode.episode;

        return Card(
          margin: const EdgeInsets.only(
            bottom: 16,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              if (posterPath != null &&
                  posterPath!.isNotEmpty)
                Image.network(
                  'https://image.tmdb.org/t/p/w500$posterPath',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'S${nextEpisode.seasonNumber.toString().padLeft(2, '0')}'
                      'E${episode.episodeNumber.toString().padLeft(2, '0')}'
                      ' · ${episode.name}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nextEpisode.seasonName,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  SeasonEpisodesPage(
                                tvShowId:
                                    nextEpisode.tvShowId,
                                seasonNumber:
                                    nextEpisode
                                        .seasonNumber,
                                seasonName:
                                    nextEpisode.seasonName,
                                tvShowName: name,
                                posterPath:
                                    posterPath,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.play_arrow,
                        ),
                        label: const Text(
                          'Continuer',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Votre progression est vide',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez des films ou des séries à votre bibliothèque pour retrouver leur progression ici.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _MovieWatchlistCard extends StatelessWidget {
  const _MovieWatchlistCard({
    required this.movieId,
    required this.title,
    required this.posterPath,
  });

  final int movieId;
  final String title;
  final String? posterPath;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (posterPath != null &&
              posterPath!.isNotEmpty)
            Image.network(
              'https://image.tmdb.org/t/p/w342$posterPath',
              width: 100,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Container(
                  width: 100,
                  height: 150,
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  child: const Icon(
                    Icons.broken_image_outlined,
                  ),
                );
              },
            )
          else
            Container(
              width: 100,
              height: 150,
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              child: const Icon(
                Icons.movie_outlined,
                size: 40,
              ),
            ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'À voir',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
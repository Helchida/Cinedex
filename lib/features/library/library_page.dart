import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './providers/library_provider.dart';
import './providers/next_episode_provider.dart';
import '../watchlist/providers/watch_progress_provider.dart';
import '../watchlist/models/media_watch_status.dart';
import '../details/pages/tv_show_details_page.dart';
import '../details/pages/movie_details_page.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() =>
      _LibraryPageState();
}

class _LibraryPageState
    extends ConsumerState<LibraryPage> {
  int _selectedType = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma bibliothèque'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          SizedBox(
  width: double.infinity,
  child: Row(
    children: [
      Expanded(
        child: _LibraryTab(
          label: 'Films',
          selected: _selectedType == 0,
          onTap: () {
            setState(() {
              _selectedType = 0;
            });
          },
        ),
      ),
      Expanded(
        child: _LibraryTab(
          label: 'Séries',
          selected: _selectedType == 1,
          onTap: () {
            setState(() {
              _selectedType = 1;
            });
          },
        ),
      ),
    ],
  ),
),

          const SizedBox(height: 16),

          Expanded(
            child: _selectedType == 0
                ? const _MoviesLibrary()
                : const _SeriesLibrary(),
          ),
        ],
      ),
    );
  }
}

class _LibraryTab extends StatelessWidget {
  const _LibraryTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context)
            .colorScheme
            .onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    color: color,
                    fontWeight: selected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
            ),
            const SizedBox(height: 10),
            AnimatedContainer(
              duration: const Duration(
                milliseconds: 200,
              ),
              height: 2,
              width: double.infinity,
              color: selected
                  ? Theme.of(context)
                      .colorScheme
                      .primary
                  : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

class _MoviesLibrary extends ConsumerWidget {
  const _MoviesLibrary();

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final moviesAsync = ref.watch(
      libraryMoviesProvider,
    );

    final watchState = ref.watch(
      watchProgressProvider,
    );

    if (watchState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return moviesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Impossible de charger vos films.\n\n$error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (movies) {
        final watchedMovies = movies.where((movie) {
          final tmdbId = movie['tmdb_id'] as int;

          return watchState.movies[tmdbId]?.status ==
              MediaWatchStatus.watched;
        }).toList();

        if (watchedMovies.isEmpty) {
          return const _EmptyLibrary(
            icon: Icons.movie_outlined,
            title: 'Aucun film vu',
            message:
                'Les films que vous aurez regardés apparaîtront ici.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(
              libraryMoviesProvider,
            );

            ref.invalidate(
              watchProgressProvider,
            );

            await ref.read(
              libraryMoviesProvider.future,
            );
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.62,
            ),
            itemCount: watchedMovies.length,
            itemBuilder: (context, index) {
              final movie = watchedMovies[index];

              return _MovieCard(
                movieId: movie['tmdb_id'] as int,
                title: movie['title'] as String,
                posterPath: movie['poster_path'] as String?,
              );
            },
          ),
        );
      },
    );
  }
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({
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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MovieDetailsPage(
                movieId: movieId,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: posterPath != null &&
                      posterPath!.isNotEmpty
                  ? Image.network(
                      'https://image.tmdb.org/t/p/w500$posterPath',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      child: const Icon(
                        Icons.movie_outlined,
                        size: 48,
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeriesLibrary extends ConsumerWidget {
  const _SeriesLibrary();

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final seriesAsync = ref.watch(
      librarySeriesProvider,
    );

    return seriesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Impossible de charger vos séries.\n\n$error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (series) {
        if (series.isEmpty) {
          return const _EmptyLibrary(
            icon: Icons.tv_outlined,
            title: 'Aucune série',
            message:
                'Les séries que vous ajoutez à votre bibliothèque apparaîtront ici.',
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            childAspectRatio: 0.62,
          ),
          itemCount: series.length,
          itemBuilder: (context, index) {
            final serie = series[index];

            return _SeriesCard(
              tvShowId: serie['tmdb_id'] as int,
              name: serie['name'] as String,
              posterPath:
                  serie['poster_path'] as String?,
            );
          },
        );
      },
    );
  }
}

class _SeriesCard extends ConsumerWidget {
  const _SeriesCard({
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
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (nextEpisode) {
        final isCompleted = nextEpisode == null;

        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TvShowDetailsPage(
                    tvShowId: tvShowId,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: posterPath != null &&
                          posterPath!.isNotEmpty
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w500$posterPath',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: double.infinity,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: const Icon(
                            Icons.tv_outlined,
                            size: 48,
                          ),
                        ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    10,
                    10,
                    10,
                    4,
                  ),
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    10,
                    0,
                    10,
                    10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.check_circle
                            : Icons.play_circle_outline,
                        size: 17,
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          isCompleted
                              ? 'Terminée'
                              : 'En cours',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

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
              icon,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),

            const SizedBox(height: 16),

            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              message,
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
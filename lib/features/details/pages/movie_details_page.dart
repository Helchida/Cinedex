import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/media_details_provider.dart';
import '../../movies/models/movie.dart';
import '../../watchlist/providers/watch_progress_provider.dart';

class MovieDetailsPage extends ConsumerWidget {
  const MovieDetailsPage({
    super.key,
    required this.movieId,
  });

  final int movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieAsync = ref.watch(
      movieDetailsProvider(movieId),
    );

    return Scaffold(
      body: movieAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text(
              'Impossible de charger le film.\n$error',
              textAlign: TextAlign.center,
            ),
          );
        },
        data: (movie) {
          return _MovieDetailsContent(
            movie: movie,
          );
        },
      ),
    );
  }
}

class _MovieDetailsContent extends StatelessWidget {
  const _MovieDetailsContent({
    required this.movie,
  });

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: _Backdrop(
              path: movie.backdropPath,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  movie: movie,
                ),
                const SizedBox(height: 24),
                _Actions(
                  movie: movie,
                ),
                const SizedBox(height: 28),
                _Genres(
                  movie: movie,
                ),
                const SizedBox(height: 24),
                _Overview(
                  movie: movie,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop({
    required this.path,
  });

  final String? path;

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(
            Icons.movie,
            color: Colors.white,
            size: 64,
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          'https://image.tmdb.org/t/p/w780$path',
          fit: BoxFit.cover,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return Container(
              color: Colors.black,
              child: const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            );
          },
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.85),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.movie,
  });

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (movie.posterPath != null &&
            movie.posterPath!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              'https://image.tmdb.org/t/p/w342${movie.posterPath}',
              width: 120,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Container(
                  width: 120,
                  height: 180,
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  child: const Icon(
                    Icons.broken_image_outlined,
                  ),
                );
              },
            ),
          ),

        const SizedBox(width: 20),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                movie.title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 12),

              if (movie.voteAverage != null)
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 20,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      movie.voteAverage!
                          .toStringAsFixed(1),
                    ),
                  ],
                ),

              const SizedBox(height: 8),

              Text(
                [
                  if (movie.releaseDate != null)
                    movie.releaseDate!.year.toString(),
                  if (movie.runtime != null)
                    '${movie.runtime} min',
                ].join(' · '),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({
    required this.movie,
  });

  final Movie movie;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final isWatched = ref.watch(
      watchProgressProvider.select(
        (state) => state.movies.containsKey(movie.id),
      ),
    );

    return Row(
      children: [
        Expanded(
          child: isWatched
              ? OutlinedButton.icon(
                  onPressed: () {
                    ref
                        .read(
                          watchProgressProvider.notifier,
                        )
                        .toggleMovie(
                          tmdbMovieId: movie.id,
                          title: movie.title,
                          posterPath: movie.posterPath,
                          releaseDate: movie.releaseDate,
                        );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Vu'),
                )
              : FilledButton.icon(
                  onPressed: () {
                    ref
                        .read(
                          watchProgressProvider.notifier,
                        )
                        .toggleMovie(
                          tmdbMovieId: movie.id,
                          title: movie.title,
                          posterPath: movie.posterPath,
                          releaseDate: movie.releaseDate,
                        );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text(
                    'Marquer comme vu',
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('À voir'),
          ),
        ),
      ],
    );
  }
}

class _Genres extends StatelessWidget {
  const _Genres({
    required this.movie,
  });

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    if (movie.genres.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: movie.genres
          .map(
            (genre) => Chip(
              label: Text(genre),
            ),
          )
          .toList(),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({
    required this.movie,
  });

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    if (movie.overview == null ||
        movie.overview!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Synopsis',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 10),

        Text(
          movie.overview!,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(
                height: 1.5,
              ),
        ),
      ],
    );
  }
}
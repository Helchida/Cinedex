import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/library_provider.dart';
import '../../watchlist/providers/watch_progress_provider.dart';
import '../../watchlist/models/media_watch_status.dart';
import 'library_movie_card.dart';
import 'library_empty_library.dart';

class MoviesLibrary extends ConsumerWidget {
  const MoviesLibrary({super.key});

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
          return const EmptyLibrary(
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

              return MovieCard(
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
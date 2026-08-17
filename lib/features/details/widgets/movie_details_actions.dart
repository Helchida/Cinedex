import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../movies/models/movie.dart';
import '../../watchlist/providers/watch_progress_provider.dart';

class MovieDetailsActions extends ConsumerWidget {
  const MovieDetailsActions({
    super.key,
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

    final isInWatchlist = ref.watch(
      watchProgressProvider.select(
        (state) =>
            state.movieWatchlist.contains(movie.id),
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
                    'Je l\'ai vu',
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ref
                  .read(
                    watchProgressProvider.notifier,
                  )
                  .toggleMovieWatchlist(
                    tmdbMovieId: movie.id,
                    title: movie.title,
                    posterPath: movie.posterPath,
                    releaseDate: movie.releaseDate,
                  );
            },
            icon: Icon(
              isWatched
                  ? Icons.bookmark
              : isInWatchlist
                  ? Icons.bookmark
                  : Icons.bookmark_border,
            ),
            label: Text(
              isWatched
                  ? 'Dans ma liste'
                  : isInWatchlist
                      ? 'Dans ma liste'
                      : 'À voir',
            ),
          ),
        ),
      ],
    );
  }
}
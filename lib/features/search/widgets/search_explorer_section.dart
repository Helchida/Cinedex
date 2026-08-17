import 'package:flutter/material.dart';

import '../../movies/models/movie.dart';
import '../../series/models/tv_show.dart';
import 'search_explorer_movie_card.dart';
import 'search_explorer_tv_show_card.dart';

class ExplorerSection extends StatelessWidget {
  const ExplorerSection({
    super.key,
    required this.title,
    this.movies,
    this.tvShows,
  });

  final String title;
  final List<Movie>? movies;
  final List<TvShow>? tvShows;

  @override
  Widget build(BuildContext context) {
    final hasMovies =
        movies != null && movies!.isNotEmpty;

    final hasTvShows =
        tvShows != null && tvShows!.isNotEmpty;

    if (!hasMovies && !hasTvShows) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            20,
            16,
            12,
          ),
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),

        SizedBox(
          height: 220,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: hasMovies
                ? movies!.length
                : tvShows!.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (hasMovies) {
                return ExplorerMovieCard(
                  movie: movies![index],
                );
              }

              return ExplorerTvShowCard(
                tvShow: tvShows![index],
              );
            },
          ),
        ),
      ],
    );
  }
}
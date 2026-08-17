import 'package:flutter/material.dart';
import '../../movies/models/movie.dart';
import '../../series/models/tv_show.dart';
import 'search_movie_result_tile.dart';
import 'search_tv_show_result_tile.dart';

class SearchResults extends StatelessWidget {
  const SearchResults({
    super.key,
    required this.movies,
    required this.tvShows,
  });

  final List<Movie> movies;
  final List<TvShow> tvShows;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      children: [
        if (movies.isNotEmpty) ...[
          const Text(
            'Films',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...movies.map(
            (movie) => MovieResultTile(
              movie: movie,
            ),
          ),

          const SizedBox(height: 24),
        ],

        if (tvShows.isNotEmpty) ...[
          const Text(
            'Séries',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...tvShows.map(
            (show) => TvShowResultTile(
              show: show,
            ),
          ),
        ],
      ],
    );
  }
}
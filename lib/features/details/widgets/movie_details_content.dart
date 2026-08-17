import 'package:flutter/material.dart';
import '../../movies/models/movie.dart';
import 'movie_details_backdrop.dart';
import 'movie_details_header.dart';
import 'movie_details_actions.dart';
import 'movie_details_genres.dart';
import 'movie_details_overview.dart';

class MovieDetailsContent extends StatelessWidget {
  const MovieDetailsContent({
    super.key,
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
            background: Backdrop(
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
                Header(
                  movie: movie,
                ),
                const SizedBox(height: 24),
                MovieDetailsActions(
                  movie: movie,
                ),
                const SizedBox(height: 28),
                Genres(
                  movie: movie,
                ),
                const SizedBox(height: 24),
                Overview(
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
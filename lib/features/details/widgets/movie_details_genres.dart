import 'package:flutter/material.dart';
import '../../movies/models/movie.dart';

class Genres extends StatelessWidget {
  const Genres({
    super.key,
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
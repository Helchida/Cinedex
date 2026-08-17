import 'package:flutter/material.dart';
import '../../series/models/tv_show.dart';

class Genres extends StatelessWidget {
  const Genres({
    super.key,
    required this.tvShow,
  });

  final TvShow tvShow;

  @override
  Widget build(BuildContext context) {
    if (tvShow.genres.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tvShow.genres
          .map(
            (genre) => Chip(
              label: Text(genre),
            ),
          )
          .toList(),
    );
  }
}
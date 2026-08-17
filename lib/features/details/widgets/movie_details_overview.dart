import 'package:flutter/material.dart';
import '../../movies/models/movie.dart';

class Overview extends StatelessWidget {
  const Overview({
    super.key,
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
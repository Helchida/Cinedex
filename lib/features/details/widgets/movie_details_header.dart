import 'package:flutter/material.dart';
import '../../movies/models/movie.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
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
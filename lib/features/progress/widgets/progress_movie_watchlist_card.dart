import 'package:flutter/material.dart';

class MovieWatchlistCard extends StatelessWidget {
  const MovieWatchlistCard({
    super.key,
    required this.movieId,
    required this.title,
    required this.posterPath,
  });

  final int movieId;
  final String title;
  final String? posterPath;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (posterPath != null &&
              posterPath!.isNotEmpty)
            Image.network(
              'https://image.tmdb.org/t/p/w342$posterPath',
              width: 100,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Container(
                  width: 100,
                  height: 150,
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  child: const Icon(
                    Icons.broken_image_outlined,
                  ),
                );
              },
            )
          else
            Container(
              width: 100,
              height: 150,
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              child: const Icon(
                Icons.movie_outlined,
                size: 40,
              ),
            ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'À voir',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
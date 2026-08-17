import 'package:flutter/material.dart';

class EpisodeImage extends StatelessWidget {
  const EpisodeImage({
    super.key,
    required this.path,
  });

  final String? path;

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest,
          child: const Center(
            child: Icon(
              Icons.movie_outlined,
              size: 48,
            ),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        'https://image.tmdb.org/t/p/w500$path',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 48,
              ),
            ),
          );
        },
      ),
    );
  }
}
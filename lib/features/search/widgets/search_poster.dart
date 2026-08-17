import 'package:flutter/material.dart';

class Poster extends StatelessWidget {
  const Poster({
    super.key,
    required this.path,
  });

  final String? path;

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return Container(
        width: 50,
        height: 75,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.movie_outlined),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        'https://image.tmdb.org/t/p/w92$path',
        width: 50,
        height: 75,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 50,
            height: 75,
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            child: const Icon(Icons.broken_image_outlined),
          );
        },
      ),
    );
  }
}
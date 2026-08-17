import 'package:flutter/material.dart';

class SeasonPoster extends StatelessWidget {
  const SeasonPoster({
    super.key,
    required this.path,
  });

  final String? path;

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return Container(
        width: 55,
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.tv),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        'https://image.tmdb.org/t/p/w185$path',
        width: 55,
        height: 80,
        fit: BoxFit.cover,
      ),
    );
  }
}
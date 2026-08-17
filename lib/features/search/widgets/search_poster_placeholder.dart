import 'package:flutter/material.dart';

class PosterPlaceholder extends StatelessWidget {
  const PosterPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest,
      child: const Center(
        child: Icon(
          Icons.movie_outlined,
          size: 40,
        ),
      ),
    );
  }
}
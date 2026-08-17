import 'package:flutter/material.dart';
import '../../series/models/episode.dart';

class WatchButton extends StatelessWidget {
  const WatchButton({
    super.key,
    required this.episode,
    required this.isWatched,
    required this.onPressed,
  });

  final Episode episode;
  final bool isWatched;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: isWatched
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.check),
              label: const Text('Vu'),
            )
          : FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.check),
              label: const Text('Marquer comme vu'),
            ),
    );
  }
}
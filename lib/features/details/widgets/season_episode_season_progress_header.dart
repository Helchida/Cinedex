import 'package:flutter/material.dart';

class SeasonProgressHeader extends StatelessWidget {
  const SeasonProgressHeader({
    super.key,
    required this.watchedCount,
    required this.totalCount,
    required this.allWatched,
    required this.onToggle,
  });

  final int watchedCount;
  final int totalCount;
  final bool allWatched;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final progress = totalCount == 0
        ? 0.0
        : watchedCount / totalCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$watchedCount / $totalCount épisodes vus',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius:
                  BorderRadius.circular(10),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: allWatched
                  ? OutlinedButton.icon(
                      onPressed: onToggle,
                      icon: const Icon(
                        Icons.remove_done,
                      ),
                      label: const Text(
                        'Tout marquer comme non vu',
                      ),
                    )
                  : FilledButton.icon(
                      onPressed: onToggle,
                      icon: const Icon(
                        Icons.done_all,
                      ),
                      label: const Text(
                        'Marquer toute la saison comme vue',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
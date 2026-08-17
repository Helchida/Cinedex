import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../series/models/tv_show.dart';
import 'tv_show_details_continue_watching_button.dart';

class ProgressSection extends ConsumerWidget {
  const ProgressSection({
    super.key,
    required this.tvShow,
    required this.watchedEpisodes,
    required this.totalEpisodes,
    required this.progress,
  });

  final TvShow tvShow;
  final int watchedEpisodes;
  final int totalEpisodes;
  final double progress;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    if (totalEpisodes == 0) {
      return const SizedBox.shrink();
    }

    final percentage = (progress * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Progression',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Text(
                  '$percentage %',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium,
                ),
              ],
            ),

            const SizedBox(height: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              '$watchedEpisodes / $totalEpisodes épisodes vus',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),

            const SizedBox(height: 16),

            if (watchedEpisodes == totalEpisodes)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.check),
                  label: const Text(
                    'Série terminée',
                  ),
                ),
              )
            else
              ContinueWatchingButton(
                tvShow: tvShow,
              ),
          ],
        ),
      ),
    );
  }
}
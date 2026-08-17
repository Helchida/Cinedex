import 'package:flutter/material.dart';
import 'profile_info_row.dart';

class SeriesFallbackCard extends StatelessWidget {
  const SeriesFallbackCard({
    super.key,
    required this.seriesCount,
    required this.watchedEpisodes,
  });

  final int seriesCount;
  final int watchedEpisodes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          InfoRow(
            icon: Icons.tv_outlined,
            title: 'Séries suivies',
            value: '$seriesCount',
          ),
          const SizedBox(height: 20),
          InfoRow(
            icon: Icons.play_circle_outline,
            title: 'Épisodes vus',
            value: '$watchedEpisodes',
          ),
        ],
      ),
    );
  }
}
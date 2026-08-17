import 'package:flutter/material.dart';
import '../../series/models/episode.dart';

class EpisodeMetadata extends StatelessWidget {
  const EpisodeMetadata({
    super.key,
    required this.episode,
  });

  final Episode episode;

  @override
  Widget build(BuildContext context) {
    final metadata = <String>[];

    if (episode.airDate != null) {
      metadata.add(
        '${episode.airDate!.day.toString().padLeft(2, '0')}/'
        '${episode.airDate!.month.toString().padLeft(2, '0')}/'
        '${episode.airDate!.year}',
      );
    }

    if (episode.runtime != null) {
      metadata.add('${episode.runtime} min');
    }

    if (episode.voteAverage != null &&
        episode.voteAverage! > 0) {
      metadata.add(
        '★ ${episode.voteAverage!.toStringAsFixed(1)}',
      );
    }

    if (metadata.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      metadata.join(' · '),
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
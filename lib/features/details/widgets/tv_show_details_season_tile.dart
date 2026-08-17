import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../series/models/season.dart';
import '../pages/season_episodes_page.dart';
import '../../watchlist/providers/watch_progress_provider.dart';
import 'tv_show_details_season_poster.dart';

class SeasonTile extends ConsumerWidget {
  const SeasonTile({
    super.key,
    required this.tvShowId,
    required this.season,
  });

  final int tvShowId;
  final Season season;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final watchedEpisodes = ref.watch(
      watchProgressProvider.select(
        (state) => state.episodes.values
            .where(
              (episode) =>
                  episode.tvShowId == tvShowId &&
                  episode.seasonNumber ==
                      season.seasonNumber,
            )
            .length,
      ),
    );

    final totalEpisodes =
        season.episodeCount ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: SeasonPoster(
          path: season.posterPath,
        ),
        title: Text(
          season.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          [
            if (totalEpisodes > 0)
              '$watchedEpisodes / $totalEpisodes épisodes vus',
            if (season.airDate != null)
              season.airDate!.year.toString(),
          ].join(' · '),
        ),
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SeasonEpisodesPage(
                tvShowId: tvShowId,
                seasonNumber: season.seasonNumber,
                seasonName: season.name,
              ),
            ),
          );
        },
      ),
    );
  }
}
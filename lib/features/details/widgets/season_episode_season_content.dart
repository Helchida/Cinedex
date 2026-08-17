import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../series/models/episode.dart';
import '../../watchlist/providers/watch_progress_provider.dart';
import 'season_episode_card.dart';
import 'season_episode_season_progress_header.dart';
import '../../watchlist/models/episode_progress.dart';
import '../../watchlist/models/episode_watch_status.dart';

class SeasonContent extends ConsumerWidget {
  const SeasonContent({
    super.key,
    required this.episodes,
    required this.tvShowId,
    required this.seasonNumber,
    required this.tvShowName,
    required this.posterPath,
  });

  final List<Episode> episodes;
  final int tvShowId;
  final int seasonNumber;
  final String tvShowName;
  final String? posterPath;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final watchedCount = ref.watch(
      watchProgressProvider.select(
        (state) {
          return state.episodes.values
              .where(
                (progress) =>
                    progress.tvShowId == tvShowId &&
                    progress.seasonNumber == seasonNumber,
              )
              .length;
        },
      ),
    );

    final totalCount = episodes.length;

    final allWatched =
        watchedCount == totalCount;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SeasonProgressHeader(
          watchedCount: watchedCount,
          totalCount: totalCount,
          allWatched: allWatched,
          onToggle: () {
            final episodeProgress =
                episodes.map(
              (episode) {
                return EpisodeProgress(
                  episodeId: episode.id,
                  tvShowId: tvShowId,
                  seasonNumber: seasonNumber,
                  episodeNumber: episode.episodeNumber,
                  status: EpisodeWatchStatus.watched,
                );
              },
            ).toList();

            ref
                .read(watchProgressProvider.notifier)
                .setSeasonWatched(
                  tvShowId: tvShowId,
                  seasonNumber: seasonNumber,
                  episodes: episodeProgress,
                  watched: !allWatched,
                  tvShowName: tvShowName,
                  posterPath: posterPath,
                );
          },
        ),
        const SizedBox(height: 20),
        ...episodes.map(
          (episode) => Padding(
            padding: const EdgeInsets.only(
              bottom: 16,
            ),
            child: EpisodeCard(
              episode: episode,
              tvShowId: tvShowId,
              tvShowName: tvShowName,
              posterPath: posterPath,
            ),
          ),
        ),
      ],
    );
  }
}
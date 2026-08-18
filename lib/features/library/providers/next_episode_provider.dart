import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../details/providers/media_details_provider.dart';
import '../../watchlist/providers/watch_progress_provider.dart';

class NextEpisode {
  const NextEpisode({
    required this.tvShowId,
    required this.seasonNumber,
    required this.seasonName,
    required this.episode,
  });

  final int tvShowId;
  final int seasonNumber;
  final String seasonName;
  final dynamic episode;
}

final nextEpisodeProvider =
    FutureProvider.family<NextEpisode?, int>(
  (ref, tvShowId) async {
    final watchState = ref.watch(
      watchProgressProvider,
    );

    if (watchState.isLoading) {
      return null;
    }

    final startSeason = await ref.read(
      tvShowStartSeasonProvider(tvShowId).future,
    );

    final seasons = await ref.read(
      tvShowSeasonsProvider(tvShowId).future,
    );

    final regularSeasons = seasons
        .where(
          (season) =>
              season.seasonNumber > 0 &&
              season.seasonNumber >= startSeason,
        )
        .toList()
      ..sort(
        (a, b) =>
            a.seasonNumber.compareTo(
          b.seasonNumber,
        ),
      );

    for (final season in regularSeasons) {
      final episodes = await ref.read(
        seasonEpisodesProvider(
          (
            tvShowId: tvShowId,
            seasonNumber: season.seasonNumber,
          ),
        ).future,
      );

      final sortedEpisodes = [...episodes]
        ..sort(
          (a, b) =>
              a.episodeNumber.compareTo(
            b.episodeNumber,
          ),
        );

      for (final episode in sortedEpisodes) {
        final watched =
            watchState.episodes.containsKey(
          episode.id,
        );

        if (!watched) {
          return NextEpisode(
            tvShowId: tvShowId,
            seasonNumber: season.seasonNumber,
            seasonName: season.name,
            episode: episode,
          );
        }
      }
    }

    return null;
  },
);
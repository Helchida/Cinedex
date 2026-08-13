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
    final watchState = ref.watch(watchProgressProvider);

    // Récupération des saisons depuis TMDB
    final seasons = await ref.read(
      tvShowSeasonsProvider(tvShowId).future,
    );

    final regularSeasons = seasons
        .where(
          (season) => season.seasonNumber > 0,
        )
        .toList()
      ..sort(
        (a, b) =>
            a.seasonNumber.compareTo(b.seasonNumber),
      );

    // On parcourt les saisons dans l'ordre
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

      // Premier épisode non vu
      for (final episode in sortedEpisodes) {
        if (!watchState.episodes.containsKey(
          episode.id,
        )) {
          return NextEpisode(
            tvShowId: tvShowId,
            seasonNumber: season.seasonNumber,
            seasonName: season.name,
            episode: episode,
          );
        }
      }
    }

    // Tous les épisodes sont vus
    return null;
  },
);
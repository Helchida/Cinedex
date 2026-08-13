import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../details/providers/media_details_provider.dart';
import '../../series/models/episode.dart';
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
  final Episode episode;
}

final nextEpisodeProvider =
    FutureProvider.family<NextEpisode?, int>(
  (ref, tvShowId) async {
    final watchState = ref.watch(
      watchProgressProvider,
    );

    // Récupération des saisons de la série.
    final seasons = await ref.watch(
      tvShowSeasonsProvider(tvShowId).future,
    );

    // On ignore la saison 0 (épisodes spéciaux).
    final sortedSeasons = seasons
        .where(
          (season) => season.seasonNumber > 0,
        )
        .toList()
      ..sort(
        (a, b) => a.seasonNumber.compareTo(
          b.seasonNumber,
        ),
      );

    // On parcourt les saisons dans l'ordre.
    for (final season in sortedSeasons) {
      final episodes = await ref.watch(
        seasonEpisodesProvider(
          (
            tvShowId: tvShowId,
            seasonNumber: season.seasonNumber,
          ),
        ).future,
      );

      // Les épisodes doivent également être dans l'ordre.
      final sortedEpisodes = [...episodes]
        ..sort(
          (a, b) => a.episodeNumber.compareTo(
            b.episodeNumber,
          ),
        );

      // On cherche le premier épisode non vu.
      for (final episode in sortedEpisodes) {
        final isWatched =
            watchState.episodes.containsKey(episode.id);

        if (!isWatched) {
          return NextEpisode(
            tvShowId: tvShowId,
            seasonNumber: season.seasonNumber,
            seasonName: season.name,
            episode: episode,
          );
        }
      }
    }

    // Tous les épisodes sont vus.
    return null;
  },
);
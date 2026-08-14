import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../movies/models/movie.dart';
import '../../series/models/tv_show.dart';
import '../../series/models/season.dart';
import '../../series/models/episode.dart';
import '../../watchlist/providers/watch_progress_provider.dart';

final movieDetailsProvider =
    FutureProvider.family<Movie, int>((ref, movieId) async {
  final api = ref.read(tmdbApiProvider);

  return api.getMovie(movieId);
});

final tvShowDetailsProvider =
    FutureProvider.family<TvShow, int>((ref, tvShowId) async {
  final api = ref.read(tmdbApiProvider);

  return api.getTvShow(tvShowId);
});

final tvShowSeasonsProvider =
    FutureProvider.family<List<Season>, int>((ref, tvShowId) async {
  final api = ref.read(tmdbApiProvider);

  return api.getTvShowSeasons(tvShowId);
});

final seasonEpisodesProvider = FutureProvider.family<
    List<Episode>,
    ({int tvShowId, int seasonNumber})>((ref, params) async {
  final api = ref.read(tmdbApiProvider);

  return api.getSeasonEpisodes(
    params.tvShowId,
    params.seasonNumber,
  );
});

final tvShowWatchStatusProvider =
    FutureProvider.family<bool, int>(
  (ref, tvShowId) async {
    final watchState = ref.watch(watchProgressProvider);

    final seasons = await ref.read(
      tvShowSeasonsProvider(tvShowId).future,
    );

    final regularSeasons = seasons.where(
      (season) => season.seasonNumber > 0,
    );

    bool hasEpisodes = false;

    for (final season in regularSeasons) {
      final episodes = await ref.read(
        seasonEpisodesProvider(
          (
            tvShowId: tvShowId,
            seasonNumber: season.seasonNumber,
          ),
        ).future,
      );

      for (final episode in episodes) {
        hasEpisodes = true;

        if (!watchState.episodes.containsKey(episode.id)) {
          return false;
        }
      }
    }

    return hasEpisodes;
  },
);

final tvShowAllEpisodesWatchedProvider =
    FutureProvider.family<bool, int>(
  (ref, tvShowId) async {
    final watchState = ref.watch(
      watchProgressProvider,
    );

    final seasons = await ref.read(
      tvShowSeasonsProvider(tvShowId).future,
    );

    final regularSeasons = seasons.where(
      (season) => season.seasonNumber > 0,
    );

    bool hasEpisodes = false;

    for (final season in regularSeasons) {
      final episodes = await ref.read(
        seasonEpisodesProvider(
          (
            tvShowId: tvShowId,
            seasonNumber: season.seasonNumber,
          ),
        ).future,
      );

      for (final episode in episodes) {
        hasEpisodes = true;

        if (!watchState.episodes.containsKey(
          episode.id,
        )) {
          return false;
        }
      }
    }

    return hasEpisodes;
  },
);
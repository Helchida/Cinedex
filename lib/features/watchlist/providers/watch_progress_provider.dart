import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/episode_progress.dart';
import '../models/episode_watch_status.dart';
import '../models/media_watch_status.dart';
import '../models/movie_progress.dart';
import '../../library/models/followed_series.dart';
import '../../library/providers/followed_series_provider.dart';

class WatchProgressState {
  const WatchProgressState({
    this.episodes = const {},
    this.movies = const {},
  });

  final Map<int, EpisodeProgress> episodes;
  final Map<int, MovieProgress> movies;

  WatchProgressState copyWith({
    Map<int, EpisodeProgress>? episodes,
    Map<int, MovieProgress>? movies,
  }) {
    return WatchProgressState(
      episodes: episodes ?? this.episodes,
      movies: movies ?? this.movies,
    );
  }
}

class WatchProgressNotifier
    extends Notifier<WatchProgressState> {
  @override
  WatchProgressState build() {
    return const WatchProgressState();
  }

  // ============================================================
  // ÉPISODES
  // ============================================================

  bool isEpisodeWatched(int episodeId) {
    return state.episodes[episodeId]?.status ==
        EpisodeWatchStatus.watched;
  }

void toggleEpisode({
  required int episodeId,
  required int tvShowId,
  required int seasonNumber,
  required int episodeNumber,
  required String tvShowName,
  String? posterPath,
}) {
  final episodes =
      Map<int, EpisodeProgress>.from(state.episodes);

  if (isEpisodeWatched(episodeId)) {
    episodes.remove(episodeId);
  } else {
    episodes[episodeId] = EpisodeProgress(
      episodeId: episodeId,
      tvShowId: tvShowId,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      status: EpisodeWatchStatus.watched,
    );

    // Ajoute automatiquement la série à la bibliothèque.
    ref.read(followedSeriesProvider.notifier).add(
      FollowedSeries(
        id: tvShowId,
        name: tvShowName,
        posterPath: posterPath,
      ),
    );
  }

  state = state.copyWith(
    episodes: episodes,
  );
}

  int watchedEpisodesCount(
    List<int> episodeIds,
  ) {
    return episodeIds
        .where(isEpisodeWatched)
        .length;
  }

  int watchedEpisodesCountForShow(int tvShowId) {
  return state.episodes.values
      .where(
        (episode) => episode.tvShowId == tvShowId,
      )
      .length;
}

int totalEpisodesCountForShow({
  required int tvShowId,
  required int totalEpisodes,
}) {
  return totalEpisodes;
}

EpisodeProgress? nextUnwatchedEpisode({
  required int tvShowId,
  required List<EpisodeProgress> episodes,
}) {
  final unwatched = episodes.where(
    (episode) =>
        episode.tvShowId == tvShowId &&
        !isEpisodeWatched(episode.episodeId),
  );

  if (unwatched.isEmpty) {
    return null;
  }

  final sorted = unwatched.toList()
    ..sort(
      (a, b) {
        final seasonComparison =
            a.seasonNumber.compareTo(b.seasonNumber);

        if (seasonComparison != 0) {
          return seasonComparison;
        }

        return a.episodeNumber.compareTo(
          b.episodeNumber,
        );
      },
    );

  return sorted.first;
}

  void setSeasonWatched({
    required int tvShowId,
    required int seasonNumber,
    required List<EpisodeProgress> episodes,
    required bool watched,
    required String tvShowName,
    String? posterPath,
  }) {
    final updated =
        Map<int, EpisodeProgress>.from(state.episodes);

    for (final episode in episodes) {
      if (watched) {
        updated[episode.episodeId] = episode;
      } else {
        updated.remove(episode.episodeId);
      }
    }

    if (watched) {
      ref.read(followedSeriesProvider.notifier).add(
        FollowedSeries(
          id: tvShowId,
          name: tvShowName,
          posterPath: posterPath,
        ),
      );
    }

    state = state.copyWith(
      episodes: updated,
    );
  }

  // ============================================================
  // FILMS
  // ============================================================

  bool isMovieWatched(int movieId) {
    return state.movies[movieId]?.status ==
        MediaWatchStatus.watched;
  }

  void toggleMovie(int movieId) {
    final movies =
        Map<int, MovieProgress>.from(state.movies);

    if (isMovieWatched(movieId)) {
      movies.remove(movieId);
    } else {
      movies[movieId] = MovieProgress(
        movieId: movieId,
        status: MediaWatchStatus.watched,
      );
    }

    state = state.copyWith(
      movies: movies,
    );
  }
}

final watchProgressProvider =
    NotifierProvider<
        WatchProgressNotifier,
        WatchProgressState>(
  WatchProgressNotifier.new,
);
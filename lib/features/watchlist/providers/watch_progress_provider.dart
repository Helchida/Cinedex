import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/episode_progress.dart';
import '../models/episode_watch_status.dart';
import '../models/media_watch_status.dart';
import '../models/movie_progress.dart';
import '../repositories/watch_progress_repository.dart';
import '../../library/providers/library_provider.dart';
import 'watch_progress_repository_provider.dart';
import '../../library/repositories/library_repository.dart';
import '../../library/providers/library_repository_provider.dart';

class WatchProgressState {
  const WatchProgressState({
    this.episodes = const {},
    this.movies = const {},
    this.isLoading = false,
  });

  final Map<int, EpisodeProgress> episodes;
  final Map<int, MovieProgress> movies;
  final bool isLoading;

  WatchProgressState copyWith({
    Map<int, EpisodeProgress>? episodes,
    Map<int, MovieProgress>? movies,
    bool? isLoading,
  }) {
    return WatchProgressState(
      episodes: episodes ?? this.episodes,
      movies: movies ?? this.movies,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WatchProgressNotifier
    extends Notifier<WatchProgressState> {
  late final WatchProgressRepository _repository;
  late final LibraryRepository _libraryRepository;

  @override
  WatchProgressState build() {
    _repository = ref.read(
      watchProgressRepositoryProvider,
    );

    _libraryRepository = ref.read(
      libraryRepositoryProvider,
    );

    Future.microtask(_load);

    return const WatchProgressState(
      isLoading: true,
    );
  }

  // CHARGEMENT
  Future<void> _load() async {
    try {
      final watchedEpisodes =
          await _repository.getWatchedEpisodes();

      final watchedMovies =
          await _repository.getWatchedMovies();

      state = state.copyWith(
        episodes: {
          for (final episode in watchedEpisodes)
            episode.episodeId: episode,
        },
        movies: {
          for (final movie in watchedMovies)
            movie.movieId: movie,
        },
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
      );
    }
  }

  // EPISODES
  bool isEpisodeWatched(int episodeId) {
    return state.episodes[episodeId]?.status ==
        EpisodeWatchStatus.watched;
  }

  Future<void> toggleEpisode({
    required int episodeId,
    required int tvShowId,
    required int seasonNumber,
    required int episodeNumber,
    required String tvShowName,
    String? posterPath,
  }) async {
    final watched = isEpisodeWatched(episodeId);

    if (watched) {
      await _repository.unmarkEpisodeWatched(
        episodeId: episodeId,
      );

      final episodes =
          Map<int, EpisodeProgress>.from(
        state.episodes,
      );

      episodes.remove(episodeId);

      state = state.copyWith(
        episodes: episodes,
      );

      return;
    }

    await _repository.markEpisodeWatched(
      tvShowId: tvShowId,
      episodeId: episodeId,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      tvShowName: tvShowName,
      posterPath: posterPath,
    );

    ref.invalidate(librarySeriesProvider);

    final episodes =
        Map<int, EpisodeProgress>.from(
      state.episodes,
    );

    episodes[episodeId] = EpisodeProgress(
      episodeId: episodeId,
      tvShowId: tvShowId,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      status: EpisodeWatchStatus.watched,
    );

    state = state.copyWith(
      episodes: episodes,
    );
  }

  // SAISON
  Future<void> setSeasonWatched({
    required int tvShowId,
    required int seasonNumber,
    required List<EpisodeProgress> episodes,
    required bool watched,
    required String tvShowName,
    String? posterPath,
  }) async {
    for (final episode in episodes) {
      final currentlyWatched =
          isEpisodeWatched(
        episode.episodeId,
      );

      if (watched && !currentlyWatched) {
        await _repository.markEpisodeWatched(
          tvShowId: tvShowId,
          episodeId: episode.episodeId,
          seasonNumber: episode.seasonNumber,
          episodeNumber: episode.episodeNumber,
          tvShowName: tvShowName,
          posterPath: posterPath,
        );
      }

      if (!watched && currentlyWatched) {
        await _repository.unmarkEpisodeWatched(
          episodeId: episode.episodeId,
        );
      }
    }

    final updated =
        Map<int, EpisodeProgress>.from(
      state.episodes,
    );

    for (final episode in episodes) {
      if (watched) {
        updated[episode.episodeId] =
            EpisodeProgress(
          episodeId: episode.episodeId,
          tvShowId: tvShowId,
          seasonNumber: episode.seasonNumber,
          episodeNumber: episode.episodeNumber,
          status: EpisodeWatchStatus.watched,
        );
      } else {
        updated.remove(episode.episodeId);
      }
    }

    state = state.copyWith(
      episodes: updated,
    );
  }

  // FILMS
  bool isMovieWatched(int tmdbMovieId) {
    return state.movies[tmdbMovieId]?.status ==
        MediaWatchStatus.watched;
  }

  Future<void> toggleMovie({
    required int tmdbMovieId,
    required String title,
    String? posterPath,
    DateTime? releaseDate,
  }) async {
    final watched =
        isMovieWatched(tmdbMovieId);

    if (watched) {
      await _repository.unmarkMovieWatched(
        tmdbMovieId: tmdbMovieId,
      );

      final movies =
          Map<int, MovieProgress>.from(
        state.movies,
      );

      movies.remove(tmdbMovieId);

      state = state.copyWith(
        movies: movies,
      );

      return;
    }

    await _repository.markMovieWatched(
      tmdbMovieId: tmdbMovieId,
      title: title,
      posterPath: posterPath,
      releaseDate: releaseDate,
    );

    final movies =
        Map<int, MovieProgress>.from(
      state.movies,
    );

    movies[tmdbMovieId] = MovieProgress(
      movieId: tmdbMovieId,
      status: MediaWatchStatus.watched,
    );

    state = state.copyWith(
      movies: movies,
    );
  }

// SERIES
Future<bool> isSeriesInLibrary(int tvShowId) async {
  return _libraryRepository.containsSeries(
    tmdbId: tvShowId,
  );
}

Future<void> addSeriesToLibrary({
  required int tvShowId,
  required String name,
  String? posterPath,
}) async {
  await _libraryRepository.addSeries(
    tmdbId: tvShowId,
    name: name,
    posterPath: posterPath,
  );

  ref.invalidate(librarySeriesProvider);
}

Future<void> removeSeriesFromLibrary({
  required int tvShowId,
}) async {
  await _libraryRepository.removeSeries(
    tmdbId: tvShowId,
  );

  ref.invalidate(librarySeriesProvider);
}
}

final watchProgressProvider =
    NotifierProvider<
        WatchProgressNotifier,
        WatchProgressState>(
  WatchProgressNotifier.new,
);
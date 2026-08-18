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
import '../../details/providers/media_details_provider.dart';
import '../../search/providers/explorer_provider.dart';

class WatchProgressState {
  const WatchProgressState({
    this.episodes = const {},
    this.movies = const {},
    this.movieWatchlist = const {},
    this.watchlistMovies = const [],
    this.isLoading = false,
  });

  final Map<int, EpisodeProgress> episodes;
  final Map<int, MovieProgress> movies;
  final Set<int> movieWatchlist;
  final List<Map<String, dynamic>> watchlistMovies;
  final bool isLoading;

  WatchProgressState copyWith({
    Map<int, EpisodeProgress>? episodes,
    Map<int, MovieProgress>? movies,
    Set<int>? movieWatchlist,
    List<Map<String, dynamic>>? watchlistMovies,
    bool? isLoading,
  }) {
    return WatchProgressState(
      episodes: episodes ?? this.episodes,
      movies: movies ?? this.movies,
      movieWatchlist:
        movieWatchlist ?? this.movieWatchlist,
      watchlistMovies:
        watchlistMovies ?? this.watchlistMovies,
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

      final watchlistMovies =
        await _repository.getWatchlistMovies();

      final watchlistMoviesDetails =
        await _repository.getWatchlistMoviesDetails();

      state = state.copyWith(
        episodes: {
          for (final episode in watchedEpisodes)
            episode.episodeId: episode,
        },
        movies: {
          for (final movie in watchedMovies)
            movie.movieId: movie,
        },
        movieWatchlist: watchlistMovies.toSet(),
        watchlistMovies:
          watchlistMoviesDetails,
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

  Future<void> toggleTvShowWatched({
    required int tvShowId,
    required String tvShowName,
    String? posterPath,
  }) async {
    final startSeason =
        await _libraryRepository.getSeriesStartSeason(
      tmdbId: tvShowId,
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

    final allEpisodes = <EpisodeProgress>[];

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
        allEpisodes.add(
          EpisodeProgress(
            episodeId: episode.id,
            tvShowId: tvShowId,
            seasonNumber: season.seasonNumber,
            episodeNumber: episode.episodeNumber,
            status: EpisodeWatchStatus.watched,
          ),
        );
      }
    }

    if (allEpisodes.isEmpty) {
      return;
    }

    final allWatched = allEpisodes.every(
      (episode) =>
          state.episodes.containsKey(
        episode.episodeId,
      ),
    );

    if (allWatched) {
      final episodeIds = allEpisodes
          .map(
            (episode) => episode.episodeId,
          )
          .toList();

      await _repository.unmarkEpisodesWatched(
        episodeIds: episodeIds,
      );

      final updated =
          Map<int, EpisodeProgress>.from(
        state.episodes,
      );

      for (final episodeId in episodeIds) {
        updated.remove(episodeId);
      }

      state = state.copyWith(
        episodes: updated,
      );

      ref.invalidate(
        librarySeriesProvider,
      );

      return;
    }

    final episodesToMark = allEpisodes.where(
      (episode) =>
          !state.episodes.containsKey(
        episode.episodeId,
      ),
    ).toList();

    await _repository.markEpisodesWatched(
      tvShowId: tvShowId,
      tvShowName: tvShowName,
      posterPath: posterPath,
      episodes: episodesToMark,
    );

    final updated =
        Map<int, EpisodeProgress>.from(
      state.episodes,
    );

    for (final episode in allEpisodes) {
      updated[episode.episodeId] = episode;
    }

    state = state.copyWith(
      episodes: updated,
    );

    ref.invalidate(
      librarySeriesProvider,
    );
  }

  // FILMS
  bool isMovieWatched(int tmdbMovieId) {
    return state.movies[tmdbMovieId]?.status ==
        MediaWatchStatus.watched;
  }

  bool isMovieInWatchlist(int tmdbMovieId) {
    return state.movieWatchlist.contains(
      tmdbMovieId,
    );
  }

  Future<void> toggleMovieWatchlist({
    required int tmdbMovieId,
    required String title,
    String? posterPath,
    DateTime? releaseDate,
  }) async {
    final inWatchlist =
        isMovieInWatchlist(tmdbMovieId);

    if (inWatchlist) {
      await _repository.removeMovieFromWatchlist(
        tmdbMovieId: tmdbMovieId,
      );

      final updatedWatchlist =
          Set<int>.from(state.movieWatchlist);

      updatedWatchlist.remove(tmdbMovieId);

      final updatedMovies =
          Map<int, MovieProgress>.from(
        state.movies,
      );

      if (!isMovieWatched(tmdbMovieId)) {
        await _repository.unmarkMovieWatched(
          tmdbMovieId: tmdbMovieId,
        );

        await _repository.deleteMovieIfUnused(
          tmdbMovieId: tmdbMovieId,
        );

        updatedMovies.remove(tmdbMovieId);
      }

      final updatedWatchlistMovies =
          state.watchlistMovies
              .where(
                (movie) =>
                    movie['tmdb_id'] != tmdbMovieId,
              )
              .toList();

      state = state.copyWith(
        movieWatchlist: updatedWatchlist,
        watchlistMovies: updatedWatchlistMovies,
        movies: updatedMovies,
      );

      ref.invalidate(explorerProvider);

      return;
    }

    await _repository.addMovieToWatchlist(
      tmdbMovieId: tmdbMovieId,
      title: title,
      posterPath: posterPath,
      releaseDate: releaseDate,
    );

    final updatedWatchlist =
        Set<int>.from(state.movieWatchlist);

    updatedWatchlist.add(tmdbMovieId);

    final updatedWatchlistMovies =
        List<Map<String, dynamic>>.from(
      state.watchlistMovies,
    );

    updatedWatchlistMovies.add({
      'tmdb_id': tmdbMovieId,
      'title': title,
      'poster_path': posterPath,
      'release_date': releaseDate
          ?.toIso8601String()
          .split('T')
          .first,
    });

    state = state.copyWith(
      movieWatchlist: updatedWatchlist,
      watchlistMovies: updatedWatchlistMovies,
    );

    ref.invalidate(explorerProvider);
  }

Future<void> toggleMovie({
  required int tmdbMovieId,
  required String title,
  String? posterPath,
  DateTime? releaseDate,
}) async {
  final watched = isMovieWatched(tmdbMovieId);

  if (watched) {
    await _repository.unmarkMovieWatched(
      tmdbMovieId: tmdbMovieId,
    );

    ref.invalidate(libraryMoviesProvider);
    

    final movies =
        Map<int, MovieProgress>.from(
      state.movies,
    );

    movies.remove(tmdbMovieId);

    state = state.copyWith(
      movies: movies,
    );

    ref.invalidate(explorerProvider);

    return;
  }

  await _repository.markMovieWatched(
    tmdbMovieId: tmdbMovieId,
    title: title,
    posterPath: posterPath,
    releaseDate: releaseDate,
  );

  ref.invalidate(libraryMoviesProvider);

  if (isMovieInWatchlist(tmdbMovieId)) {
    await _repository.removeMovieFromWatchlist(
      tmdbMovieId: tmdbMovieId,
    );
  }

  final movies =
      Map<int, MovieProgress>.from(
    state.movies,
  );

  movies[tmdbMovieId] = MovieProgress(
    movieId: tmdbMovieId,
    status: MediaWatchStatus.watched,
  );

  final watchlist =
      Set<int>.from(state.movieWatchlist);

  watchlist.remove(tmdbMovieId);

  final watchlistMovies =
      state.watchlistMovies
          .where(
            (movie) =>
                movie['tmdb_id'] != tmdbMovieId,
          )
          .toList();

  state = state.copyWith(
    movies: movies,
    movieWatchlist: watchlist,
    watchlistMovies: watchlistMovies,
  );

  ref.invalidate(explorerProvider);
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
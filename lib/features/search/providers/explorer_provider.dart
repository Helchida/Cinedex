import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../models/explorer_content.dart';
import '../../watchlist/providers/watch_progress_repository_provider.dart';
import '../../watchlist/models/movie_progress.dart';
import '../../movies/models/movie.dart';
import '../../series/models/tv_show.dart';

final explorerProvider =
    FutureProvider<ExplorerContent>((ref) async {
  final api = ref.read(tmdbApiProvider);

  final watchProgressRepository =
      ref.read(watchProgressRepositoryProvider);

  final classicContent = await Future.wait([
    api.getPopularMovies(),
    api.getPopularTvShows(),
    api.getNowPlayingMovies(),
    api.getOnTheAirTvShows(),
  ]);

  final popularMovies = classicContent[0] as List<Movie>;
  final popularTvShows = classicContent[1] as List<TvShow>;
  final nowPlayingMovies = classicContent[2] as List<Movie>;
  final onTheAirTvShows = classicContent[3] as List<TvShow>;

  final userContent = await Future.wait([
    watchProgressRepository.getWatchedMovies(),
    watchProgressRepository.getWatchedTvShowIds(),
    watchProgressRepository.getWatchlistMovies(),
  ]);

  final watchedMovies =
      userContent[0] as List<MovieProgress>;

  final watchedTvShowIds =
      (userContent[1] as List<int>).toSet();

  final watchlistMovieIds =
      (userContent[2] as List<int>).toSet();

  final watchedMovieIds = watchedMovies
      .map((movie) => movie.movieId)
      .toSet();

  final movieRecommendationResults =
      await Future.wait(
    watchedMovies
        .take(5)
        .map(
          (movie) =>
              api.getRecommendedMovies(movie.movieId),
        ),
  );

  final recommendedMovies = movieRecommendationResults
      .expand((movies) => movies)
      .toList();

  final tvShowRecommendationResults =
      await Future.wait(
    watchedTvShowIds
        .take(5)
        .map(
          (tvShowId) =>
              api.getRecommendedTvShows(tvShowId),
        ),
  );

  final recommendedTvShows = tvShowRecommendationResults
      .expand((tvShows) => tvShows)
      .toList();

  final uniqueRecommendedMovies = {
    for (final movie in recommendedMovies)
      if (!watchedMovieIds.contains(movie.id) &&
          !watchlistMovieIds.contains(movie.id))
        movie.id: movie,
  }.values.toList();

  final uniqueRecommendedTvShows = {
    for (final tvShow in recommendedTvShows)
      if (!watchedTvShowIds.contains(tvShow.id))
        tvShow.id: tvShow,
  }.values.toList();

  return ExplorerContent(
    popularMovies: popularMovies,
    popularTvShows: popularTvShows,
    nowPlayingMovies: nowPlayingMovies,
    onTheAirTvShows: onTheAirTvShows,
    recommendedMovies:
        uniqueRecommendedMovies.take(10).toList(),
    recommendedTvShows:
        uniqueRecommendedTvShows.take(10).toList(),
  );
});
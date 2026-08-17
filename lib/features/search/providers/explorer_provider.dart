import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../models/explorer_content.dart';
import '../models/media_credits.dart';
import '../services/recommendation_service.dart';

import '../../watchlist/providers/watch_progress_repository_provider.dart';
import '../../watchlist/providers/watch_progress_provider.dart';
import '../../watchlist/models/movie_progress.dart';

import '../../movies/models/movie.dart';
import '../../series/models/tv_show.dart';

final explorerProvider =
    FutureProvider<ExplorerContent>((ref) async {
  final api = ref.read(tmdbApiProvider);

  ref.watch(watchProgressProvider);

  final watchProgressRepository =
      ref.read(watchProgressRepositoryProvider);

  const recommendationService =
      RecommendationService();

  final classicContent = await Future.wait([
    api.getPopularMovies(),
    api.getPopularTvShows(),
    api.getNowPlayingMovies(),
    api.getOnTheAirTvShows(),
  ]);

  final popularMovies =
      classicContent[0] as List<Movie>;

  final popularTvShows =
      classicContent[1] as List<TvShow>;

  final nowPlayingMovies =
      classicContent[2] as List<Movie>;

  final onTheAirTvShows =
      classicContent[3] as List<TvShow>;

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

  final watchedMovieDetails =
      await Future.wait(
    watchedMovies.map(
      (movie) => api.getMovie(movie.movieId),
    ),
  );

  final watchedMovieAt = {
    for (final progress in watchedMovies)
      progress.movieId: progress.watchedAt,
  };

  final watchedMovieCreditsResults =
      await Future.wait(
    watchedMovieDetails.map(
      (movie) => api.getMovieCredits(movie.id),
    ),
  );

  final watchedMovieCredits =
      <int, MediaCredits>{
    for (var i = 0;
        i < watchedMovieDetails.length;
        i++)
      watchedMovieDetails[i].id:
          watchedMovieCreditsResults[i],
  };

  final movieProfile =
      recommendationService.buildMovieProfile(
    watchedMovies: watchedMovieDetails,
    credits: watchedMovieCredits,
    watchedAt: watchedMovieAt,
  );

  final movieSources =
      recommendationService
          .selectMovieRecommendationSources(
    watchedMovies: watchedMovieDetails,
    profile: movieProfile,
    watchedAt: watchedMovieAt,
    maxSources: 20,
  );

  final movieRecommendationResults =
      await Future.wait(
    movieSources.map(
      (movie) =>
          api.getRecommendedMovies(movie.id),
    ),
  );

  final recommendedMovieCandidates =
      movieRecommendationResults
          .expand((movies) => movies)
          .toList();

  final uniqueMovieCandidates = {
    for (final movie
        in recommendedMovieCandidates)
      if (!watchedMovieIds.contains(movie.id) &&
          !watchlistMovieIds.contains(movie.id))
        movie.id: movie,
  }.values.toList();

  final quickScoredMovies =
      uniqueMovieCandidates.map(
    (movie) {
      final score =
          recommendationService.quickMovieScore(
        movie: movie,
        profile: movieProfile,
      );

      return (
        movie: movie,
        score: score,
      );
    },
  ).toList();

  quickScoredMovies.sort(
    (a, b) =>
        b.score.compareTo(a.score),
  );

  final movieCandidatesForCredits =
      quickScoredMovies
          .take(40)
          .map((item) => item.movie)
          .toList();

  final candidateMovieCreditsResults =
      await Future.wait(
    movieCandidatesForCredits.map(
      (movie) =>
          api.getMovieCredits(movie.id),
    ),
  );

  final candidateMovieCredits =
      <int, MediaCredits>{
    for (var i = 0;
        i < movieCandidatesForCredits.length;
        i++)
      movieCandidatesForCredits[i].id:
          candidateMovieCreditsResults[i],
  };

  final scoredMovies =
      movieCandidatesForCredits.map(
    (movie) {
      final credits =
          candidateMovieCredits[movie.id];

      if (credits == null) {
        return (
          movie: movie,
          score: 0.0,
        );
      }

      final score =
          recommendationService.scoreMovie(
        movie: movie,
        credits: credits,
        profile: movieProfile,
      );

      return (
        movie: movie,
        score: score,
      );
    },
  ).toList();

  scoredMovies.sort(
    (a, b) =>
        b.score.compareTo(a.score),
  );

  final uniqueRecommendedMovies =
      scoredMovies
          .map((item) => item.movie)
          .take(10)
          .toList();

  final watchedTvShowAt =
      await watchProgressRepository
          .getWatchedTvShowsWatchedAt();

  final watchedTvShows =
      await Future.wait(
    watchedTvShowIds.map(
      (tvShowId) =>
          api.getTvShow(tvShowId),
    ),
  );

  final watchedTvShowCreditsResults =
      await Future.wait(
    watchedTvShows.map(
      (tvShow) =>
          api.getTvShowCredits(tvShow.id),
    ),
  );

  final watchedTvShowCredits =
      <int, MediaCredits>{
    for (var i = 0;
        i < watchedTvShows.length;
        i++)
      watchedTvShows[i].id:
          watchedTvShowCreditsResults[i],
  };

  final tvShowProfile =
      recommendationService.buildTvShowProfile(
    watchedTvShows: watchedTvShows,
    credits: watchedTvShowCredits,
    watchedAt: watchedTvShowAt,
  );

  final tvShowSources =
      recommendationService
          .selectTvShowRecommendationSources(
    watchedTvShows: watchedTvShows,
    profile: tvShowProfile,
    watchedAt: watchedTvShowAt,
    maxSources: 20,
  );

  final tvShowRecommendationResults =
      await Future.wait(
    tvShowSources.map(
      (tvShow) =>
          api.getRecommendedTvShows(tvShow.id),
    ),
  );

  final recommendedTvShowCandidates =
      tvShowRecommendationResults
          .expand((tvShows) => tvShows)
          .toList();

  final uniqueTvShowCandidates = {
    for (final tvShow
        in recommendedTvShowCandidates)
      if (!watchedTvShowIds.contains(tvShow.id))
        tvShow.id: tvShow,
  }.values.toList();

  final quickScoredTvShows =
      uniqueTvShowCandidates.map(
    (tvShow) {
      final score =
          recommendationService.quickTvShowScore(
        tvShow: tvShow,
        profile: tvShowProfile,
      );

      return (
        tvShow: tvShow,
        score: score,
      );
    },
  ).toList();

  quickScoredTvShows.sort(
    (a, b) =>
        b.score.compareTo(a.score),
  );

  final tvShowCandidatesForCredits =
      quickScoredTvShows
          .take(40)
          .map((item) => item.tvShow)
          .toList();

  final candidateTvShowCreditsResults =
      await Future.wait(
    tvShowCandidatesForCredits.map(
      (tvShow) =>
          api.getTvShowCredits(tvShow.id),
    ),
  );

  final candidateTvShowCredits =
      <int, MediaCredits>{
    for (var i = 0;
        i < tvShowCandidatesForCredits.length;
        i++)
      tvShowCandidatesForCredits[i].id:
          candidateTvShowCreditsResults[i],
  };

  final scoredTvShows =
      tvShowCandidatesForCredits.map(
    (tvShow) {
      final credits =
          candidateTvShowCredits[tvShow.id];

      if (credits == null) {
        return (
          tvShow: tvShow,
          score: 0.0,
        );
      }

      final score =
          recommendationService.scoreTvShow(
        tvShow: tvShow,
        credits: credits,
        profile: tvShowProfile,
      );

      return (
        tvShow: tvShow,
        score: score,
      );
    },
  ).toList();

  scoredTvShows.sort(
    (a, b) =>
        b.score.compareTo(a.score),
  );

  final uniqueRecommendedTvShows =
      scoredTvShows
          .map((item) => item.tvShow)
          .take(10)
          .toList();

  return ExplorerContent(
    popularMovies: popularMovies,
    popularTvShows: popularTvShows,
    nowPlayingMovies: nowPlayingMovies,
    onTheAirTvShows: onTheAirTvShows,
    recommendedMovies: uniqueRecommendedMovies,
    recommendedTvShows: uniqueRecommendedTvShows,
  );
});
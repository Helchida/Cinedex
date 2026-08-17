import 'dart:math';

import '../models/user_taste_profile.dart';
import '../models/media_credits.dart';
import '../../movies/models/movie.dart';
import '../../series/models/tv_show.dart';

class RecommendationService {
  const RecommendationService();

  UserTasteProfile buildMovieProfile({
    required List<Movie> watchedMovies,
    required Map<int, MediaCredits> credits,
    required Map<int, DateTime?> watchedAt,
  }) {
    final genres = <int, double>{};
    final directors = <int, double>{};
    final actors = <int, double>{};

    for (final movie in watchedMovies) {
      final movieCredits = credits[movie.id];

      if (movieCredits == null) {
        continue;
      }

      final weight = _recencyWeight(
        watchedAt[movie.id],
      );

      for (final genreId in movie.genreIds) {
        genres[genreId] =
            (genres[genreId] ?? 0) + weight;
      }

      for (final directorId in movieCredits.directorIds) {
        directors[directorId] =
            (directors[directorId] ?? 0) + weight;
      }

      for (final actorId in movieCredits.actorIds) {
        actors[actorId] =
            (actors[actorId] ?? 0) + weight;
      }
    }

    return UserTasteProfile(
      genres: genres,
      directors: directors,
      actors: actors,
    );
  }


  UserTasteProfile buildTvShowProfile({
    required List<TvShow> watchedTvShows,
    required Map<int, MediaCredits> credits,
    required Map<int, DateTime?> watchedAt,
  }) {
    final genres = <int, double>{};
    final creators = <int, double>{};
    final actors = <int, double>{};

    for (final tvShow in watchedTvShows) {
      final tvShowCredits = credits[tvShow.id];

      if (tvShowCredits == null) {
        continue;
      }

      final weight = _recencyWeight(
        watchedAt[tvShow.id],
      );

      for (final genreId in tvShow.genreIds) {
        genres[genreId] =
            (genres[genreId] ?? 0) + weight;
      }

      for (final creatorId in tvShowCredits.creatorIds) {
        creators[creatorId] =
            (creators[creatorId] ?? 0) + weight;
      }

      for (final actorId in tvShowCredits.actorIds) {
        actors[actorId] =
            (actors[actorId] ?? 0) + weight;
      }
    }

    return UserTasteProfile(
      genres: genres,
      directors: creators,
      actors: actors,
    );
  }

  List<Movie> selectMovieRecommendationSources({
    required List<Movie> watchedMovies,
    required UserTasteProfile profile,
    required Map<int, DateTime?> watchedAt,
    int maxSources = 20,
  }) {
    if (watchedMovies.length <= maxSources) {
      return watchedMovies;
    }

    final scored = watchedMovies.map((movie) {
      final genreScore = _calculateGenrePreference(
        movie.genreIds,
        profile.genres,
      );

      final recencyScore = _recencyWeight(
        watchedAt[movie.id],
      );

      return (
        movie: movie,
        score: genreScore * 0.7 + recencyScore * 0.3,
      );
    }).toList();

    scored.sort(
      (a, b) => b.score.compareTo(a.score),
    );

    final selected = <Movie>[];


    for (final item in scored) {
      if (selected.length >= maxSources) {
        break;
      }

      selected.add(item.movie);
    }

    return selected;
  }

  List<TvShow> selectTvShowRecommendationSources({
    required List<TvShow> watchedTvShows,
    required UserTasteProfile profile,
    required Map<int, DateTime?> watchedAt,
    int maxSources = 20,
  }) {
    if (watchedTvShows.length <= maxSources) {
      return watchedTvShows;
    }

    final scored = watchedTvShows.map((tvShow) {
      final genreScore = _calculateGenrePreference(
        tvShow.genreIds,
        profile.genres,
      );

      final recencyScore = _recencyWeight(
        watchedAt[tvShow.id],
      );

      return (
        tvShow: tvShow,
        score: genreScore * 0.7 + recencyScore * 0.3,
      );
    }).toList();

    scored.sort(
      (a, b) => b.score.compareTo(a.score),
    );

    final selected = <TvShow>[];

    for (final item in scored) {
      if (selected.length >= maxSources) {
        break;
      }

      selected.add(item.tvShow);
    }

    return selected;
  }

  double quickMovieScore({
    required Movie movie,
    required UserTasteProfile profile,
  }) {
    double score = 0;

    score +=
        _calculateGenrePreference(
              movie.genreIds,
              profile.genres,
            ) *
            0.7;

    score +=
        ((movie.voteAverage ?? 0) / 10)
                .clamp(0.0, 1.0) *
            0.2;


    final popularity =
        movie.popularity ?? 0;

    final popularityScore =
        popularity > 0
            ? (log(popularity + 1) / log(1000))
                .clamp(0.0, 1.0)
            : 0.0;

    score += popularityScore * 0.1;

    return score;
  }

  double quickTvShowScore({
    required TvShow tvShow,
    required UserTasteProfile profile,
  }) {
    double score = 0;


    score +=
        _calculateGenrePreference(
              tvShow.genreIds,
              profile.genres,
            ) *
            0.7;


    score +=
        ((tvShow.voteAverage ?? 0) / 10)
                .clamp(0.0, 1.0) *
            0.2;


    final popularity =
        tvShow.popularity ?? 0;

    final popularityScore =
        popularity > 0
            ? (log(popularity + 1) / log(1000))
                .clamp(0.0, 1.0)
            : 0.0;

    score += popularityScore * 0.1;

    return score;
  }

  double _recencyWeight(DateTime? watchedAt) {
    if (watchedAt == null) {
      return 1.0;
    }

    final difference =
        DateTime.now().difference(watchedAt);

    final days = difference.inDays;

    if (days < 30) {
      return 1.50;
    }

    if (days < 90) {
      return 1.30;
    }

    if (days < 180) {
      return 1.15;
    }

    if (days < 365) {
      return 1.05;
    }

    return 1.0;
  }

  double _calculateGenrePreference(
    List<int> genreIds,
    Map<int, double> preferences,
  ) {
    if (genreIds.isEmpty ||
        preferences.isEmpty) {
      return 0;
    }

    double score = 0;

    for (final genreId in genreIds) {
      score += preferences[genreId] ?? 0;
    }

    final maxPreference =
        preferences.values.reduce(
      (a, b) => a > b ? a : b,
    );

    if (maxPreference <= 0) {
      return 0;
    }

    return (score / maxPreference)
        .clamp(0.0, 1.0);
  }


  double scoreMovie({
    required Movie movie,
    required MediaCredits credits,
    required UserTasteProfile profile,
  }) {
    double score = 0;

    if (movie.genreIds.isNotEmpty &&
        profile.genres.isNotEmpty) {
      final genreScore =
          _calculateGenrePreference(
        movie.genreIds,
        profile.genres,
      );

      score += genreScore * 35;
    }

    if (credits.directorIds.isNotEmpty &&
        profile.directors.isNotEmpty) {
      double directorScore = 0;

      for (final directorId
          in credits.directorIds) {
        directorScore +=
            profile.directors[directorId] ?? 0;
      }

      final maxPreference =
          profile.directors.values.reduce(
        (a, b) => a > b ? a : b,
      );

      if (maxPreference > 0) {
        score +=
            (directorScore / maxPreference)
                .clamp(0.0, 1.0) *
            20;
      }
    }

    if (credits.actorIds.isNotEmpty &&
        profile.actors.isNotEmpty) {
      double actorScore = 0;

      for (final actorId
          in credits.actorIds) {
        actorScore +=
            profile.actors[actorId] ?? 0;
      }

      final maxPreference =
          profile.actors.values.reduce(
        (a, b) => a > b ? a : b,
      );

      if (maxPreference > 0) {
        score +=
            (actorScore / maxPreference)
                .clamp(0.0, 1.0) *
            15;
      }
    }

    score +=
        ((movie.voteAverage ?? 0) / 10)
                .clamp(0.0, 1.0) *
            10;

    final popularity =
        movie.popularity ?? 0;

    final popularityScore =
        popularity > 0
            ? (log(popularity + 1) / log(1000))
                .clamp(0.0, 1.0)
            : 0.0;

    score += popularityScore * 5;

    return score.clamp(0.0, 100.0);
  }

  double scoreTvShow({
    required TvShow tvShow,
    required MediaCredits credits,
    required UserTasteProfile profile,
  }) {
    double score = 0;

    if (tvShow.genreIds.isNotEmpty &&
        profile.genres.isNotEmpty) {
      final genreScore =
          _calculateGenrePreference(
        tvShow.genreIds,
        profile.genres,
      );

      score += genreScore * 35;
    }

    if (credits.creatorIds.isNotEmpty &&
        profile.directors.isNotEmpty) {
      double creatorScore = 0;

      for (final creatorId
          in credits.creatorIds) {
        creatorScore +=
            profile.directors[creatorId] ?? 0;
      }

      final maxPreference =
          profile.directors.values.reduce(
        (a, b) => a > b ? a : b,
      );

      if (maxPreference > 0) {
        score +=
            (creatorScore / maxPreference)
                .clamp(0.0, 1.0) *
            20;
      }
    }

    if (credits.actorIds.isNotEmpty &&
        profile.actors.isNotEmpty) {
      double actorScore = 0;

      for (final actorId
          in credits.actorIds) {
        actorScore +=
            profile.actors[actorId] ?? 0;
      }

      final maxPreference =
          profile.actors.values.reduce(
        (a, b) => a > b ? a : b,
      );

      if (maxPreference > 0) {
        score +=
            (actorScore / maxPreference)
                .clamp(0.0, 1.0) *
            15;
      }
    }

    score +=
        ((tvShow.voteAverage ?? 0) / 10)
                .clamp(0.0, 1.0) *
            10;

    final popularity =
        tvShow.popularity ?? 0;

    final popularityScore =
        popularity > 0
            ? (log(popularity + 1) / log(1000))
                .clamp(0.0, 1.0)
            : 0.0;

    score += popularityScore * 5;

    return score.clamp(0.0, 100.0);
  }
}
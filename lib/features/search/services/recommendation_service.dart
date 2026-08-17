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

      for (final directorId
          in movieCredits.directorIds) {
        directors[directorId] =
            (directors[directorId] ?? 0) + weight;
      }

      for (final actorId
          in movieCredits.actorIds) {
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

      for (final creatorId
          in tvShowCredits.creatorIds) {
        creators[creatorId] =
            (creators[creatorId] ?? 0) + weight;
      }

      for (final actorId
          in tvShowCredits.actorIds) {
        actors[actorId] =
            (actors[actorId] ?? 0) + weight;
      }
    }

    return UserTasteProfile(
      genres: genres,
      creators: creators,
      actors: actors,
    );
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


  double scoreMovie({
    required Movie movie,
    required MediaCredits credits,
    required UserTasteProfile profile,
  }) {
    double score = 0;

    if (movie.genreIds.isNotEmpty &&
        profile.genres.isNotEmpty) {
      double genreScore = 0;

      for (final genreId in movie.genreIds) {
        genreScore +=
            profile.genres[genreId] ?? 0;
      }

      final maxPreference =
          profile.genres.values.reduce(
        (a, b) => a > b ? a : b,
      );

      if (maxPreference > 0) {
        score +=
            (genreScore / maxPreference)
                .clamp(0.0, 1.0) *
            35;
      }
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

      for (final actorId in credits.actorIds) {
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
      double genreScore = 0;

      for (final genreId in tvShow.genreIds) {
        genreScore +=
            profile.genres[genreId] ?? 0;
      }

      final maxPreference =
          profile.genres.values.reduce(
        (a, b) => a > b ? a : b,
      );

      if (maxPreference > 0) {
        score +=
            (genreScore / maxPreference)
                .clamp(0.0, 1.0) *
            35;
      }
    }

    if (credits.creatorIds.isNotEmpty &&
      profile.creators.isNotEmpty) {

    double creatorScore = 0;

    for (final creatorId in credits.creatorIds) {
      creatorScore +=
          profile.creators[creatorId] ?? 0;
    }

    final maxPreference =
        profile.creators.values.reduce(
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

      for (final actorId in credits.actorIds) {
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
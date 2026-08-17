import '../../features/movies/models/movie.dart';
import '../../features/search/models/search_result.dart';
import '../../features/series/models/tv_show.dart';
import '../../features/series/models/season.dart';
import '../../features/series/models/episode.dart';
import '../../features/search/models/media_credits.dart';
import '../cache/tmdb_cache_service.dart';

import 'api_client.dart';

class TmdbApi {
  TmdbApi(
    this._client,
    this._cache,
  );

  final ApiClient _client;
  final TmdbCacheService _cache;

  Future<SearchResult> searchMulti(String query) async {
    final response = await _client.dio.get(
      '/search/multi',
      queryParameters: {
        'query': query,
        'language': 'fr-FR',
        'include_adult': false,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;

    final movies = <Movie>[];
    final tvShows = <TvShow>[];

    for (final item in results) {
      final json = item as Map<String, dynamic>;

      switch (json['media_type']) {
        case 'movie':
          movies.add(Movie.fromJson(json));
          break;

        case 'tv':
          tvShows.add(TvShow.fromJson(json));
          break;
      }
    }

    return SearchResult(
      movies: movies,
      tvShows: tvShows,
    );
  }

  Future<List<Movie>> getPopularMovies() async {
    final response = await _client.dio.get(
      '/movie/popular',
      queryParameters: {
        'language': 'fr-FR',
        'page': 1,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>? ?? [];

    return results
        .map(
          (item) => Movie.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<TvShow>> getPopularTvShows() async {
    final response = await _client.dio.get(
      '/tv/popular',
      queryParameters: {
        'language': 'fr-FR',
        'page': 1,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>? ?? [];

    return results
        .map(
          (item) => TvShow.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<Movie>> getNowPlayingMovies() async {
    final response = await _client.dio.get(
      '/movie/now_playing',
      queryParameters: {
        'language': 'fr-FR',
        'page': 1,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>? ?? [];

    return results
        .map(
          (item) => Movie.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<TvShow>> getOnTheAirTvShows() async {
    final response = await _client.dio.get(
      '/tv/on_the_air',
      queryParameters: {
        'language': 'fr-FR',
        'page': 1,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>? ?? [];

    return results
        .map(
          (item) => TvShow.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<Movie> getMovie(int movieId) async {
    final cacheKey = 'movie_details_$movieId';

    final cached = _cache.get(cacheKey);

    if (cached != null) {
      return Movie.fromJson(
        Map<String, dynamic>.from(cached),
      );
    }

    final response = await _client.dio.get(
      '/movie/$movieId',
      queryParameters: {
        'language': 'fr-FR',
      },
    );

    final data =
        response.data as Map<String, dynamic>;

    await _cache.save(
      key: cacheKey,
      data: data,
      duration: const Duration(days: 7),
    );

    return Movie.fromJson(data);
  }

  Future<TvShow> getTvShow(int tvShowId) async {
    final cacheKey = 'tv_details_$tvShowId';

    final cached = _cache.get(cacheKey);

    if (cached != null) {
      return TvShow.fromJson(
        Map<String, dynamic>.from(cached),
      );
    }

    final response = await _client.dio.get(
      '/tv/$tvShowId',
      queryParameters: {
        'language': 'fr-FR',
      },
    );

    final data =
        response.data as Map<String, dynamic>;

    await _cache.save(
      key: cacheKey,
      data: data,
      duration: const Duration(days: 7),
    );

    return TvShow.fromJson(data);
  }

  Future<List<Season>> getTvShowSeasons(int tvShowId) async {
    final response = await _client.dio.get(
      '/tv/$tvShowId',
      queryParameters: {
        'language': 'fr-FR',
      },
    );

    final data = response.data as Map<String, dynamic>;
    final seasons = data['seasons'] as List<dynamic>? ?? [];

    return seasons
        .map(
          (season) => Season.fromJson(
            season as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<Episode>> getSeasonEpisodes(
    int tvShowId,
    int seasonNumber,
  ) async {
    final response = await _client.dio.get(
      '/tv/$tvShowId/season/$seasonNumber',
      queryParameters: {
        'language': 'fr-FR',
      },
    );

    final data = response.data as Map<String, dynamic>;
    final episodes = data['episodes'] as List<dynamic>? ?? [];

    return episodes
        .map(
          (episode) => Episode.fromJson(
            episode as Map<String, dynamic>,
          ),
        )
        .toList();
  }

Future<List<Movie>> getRecommendedMovies(
  int movieId,
) async {
  final cacheKey =
      'movie_recommendations_$movieId';

  final cached = _cache.get(cacheKey);

  if (cached != null) {
    return (cached as List)
        .map(
          (item) => Movie.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  final response = await _client.dio.get(
    '/movie/$movieId/recommendations',
    queryParameters: {
      'language': 'fr-FR',
      'page': 1,
    },
  );

  final data =
      response.data as Map<String, dynamic>;

  final results =
      data['results'] as List<dynamic>? ?? [];

  await _cache.save(
    key: cacheKey,
    data: results,
    duration: const Duration(days: 1),
  );

  return results
      .map(
        (item) => Movie.fromJson(
          item as Map<String, dynamic>,
        ),
      )
      .toList();
}

Future<List<TvShow>> getRecommendedTvShows(
  int tvShowId,
) async {
  final cacheKey =
      'tv_recommendations_$tvShowId';

  final cached = _cache.get(cacheKey);

  if (cached != null) {
    return (cached as List)
        .map(
          (item) => TvShow.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  final response = await _client.dio.get(
    '/tv/$tvShowId/recommendations',
    queryParameters: {
      'language': 'fr-FR',
      'page': 1,
    },
  );

  final data =
      response.data as Map<String, dynamic>;

  final results =
      data['results'] as List<dynamic>? ?? [];

  await _cache.save(
    key: cacheKey,
    data: results,
    duration: const Duration(days: 1),
  );

  return results
      .map(
        (item) => TvShow.fromJson(
          item as Map<String, dynamic>,
        ),
      )
      .toList();
}

Future<MediaCredits> getMovieCredits(
  int movieId,
) async {
  final cacheKey = 'movie_credits_$movieId';

  final cached = _cache.get(cacheKey);

  if (cached != null) {
    final data =
        Map<String, dynamic>.from(cached);

    return MediaCredits(
      directorIds:
          List<int>.from(
        data['directorIds'] ?? [],
      ),
      actorIds:
          List<int>.from(
        data['actorIds'] ?? [],
      ),
    );
  }

  final response = await _client.dio.get(
    '/movie/$movieId/credits',
    queryParameters: {
      'language': 'fr-FR',
    },
  );

  final data =
      response.data as Map<String, dynamic>;

  final crew =
      data['crew'] as List<dynamic>? ?? [];

  final cast =
      data['cast'] as List<dynamic>? ?? [];

  final directorIds = crew
      .where(
        (person) =>
            person['job'] == 'Director',
      )
      .map(
        (person) => person['id'] as int,
      )
      .toList();

  final actorIds = cast
      .take(10)
      .map(
        (person) => person['id'] as int,
      )
      .toList();

  await _cache.save(
    key: cacheKey,
    data: {
      'directorIds': directorIds,
      'actorIds': actorIds,
    },
    duration: const Duration(days: 30),
  );

  return MediaCredits(
    directorIds: directorIds,
    actorIds: actorIds,
  );
}

  Future<MediaCredits> getTvShowCredits(
    int tvShowId,
  ) async {
    final cacheKey = 'tv_credits_$tvShowId';

    final cached = _cache.get(cacheKey);

    if (cached != null) {
      final data =
          Map<String, dynamic>.from(cached);

      return MediaCredits(
        creatorIds:
            List<int>.from(
          data['creatorIds'] ?? [],
        ),
        actorIds:
            List<int>.from(
          data['actorIds'] ?? [],
        ),
      );
    }

    final response = await _client.dio.get(
      '/tv/$tvShowId/credits',
      queryParameters: {
        'language': 'fr-FR',
      },
    );

    final data =
        response.data as Map<String, dynamic>;

    final crew =
        data['crew'] as List<dynamic>? ?? [];

    final cast =
        data['cast'] as List<dynamic>? ?? [];

    final creatorIds = crew
        .where(
          (person) =>
              person['job'] ==
                  'Executive Producer' ||
              person['department'] ==
                  'Writing',
        )
        .map(
          (person) => person['id'] as int,
        )
        .toList();

    final actorIds = cast
        .take(10)
        .map(
          (person) => person['id'] as int,
        )
        .toList();

    await _cache.save(
      key: cacheKey,
      data: {
        'creatorIds': creatorIds,
        'actorIds': actorIds,
      },
      duration: const Duration(days: 30),
    );

    return MediaCredits(
      creatorIds: creatorIds,
      actorIds: actorIds,
    );
  }
}
import '../../features/movies/models/movie.dart';
import '../../features/search/models/search_result.dart';
import '../../features/series/models/tv_show.dart';
import '../../features/series/models/season.dart';
import '../../features/series/models/episode.dart';

import 'api_client.dart';

class TmdbApi {
  TmdbApi(this._client);

  final ApiClient _client;

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
  final response = await _client.dio.get(
    '/movie/$movieId',
    queryParameters: {
      'language': 'fr-FR',
    },
  );

  return Movie.fromJson(response.data as Map<String, dynamic>);
}

  Future<TvShow> getTvShow(int tvShowId) async {
    final response = await _client.dio.get(
      '/tv/$tvShowId',
      queryParameters: {
        'language': 'fr-FR',
      },
    );

    return TvShow.fromJson(response.data as Map<String, dynamic>);
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
}
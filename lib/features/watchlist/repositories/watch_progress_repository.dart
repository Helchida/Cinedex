import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/episode_progress.dart';
import '../models/episode_watch_status.dart';
import '../models/movie_progress.dart';
import '../models/media_watch_status.dart';
import '../../library/repositories/library_repository.dart';

class WatchProgressRepository {
  WatchProgressRepository(this.supabase, this.libraryRepository);

  final SupabaseClient supabase;
  final LibraryRepository libraryRepository;

  String get _userId {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté.');
    }

    return user.id;
  }

  Future<List<MovieProgress>> getWatchedMovies() async {
    final response = await supabase
        .from('movie_progress')
        .select('''
          status,
          watched_at,
          movies (
            tmdb_id
          )
        ''')
        .eq('user_id', _userId);

    return (response as List).map((json) {
      final movie = json['movies'];

      return MovieProgress(
        movieId: movie['tmdb_id'] as int,
        status: MediaWatchStatus.watched,
        watchedAt: json['watched_at'] != null
            ? DateTime.parse(
                json['watched_at'] as String,
              )
            : null,
      );
    }).toList();
  }

  Future<void> markMovieWatched({
    required int tmdbMovieId,
    required String title,
    String? posterPath,
    DateTime? releaseDate,
  }) async {
    final movieId = await _getOrCreateMovie(
      userId: _userId,
      tmdbMovieId: tmdbMovieId,
      title: title,
      posterPath: posterPath,
      releaseDate: releaseDate,
    );

    await supabase.from('movie_progress').upsert(
      {
        'user_id': _userId,
        'movie_id': movieId,
        'status': 'watched',
      },
      onConflict: 'user_id,movie_id',
    );
  }

  Future<void> unmarkMovieWatched({
    required int tmdbMovieId,
  }) async {
    final movie = await supabase
        .from('movies')
        .select('id')
        .eq('user_id', _userId)
        .eq('tmdb_id', tmdbMovieId)
        .maybeSingle();

    if (movie == null) {
      return;
    }

    await supabase
        .from('movie_progress')
        .delete()
        .eq('user_id', _userId)
        .eq('movie_id', movie['id'] as int);
  }

  Future<bool> isMovieInWatchlist({
  required int tmdbMovieId,
}) async {
  final movie = await supabase
      .from('movies')
      .select('id')
      .eq('user_id', _userId)
      .eq('tmdb_id', tmdbMovieId)
      .maybeSingle();

  if (movie == null) {
    return false;
  }

  final result = await supabase
      .from('movie_watchlist')
      .select('id')
      .eq('user_id', _userId)
      .eq('movie_id', movie['id'] as int)
      .maybeSingle();

  return result != null;
}

Future<void> addMovieToWatchlist({
  required int tmdbMovieId,
  required String title,
  String? posterPath,
  DateTime? releaseDate,
}) async {
  final movieId = await _getOrCreateMovie(
    userId: _userId,
    tmdbMovieId: tmdbMovieId,
    title: title,
    posterPath: posterPath,
    releaseDate: releaseDate,
  );

  await supabase
      .from('movie_watchlist')
      .upsert(
        {
          'user_id': _userId,
          'movie_id': movieId,
        },
        onConflict: 'user_id,movie_id',
      );
}

Future<void> removeMovieFromWatchlist({
  required int tmdbMovieId,
}) async {
  final movie = await supabase
      .from('movies')
      .select('id')
      .eq('user_id', _userId)
      .eq('tmdb_id', tmdbMovieId)
      .maybeSingle();

  if (movie == null) {
    return;
  }

  await supabase
      .from('movie_watchlist')
      .delete()
      .eq('user_id', _userId)
      .eq('movie_id', movie['id'] as int);
}

Future<List<int>> getWatchlistMovies() async {
  final response = await supabase
      .from('movie_watchlist')
      .select('''
        movies (
          tmdb_id
        )
      ''')
      .eq('user_id', _userId);

  return (response as List).map<int>((json) {
    final movie = json['movies'];

    return movie['tmdb_id'] as int;
  }).toList();
}

Future<List<Map<String, dynamic>>> getWatchlistMoviesDetails() async {
  final response = await supabase
      .from('movie_watchlist')
      .select('''
        movies (
          tmdb_id,
          title,
          poster_path,
          release_date
        )
      ''')
      .eq('user_id', _userId);

  return (response as List)
      .map(
        (json) => json['movies'] as Map<String, dynamic>,
      )
      .toList();
}

Future<void> deleteMovieIfUnused({
  required int tmdbMovieId,
}) async {
  final movie = await supabase
      .from('movies')
      .select('id')
      .eq('user_id', _userId)
      .eq('tmdb_id', tmdbMovieId)
      .maybeSingle();

  if (movie == null) {
    return;
  }

  final movieId = movie['id'] as int;

  final progress = await supabase
      .from('movie_progress')
      .select('id')
      .eq('user_id', _userId)
      .eq('movie_id', movieId)
      .maybeSingle();

  final watchlist = await supabase
      .from('movie_watchlist')
      .select('id')
      .eq('user_id', _userId)
      .eq('movie_id', movieId)
      .maybeSingle();

  if (progress == null && watchlist == null) {
    await supabase
        .from('movies')
        .delete()
        .eq('id', movieId)
        .eq('user_id', _userId);
  }
}

  Future<int> _getOrCreateMovie({
    required String userId,
    required int tmdbMovieId,
    required String title,
    String? posterPath,
    DateTime? releaseDate,
  }) async {
    final existing = await supabase
        .from('movies')
        .select('id')
        .eq('user_id', userId)
        .eq('tmdb_id', tmdbMovieId)
        .maybeSingle();

    if (existing != null) {
      return existing['id'] as int;
    }

    final inserted = await supabase
        .from('movies')
        .insert({
          'user_id': userId,
          'tmdb_id': tmdbMovieId,
          'title': title,
          'poster_path': posterPath,
          'release_date': releaseDate
              ?.toIso8601String()
              .split('T')
              .first,
        })
        .select('id')
        .single();

    return inserted['id'] as int;
  }

  Future<List<EpisodeProgress>> getWatchedEpisodes() async {
    const pageSize = 1000;
    var offset = 0;

    final allEpisodes = <EpisodeProgress>[];

    while (true) {
      final response = await supabase
          .from('episode_progress')
          .select('''
            tmdb_episode_id,
            season_number,
            episode_number,
            status,
            series (
              tmdb_id
            )
          ''')
          .eq('user_id', _userId)
          .range(offset, offset + pageSize - 1);

      for (final json in response as List) {
        final series = json['series'];

        if (series == null) {
          continue;
        }

        allEpisodes.add(
          EpisodeProgress(
            episodeId: json['tmdb_episode_id'] as int,
            tvShowId: series['tmdb_id'] as int,
            seasonNumber: json['season_number'] as int,
            episodeNumber: json['episode_number'] as int,
            status: EpisodeWatchStatus.watched,
          ),
        );
      }

      if (response.length < pageSize) {
        break;
      }

      offset += pageSize;
    }

    return allEpisodes;
  }

  Future<List<int>> getWatchedTvShowIds() async {
  final episodes = await getWatchedEpisodes();

  return episodes
      .map((episode) => episode.tvShowId)
      .toSet()
      .toList();
}

  Future<void> markEpisodeWatched({
    required int tvShowId,
    required int episodeId,
    required int seasonNumber,
    required int episodeNumber,
    required String tvShowName,
    String? posterPath,
  }) async {

    await libraryRepository.addSeries(
      tmdbId: tvShowId,
      name: tvShowName,
      posterPath: posterPath,
    );

    final seriesId = await _getOrCreateSeries(
      userId: _userId,
      tvShowId: tvShowId,
      name: tvShowName,
      posterPath: posterPath,
    );

    await supabase.from('episode_progress').upsert(
      {
        'user_id': _userId,
        'series_id': seriesId,
        'tmdb_episode_id': episodeId,
        'season_number': seasonNumber,
        'episode_number': episodeNumber,
        'status': 'watched',
      },
      onConflict: 'user_id,tmdb_episode_id',
    );
  }

  Future<void> unmarkEpisodeWatched({
    required int episodeId,
  }) async {
    await supabase
        .from('episode_progress')
        .delete()
        .eq('user_id', _userId)
        .eq('tmdb_episode_id', episodeId);
  }

  Future<int> _getOrCreateSeries({
    required String userId,
    required int tvShowId,
    required String name,
    String? posterPath,
  }) async {
    final existing = await supabase
        .from('series')
        .select('id')
        .eq('user_id', userId)
        .eq('tmdb_id', tvShowId)
        .maybeSingle();

    if (existing != null) {
      return existing['id'] as int;
    }

    final inserted = await supabase
        .from('series')
        .insert({
          'user_id': userId,
          'tmdb_id': tvShowId,
          'name': name,
          'poster_path': posterPath,
        })
        .select('id')
        .single();

    return inserted['id'] as int;
  }

  Future<void> markEpisodesWatched({
    required int tvShowId,
    required String tvShowName,
    required List<EpisodeProgress> episodes,
    String? posterPath,
  }) async {
    if (episodes.isEmpty) {
      return;
    }

    final seriesId = await _getOrCreateSeries(
      userId: _userId,
      tvShowId: tvShowId,
      name: tvShowName,
      posterPath: posterPath,
    );

    final rows = episodes.map((episode) {
      return {
        'user_id': _userId,
        'series_id': seriesId,
        'tmdb_episode_id': episode.episodeId,
        'season_number': episode.seasonNumber,
        'episode_number': episode.episodeNumber,
        'status': 'watched',
      };
    }).toList();

    await supabase
        .from('episode_progress')
        .upsert(
          rows,
          onConflict: 'user_id,tmdb_episode_id',
        );
  }

  Future<void> unmarkEpisodesWatched({
    required List<int> episodeIds,
  }) async {
    if (episodeIds.isEmpty) {
      return;
    }

    await supabase
        .from('episode_progress')
        .delete()
        .eq('user_id', _userId)
        .inFilter('tmdb_episode_id', episodeIds);
  }

Future<Map<int, DateTime?>> getWatchedTvShowsWatchedAt() async {
  final response = await supabase
      .from('episode_progress')
      .select('''
        tmdb_episode_id,
        watched_at,
        series (
          tmdb_id
        )
      ''')
      .eq('user_id', _userId);

  final result = <int, DateTime?>{};

  for (final json in response as List) {
    final series = json['series'];

    if (series == null) {
      continue;
    }

    final tvShowId = series['tmdb_id'] as int;

    final watchedAt = DateTime.tryParse(
      json['watched_at'] as String? ?? '',
    );

    final currentDate = result[tvShowId];

    if (currentDate == null ||
        (watchedAt != null &&
            watchedAt.isAfter(currentDate))) {
      result[tvShowId] = watchedAt;
    }
  }

  return result;
}

}
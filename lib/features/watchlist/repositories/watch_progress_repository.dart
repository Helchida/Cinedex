import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/episode_progress.dart';
import '../models/episode_watch_status.dart';
import '../models/movie_progress.dart';
import '../models/media_watch_status.dart';

class WatchProgressRepository {
  WatchProgressRepository(this.supabase);

  final SupabaseClient supabase;

  String get _userId {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté.');
    }

    return user.id;
  }

  // ============================================================
  // FILMS
  // ============================================================

  /// Récupère tous les films vus.
  ///
  /// movieId contient ici le TMDB ID du film.
  Future<List<MovieProgress>> getWatchedMovies() async {
    final response = await supabase
        .from('movie_progress')
        .select('''
          status,
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
      );
    }).toList();
  }

  /// Marque un film comme vu.
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

  /// Retire un film des films vus.
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

  // ============================================================
  // EPISODES
  // ============================================================

  /// Récupère tous les épisodes vus.
  Future<List<EpisodeProgress>> getWatchedEpisodes() async {
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
        .eq('user_id', _userId);

    return (response as List).map((json) {
      final series = json['series'];

      return EpisodeProgress(
        episodeId: json['tmdb_episode_id'] as int,
        tvShowId: series['tmdb_id'] as int,
        seasonNumber: json['season_number'] as int,
        episodeNumber: json['episode_number'] as int,
        status: EpisodeWatchStatus.watched,
      );
    }).toList();
  }

  /// Marque un épisode comme vu.
  ///
  /// La série est automatiquement ajoutée à la bibliothèque.
  Future<void> markEpisodeWatched({
    required int tvShowId,
    required int episodeId,
    required int seasonNumber,
    required int episodeNumber,
    required String tvShowName,
    String? posterPath,
  }) async {
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

  /// Retire un épisode des épisodes vus.
  Future<void> unmarkEpisodeWatched({
    required int episodeId,
  }) async {
    await supabase
        .from('episode_progress')
        .delete()
        .eq('user_id', _userId)
        .eq('tmdb_episode_id', episodeId);
  }

  // ============================================================
  // SERIES
  // ============================================================

  Future<List<Map<String, dynamic>>> getSeries() async {
    final response = await supabase
        .from('series')
        .select()
        .eq('user_id', _userId)
        .order('created_at');

    return List<Map<String, dynamic>>.from(response);
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

  // ============================================================
// BIBLIOTHÈQUE - SERIES
// ============================================================

/// Vérifie si une série est présente dans la bibliothèque.
Future<bool> isSeriesInLibrary({
  required int tmdbSeriesId,
}) async {
  final user = supabase.auth.currentUser;

  if (user == null) {
    throw Exception('Utilisateur non connecté.');
  }

  final response = await supabase
      .from('series')
      .select('id')
      .eq('user_id', user.id)
      .eq('tmdb_id', tmdbSeriesId)
      .maybeSingle();

  return response != null;
}

/// Ajoute une série à la bibliothèque.
Future<void> addSeriesToLibrary({
  required int tmdbSeriesId,
  required String name,
  String? posterPath,
}) async {
  final user = supabase.auth.currentUser;

  if (user == null) {
    throw Exception('Utilisateur non connecté.');
  }

  await _getOrCreateSeries(
    userId: user.id,
    tvShowId: tmdbSeriesId,
    name: name,
    posterPath: posterPath,
  );
}

/// Retire une série de la bibliothèque.
///
/// Attention : cette méthode ne supprime pas les épisodes vus.
/// Elle retire uniquement la série de la bibliothèque.
Future<void> removeSeriesFromLibrary({
  required int tmdbSeriesId,
}) async {
  final user = supabase.auth.currentUser;

  if (user == null) {
    throw Exception('Utilisateur non connecté.');
  }

  await supabase
      .from('series')
      .delete()
      .eq('user_id', user.id)
      .eq('tmdb_id', tmdbSeriesId);
}
}
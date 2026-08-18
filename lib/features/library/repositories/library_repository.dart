import 'package:supabase_flutter/supabase_flutter.dart';

class LibraryRepository {
  LibraryRepository(this.supabase);

  final SupabaseClient supabase;

  String get _userId {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté.');
    }

    return user.id;
  }

  Future<List<Map<String, dynamic>>> getSeries() async {
    final response = await supabase
        .from('series')
        .select()
        .eq('user_id', _userId)
        .order('created_at');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addSeries({
    required int tmdbId,
    required String name,
    String? posterPath,
    DateTime? firstAirDate,
  }) async {
    await supabase.from('series').upsert(
      {
        'user_id': _userId,
        'tmdb_id': tmdbId,
        'name': name,
        'poster_path': posterPath,
        'first_air_date': firstAirDate
            ?.toIso8601String()
            .split('T')
            .first,
      },
      onConflict: 'user_id,tmdb_id',
    );
  }

  Future<void> removeSeries({
    required int tmdbId,
  }) async {
    await supabase
        .from('series')
        .delete()
        .eq('user_id', _userId)
        .eq('tmdb_id', tmdbId);
  }

  Future<bool> containsSeries({
    required int tmdbId,
  }) async {
    final response = await supabase
        .from('series')
        .select('id')
        .eq('user_id', _userId)
        .eq('tmdb_id', tmdbId)
        .maybeSingle();

    return response != null;
  }

  Future<int> getSeriesStartSeason({
    required int tmdbId,
  }) async {
    final series = await supabase
        .from('series')
        .select('id')
        .eq('user_id', _userId)
        .eq('tmdb_id', tmdbId)
        .maybeSingle();

    if (series == null) {
      return 1;
    }

    final tracking = await supabase
        .from('series_tracking')
        .select('start_season')
        .eq('user_id', _userId)
        .eq('series_id', series['id'] as int)
        .maybeSingle();

    return tracking?['start_season'] as int? ?? 1;
  }

  Future<void> setSeriesStartSeason({
    required int tmdbId,
    required int startSeason,
    required String name,
    String? posterPath,
  }) async {
    if (startSeason < 1) {
      throw ArgumentError(
        'La saison de départ doit être supérieure à 0.',
      );
    }

    await addSeries(
      tmdbId: tmdbId,
      name: name,
      posterPath: posterPath,
    );

    final series = await supabase
        .from('series')
        .select('id')
        .eq('user_id', _userId)
        .eq('tmdb_id', tmdbId)
        .single();

    await supabase.from('series_tracking').upsert(
      {
        'user_id': _userId,
        'series_id': series['id'] as int,
        'start_season': startSeason,
      },
      onConflict: 'user_id,series_id',
    );
  }

  Future<List<Map<String, dynamic>>> getMovies() async {
    final response = await supabase
        .from('movies')
        .select()
        .eq('user_id', _userId)
        .order('created_at');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addMovie({
    required int tmdbId,
    required String title,
    String? posterPath,
    DateTime? releaseDate,
  }) async {
    await supabase.from('movies').upsert(
      {
        'user_id': _userId,
        'tmdb_id': tmdbId,
        'title': title,
        'poster_path': posterPath,
        'release_date': releaseDate
            ?.toIso8601String()
            .split('T')
            .first,
      },
      onConflict: 'user_id,tmdb_id',
    );
  }

  Future<void> removeMovie({
    required int tmdbId,
  }) async {
    await supabase
        .from('movies')
        .delete()
        .eq('user_id', _userId)
        .eq('tmdb_id', tmdbId);
  }
}
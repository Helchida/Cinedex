import 'package:supabase_flutter/supabase_flutter.dart';

class MovieWatchlistRepository {
  MovieWatchlistRepository(
    this._supabase,
  );

  final SupabaseClient _supabase;

  String get _userId =>
      _supabase.auth.currentUser!.id;

  Future<bool> isMovieInWatchlist(
    int movieId,
  ) async {
    final result = await _supabase
        .from('movie_watchlist')
        .select('id')
        .eq('user_id', _userId)
        .eq('movie_id', movieId)
        .maybeSingle();

    return result != null;
  }

  Future<void> addMovieToWatchlist(
    int movieId,
  ) async {
    await _supabase
        .from('movie_watchlist')
        .upsert(
          {
            'user_id': _userId,
            'movie_id': movieId,
          },
          onConflict: 'user_id,movie_id',
        );
  }

  Future<void> removeMovieFromWatchlist(
    int movieId,
  ) async {
    await _supabase
        .from('movie_watchlist')
        .delete()
        .eq('user_id', _userId)
        .eq('movie_id', movieId);
  }

  Future<List<int>> getWatchlistMovieIds() async {
    final rows = await _supabase
        .from('movie_watchlist')
        .select('movie_id')
        .eq('user_id', _userId);

    return rows
        .map<int>(
          (row) => row['movie_id'] as int,
        )
        .toList();
  }
}
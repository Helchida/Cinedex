class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  static const tmdbAccessToken = String.fromEnvironment(
    'TMDB_ACCESS_TOKEN',
  );
}
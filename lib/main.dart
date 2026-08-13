import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';

const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
);

const supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
);

const tmdbAccessToken = String.fromEnvironment(
  'TMDB_ACCESS_TOKEN',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception(
      'Les variables SUPABASE_URL et SUPABASE_ANON_KEY sont introuvables.',
    );
  }

  if (tmdbAccessToken.isEmpty) {
    throw Exception(
      'La variable TMDB_ACCESS_TOKEN est introuvable.',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: CinedexApp(),
    ),
  );
}
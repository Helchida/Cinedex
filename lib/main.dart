import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Env.supabaseUrl.isEmpty ||
      Env.supabaseAnonKey.isEmpty) {
    throw Exception(
      'Les variables SUPABASE_URL et SUPABASE_ANON_KEY '
      'sont introuvables.',
    );
  }

  if (Env.tmdbAccessToken.isEmpty) {
    throw Exception(
      'La variable TMDB_ACCESS_TOKEN est introuvable.',
    );
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: CinedexApp(),
    ),
  );
}
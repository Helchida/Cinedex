import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// État d'authentification Supabase.
final authStateProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.read(supabaseProvider);

  return supabase.auth.onAuthStateChange;
});

/// Utilisateur actuellement connecté.
///
/// Retourne null si aucun utilisateur n'est connecté.
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (state) => state.session?.user,
    loading: () => null,
    error: (_, __) => null,
  );
});
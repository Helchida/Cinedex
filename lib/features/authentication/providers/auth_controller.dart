import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final supabase = ref.read(supabaseProvider);

      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final supabase = ref.read(supabaseProvider);

      await supabase.auth.signUp(
        email: email,
        password: password,
      );

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();

    try {
      final supabase = ref.read(supabaseProvider);

      await supabase.auth.signOut();

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
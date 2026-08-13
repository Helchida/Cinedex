import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_provider.dart';

final authNotifierProvider =
    NotifierProvider<AuthNotifier, void>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final supabase = ref.read(supabaseProvider);

    await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        if (displayName != null && displayName.trim().isNotEmpty)
          'display_name': displayName.trim(),
      },
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final supabase = ref.read(supabaseProvider);

    await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    final supabase = ref.read(supabaseProvider);

    await supabase.auth.signOut();
  }
}
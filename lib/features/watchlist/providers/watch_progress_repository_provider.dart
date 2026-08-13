import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/watch_progress_repository.dart';
import '../../../core/supabase/supabase_provider.dart';

final watchProgressRepositoryProvider =
    Provider<WatchProgressRepository>((ref) {
  final supabase = ref.read(supabaseProvider);

  return WatchProgressRepository(supabase);
});
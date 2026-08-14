import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/watch_progress_repository.dart';
import '../../../core/supabase/supabase_provider.dart';
import '../../library/providers/library_repository_provider.dart';

final watchProgressRepositoryProvider =
    Provider<WatchProgressRepository>((ref) {
  final supabase = ref.read(supabaseProvider);
  final libraryRepository = ref.read(libraryRepositoryProvider);

  return WatchProgressRepository(supabase, libraryRepository);
});
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_provider.dart';
import '../repositories/library_repository.dart';

final libraryRepositoryProvider =
    Provider<LibraryRepository>((ref) {
  final supabase = ref.read(supabaseProvider);

  return LibraryRepository(supabase);
});
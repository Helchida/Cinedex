import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'supabase_provider.dart';

final supabaseConnectionTestProvider =
    FutureProvider<String>((ref) async {
  final supabase = ref.read(supabaseProvider);

  final response = await supabase
      .from('profiles')
      .select('id')
      .limit(1);

  return 'Connexion Supabase OK — ${response.length} profil(s) trouvé(s)';
});
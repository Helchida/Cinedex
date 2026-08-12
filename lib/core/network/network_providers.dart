import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'tmdb_api.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final tmdbApiProvider = Provider<TmdbApi>((ref) {
  final client = ref.watch(apiClientProvider);

  return TmdbApi(client);
});
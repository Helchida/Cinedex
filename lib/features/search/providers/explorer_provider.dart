import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../models/explorer_content.dart';

final explorerProvider =
    FutureProvider<ExplorerContent>((ref) async {
  final api = ref.read(tmdbApiProvider);

  final popularMovies = await api.getPopularMovies();
  final popularTvShows = await api.getPopularTvShows();
  final nowPlayingMovies = await api.getNowPlayingMovies();
  final onTheAirTvShows = await api.getOnTheAirTvShows();

  return ExplorerContent(
    popularMovies: popularMovies,
    popularTvShows: popularTvShows,
    nowPlayingMovies: nowPlayingMovies,
    onTheAirTvShows: onTheAirTvShows,
  );
});
import '../../movies/models/movie.dart';
import '../../series/models/tv_show.dart';

class ExplorerContent {
  const ExplorerContent({
    required this.popularMovies,
    required this.popularTvShows,
    required this.nowPlayingMovies,
    required this.onTheAirTvShows,
    required this.recommendedMovies,
    required this.recommendedTvShows,
  });

  final List<Movie> popularMovies;
  final List<TvShow> popularTvShows;
  final List<Movie> nowPlayingMovies;
  final List<TvShow> onTheAirTvShows;

  final List<Movie> recommendedMovies;
  final List<TvShow> recommendedTvShows;
}
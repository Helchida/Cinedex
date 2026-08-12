import '../../movies/models/movie.dart';
import '../../series/models/tv_show.dart';

class SearchResult {
  const SearchResult({
    required this.movies,
    required this.tvShows,
  });

  final List<Movie> movies;
  final List<TvShow> tvShows;
}
import 'media_watch_status.dart';

class MovieProgress {
  const MovieProgress({
    required this.movieId,
    required this.status,
  });

  final int movieId;
  final MediaWatchStatus status;
}
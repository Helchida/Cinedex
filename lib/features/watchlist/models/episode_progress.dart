import 'episode_watch_status.dart';

class EpisodeProgress {
  const EpisodeProgress({
    required this.episodeId,
    required this.tvShowId,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.status,
  });

  final int episodeId;
  final int tvShowId;
  final int seasonNumber;
  final int episodeNumber;
  final EpisodeWatchStatus status;
}
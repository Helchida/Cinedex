class SeriesStats {
  const SeriesStats({
    required this.completed,
    required this.inProgress,
    required this.totalEpisodes,
    required this.watchedEpisodes,
  });

  final int completed;
  final int inProgress;
  final int totalEpisodes;
  final int watchedEpisodes;
}
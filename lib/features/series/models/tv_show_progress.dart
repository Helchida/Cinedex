class TvShowProgress {
  const TvShowProgress({
    required this.watchedEpisodes,
    required this.totalEpisodes,
  });

  final int watchedEpisodes;
  final int totalEpisodes;

  double get percentage {
    if (totalEpisodes == 0) {
      return 0;
    }

    return watchedEpisodes / totalEpisodes;
  }

  bool get isCompleted {
    return totalEpisodes > 0 &&
        watchedEpisodes == totalEpisodes;
  }
}
class MediaCredits {
  const MediaCredits({
    this.genreIds = const [],
    this.directorIds = const [],
    this.creatorIds = const [],
    this.actorIds = const [],
  });

  final List<int> genreIds;
  final List<int> directorIds;
  final List<int> creatorIds;
  final List<int> actorIds;
}
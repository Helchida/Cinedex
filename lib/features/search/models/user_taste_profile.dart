class UserTasteProfile {
  const UserTasteProfile({
    this.genres = const {},
    this.directors = const {},
    this.creators = const {},
    this.actors = const {},
  });

  final Map<int, double> genres;
  final Map<int, double> directors;
  final Map<int, double> creators;
  final Map<int, double> actors;
}
class FollowedSeries {
  const FollowedSeries({
    required this.id,
    required this.name,
    this.posterPath,
  });

  final int id;
  final String name;
  final String? posterPath;
}
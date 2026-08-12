class Season {
  const Season({
    required this.id,
    required this.seasonNumber,
    required this.name,
    this.overview,
    this.posterPath,
    this.airDate,
    this.episodeCount,
  });

  final int id;
  final int seasonNumber;
  final String name;
  final String? overview;
  final String? posterPath;
  final DateTime? airDate;
  final int? episodeCount;

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'] as int,
      seasonNumber: json['season_number'] as int,
      name: json['name'] as String? ?? '',
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      airDate: _parseDate(json['air_date']),
      episodeCount: json['episode_count'] as int?,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}
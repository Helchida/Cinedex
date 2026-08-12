class Episode {
  const Episode({
    required this.id,
    required this.episodeNumber,
    required this.seasonNumber,
    required this.name,
    this.overview,
    this.stillPath,
    this.airDate,
    this.voteAverage,
    this.runtime,
  });

  final int id;
  final int episodeNumber;
  final int seasonNumber;
  final String name;
  final String? overview;
  final String? stillPath;
  final DateTime? airDate;
  final double? voteAverage;
  final int? runtime;

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] as int,
      episodeNumber: json['episode_number'] as int,
      seasonNumber: json['season_number'] as int,
      name: json['name'] as String? ?? '',
      overview: json['overview'] as String?,
      stillPath: json['still_path'] as String?,
      airDate: _parseDate(json['air_date']),
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      runtime: json['runtime'] as int?,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}
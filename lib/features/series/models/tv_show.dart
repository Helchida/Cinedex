class TvShow {
  const TvShow({
    required this.id,
    required this.name,
    this.originalName,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.firstAirDate,
    this.voteAverage,
    this.voteCount,
    this.popularity,
    this.genres = const [],
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.tagline,
    this.genreIds = const [],
  });

  final int id;
  final String name;
  final String? originalName;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final DateTime? firstAirDate;
  final double? voteAverage;
  final int? voteCount;
  final double? popularity;
  final List<String> genres;
  final int? numberOfSeasons;
  final int? numberOfEpisodes;
  final String? tagline;
  final List<int> genreIds;

  factory TvShow.fromJson(Map<String, dynamic> json) {
    return TvShow(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      originalName: json['original_name'] as String?,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      firstAirDate: _parseDate(json['first_air_date']),
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: json['vote_count'] as int?,
      popularity: (json['popularity'] as num?)?.toDouble(),
      genres: (json['genres'] as List<dynamic>?)
              ?.map(
                (genre) => genre['name'] as String,
              )
              .toList() ??
          [],
      numberOfSeasons: json['number_of_seasons'] as int?,
      numberOfEpisodes: json['number_of_episodes'] as int?,
      tagline: json['tagline'] as String?,
      genreIds:
        (json['genre_ids'] as List<dynamic>?)
                ?.map((id) => id as int)
                .toList() ??
            (json['genres'] as List<dynamic>?)
                ?.map(
                  (genre) =>
                      genre['id'] as int,
                )
                .toList() ??
            [],
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}
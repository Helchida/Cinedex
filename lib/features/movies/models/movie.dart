class Movie {
  const Movie({
    required this.id,
    required this.title,
    this.originalTitle,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.voteAverage,
    this.voteCount,
    this.popularity,
    this.runtime,
    this.tagline,
    this.genres = const [],
    this.genreIds = const [],
  });

  final int id;
  final String title;
  final String? originalTitle;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final DateTime? releaseDate;
  final double? voteAverage;
  final int? voteCount;
  final double? popularity;
  final int? runtime;
  final String? tagline;
  final List<String> genres;
  final List<int> genreIds;

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      originalTitle: json['original_title'] as String?,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: _parseDate(json['release_date']),
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: json['vote_count'] as int?,
      popularity: (json['popularity'] as num?)?.toDouble(),
      runtime: json['runtime'] as int?,
      tagline: json['tagline'] as String?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map(
                (genre) => genre['name'] as String,
              )
              .toList() ??
          [],
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
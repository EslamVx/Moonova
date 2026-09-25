class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String releaseDate;
  final List<int> genreIds;
  final String originalLanguage;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.genreIds,
    required this.originalLanguage,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    final genreIds = json['genre_ids'] != null
        ? List<int>.from(json['genre_ids'])
        : (json['genres'] as List? ?? [])
              .map((genre) => genre['id'] as int)
              .toList();

    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      releaseDate: json['release_date'] ?? '',
      genreIds: genreIds,
      originalLanguage: json['original_language'] ?? '',
    );
  }
}

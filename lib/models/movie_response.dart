import 'movie.dart';

class MovieResponse {
  final int page;
  final List<Movie> movies;
  final int totalPages;
  final int totalResults;

  MovieResponse({
    required this.page,
    required this.movies,
    required this.totalPages,
    required this.totalResults,
  });

  factory MovieResponse.fromJson(Map<String, dynamic> json) {
    return MovieResponse(
      page: json['page'] ?? 1,
      movies: (json['results'] as List? ?? [])
          .map((movie) => Movie.fromJson(movie))
          .toList(),
      totalPages: json['total_pages'] ?? 1,
      totalResults: json['total_results'] ?? 0,
    );
  }
}

import '../models/genre.dart';
import '../models/movie.dart';
import '../models/movie_response.dart';
import '../services/tmdb_service.dart';

class MovieController {
  final TmdbService _tmdbService = TmdbService();

  Future<MovieResponse> getPopularMovies() async {
    return await _tmdbService.getPopularMovies();
  }

  Future<MovieResponse> getTrendingMovies() async {
    return await _tmdbService.getTrendingMovies();
  }

  Future<MovieResponse> searchMovies(String query) async {
    return await _tmdbService.searchMovies(query);
  }

  Future<List<Genre>> getMovieGenres() async {
    return await _tmdbService.getMovieGenres();
  }

  Future<Movie> getMovieDetails(int movieId) async {
    return await _tmdbService.getMovieDetails(movieId);
  }
}

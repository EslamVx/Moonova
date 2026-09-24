import '../models/movie_response.dart';
import '../services/tmdb_service.dart';

class MovieController {
  final TmdbService _tmdbService = TmdbService();

  Future<MovieResponse> getPopularMovies() async {
    return await _tmdbService.getPopularMovies();
  }
}

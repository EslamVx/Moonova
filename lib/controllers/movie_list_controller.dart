import '../models/user_movie.dart';

class MovieListController {
  final List<UserMovie> _userMovies = [];

  List<UserMovie> get userMovies => List.unmodifiable(_userMovies);

  UserMovie getMovie(int movieId, String userId) {
    return _userMovies.firstWhere(
      (movie) => movie.movieId == movieId && movie.userId == userId,
      orElse: () => UserMovie(userId: userId, movieId: movieId),
    );
  }

  void updateMovie(UserMovie userMovie) {
    final index = _userMovies.indexWhere(
      (movie) =>
          movie.movieId == userMovie.movieId &&
          movie.userId == userMovie.userId,
    );

    if (index == -1) {
      _userMovies.add(userMovie);
    } else {
      _userMovies[index] = userMovie;
    }
  }

  void removeMovie(String userId, int movieId) {
    _userMovies.removeWhere(
      (movie) => movie.userId == userId && movie.movieId == movieId,
    );
  }
}

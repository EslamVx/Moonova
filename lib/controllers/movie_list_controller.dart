import '../models/user_movie.dart';
import '../services/firestore_service.dart';

class MovieListController {
  final FirestoreService _firestoreService = FirestoreService();

  final List<UserMovie> _userMovies = [];

  List<UserMovie> get userMovies => List.unmodifiable(_userMovies);

  Future<void> loadUserMovies(String userId) async {
    final movies = await _firestoreService.getUserMovies(userId);

    _userMovies
      ..clear()
      ..addAll(movies);
  }

  UserMovie getMovie(int movieId, String userId) {
    return _userMovies.firstWhere(
      (movie) => movie.movieId == movieId && movie.userId == userId,
      orElse: () => UserMovie(userId: userId, movieId: movieId),
    );
  }

  List<UserMovie> getFavorites(String userId) {
    return _userMovies
        .where((movie) => movie.userId == userId && movie.isFavorite)
        .toList();
  }

  List<UserMovie> getWatched(String userId) {
    return _userMovies
        .where((movie) => movie.userId == userId && movie.isWatched)
        .toList();
  }

  List<UserMovie> getWatching(String userId) {
    return _userMovies
        .where((movie) => movie.userId == userId && movie.isWatching)
        .toList();
  }

  List<UserMovie> getWantToWatch(String userId) {
    return _userMovies
        .where((movie) => movie.userId == userId && movie.isWantToWatch)
        .toList();
  }

  Future<void> updateMovie(UserMovie userMovie) async {
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

    await _firestoreService.saveUserMovie(userMovie);
  }

  Future<void> removeMovie(String userId, int movieId) async {
    _userMovies.removeWhere(
      (movie) => movie.userId == userId && movie.movieId == movieId,
    );

    await _firestoreService.deleteUserMovie(userId: userId, movieId: movieId);
  }
}

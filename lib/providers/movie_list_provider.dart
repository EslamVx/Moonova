import 'package:flutter/material.dart';

import '../controllers/movie_list_controller.dart';
import '../models/user_movie.dart';

class MovieListProvider extends ChangeNotifier {
  final MovieListController _controller = MovieListController();

  UserMovie? _currentMovie;

  UserMovie? get currentMovie => _currentMovie;

  void loadMovie({required String userId, required int movieId}) {
    _currentMovie = _controller.getMovie(movieId, userId);

    notifyListeners();
  }

  void toggleFavorite() {
    if (_currentMovie == null) {
      return;
    }

    _currentMovie = _currentMovie!.copyWith(
      isFavorite: !_currentMovie!.isFavorite,
    );

    _controller.updateMovie(_currentMovie!);

    notifyListeners();
  }

  void toggleWatched() {
    if (_currentMovie == null) {
      return;
    }

    _currentMovie = _currentMovie!.copyWith(
      isWatched: !_currentMovie!.isWatched,
    );

    _controller.updateMovie(_currentMovie!);

    notifyListeners();
  }

  void toggleWatching() {
    if (_currentMovie == null) {
      return;
    }

    _currentMovie = _currentMovie!.copyWith(
      isWatching: !_currentMovie!.isWatching,
    );

    _controller.updateMovie(_currentMovie!);

    notifyListeners();
  }

  void toggleWantToWatch() {
    if (_currentMovie == null) {
      return;
    }

    _currentMovie = _currentMovie!.copyWith(
      isWantToWatch: !_currentMovie!.isWantToWatch,
    );

    _controller.updateMovie(_currentMovie!);

    notifyListeners();
  }
}

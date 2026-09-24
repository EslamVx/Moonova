import 'package:flutter/material.dart';

import '../controllers/movie_controller.dart';
import '../models/movie.dart';

class MovieProvider extends ChangeNotifier {
  final MovieController _controller = MovieController();

  List<Movie> _popularMovies = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Movie> get popularMovies => _popularMovies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPopularMovies() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final response = await _controller.getPopularMovies();

      _popularMovies = response.movies;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }
}

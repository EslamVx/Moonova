import 'package:flutter/material.dart';

import '../controllers/movie_controller.dart';
import '../models/movie.dart';

class MovieProvider extends ChangeNotifier {
  final MovieController _controller = MovieController();

  List<Movie> _popularMovies = [];
  List<Movie> _searchResults = [];

  bool _isLoading = false;
  bool _isSearching = false;

  String? _errorMessage;
  String? _searchErrorMessage;

  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get searchResults => _searchResults;

  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;

  String? get errorMessage => _errorMessage;
  String? get searchErrorMessage => _searchErrorMessage;

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

  Future<void> searchMovies(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    _isSearching = true;
    _searchErrorMessage = null;

    notifyListeners();

    try {
      final response = await _controller.searchMovies(query.trim());

      _searchResults = response.movies;
    } catch (e) {
      _searchErrorMessage = e.toString();
    } finally {
      _isSearching = false;

      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    _searchErrorMessage = null;
    _isSearching = false;

    notifyListeners();
  }
}

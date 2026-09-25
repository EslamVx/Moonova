import 'package:flutter/material.dart';

import '../controllers/movie_controller.dart';
import '../models/genre.dart';
import '../models/movie.dart';

class MovieProvider extends ChangeNotifier {
  final MovieController _controller = MovieController();

  List<Movie> _popularMovies = [];
  List<Movie> _trendingMovies = [];
  List<Movie> _searchResults = [];
  List<Genre> _genres = [];

  Movie? _selectedMovie;

  bool _isLoading = false;
  bool _isSearching = false;
  bool _isLoadingGenres = false;
  bool _isLoadingDetails = false;

  String? _errorMessage;
  String? _searchErrorMessage;
  String? _genreErrorMessage;
  String? _detailsErrorMessage;

  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get searchResults => _searchResults;
  List<Genre> get genres => _genres;

  Movie? get selectedMovie => _selectedMovie;

  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isLoadingGenres => _isLoadingGenres;
  bool get isLoadingDetails => _isLoadingDetails;

  String? get errorMessage => _errorMessage;
  String? get searchErrorMessage => _searchErrorMessage;
  String? get genreErrorMessage => _genreErrorMessage;
  String? get detailsErrorMessage => _detailsErrorMessage;

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

  Future<void> loadTrendingMovies() async {
    try {
      final response = await _controller.getTrendingMovies();

      _trendingMovies = response.movies;
    } catch (e) {
      _trendingMovies = [];
    }

    notifyListeners();
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

  Future<void> loadGenres() async {
    if (_genres.isNotEmpty) {
      return;
    }

    _isLoadingGenres = true;
    _genreErrorMessage = null;

    notifyListeners();

    try {
      _genres = await _controller.getMovieGenres();
    } catch (e) {
      _genreErrorMessage = e.toString();
    } finally {
      _isLoadingGenres = false;

      notifyListeners();
    }
  }

  Future<void> loadMovieDetails(int movieId) async {
    _isLoadingDetails = true;
    _detailsErrorMessage = null;
    _selectedMovie = null;

    notifyListeners();

    try {
      _selectedMovie = await _controller.getMovieDetails(movieId);

      await loadGenres();
    } catch (e) {
      _detailsErrorMessage = e.toString();
    } finally {
      _isLoadingDetails = false;

      notifyListeners();
    }
  }

  String getGenreName(int genreId) {
    final genre = _genres.where((genre) => genre.id == genreId).firstOrNull;

    return genre?.name ?? '';
  }

  void clearSearch() {
    _searchResults = [];
    _searchErrorMessage = null;
    _isSearching = false;

    notifyListeners();
  }

  void clearSelectedMovie() {
    _selectedMovie = null;
    _detailsErrorMessage = null;

    notifyListeners();
  }
}

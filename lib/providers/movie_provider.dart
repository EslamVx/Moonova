import 'package:flutter/material.dart';

import '../controllers/movie_controller.dart';
import '../models/cast.dart';
import '../models/genre.dart';
import '../models/movie.dart';

class MovieProvider extends ChangeNotifier {
  final MovieController _controller = MovieController();

  List<Movie> _popularMovies = [];
  List<Movie> _trendingMovies = [];
  List<Movie> _searchResults = [];
  List<Movie> _recommendations = [];
  List<Genre> _genres = [];
  List<Cast> _movieCast = [];

  final Map<int, Movie> _movieCache = {};

  Movie? _selectedMovie;

  bool _isLoading = false;
  bool _isSearching = false;
  bool _isRecommendationsLoading = false;
  bool _isLoadingGenres = false;
  bool _isLoadingDetails = false;
  bool _isCastLoading = false;

  String? _errorMessage;
  String? _searchErrorMessage;
  String? _genreErrorMessage;
  String? _detailsErrorMessage;
  String? _castError;

  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get searchResults => _searchResults;
  List<Movie> get recommendations => _recommendations;
  List<Genre> get genres => _genres;
  List<Cast> get movieCast => _movieCast;

  Movie? get selectedMovie => _selectedMovie;

  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isRecommendationsLoading => _isRecommendationsLoading;
  bool get isLoadingGenres => _isLoadingGenres;
  bool get isLoadingDetails => _isLoadingDetails;
  bool get isCastLoading => _isCastLoading;

  String? get errorMessage => _errorMessage;
  String? get searchErrorMessage => _searchErrorMessage;
  String? get genreErrorMessage => _genreErrorMessage;
  String? get detailsErrorMessage => _detailsErrorMessage;
  String? get castError => _castError;

  Future<void> loadPopularMovies() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final response = await _controller.getPopularMovies();

      _popularMovies = response.movies;

      for (final movie in response.movies) {
        _movieCache[movie.id] = movie;
      }
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

      for (final movie in response.movies) {
        _movieCache[movie.id] = movie;
      }
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

      for (final movie in response.movies) {
        _movieCache[movie.id] = movie;
      }
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

      _movieCache[movieId] = _selectedMovie!;

      await loadGenres();
    } catch (e) {
      _detailsErrorMessage = e.toString();
    } finally {
      _isLoadingDetails = false;

      notifyListeners();
    }
  }

  Future<void> loadMovieCast(int movieId) async {
    _isCastLoading = true;
    _castError = null;

    notifyListeners();

    try {
      _movieCast = await _controller.getMovieCast(movieId);
    } catch (e) {
      _castError = e.toString();
      _movieCast = [];
    } finally {
      _isCastLoading = false;

      notifyListeners();
    }
  }

  Future<void> loadMovieRecommendations(int movieId) async {
    _isRecommendationsLoading = true;

    notifyListeners();

    try {
      final response = await _controller.getMovieRecommendations(movieId);

      _recommendations = response.movies;

      for (final movie in response.movies) {
        _movieCache[movie.id] = movie;
      }
    } catch (e) {
      _recommendations = [];
    } finally {
      _isRecommendationsLoading = false;

      notifyListeners();
    }
  }

  Future<Movie?> fetchMovie(int movieId) async {
    final cachedMovie = _movieCache[movieId];

    if (cachedMovie != null) {
      return cachedMovie;
    }

    try {
      final movie = await _controller.getMovieDetails(movieId);

      _movieCache[movieId] = movie;

      return movie;
    } catch (e) {
      return null;
    }
  }

  Movie? getMovieFromCache(int movieId) {
    return _movieCache[movieId];
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
    _movieCast = [];
    _recommendations = [];
    _castError = null;
    _detailsErrorMessage = null;

    notifyListeners();
  }
}

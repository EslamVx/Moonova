import 'package:flutter/material.dart';

import '../controllers/movie_controller.dart';
import '../models/cast.dart';
import '../models/genre.dart';
import '../models/movie.dart';

class MovieDetailsProvider extends ChangeNotifier {
  final MovieController _controller = MovieController();

  Movie? _movie;
  List<Cast> _cast = [];
  List<Movie> _recommendations = [];
  List<Genre> _genres = [];

  bool _isLoadingDetails = false;
  bool _isCastLoading = false;
  bool _isRecommendationsLoading = false;
  bool _isLoadingGenres = false;

  String? _detailsError;
  String? _castError;

  Movie? get movie => _movie;
  List<Cast> get cast => _cast;
  List<Movie> get recommendations => _recommendations;
  List<Genre> get genres => _genres;

  bool get isLoadingDetails => _isLoadingDetails;
  bool get isCastLoading => _isCastLoading;
  bool get isRecommendationsLoading => _isRecommendationsLoading;
  bool get isLoadingGenres => _isLoadingGenres;

  String? get detailsError => _detailsError;
  String? get castError => _castError;

  Future<void> loadMovie(int movieId) async {
    _isLoadingDetails = true;
    _detailsError = null;

    notifyListeners();

    try {
      _movie = await _controller.getMovieDetails(movieId);
      await loadGenres();
    } catch (e) {
      _detailsError = e.toString();
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  Future<void> loadCast(int movieId) async {
    _isCastLoading = true;
    _castError = null;

    notifyListeners();

    try {
      _cast = await _controller.getMovieCast(movieId);
    } catch (e) {
      _castError = e.toString();
      _cast = [];
    } finally {
      _isCastLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRecommendations(int movieId) async {
    _isRecommendationsLoading = true;

    notifyListeners();

    try {
      final response = await _controller.getMovieRecommendations(movieId);

      _recommendations = response.movies;
    } catch (e) {
      _recommendations = [];
    } finally {
      _isRecommendationsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadGenres() async {
    if (_genres.isNotEmpty) {
      return;
    }

    _isLoadingGenres = true;

    notifyListeners();

    try {
      _genres = await _controller.getMovieGenres();
    } catch (e) {
      _genres = [];
    } finally {
      _isLoadingGenres = false;
      notifyListeners();
    }
  }

  String getGenreName(int genreId) {
    final genre = _genres.where((genre) => genre.id == genreId).firstOrNull;

    return genre?.name ?? '';
  }

  Future<void> loadAll(int movieId) async {
    await Future.wait([
      loadMovie(movieId),
      loadCast(movieId),
      loadRecommendations(movieId),
    ]);
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../controllers/movie_list_controller.dart';
import '../models/user_movie.dart';

class MovieListProvider extends ChangeNotifier {
  final MovieListController _controller = MovieListController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserMovie? _currentMovie;

  List<UserMovie> _favorites = [];
  List<UserMovie> _watched = [];
  List<UserMovie> _watching = [];
  List<UserMovie> _wantToWatch = [];

  bool _isLoading = false;

  UserMovie? get currentMovie => _currentMovie;

  List<UserMovie> get favorites => _favorites;
  List<UserMovie> get watched => _watched;
  List<UserMovie> get watching => _watching;
  List<UserMovie> get wantToWatch => _wantToWatch;

  bool get isLoading => _isLoading;

  MovieListProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        loadUserMovies(user.uid);
      } else {
        _clearLibrary();
      }
    });
  }

  Future<void> loadUserMovies(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _controller.loadUserMovies(userId);
      _loadLists(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadMovie({required String userId, required int movieId}) {
    _currentMovie = _controller.getMovie(movieId, userId);
    _loadLists(userId);
    notifyListeners();
  }

  void _loadLists(String userId) {
    _favorites = _controller.getFavorites(userId);
    _watched = _controller.getWatched(userId);
    _watching = _controller.getWatching(userId);
    _wantToWatch = _controller.getWantToWatch(userId);
  }

  Future<void> toggleFavorite() async {
    if (_currentMovie == null) return;

    _currentMovie = _currentMovie!.copyWith(
      isFavorite: !_currentMovie!.isFavorite,
    );

    await _controller.updateMovie(_currentMovie!);

    _loadLists(_currentMovie!.userId);
    notifyListeners();
  }

  Future<void> toggleWatched() async {
    if (_currentMovie == null) return;

    _currentMovie = _currentMovie!.copyWith(
      isWatched: !_currentMovie!.isWatched,
    );

    await _controller.updateMovie(_currentMovie!);

    _loadLists(_currentMovie!.userId);
    notifyListeners();
  }

  Future<void> toggleWatching() async {
    if (_currentMovie == null) return;

    _currentMovie = _currentMovie!.copyWith(
      isWatching: !_currentMovie!.isWatching,
    );

    await _controller.updateMovie(_currentMovie!);

    _loadLists(_currentMovie!.userId);
    notifyListeners();
  }

  Future<void> toggleWantToWatch() async {
    if (_currentMovie == null) return;

    _currentMovie = _currentMovie!.copyWith(
      isWantToWatch: !_currentMovie!.isWantToWatch,
    );

    await _controller.updateMovie(_currentMovie!);

    _loadLists(_currentMovie!.userId);
    notifyListeners();
  }

  Future<void> removeFromFavorites(int movieId) async {
    await _removeFromList(
      movieId,
      (movie) => movie.copyWith(isFavorite: false),
    );
  }

  Future<void> removeFromWatched(int movieId) async {
    await _removeFromList(movieId, (movie) => movie.copyWith(isWatched: false));
  }

  Future<void> removeFromWatching(int movieId) async {
    await _removeFromList(
      movieId,
      (movie) => movie.copyWith(isWatching: false),
    );
  }

  Future<void> removeFromWantToWatch(int movieId) async {
    await _removeFromList(
      movieId,
      (movie) => movie.copyWith(isWantToWatch: false),
    );
  }

  Future<void> _removeFromList(
    int movieId,
    UserMovie Function(UserMovie) update,
  ) async {
    final user = _auth.currentUser;

    if (user == null) return;

    final movie = _controller.getMovie(movieId, user.uid);

    final updatedMovie = update(movie);

    await _controller.updateMovie(updatedMovie);

    _loadLists(user.uid);

    notifyListeners();
  }

  Future<void> removeMovie(int movieId) async {
    final user = _auth.currentUser;

    if (user == null) return;

    await _controller.removeMovie(user.uid, movieId);

    _loadLists(user.uid);

    notifyListeners();
  }

  void _clearLibrary() {
    _currentMovie = null;
    _favorites = [];
    _watched = [];
    _watching = [];
    _wantToWatch = [];
    _isLoading = false;

    notifyListeners();
  }
}

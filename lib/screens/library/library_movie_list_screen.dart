import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/movie.dart';
import '../../models/user_movie.dart';
import '../../providers/movie_list_provider.dart';
import '../../providers/movie_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/movie_card.dart';
import 'library_type.dart';

class LibraryMovieListScreen extends StatefulWidget {
  final String title;
  final LibraryType type;

  const LibraryMovieListScreen({
    super.key,
    required this.title,
    required this.type,
  });

  @override
  State<LibraryMovieListScreen> createState() => _LibraryMovieListScreenState();
}

class _LibraryMovieListScreenState extends State<LibraryMovieListScreen> {
  final List<Movie> _movies = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMovies();
    });
  }

  Future<void> _loadMovies() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final movieListProvider = context.read<MovieListProvider>();
      final movieProvider = context.read<MovieProvider>();

      final userMovies = _getUserMovies(movieListProvider);
      final movies = <Movie>[];

      for (final userMovie in userMovies) {
        final cachedMovie = movieProvider.getMovieFromCache(userMovie.movieId);

        if (cachedMovie != null) {
          movies.add(cachedMovie);
          continue;
        }

        final movie = await movieProvider.fetchMovie(userMovie.movieId);

        if (movie != null) {
          movies.add(movie);
        }
      }

      if (!mounted) return;

      setState(() {
        _movies
          ..clear()
          ..addAll(movies);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = 'Failed to load your movies.';
      });
    }
  }

  List<UserMovie> _getUserMovies(MovieListProvider provider) {
    switch (widget.type) {
      case LibraryType.favorite:
        return provider.favorites;
      case LibraryType.watched:
        return provider.watched;
      case LibraryType.watching:
        return provider.watching;
      case LibraryType.wantToWatch:
        return provider.wantToWatch;
    }
  }

  Future<void> _removeMovie(Movie movie) async {
    final provider = context.read<MovieListProvider>();

    try {
      switch (widget.type) {
        case LibraryType.favorite:
          await provider.removeFromFavorites(movie.id);
          break;
        case LibraryType.watched:
          await provider.removeFromWatched(movie.id);
          break;
        case LibraryType.watching:
          await provider.removeFromWatching(movie.id);
          break;
        case LibraryType.wantToWatch:
          await provider.removeFromWantToWatch(movie.id);
          break;
      }

      if (!mounted) return;

      setState(() {
        _movies.removeWhere((item) => item.id == movie.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed from ${widget.title}'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to remove movie.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingState(message: 'Loading your movies...');
    }

    if (_error != null) {
      return ErrorState(message: _error!, onRetry: _loadMovies);
    }

    if (_movies.isEmpty) {
      return EmptyState(
        title: 'No movies here yet',
        message: _getEmptyMessage(),
        icon: _getEmptyIcon(),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      itemCount: _movies.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        mainAxisExtent: 325,
      ),
      itemBuilder: (context, index) {
        final movie = _movies[index];

        return Dismissible(
          key: ValueKey(movie.id),
          direction: DismissDirection.horizontal,
          confirmDismiss: (_) async {
            await _removeMovie(movie);
            return false;
          },
          background: _buildDismissBackground(),
          secondaryBackground: _buildDismissBackground(),
          child: MovieCard(movie: movie),
        );
      },
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        Icons.delete_outline_rounded,
        color: Theme.of(context).colorScheme.error,
        size: 32,
      ),
    );
  }

  String _getEmptyMessage() {
    switch (widget.type) {
      case LibraryType.favorite:
        return 'Movies you love will appear here.';
      case LibraryType.watched:
        return 'Movies you have watched will appear here.';
      case LibraryType.watching:
        return 'Movies you are watching will appear here.';
      case LibraryType.wantToWatch:
        return 'Movies you want to watch will appear here.';
    }
  }

  IconData _getEmptyIcon() {
    switch (widget.type) {
      case LibraryType.favorite:
        return Icons.favorite_outline_rounded;
      case LibraryType.watched:
        return Icons.visibility_outlined;
      case LibraryType.watching:
        return Icons.play_circle_outline_rounded;
      case LibraryType.wantToWatch:
        return Icons.bookmark_outline_rounded;
    }
  }
}

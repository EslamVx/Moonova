import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/movie.dart';
import '../../models/user_movie.dart';
import '../../providers/movie_list_provider.dart';
import '../../providers/movie_provider.dart';
import '../../widgets/movie_card.dart';
import 'library_screen.dart';

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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMovies();
    });
  }

  Future<void> _loadMovies() async {
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
      ),
    );
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_movies.isEmpty) {
      return const Center(child: Text('No movies in this list'));
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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
        color: Colors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.delete_outline_rounded,
        color: Colors.red,
        size: 32,
      ),
    );
  }
}

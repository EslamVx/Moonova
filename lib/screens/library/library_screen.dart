import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/movie.dart';
import '../../models/user_movie.dart';
import '../../providers/movie_list_provider.dart';
import '../../providers/movie_provider.dart';
import 'library_movie_list_screen.dart';
import 'library_type.dart';
import '../../core/utils/page_transitions.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieListProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Library')),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.82,
        children: [
          _buildLibraryCard(
            context,
            title: 'Favorites',
            icon: Icons.favorite_rounded,
            movies: provider.favorites,
            type: LibraryType.favorite,
          ),
          _buildLibraryCard(
            context,
            title: 'Watched',
            icon: Icons.visibility_rounded,
            movies: provider.watched,
            type: LibraryType.watched,
          ),
          _buildLibraryCard(
            context,
            title: 'Watching',
            icon: Icons.play_circle_rounded,
            movies: provider.watching,
            type: LibraryType.watching,
          ),
          _buildLibraryCard(
            context,
            title: 'Want to Watch',
            icon: Icons.bookmark_rounded,
            movies: provider.wantToWatch,
            type: LibraryType.wantToWatch,
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<UserMovie> movies,
    required LibraryType type,
  }) {
    final movieProvider = context.read<MovieProvider>();

    final posters = movies
        .map((movie) => movieProvider.getMovieFromCache(movie.movieId))
        .whereType<Movie>()
        .take(3)
        .toList();

    return _LibraryCard(
      title: title,
      icon: icon,
      movies: movies,
      posters: posters,
      onTap: () {
        Navigator.push(
          context,
          PageTransitions.fadeSlide(
            page: LibraryMovieListScreen(title: title, type: type),
          ),
        );
      },
    );
  }
}

class _LibraryCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<UserMovie> movies;
  final List<Movie> posters;
  final VoidCallback onTap;

  const _LibraryCard({
    required this.title,
    required this.icon,
    required this.movies,
    required this.posters,
    required this.onTap,
  });

  @override
  State<_LibraryCard> createState() => _LibraryCardState();
}

class _LibraryCardState extends State<_LibraryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.forward();
  }

  void _onTapCancel() {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: theme.colorScheme.surface,
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned.fill(child: _buildPosterBackground(context)),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.05),
                          Colors.black.withValues(alpha: 0.25),
                          Colors.black.withValues(alpha: 0.92),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 21,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.movies.length}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 12,
                  bottom: 16,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.movies.length} ${widget.movies.length == 1 ? 'movie' : 'movies'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPosterBackground(BuildContext context) {
    if (widget.posters.isEmpty) {
      final theme = Theme.of(context);

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.55),
              theme.colorScheme.secondary.withValues(alpha: 0.35),
            ],
          ),
        ),
        child: const Center(
          child: Icon(Icons.movie_outlined, size: 56, color: Colors.white24),
        ),
      );
    }

    return Row(
      children: widget.posters.map((movie) {
        return Expanded(
          child: Image.network(
            'https://image.tmdb.org/t/p/w500${movie.posterPath}',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              );
            },
          ),
        );
      }).toList(),
    );
  }
}

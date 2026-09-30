import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/page_transitions.dart';
import '../../models/movie.dart';
import '../../providers/auth_provider.dart';
import '../../providers/movie_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/movie_horizontal_list.dart';
import '../auth/login_screen.dart';
import '../library/library_screen.dart';
import '../movie_details/movie_details_screen.dart';
import '../movie_list/movie_list_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MovieProvider>();

      if (provider.popularMovies.isEmpty) {
        provider.loadPopularMovies();
      }

      if (provider.trendingMovies.isEmpty) {
        provider.loadTrendingMovies();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Moonova',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                PageTransitions.fadeSlide(page: const LibraryScreen()),
              );
            },
            icon: const Icon(Icons.video_library_outlined),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                PageTransitions.fadeSlide(page: const SearchScreen()),
              );
            },
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                PageTransitions.fadeSlide(
                  page: authProvider.isAuthenticated
                      ? const ProfileScreen()
                      : const LoginScreen(),
                ),
              );
            },
            icon: authProvider.isAuthenticated
                ? CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      _getUserInitial(authProvider.user?.displayName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const Icon(Icons.person_outline_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  String _getUserInitial(String? name) {
    if (name != null && name.trim().isNotEmpty) {
      return name.trim()[0].toUpperCase();
    }

    return 'U';
  }

  Widget _buildBody(MovieProvider provider) {
    final hasPopularMovies = provider.popularMovies.isNotEmpty;
    final hasTrendingMovies = provider.trendingMovies.isNotEmpty;

    if (provider.errorMessage != null &&
        !hasPopularMovies &&
        !hasTrendingMovies &&
        !provider.isLoading) {
      return ErrorState(
        message: 'We could not load the movies.\nPlease try again.',
        onRetry: () {
          provider.loadPopularMovies();
          provider.loadTrendingMovies();
        },
      );
    }

    if (!provider.isLoading && !hasPopularMovies && !hasTrendingMovies) {
      return const EmptyState(
        title: 'No movies found',
        message: 'We could not find any movies right now.',
        icon: Icons.movie_outlined,
      );
    }

    final featuredMovie = provider.trendingMovies.isNotEmpty
        ? provider.trendingMovies.first
        : provider.popularMovies.isNotEmpty
        ? provider.popularMovies.first
        : null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Text(
              'Discover your next movie',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (featuredMovie != null) ...[
            _buildFeaturedMovie(featuredMovie),
            const SizedBox(height: 28),
          ],
          _buildPopularSection(provider),
          _buildTrendingSection(provider),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPopularSection(MovieProvider provider) {
    final isLoading =
        provider.isPopularLoading && provider.popularMovies.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Popular Movies',
          hasMovies: provider.popularMovies.isNotEmpty,
          onSeeAll: () {
            Navigator.push(
              context,
              PageTransitions.fadeSlide(
                page: MovieListScreen(
                  title: 'Popular Movies',
                  movies: provider.popularMovies,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        if (provider.popularErrorMessage != null &&
            provider.popularMovies.isEmpty &&
            !provider.isPopularLoading)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Unable to load popular movies.'),
          )
        else
          MovieHorizontalList(
            movies: provider.popularMovies,
            isLoading: isLoading,
          ),
      ],
    );
  }

  Widget _buildTrendingSection(MovieProvider provider) {
    final isLoading =
        provider.isTrendingLoading && provider.trendingMovies.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        _buildSectionHeader(
          title: 'Trending Now',
          hasMovies: provider.trendingMovies.isNotEmpty,
          onSeeAll: () {
            Navigator.push(
              context,
              PageTransitions.fadeSlide(
                page: MovieListScreen(
                  title: 'Trending Now',
                  movies: provider.trendingMovies,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        if (provider.trendingErrorMessage != null &&
            provider.trendingMovies.isEmpty &&
            !provider.isTrendingLoading)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Unable to load trending movies.'),
          )
        else
          MovieHorizontalList(
            movies: provider.trendingMovies,
            isLoading: isLoading,
          ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required bool hasMovies,
    required VoidCallback onSeeAll,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (hasMovies)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('See all'),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedMovie(Movie movie) {
    return _FeaturedMovieCard(movie: movie);
  }
}

class _FeaturedMovieCard extends StatefulWidget {
  final Movie movie;

  const _FeaturedMovieCard({required this.movie});

  @override
  State<_FeaturedMovieCard> createState() => _FeaturedMovieCardState();
}

class _FeaturedMovieCardState extends State<_FeaturedMovieCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
      lowerBound: 0.98,
      upperBound: 1.0,
      value: 1.0,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _pressController.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    _pressController.forward();
  }

  void _onTapCancel() {
    _pressController.forward();
  }

  void _openDetails() {
    Navigator.push(
      context,
      PageTransitions.fadeSlide(page: MovieDetailsScreen(movie: widget.movie)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.96, end: 1),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 18 * (1 - value)),
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: _openDetails,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 420,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildBackdrop(),
                    _buildGradient(),
                    _buildContent(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackdrop() {
    final backdropPath = widget.movie.backdropPath;

    if (backdropPath == null || backdropPath.isEmpty) {
      return _buildBackdropPlaceholder();
    }

    return Image.network(
      'https://image.tmdb.org/t/p/w780$backdropPath',
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }

        return _buildBackdropLoading();
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildBackdropPlaceholder();
      },
    );
  }

  Widget _buildBackdropLoading() {
    return Container(
      color: AppColors.darkSurfaceSoft,
      child: const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildBackdropPlaceholder() {
    return Container(
      color: AppColors.darkSurfaceSoft,
      child: const Center(
        child: Icon(Icons.movie_outlined, size: 64, color: Colors.white38),
      ),
    );
  }

  Widget _buildGradient() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [Colors.black26, Colors.transparent],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final movie = widget.movie;

    final releaseYear = movie.releaseDate.length >= 4
        ? movie.releaseDate.substring(0, 4)
        : 'N/A';

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black12, Colors.black87],
          stops: [0.25, 0.55, 1.0],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TRENDING NOW',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                height: 1.1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 5),
                Text(
                  movie.voteAverage.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.white54,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  releaseYear,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _openDetails,
                icon: const Icon(Icons.play_arrow_rounded, size: 21),
                label: const Text('View Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/movie.dart';
import '../../providers/movie_details_provider.dart';
import '../../providers/movie_list_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/movie_card.dart';
import '../../widgets/movie_card_skeleton.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late final MovieDetailsProvider _detailsProvider;

  @override
  void initState() {
    super.initState();

    _detailsProvider = MovieDetailsProvider();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detailsProvider.loadAll(widget.movie.id);

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        context.read<MovieListProvider>().loadMovie(
          userId: user.uid,
          movieId: widget.movie.id,
        );
      }
    });
  }

  @override
  void dispose() {
    _detailsProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _detailsProvider,
      child: Consumer<MovieDetailsProvider>(
        builder: (context, provider, child) {
          final movieListProvider = context.watch<MovieListProvider>();

          return Scaffold(
            appBar: AppBar(title: const Text('Movie Details')),
            body: _buildBody(provider, movieListProvider),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    MovieDetailsProvider provider,
    MovieListProvider movieListProvider,
  ) {
    if (provider.isLoadingDetails) {
      return _buildDetailsSkeleton();
    }

    if (provider.detailsError != null) {
      return ErrorState(
        message: 'We could not load this movie.\nPlease try again.',
        onRetry: () {
          provider.loadAll(widget.movie.id);
        },
      );
    }

    final movie = provider.movie;

    if (movie == null) {
      return const EmptyState(
        title: 'Movie not found',
        message: 'We could not find the movie details.',
        icon: Icons.movie_filter_outlined,
      );
    }

    final user = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBackdrop(movie),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMovieHeader(movie),
                const SizedBox(height: 20),
                _buildGenres(provider, movie),
                const SizedBox(height: 24),
                if (user != null && movieListProvider.currentMovie != null)
                  _buildMovieActions(movieListProvider),
                const SizedBox(height: 28),
                _buildSectionTitle('Overview'),
                const SizedBox(height: 8),
                Text(
                  movie.overview.isEmpty
                      ? 'No overview available.'
                      : movie.overview,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 32),
                _buildSectionTitle('Cast'),
                const SizedBox(height: 14),
                _buildCast(provider),
                const SizedBox(height: 32),
                _buildSectionTitle('You May Also Like'),
                const SizedBox(height: 14),
                _buildRecommendations(provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackdrop(Movie movie) {
    if (movie.backdropPath == null) {
      return _buildBackdropPlaceholder();
    }

    return SizedBox(
      width: double.infinity,
      height: 260,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://image.tmdb.org/t/p/w780${movie.backdropPath}',
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
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackdropLoading() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildBackdropPlaceholder() {
    return Container(
      width: double.infinity,
      height: 260,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.movie_outlined,
        size: 64,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildMovieHeader(Movie movie) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie.title,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: AppColors.warning,
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                movie.voteAverage.toStringAsFixed(1),
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 20),
              Icon(
                Icons.calendar_today_outlined,
                size: 19,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                movie.releaseDate.isEmpty ? 'Unknown' : movie.releaseDate,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenres(MovieDetailsProvider provider, Movie movie) {
    if (movie.genreIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final genres = movie.genreIds
        .map(provider.getGenreName)
        .where((name) => name.isNotEmpty)
        .toList();

    if (genres.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genres.map(_buildGenreChip).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCast(MovieDetailsProvider provider) {
    if (provider.isCastLoading) {
      return _buildCastSkeleton();
    }

    if (provider.castError != null) {
      return Text(
        'Failed to load cast.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    if (provider.cast.isEmpty) {
      return const EmptyState(
        title: 'No cast information',
        message: 'Cast information is not available for this movie.',
        icon: Icons.people_outline_rounded,
      );
    }

    final castCount = provider.cast.length > 10 ? 10 : provider.cast.length;

    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: castCount,
        separatorBuilder: (_, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final cast = provider.cast[index];

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.94, end: 1),
            duration: Duration(milliseconds: 250 + (index * 40)),
            curve: Curves.easeOutCubic,
            child: _buildCastCard(cast),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - value)),
                  child: child,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCastCard(dynamic cast) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 120,
              height: 170,
              child: cast.profilePath != null
                  ? Image.network(
                      'https://image.tmdb.org/t/p/w300${cast.profilePath}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildCastPlaceholder();
                      },
                    )
                  : _buildCastPlaceholder(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cast.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            cast.character,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildCastSkeleton() {
    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return const MovieCardSkeleton(width: 120);
        },
      ),
    );
  }

  Widget _buildRecommendations(MovieDetailsProvider provider) {
    if (provider.isRecommendationsLoading) {
      return SizedBox(
        height: 290,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          separatorBuilder: (_, index) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            return const MovieCardSkeleton(width: 150);
          },
        ),
      );
    }

    if (provider.recommendations.isEmpty) {
      return const EmptyState(
        title: 'No recommendations',
        message: 'No similar movies are available right now.',
        icon: Icons.movie_filter_outlined,
      );
    }

    final recommendationCount = provider.recommendations.length > 10
        ? 10
        : provider.recommendations.length;

    return SizedBox(
      height: 300,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(right: 20),
        itemCount: recommendationCount,
        separatorBuilder: (_, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return MovieCard(movie: provider.recommendations[index], width: 150);
        },
      ),
    );
  }

  Widget _buildCastPlaceholder() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.person_outline_rounded,
        size: 42,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildMovieActions(MovieListProvider provider) {
    final movie = provider.currentMovie!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('My Library'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                label: 'Favorite',
                icon: movie.isFavorite ? Icons.favorite : Icons.favorite_border,
                isActive: movie.isFavorite,
                onPressed: provider.toggleFavorite,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                label: 'Watched',
                icon: movie.isWatched
                    ? Icons.visibility
                    : Icons.visibility_outlined,
                isActive: movie.isWatched,
                onPressed: provider.toggleWatched,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                label: 'Watching',
                icon: movie.isWatching
                    ? Icons.play_circle
                    : Icons.play_circle_outline,
                isActive: movie.isWatching,
                onPressed: provider.toggleWatching,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                label: 'Want to Watch',
                icon: movie.isWantToWatch
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                isActive: movie.isWantToWatch,
                onPressed: provider.toggleWantToWatch,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          foregroundColor: isActive
              ? AppColors.primary
              : theme.colorScheme.onSurface,
          side: BorderSide(
            color: isActive ? AppColors.primary : theme.dividerColor,
          ),
          backgroundColor: isActive
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildGenreChip(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildDetailsSkeleton() {
    final theme = Theme.of(context);
    final skeletonColor = theme.colorScheme.surfaceContainerHighest;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: double.infinity, height: 260, color: skeletonColor),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSkeletonBox(width: 240, height: 28),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildSkeletonBox(width: 70, height: 18),
                    const SizedBox(width: 20),
                    _buildSkeletonBox(width: 100, height: 18),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildSkeletonBox(width: 70, height: 32),
                    const SizedBox(width: 8),
                    _buildSkeletonBox(width: 90, height: 32),
                    const SizedBox(width: 8),
                    _buildSkeletonBox(width: 80, height: 32),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSkeletonBox(width: 110, height: 22),
                const SizedBox(height: 14),
                _buildSkeletonBox(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                _buildSkeletonBox(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                _buildSkeletonBox(width: 260, height: 16),
                const SizedBox(height: 32),
                _buildSkeletonBox(width: 70, height: 22),
                const SizedBox(height: 14),
                const MovieCardSkeleton(width: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

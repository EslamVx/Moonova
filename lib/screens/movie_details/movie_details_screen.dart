import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/movie.dart';
import '../../providers/movie_details_provider.dart';
import '../../providers/movie_list_provider.dart';
import '../../widgets/movie_card.dart';

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
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.detailsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(provider.detailsError!, textAlign: TextAlign.center),
        ),
      );
    }

    final movie = provider.movie;

    if (movie == null) {
      return const Center(child: Text('Movie not found'));
    }

    final user = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (movie.backdropPath != null)
            Image.network(
              'https://image.tmdb.org/t/p/w780${movie.backdropPath}',
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(20),
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
                    const Icon(Icons.star_rounded, color: AppColors.warning),
                    const SizedBox(width: 6),
                    Text(
                      movie.voteAverage.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 20),
                    const Icon(Icons.calendar_today_outlined),
                    const SizedBox(width: 6),
                    Text(
                      movie.releaseDate.isEmpty ? 'Unknown' : movie.releaseDate,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (movie.genreIds.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: movie.genreIds
                        .map(
                          (genreId) =>
                              _buildGenreChip(provider.getGenreName(genreId)),
                        )
                        .whereType<Widget>()
                        .toList(),
                  ),
                const SizedBox(height: 24),
                if (user != null && movieListProvider.currentMovie != null)
                  _buildMovieActions(movieListProvider),
                const SizedBox(height: 28),
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  movie.overview.isEmpty
                      ? 'No overview available.'
                      : movie.overview,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 28),
                Text(
                  'Cast',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildCast(provider),
                const SizedBox(height: 28),
                Text(
                  'You May Also Like',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildRecommendations(provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCast(MovieDetailsProvider provider) {
    if (provider.isCastLoading) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.castError != null) {
      return Text(
        'Failed to load cast.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    if (provider.cast.isEmpty) {
      return Text(
        'No cast information available.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final castCount = provider.cast.length > 10 ? 10 : provider.cast.length;

    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: castCount,
        separatorBuilder: (_, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final cast = provider.cast[index];

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
        },
      ),
    );
  }

  Widget _buildRecommendations(MovieDetailsProvider provider) {
    if (provider.isRecommendationsLoading) {
      return const SizedBox(
        height: 290,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.recommendations.isEmpty) {
      return Text(
        'No recommendations available.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final recommendationCount = provider.recommendations.length > 10
        ? 10
        : provider.recommendations.length;

    return SizedBox(
      height: 290,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
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
      child: const Icon(Icons.person_outline_rounded, size: 42),
    );
  }

  Widget _buildMovieActions(MovieListProvider provider) {
    final movie = provider.currentMovie!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Library',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
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
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: isActive
            ? AppColors.primary
            : Theme.of(context).colorScheme.onSurface,
        side: BorderSide(
          color: isActive ? AppColors.primary : Theme.of(context).dividerColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget? _buildGenreChip(String name) {
    if (name.isEmpty) {
      return null;
    }

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
}

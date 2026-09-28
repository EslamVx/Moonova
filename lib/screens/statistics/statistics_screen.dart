import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/movie_list_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieListProvider>();
    final theme = Theme.of(context);

    final favorites = provider.favorites.length;
    final watched = provider.watched.length;
    final watching = provider.watching.length;
    final wantToWatch = provider.wantToWatch.length;

    final totalMovies = {
      ...provider.favorites.map((movie) => movie.movieId),
      ...provider.watched.map((movie) => movie.movieId),
      ...provider.watching.map((movie) => movie.movieId),
      ...provider.wantToWatch.map((movie) => movie.movieId),
    }.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Movie Library',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A quick overview of your movie activity.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  _buildTotalCard(context, totalMovies),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.25,
                    children: [
                      _buildStatCard(
                        context,
                        icon: Icons.favorite_rounded,
                        title: 'Favorites',
                        value: favorites,
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.visibility_rounded,
                        title: 'Watched',
                        value: watched,
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.play_circle_fill_rounded,
                        title: 'Watching',
                        value: watching,
                      ),
                      _buildStatCard(
                        context,
                        icon: Icons.bookmark_rounded,
                        title: 'Want to Watch',
                        value: wantToWatch,
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTotalCard(BuildContext context, int totalMovies) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.movie_rounded, size: 42, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            '$totalMovies',
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Total Movies',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int value,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 30, color: theme.colorScheme.primary),
          Text(
            '$value',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

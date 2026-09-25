import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/movie.dart';
import '../../providers/movie_provider.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().loadMovieDetails(widget.movie.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Movie Details')),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(MovieProvider provider) {
    if (provider.isLoadingDetails) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.detailsErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            provider.detailsErrorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final movie = provider.selectedMovie;

    if (movie == null) {
      return const Center(child: Text('Movie not found'));
    }

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
              ],
            ),
          ),
        ],
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

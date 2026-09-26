import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/movie.dart';
import '../../providers/auth_provider.dart';
import '../../providers/movie_provider.dart';
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
                MaterialPageRoute(builder: (_) => const LibraryScreen()),
              );
            },
            icon: const Icon(Icons.video_library_outlined),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => authProvider.isAuthenticated
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
    if (provider.isLoading && provider.popularMovies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.popularMovies.isEmpty) {
      return Center(child: Text(provider.errorMessage!));
    }

    if (provider.popularMovies.isEmpty && provider.trendingMovies.isEmpty) {
      return const Center(child: Text('No movies found'));
    }

    final featuredMovie = provider.trendingMovies.isNotEmpty
        ? provider.trendingMovies.first
        : provider.popularMovies.first;

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
          _buildFeaturedMovie(featuredMovie),
          const SizedBox(height: 28),
          if (provider.popularMovies.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Movies',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieListScreen(
                            title: 'Popular Movies',
                            movies: provider.popularMovies,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'See all',
                      style: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            MovieHorizontalList(movies: provider.popularMovies),
          ],
          if (provider.trendingMovies.isNotEmpty) ...[
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trending Now',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieListScreen(
                            title: 'Trending Now',
                            movies: provider.trendingMovies,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'See all',
                      style: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            MovieHorizontalList(movies: provider.trendingMovies),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFeaturedMovie(Movie movie) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MovieDetailsScreen(movie: movie)),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 420,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://image.tmdb.org/t/p/w780${movie.backdropPath}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: AppColors.darkSurfaceSoft);
                  },
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                          const SizedBox(width: 12),
                          Text(
                            movie.releaseDate.isNotEmpty
                                ? movie.releaseDate.substring(0, 4)
                                : 'N/A',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
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
}

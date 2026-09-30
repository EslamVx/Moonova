import 'package:flutter/material.dart';

import '../../models/movie.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/movie_card.dart';

class MovieListScreen extends StatelessWidget {
  final String title;
  final List<Movie> movies;

  const MovieListScreen({super.key, required this.title, required this.movies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: movies.isEmpty
          ? const EmptyState(
              title: 'No movies found',
              message: 'There are no movies available in this list.',
              icon: Icons.movie_filter_outlined,
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              itemCount: movies.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
                mainAxisExtent: 325,
              ),
              itemBuilder: (context, index) {
                final movie = movies[index];

                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.94, end: 1),
                  duration: Duration(milliseconds: 250 + (index * 40)),
                  curve: Curves.easeOutCubic,
                  child: MovieCard(movie: movie),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 12 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

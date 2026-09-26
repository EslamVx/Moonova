import 'package:flutter/material.dart';

import '../../models/movie.dart';
import '../../widgets/movie_card.dart';

class MovieListScreen extends StatelessWidget {
  final String title;
  final List<Movie> movies;

  const MovieListScreen({super.key, required this.title, required this.movies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        itemCount: movies.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 24,
          mainAxisExtent: 325,
        ),
        itemBuilder: (context, index) {
          return MovieCard(movie: movies[index]);
        },
      ),
    );
  }
}

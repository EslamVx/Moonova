import 'package:flutter/material.dart';

import '../models/movie.dart';
import 'movie_card.dart';

class MovieHorizontalList extends StatelessWidget {
  final List<Movie> movies;

  const MovieHorizontalList({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: movies.length,
        separatorBuilder: (_, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return MovieCard(movie: movies[index]);
        },
      ),
    );
  }
}

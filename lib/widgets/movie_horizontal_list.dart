import 'package:flutter/material.dart';

import '../models/movie.dart';
import 'movie_card.dart';
import 'movie_card_skeleton.dart';

class MovieHorizontalList extends StatelessWidget {
  final List<Movie> movies;
  final bool isLoading;

  const MovieHorizontalList({
    super.key,
    required this.movies,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: isLoading ? 6 : movies.length,
        separatorBuilder: (_, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          if (isLoading) {
            return MovieCardSkeleton(width: 150);
          }

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.94, end: 1),
            duration: Duration(milliseconds: 250 + (index * 50)),
            curve: Curves.easeOutCubic,
            child: MovieCard(movie: movies[index], width: 150),
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

import 'package:flutter/material.dart';
import 'package:popcorn_hub/feature/movies/models/movie.dart';
import 'package:popcorn_hub/feature/movies/widgets/movie_card.dart';

class MovieGrid extends StatelessWidget {
  const MovieGrid({
    required this.movies,
    required this.scrollController,
    required this.isLoadingMore,
    required this.onFavoritePressed,
    super.key,
  });
  final List<Movie> movies;
  final ScrollController scrollController;
  final bool isLoadingMore;
  final void Function(Movie)
      onFavoritePressed; // Updated with explicit return type

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return MovieCard(
                movie: movie,
                onFavoritePressed: () => onFavoritePressed(movie),
              );
            },
          ),
        ),
        if (isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}

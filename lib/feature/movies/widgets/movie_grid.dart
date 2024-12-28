import 'package:flutter/material.dart';
import 'package:popcorn_hub/feature/movies/models/movie.dart';
import 'package:popcorn_hub/feature/movies/widgets/movie_card.dart';

/// A grid view that displays a collection of movies.
///
/// This widget creates a responsive grid of movie cards with infinite scrolling
/// capability and loading indicators.
///
/// Example usage:
/// ```dart
/// MovieGrid(
///   movies: moviesList,
///   scrollController: scrollController,
///   isLoadingMore: false,
///   onFavoritePressed: (movie) {
///     // Handle favorite toggle
///   },
/// )
/// ```
class MovieGrid extends StatelessWidget {
  /// Creates a movie grid.
  ///
  /// All parameters are required:
  /// * [movies] - The list of movies to display
  /// * [scrollController] - Controller for handling scroll events
  /// * [isLoadingMore] - Indicates if more items are being loaded
  /// * [onFavoritePressed] - Callback when a movie's favorite status is toggled
  const MovieGrid({
    required this.movies,
    required this.scrollController,
    required this.isLoadingMore,
    required this.onFavoritePressed,
    super.key,
  });

  /// The list of movies to display in the grid.
  final List<Movie> movies;

  /// Controller for handling scroll events and pagination.
  final ScrollController scrollController;

  /// Indicates whether more movies are being loaded.
  final bool isLoadingMore;

  /// Callback function when a movie's favorite status is toggled.
  ///
  /// Takes a [Movie] parameter and returns void.
  final void Function(Movie) onFavoritePressed;

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

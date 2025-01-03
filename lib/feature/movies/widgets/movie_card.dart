import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:popcorn_hub/core/api/api_config.dart';
import 'package:popcorn_hub/feature/movies/models/movie.dart';

/// A card widget that displays a movie's poster and title.
///
/// This widget creates a visually appealing card with:
/// * Movie poster image with loading and error states
/// * Movie title with ellipsis for overflow
/// * Favorite toggle button
///
/// Example usage:
/// ```dart
/// MovieCard(
///   movie: Movie(
///     title: 'Movie Title',
///     posterPath: '/path/to/poster.jpg',
///     isFavorite: false,
///   ),
///   onFavoritePressed: () {
///     // Handle favorite toggle
///   },
/// )
/// ```
class MovieCard extends StatelessWidget {
  /// Creates a movie card.
  ///
  /// Requires:
  /// * [movie] - The movie data to display
  /// * [onFavoritePressed] - Callback when the favorite button is pressed
  const MovieCard({
    required this.movie,
    required this.onFavoritePressed,
    super.key,
  });

  /// The movie data to display in the card.
  final Movie movie;

  /// Callback function when the favorite button is pressed.
  final VoidCallback onFavoritePressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: '${ApiConfig.imageBaseUrl}${movie.posterPath}',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.error),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  movie.title ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onFavoritePressed,
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                  ),
                  child: Icon(
                    movie.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: movie.isFavorite ? Colors.red : Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

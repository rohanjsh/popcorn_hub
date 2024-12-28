import 'package:popcorn_hub/core/api/api_client.dart';
import 'package:popcorn_hub/core/api/api_config.dart';
import 'package:popcorn_hub/feature/movies/models/movie.dart';

/// Repository class responsible for handling movie-related API operations.
///
/// This repository provides methods to fetch trending movies and search for
/// movies
/// using TMDB API. It uses [ApiClient] to make HTTP requests and handles the
/// response parsing.
///
/// Example usage:
/// ```dart
/// final apiClient = ApiClient();
/// final repository = MoviesRepository(apiClient);
///
/// // Fetch trending movies
/// final trendingMovies = await repository.getTrendingMovies(1);
///
/// // Search for movies
/// final searchResults = await repository.searchMovies('The Matrix');
/// ```
class MoviesRepository {
  /// Creates a [MoviesRepository] instance with the provided [ApiClient].
  ///
  /// The [_apiClient] parameter is required and will be used for making
  /// HTTP requests to the movie API endpoints.
  MoviesRepository(this._apiClient);
  final ApiClient _apiClient;

  /// Fetches trending movies for the specified page.
  ///
  /// Makes a GET request to the trending movies endpoint and returns a list
  /// of [Movie] objects.
  ///
  /// Parameters:
  ///   - [page]: The page number to fetch (starts from 1)
  ///
  /// Returns:
  ///   A [Future] that resolves to a [List<Movie>] containing the trending
  /// movies.
  ///
  /// Throws:
  ///   - [Exception] if the API request fails or returns invalid data.
  ///
  /// Example:
  /// ```dart
  /// final movies = await repository.getTrendingMovies(1);
  /// for (final movie in movies) {
  ///   print('${movie.title} (${movie.releaseDate})');
  /// }
  /// ```
  Future<List<Movie>> getTrendingMovies(int page) async {
    final response = await _apiClient.get(
      ApiConfig.trendingMovies,
      queryParameters: {'page': page},
      fromJson: (json) => (json['results'] as List)
          .map((movieJson) => Movie.fromJson(movieJson as Map<String, dynamic>))
          .toList(),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Failed to fetch movies');
    }

    return response.data!;
  }

  /// Searches for movies based on the provided query.
  ///
  /// Makes a GET request to the search endpoint and returns a list of
  /// [Movie] objects that match the search criteria.
  ///
  /// Parameters:
  ///   - [query]: The search term to look for in movie titles and descriptions
  ///
  /// Returns:
  ///   A [Future] that resolves to a [List<Movie>] containing the search
  /// results.
  ///
  /// Throws:
  ///   - [Exception] if the API request fails or returns invalid data.
  ///
  /// Example:
  /// ```dart
  /// final searchResults = await repository.searchMovies('Inception');
  /// print('Found ${searchResults.length} movies matching "Inception"');
  /// ```
  Future<List<Movie>> searchMovies(String query) async {
    final response = await _apiClient.get(
      ApiConfig.searchMovies,
      queryParameters: {
        'query': query,
        'page': 1,
      },
      fromJson: (json) => (json['results'] as List)
          .map((movieJson) => Movie.fromJson(movieJson as Map<String, dynamic>))
          .toList(),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Failed to search movies');
    }

    return response.data!;
  }
}

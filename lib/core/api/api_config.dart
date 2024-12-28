// ignore_for_file: lines_longer_than_80_chars

/// Configuration class containing API-related constants and endpoints.
///
/// This class provides centralized access to all API-related configuration
/// including base URLs, authentication keys, and endpoint paths.
class ApiConfig {
  const ApiConfig._();

  /// The base URL for TMDB API v3.
  static const String baseUrl = 'https://api.themoviedb.org/3';

  /// Authentication bearer token for TMDB API access.
  ///
  /// This token is used in the Authorization header for all API requests.
  static const String authKey =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwNzYwZjdjMDRhMDNmZDc0ODlhMmExODczNDNjODJmMCIsIm5iZiI6MTYzMzU4ODIwMy45MzkwMDAxLCJzdWIiOiI2MTVlOTNlYmQxNDQ0MzAwNjAzMDQyY2UiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.LZnwIow7OZ8LzluutBuCgpglGUOgKk0lN9LFM83V5c8';

  /// Endpoint for fetching trending movies of the day.
  static const String trendingMovies = '/trending/movie/day';

  /// Endpoint for searching movies by query.
  static const String searchMovies = '/search/movie';

  /// Base URL for fetching movie images with width 500px.
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  /// Base URL for fetching original size movie images.
  static const String imageOriginalBaseUrl =
      'https://image.tmdb.org/t/p/original';
}

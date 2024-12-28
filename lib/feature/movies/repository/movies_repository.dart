import 'package:popcorn_hub/core/api/api_client.dart';
import 'package:popcorn_hub/core/api/api_config.dart';
import 'package:popcorn_hub/feature/movies/models/movie.dart';

class MoviesRepository {
  MoviesRepository(this._apiClient);
  final ApiClient _apiClient;

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

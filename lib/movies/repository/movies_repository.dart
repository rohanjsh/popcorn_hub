// ignore_for_file: avoid_dynamic_calls, inference_failure_on_function_invocation

import 'package:dio/dio.dart';
import 'package:popcorn_hub/movies/models/movie.dart';

class MoviesRepository {
  MoviesRepository(this._dio) {
    _dio.options.headers['Authorization'] =
        'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwNzYwZjdjMDRhMDNmZDc0ODlhMmExODczNDNjODJmMCIsIm5iZiI6MTYzMzU4ODIwMy45MzkwMDAxLCJzdWIiOiI2MTVlOTNlYmQxNDQ0MzAwNjAzMDQyY2UiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.LZnwIow7OZ8LzluutBuCgpglGUOgKk0lN9LFM83V5c8';
  }
  final Dio _dio;

  Future<List<Movie>> getTrendingMovies(int page) async {
    try {
      final response = await _dio.get(
        'https://api.themoviedb.org/3/trending/movie/day',
        queryParameters: {
          'page': page,
        },
      );

      return (response.data['results'] as List)
          .map((json) => Movie.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch movies');
    }
  }
}

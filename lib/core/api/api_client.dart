import 'package:dio/dio.dart';
import 'package:popcorn_hub/core/api/api_config.dart';
import 'package:popcorn_hub/core/api/api_response.dart';

/// A client for making HTTP requests to the TMDB API.
///
/// This client handles authentication, request interceptors, and response
/// parsing.
/// It uses [Dio] as the underlying HTTP client and wraps responses in
/// [ApiResponse].
///
/// Example usage:
/// ```dart
/// final apiClient = ApiClient();
///
/// // Fetch movie details
/// final response = await apiClient.get<Movie>(
///   '/movie/550',
///   fromJson: (json) => Movie.fromJson(json),
/// );
///
/// if (response.success) {
///   final movie = response.data;
///   print(movie.title);
/// } else {
///   print('Error: ${response.error}');
/// }
/// ```
class ApiClient {
  /// Creates a new instance of [ApiClient] with preconfigured [Dio] settings.
  ///
  /// Initializes [Dio] with base URL and authorization headers from [ApiConfig]
  /// .
  /// Sets up request/response interceptors for logging and error handling.
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        headers: {
          'Authorization': 'Bearer ${ApiConfig.authKey}',
          'Content-Type': 'application/json',
        },
      ),
    );
    _setupInterceptors();
  }

  late final Dio _dio;

  /// Configures request, response, and error interceptors for the [Dio]
  /// instance.
  ///
  /// These interceptors can be used for logging, request/response transformation,
  /// error handling, and other cross-cutting concerns.
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          return handler.reject(error);
        },
        onRequest: (request, handler) async {
          return handler.next(request);
        },
        onResponse: (response, handler) async {
          return handler.next(response);
        },
      ),
    );
  }

  /// Performs a GET request to the specified endpoint.
  ///
  /// Parameters:
  /// - [path]: The API endpoint path relative to the base URL
  /// - [queryParameters]: Optional query parameters to append to the URL
  /// - [fromJson]: Optional function to convert the JSON response to type [T]
  ///
  /// Returns an [ApiResponse<T>] containing either the parsed data or error
  /// information.
  ///
  /// Example:
  /// ```dart
  /// final response = await apiClient.get<List<Movie>>(
  ///   ApiConfig.trendingMovies,
  ///   queryParameters: {'page': 1},
  ///   fromJson: (json) => (json['results'] as List)
  ///     .map((e) => Movie.fromJson(e))
  ///     .toList(),
  /// );
  /// ```
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    try {
      final response =
          await _dio.get<dynamic>(path, queryParameters: queryParameters);
      return ApiResponse.success(
        data: fromJson?.call(response.data as Map<String, dynamic>) ??
            response.data as T,
      );
    } on DioException catch (e) {
      return ApiResponse.error(message: e.message ?? 'Network error occurred');
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }
}

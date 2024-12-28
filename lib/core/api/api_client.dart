import 'package:dio/dio.dart';
import 'package:popcorn_hub/core/api/api_config.dart';
import 'package:popcorn_hub/core/api/api_response.dart';

class ApiClient {
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

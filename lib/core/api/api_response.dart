class ApiResponse<T> {
  ApiResponse.success({required this.data})
      : error = null,
        success = true;

  ApiResponse.error({String? message})
      : data = null,
        error = message,
        success = false;
  final T? data;
  final String? error;
  final bool success;
}

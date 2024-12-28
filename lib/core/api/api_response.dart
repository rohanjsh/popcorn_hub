/// A generic wrapper class for API responses that handles both success and error cases.
///
/// Type parameter [T] represents the expected data type for successful responses.
///
/// Example usage:
/// ```dart
/// // Success response with data
/// final successResponse = ApiResponse<User>.success(data: user);
/// if (successResponse.success) {
///   print(successResponse.data);
/// }
///
/// // Error response
/// final errorResponse = ApiResponse<User>.error(message: 'User not found');
/// if (!errorResponse.success) {
///   print(errorResponse.error);
/// }
/// ```
class ApiResponse<T> {
  /// Creates a success response with required data.
  ///
  /// [data] contains the successful response data of type [T].
  ApiResponse.success({required this.data})
      : error = null,
        success = true;

  /// Creates an error response with an optional error message.
  ///
  /// [message] is the error description that occurred during the API call.
  ApiResponse.error({String? message})
      : data = null,
        error = message,
        success = false;

  /// The response data of type [T] when the API call is successful.
  final T? data;

  /// The error message when the API call fails.
  final String? error;

  /// Indicates whether the API call was successful.
  final bool success;
}

import 'package:dio/dio.dart';

class ApiResponse {
  final Response? response;
  final dynamic error;

  ApiResponse(this.response, this.error);

  ApiResponse.withError(dynamic errorValue)
      : response = null,
        error = errorValue;

  ApiResponse.withSuccess(Response responseValue)
      : response = responseValue,
        error = null;

  /// Check if the response is successful
  bool get isSuccess => response != null && error == null;

  /// Get the response data
  dynamic get data => response?.data;

  /// Get the error message
  String get message => error?.toString() ?? 'Unknown error';

  /// Get the status code
  int? get statusCode => response?.statusCode;
}

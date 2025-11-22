import 'package:dio/dio.dart';
import 'my_error_response.dart';
import '../../../util/app_constant.dart';

class ApiErrorHandler {
  static dynamic getMessage(error) {
    dynamic errorDescription = "";
    if (error is Exception) {
      try {
        if (error is DioException) {
          switch (error.type) {
            case DioExceptionType.connectionError:
            case DioExceptionType.cancel:
            // errorDescription = "Request to API server was cancelled";
              errorDescription = AppConstants.networkServerError;
              break;
            case DioExceptionType.connectionTimeout:
            // errorDescription = "Connection timeout with API server";
              errorDescription = AppConstants.networkServerError;
              break;
            case DioExceptionType.unknown:
              errorDescription =
              // "Connection to API server failed due to internet connection";
              AppConstants.networkServerError;
              break;
            case DioExceptionType.receiveTimeout:
              errorDescription = "Request timed out. The server is taking too long to respond. Please try again later.";
              break;
            case DioExceptionType.badResponse:
              switch (error.response?.statusCode) {
                case 404:
                  errorDescription = "Endpoint not found. Please check if the server is running.";
                  break;
                case 401:
                  errorDescription = "Unauthorized. Please check your credentials.";
                  break;
                case 400:
                  errorDescription = "Bad request. Please check your input data.";
                  break;
                case 500:
                case 502:
                  errorDescription = "Server error. Please try again later.";
                  break;
                case 503:
                  errorDescription = "Service unavailable. Please try again later.";
                  break;
                case 409:
                  errorDescription = "User already has a wallet";
                  break;
                case 402:
                  try {
                    MyMethodErrorResponse myMethodErrorResponse =
                    MyMethodErrorResponse.fromJson(error.response?.data);
                    if (myMethodErrorResponse.message.isNotEmpty) {
                      errorDescription = myMethodErrorResponse;
                    } else {
                      errorDescription =
                      "Payment required - status code: ${error.response?.statusCode}";
                    }
                  } catch (e) {
                    errorDescription =
                    "Payment required - status code: ${error.response?.statusCode}";
                  }
                  break;
                default:
                  try {
                    MyErrorResponse errorResponse =
                    MyErrorResponse.fromJson(error.response?.data);
                    if (errorResponse.message.isNotEmpty) {
                      errorDescription = errorResponse;
                    } else {
                      errorDescription =
                      "Failed to load data - status code: ${error.response?.statusCode}";
                    }
                  } catch (e) {
                    errorDescription =
                    "Failed to load data - status code: ${error.response?.statusCode}";
                  }
              }
              break;
            case DioExceptionType.sendTimeout:
              errorDescription = AppConstants.networkServerError;
              break;
            case DioExceptionType.badCertificate:
            // TODO: Handle this case.
              break;
          }
        } else {
          errorDescription = "Unexpected error occured";
        }
      } on FormatException catch (e) {
        errorDescription = e.toString();
      }
    } else {
      errorDescription = "is not a subtype of exception";
    }
    return errorDescription;
  }
}
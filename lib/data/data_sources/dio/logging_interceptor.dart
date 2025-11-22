import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

class LoggingInterceptor extends InterceptorsWrapper {
  int maxCharactersPerLine = 200;

  @override
  Future onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Log basic request information
    print("--> ${options.method} ${options.baseUrl + options.path}");
    print("Headers: ${options.headers}");

    // Check if the request data is FormData
    if (options.data is FormData) {
      FormData formData = options.data as FormData;

      // Log FormData fields
      for (var field in formData.fields) {
        print("Field: ${field.key} = ${field.value}");
      }

      // Log FormData files
      for (var file in formData.files) {
        print("File: ${file.key} = ${file.value.filename}");
      }
    } else {
      // Log JSON or other data types
      try {
        log("Params: ${json.encode(options.data)}");
      } catch (e) {
        print("Params: ${options.data}");
      }
    }

    print("<-- END HTTP");
    return super.onRequest(options, handler);
  }

  @override
  Future onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    // Log basic response information
    print(
        "<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.baseUrl + response.requestOptions.path}");
    print("Headers: ${response.headers}");

    // Log response body in chunks if it's too long
    String responseAsString = response.data.toString();
    if (responseAsString.length > maxCharactersPerLine) {
      int iterations = (responseAsString.length / maxCharactersPerLine).floor();
      for (int i = 0; i <= iterations; i++) {
        int endingIndex = i * maxCharactersPerLine + maxCharactersPerLine;
        if (endingIndex > responseAsString.length) {
          endingIndex = responseAsString.length;
        }
        print(
            responseAsString.substring(i * maxCharactersPerLine, endingIndex));
      }
    } else {
      print(response.data);
    }

    print("<-- END HTTP");
    return super.onResponse(response, handler);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    // Log error information
    print(
        "ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}");
    print("Message: ${err.message}");

    if (err.response != null) {
      String responseAsString = err.response.toString();
      if (responseAsString.length > maxCharactersPerLine) {
        int iterations =
        (responseAsString.length / maxCharactersPerLine).floor();
        for (int i = 0; i <= iterations; i++) {
          int endingIndex = i * maxCharactersPerLine + maxCharactersPerLine;
          if (endingIndex > responseAsString.length) {
            endingIndex = responseAsString.length;
          }
          print(responseAsString.substring(
              i * maxCharactersPerLine, endingIndex));
        }
      } else {
        print(err.response);
      }
    }

    print("<-- END ERROR");

    // Map connectivity/timeout to friendly message
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown) {
      final friendly = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: 'No internet connection or either server is down.',
      );
      return handler.next(friendly);
    }

    return super.onError(err, handler);
  }
}

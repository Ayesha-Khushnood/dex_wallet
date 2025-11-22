/// statusCode : 400
/// message : ["User Email Already Exist"]
/// error : "Bad Request"
library;

class MyErrorResponse {
  MyErrorResponse({
    int? statusCode,
    required List<String> message,
    String? error,
  }) {
    _statusCode = statusCode;
    _message = message;
    _error = error;
  }

  MyErrorResponse.fromJson(dynamic json) {
    _statusCode = json['statusCode'];
    _message = json['message'] != null ? json['message'].cast<String>() : [];
    _error = json['error'];
  }
  int? _statusCode;
  List<String> _message = <String>[];
  String? _error;

  int? get statusCode => _statusCode;
  List<String> get message => _message;
  String? get error => _error;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['statusCode'] = _statusCode;
    map['message'] = _message;
    map['error'] = _error;
    return map;
  }
}

class MyMethodErrorResponse {
  MyMethodErrorResponse({
    int? statusCode,
    required String message,
    String? error,
  }) {
    _statusCode = statusCode;
    _message = message;
    _error = error;
  }

  MyMethodErrorResponse.fromJson(dynamic json) {
    print('this is my error ${json['message']}');
    _statusCode = json['statusCode'];
    _message = json['message'] ?? '';
    _error = json['error'];
  }
  int? _statusCode;
  String _message = '';
  String? _error;

  int? get statusCode => _statusCode;
  String get message => _message;
  String? get error => _error;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['statusCode'] = _statusCode;
    map['message'] = _message;
    map['error'] = _error;
    return map;
  }
}

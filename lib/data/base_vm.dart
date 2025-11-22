import 'package:flutter/material.dart';

/// Base ViewModel for all screens
/// Contains common properties and methods (e.g., loading state).
class BaseVM extends ChangeNotifier {
  bool _isLoading = false;
  bool _disposed = false;

  bool get isLoading => _isLoading;
  bool get mounted => !_disposed;
  bool get disposed => _disposed;

  /// Updates loading state and notifies listeners
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

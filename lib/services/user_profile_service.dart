import 'package:flutter/material.dart';
import '../data/repos/auth_repo.dart';
import '../data/model/user_model.dart';

class UserProfileService extends ChangeNotifier {
  static UserProfileService? _instance;
  static UserProfileService get instance {
    _instance ??= UserProfileService._internal();
    return _instance!;
  }

  UserProfileService._internal();

  final AuthRepo _authRepo = AuthRepo();
  
  UserModel? _user;
  bool _isLoading = false;
  bool _isLoaded = false;
  String? _error;
  DateTime? _lastLoaded;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  bool get hasUser => _user != null;
  String? get error => _error;
  bool get isStale => _lastLoaded == null || 
    DateTime.now().difference(_lastLoaded!).inMinutes > 5; // 5 minutes cache

  /// Load user profile from API (with caching)
  Future<void> loadUserProfile({bool forceRefresh = false}) async {
    // If already loaded and not stale, don't reload
    if (_isLoaded && !forceRefresh && !isStale) {
      print('📋 UserProfileService - Using cached profile data');
      return;
    }

    // If already loading, don't start another request
    if (_isLoading) {
      print('⏳ UserProfileService - Already loading profile...');
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      print('🔄 UserProfileService - Loading user profile...');
      
      final response = await _authRepo.getUserProfile();
      
      if (response.isSuccess) {
        print('✅ UserProfileService - User profile loaded successfully');
        
        // Extract user data from response
        final userData = _extractUserFromResponse(response.data);
        if (userData != null) {
          _user = userData;
          _isLoaded = true;
          _lastLoaded = DateTime.now();
          _error = null;
        } else {
          _error = 'Failed to parse user data';
        }
      } else {
        _error = response.message ?? 'Failed to load user profile';
        print('❌ UserProfileService - Failed to load user profile: $_error');
      }
    } catch (e) {
      _error = 'Network error: $e';
      print('💥 UserProfileService - Exception loading user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile({
    String? username,
    String? firstName,
    String? lastName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      print('🔄 UserProfileService - Updating user profile...');
      
      final response = await _authRepo.updateUserProfile(
        username: username,
        firstName: firstName,
        lastName: lastName,
      );
      
      if (response.isSuccess) {
        print('✅ UserProfileService - User profile updated successfully');
        
        // Update local user data
        final userData = _extractUserFromResponse(response.data);
        if (userData != null) {
          _user = userData;
          _lastLoaded = DateTime.now();
          _error = null;
          notifyListeners();
          return true;
        } else {
          _error = 'Failed to parse updated user data';
          return false;
        }
      } else {
        _error = response.message ?? 'Failed to update user profile';
        print('❌ UserProfileService - Failed to update user profile: $_error');
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      print('💥 UserProfileService - Exception updating user profile: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear cached data
  void clearCache() {
    _user = null;
    _isLoaded = false;
    _error = null;
    _lastLoaded = null;
    notifyListeners();
  }

  /// Extract user data from API response
  UserModel? _extractUserFromResponse(dynamic responseData) {
    try {
      if (responseData is Map<String, dynamic>) {
        if (responseData['data'] != null && responseData['data'] is Map<String, dynamic>) {
          final data = responseData['data'] as Map<String, dynamic>;
          if (data['user'] != null && data['user'] is Map<String, dynamic>) {
            return UserModel.fromJson(data['user'] as Map<String, dynamic>);
          }
        }
      }
    } catch (e) {
      print('⚠️ UserProfileService - Could not extract user from response: $e');
    }
    return null;
  }

  /// Format date for display
  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Not available';
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  /// Get verification status text
  String getVerificationStatus() {
    if (_user == null) return 'Unknown';
    if (_user!.isEmailVerified) return 'Verified';
    return 'Not Verified';
  }

  /// Get verification status color
  Color getVerificationColor() {
    if (_user == null) return Colors.grey;
    if (_user!.isEmailVerified) return Colors.green;
    return Colors.orange;
  }
}

import 'package:flutter/material.dart';
import '../../../../data/base_vm.dart';
import '../../../../data/model/user_model.dart';
import '../../../../services/user_profile_service.dart';

class UserProfileVM extends BaseVM {
  final UserProfileService _profileService = UserProfileService.instance;
  
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  
  bool _isUpdating = false;
  bool _isEditMode = false;
  
  // Getters
  UserModel? get user => _profileService.user;
  bool get isLoading => _profileService.isLoading;
  bool get isUpdating => _isUpdating;
  bool get isEditMode => _isEditMode;
  bool get hasUser => _profileService.hasUser;
  String? get error => _profileService.error;
  
  /// Load user profile from service (with caching)
  Future<void> loadUserProfile() async {
    await _profileService.loadUserProfile();
    _populateControllers();
    notifyListeners();
  }
  
  /// Update user profile
  Future<void> updateUserProfile() async {
    if (!_validateInputs()) return;
    
    _isUpdating = true;
    notifyListeners();
    
    final success = await _profileService.updateUserProfile(
      username: usernameController.text.trim(),
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
    );
    
    if (success) {
      _populateControllers();
      _isEditMode = false;
    }
    
    _isUpdating = false;
    notifyListeners();
  }
  
  /// Toggle edit mode
  void toggleEditMode() {
    _isEditMode = !_isEditMode;
    if (_isEditMode) {
      _populateControllers();
    }
    notifyListeners();
  }
  
  /// Cancel edit mode
  void cancelEdit() {
    _isEditMode = false;
    _populateControllers(); // Reset to original values
    notifyListeners();
  }
  
  /// Populate text controllers with current user data
  void _populateControllers() {
    if (_profileService.user != null) {
      usernameController.text = _profileService.user!.username;
      firstNameController.text = _profileService.user!.firstName;
      lastNameController.text = _profileService.user!.lastName;
    }
  }
  
  
  /// Validate form inputs
  bool _validateInputs() {
    if (usernameController.text.trim().isEmpty) {
      print('❌ Username is required');
      return false;
    }
    
    if (firstNameController.text.trim().isEmpty) {
      print('❌ First name is required');
      return false;
    }
    
    if (lastNameController.text.trim().isEmpty) {
      print('❌ Last name is required');
      return false;
    }
    
    return true;
  }
  
  /// Format date for display
  String formatDate(String? dateString) {
    return _profileService.formatDate(dateString);
  }
  
  /// Get verification status text
  String getVerificationStatus() {
    return _profileService.getVerificationStatus();
  }
  
  /// Get verification status color
  Color getVerificationColor() {
    return _profileService.getVerificationColor();
  }
  
  @override
  void dispose() {
    usernameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }
}

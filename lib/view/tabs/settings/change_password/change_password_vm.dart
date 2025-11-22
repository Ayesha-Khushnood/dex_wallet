import 'package:flutter/material.dart';
import '../../../../data/base_vm.dart';
import '../../../../data/repos/auth_repo.dart';

class ChangePasswordVM extends BaseVM {
  final AuthRepo _authRepo = AuthRepo();
  
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isCurrentPasswordVisible => _isCurrentPasswordVisible;
  bool get isNewPasswordVisible => _isNewPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  
  void toggleCurrentPasswordVisibility() {
    _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
    notifyListeners();
  }
  
  void toggleNewPasswordVisibility() {
    _isNewPasswordVisible = !_isNewPasswordVisible;
    notifyListeners();
  }
  
  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }
  
  /// Change user password
  Future<void> changePassword(BuildContext context) async {
    if (!_validateInputs(context)) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      print('🔄 Changing password...');
      
      final response = await _authRepo.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );
      
      if (response.isSuccess) {
        print('✅ Password changed successfully');
        
        _showSuccessDialog(
          context, 
          'Password Changed', 
          'Your password has been changed successfully.',
          () => Navigator.pop(context),
        );
      } else {
        print('❌ Failed to change password: ${response.message}');
        _showErrorDialog(context, 'Password Change Failed', response.message);
      }
    } catch (e) {
      print('💥 Exception during password change: $e');
      _showErrorDialog(context, 'Error', 'An unexpected error occurred: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Validate form inputs
  bool _validateInputs(BuildContext context) {
    if (currentPasswordController.text.isEmpty) {
      _showErrorDialog(context, 'Validation Error', 'Please enter your current password.');
      return false;
    }
    
    if (newPasswordController.text.isEmpty) {
      _showErrorDialog(context, 'Validation Error', 'Please enter a new password.');
      return false;
    }
    
    if (newPasswordController.text.length < 6) {
      _showErrorDialog(context, 'Validation Error', 'New password must be at least 6 characters long.');
      return false;
    }
    
    if (confirmPasswordController.text.isEmpty) {
      _showErrorDialog(context, 'Validation Error', 'Please confirm your new password.');
      return false;
    }
    
    if (newPasswordController.text != confirmPasswordController.text) {
      _showErrorDialog(context, 'Validation Error', 'New passwords do not match.');
      return false;
    }
    
    if (currentPasswordController.text == newPasswordController.text) {
      _showErrorDialog(context, 'Validation Error', 'New password must be different from current password.');
      return false;
    }
    
    return true;
  }
  
  void _showSuccessDialog(BuildContext context, String title, String message, [VoidCallback? onOk]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onOk?.call();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}

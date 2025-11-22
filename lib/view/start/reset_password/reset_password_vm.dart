import 'package:flutter/material.dart';
import '../../../data/base_vm.dart';
import '../../../data/repos/auth_repo.dart';

class ResetPasswordVM extends BaseVM {
  final AuthRepo _authRepo = AuthRepo();
  final String email;
  
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isResending = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  // Constructor
  ResetPasswordVM({required this.email});
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isResending => _isResending;
  bool get isNewPasswordVisible => _isNewPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  
  void toggleNewPasswordVisibility() {
    _isNewPasswordVisible = !_isNewPasswordVisible;
    notifyListeners();
  }
  
  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }
  
  Future<void> resetPassword(BuildContext context) async {
    if (!_validateInputs(context)) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      print('🔄 Resetting password...');
      
      final response = await _authRepo.resetPassword(
        email: email,
        otp: otpController.text.trim(),
        newPassword: newPasswordController.text,
      );
      
      if (response.isSuccess) {
        print('✅ Password reset successful');
        
        _showSuccessDialog(
          context, 
          'Password Reset Successful', 
          'Your password has been reset successfully. Please login with your new password.',
          () => Navigator.pushNamedAndRemoveUntil(
            context, 
            "/login", 
            (route) => false,
          ),
        );
      } else {
        print('❌ Password reset failed: ${response.message}');
        _showErrorDialog(context, 'Password Reset Failed', response.message);
      }
    } catch (e) {
      print('💥 Exception during password reset: $e');
      _showErrorDialog(context, 'Error', 'An unexpected error occurred: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> resendOTP(BuildContext context) async {
    if (_isResending) return;
    
    _isResending = true;
    notifyListeners();
    
    try {
      print('🔄 Resending password reset OTP...');
      
      final response = await _authRepo.sendPasswordResetOTP(
        email: email,
      );
      
      if (response.isSuccess) {
        print('✅ Password reset OTP resent successfully');
        _showSuccessDialog(
          context, 
          'OTP Sent', 
          'A new verification code has been sent to your email address.',
        );
      } else {
        print('❌ Failed to resend password reset OTP: ${response.message}');
        _showErrorDialog(context, 'Failed to Resend OTP', response.message);
      }
    } catch (e) {
      print('💥 Exception during OTP resend: $e');
      _showErrorDialog(context, 'Error', 'An unexpected error occurred: $e');
    } finally {
      _isResending = false;
      notifyListeners();
    }
  }
  
  bool _validateInputs(BuildContext context) {
    if (otpController.text.trim().isEmpty) {
      _showErrorDialog(context, 'Validation Error', 'Please enter the verification code.');
      return false;
    }
    
    if (otpController.text.trim().length < 4) {
      _showErrorDialog(context, 'Validation Error', 'Please enter a valid verification code.');
      return false;
    }
    
    if (newPasswordController.text.isEmpty) {
      _showErrorDialog(context, 'Validation Error', 'Please enter a new password.');
      return false;
    }
    
    if (newPasswordController.text.length < 6) {
      _showErrorDialog(context, 'Validation Error', 'Password must be at least 6 characters long.');
      return false;
    }
    
    if (confirmPasswordController.text.isEmpty) {
      _showErrorDialog(context, 'Validation Error', 'Please confirm your new password.');
      return false;
    }
    
    if (newPasswordController.text != confirmPasswordController.text) {
      _showErrorDialog(context, 'Validation Error', 'Passwords do not match.');
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
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}

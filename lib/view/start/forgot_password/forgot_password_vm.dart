import 'package:flutter/material.dart';
import '../../../data/base_vm.dart';
import '../../../data/repos/auth_repo.dart';

class ForgotPasswordVM extends BaseVM {
  final AuthRepo _authRepo = AuthRepo();
  
  final TextEditingController emailController = TextEditingController();
  
  bool _isLoading = false;
  
  // Getters
  bool get isLoading => _isLoading;
  
  Future<void> sendPasswordResetOTP(BuildContext context) async {
    if (!_validateInputs(context)) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      print('🔄 Sending password reset OTP...');
      
      final response = await _authRepo.sendPasswordResetOTP(
        email: emailController.text.trim(),
      );
      
      if (response.isSuccess) {
        print('✅ Password reset OTP sent successfully');
        
        // Navigate to reset password screen with email
        Navigator.pushReplacementNamed(
          context, 
          "/reset_password",
          arguments: emailController.text.trim(),
        );
      } else {
        print('❌ Failed to send password reset OTP: ${response.message}');
        _showErrorDialog(context, 'Failed to Send OTP', response.message);
      }
    } catch (e) {
      print('💥 Exception during password reset: $e');
      _showErrorDialog(context, 'Error', 'An unexpected error occurred: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  bool _validateInputs(BuildContext context) {
    if (emailController.text.trim().isEmpty) {
      _showErrorDialog(context, 'Validation Error', 'Please enter your email address.');
      return false;
    }
    
    if (!_isValidEmail(emailController.text.trim())) {
      _showErrorDialog(context, 'Validation Error', 'Please enter a valid email address.');
      return false;
    }
    
    return true;
  }
  
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
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
    emailController.dispose();
    super.dispose();
  }
}

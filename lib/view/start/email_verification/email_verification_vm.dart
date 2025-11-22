import 'package:flutter/material.dart';
import '../../../data/base_vm.dart';
import '../../../data/repos/auth_repo.dart';

class EmailVerificationVM extends BaseVM {
  final AuthRepo _authRepo = AuthRepo();
  final String email;
  
  final TextEditingController otpController = TextEditingController();
  
  bool _isLoading = false;
  bool _isResending = false;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isResending => _isResending;
  
  EmailVerificationVM({required this.email});
  
  Future<void> verifyEmail(BuildContext context) async {
    if (otpController.text.trim().isEmpty) {
      _showErrorDialog(context, 'Validation Error', 'Please enter the verification code.');
      return;
    }
    
    if (otpController.text.trim().length < 4) {
      _showErrorDialog(context, 'Validation Error', 'Please enter a valid verification code.');
      return;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      print('🔄 Verifying email with OTP...');
      
      final response = await _authRepo.verifyEmail(
        email: email,
        otp: otpController.text.trim(),
      );
      
      if (response.isSuccess) {
        print('✅ Email verification successful!');
        
        // After email verification, user needs to login
        print('📧 Email verified successfully, redirecting to login');
        Navigator.pushReplacementNamed(context, "/login");
      } else {
        print('❌ Email verification failed: ${response.message}');
        _showErrorDialog(context, 'Verification Failed', response.message);
      }
    } catch (e) {
      print('💥 Exception during email verification: $e');
      _showErrorDialog(context, 'Error', 'An unexpected error occurred: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> resendOTP(BuildContext context) async {
    _isResending = true;
    notifyListeners();
    
    try {
      print('🔄 Resending OTP...');
      
      final response = await _authRepo.sendEmailVerificationOTP(
        email: email,
      );
      
      if (response.isSuccess) {
        print('✅ OTP resent successfully');
        _showSuccessDialog(
          context, 
          'OTP Sent', 
          'A new verification code has been sent to your email address.'
        );
      } else {
        print('❌ Failed to resend OTP: ${response.message}');
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
  
  void _showSuccessDialog(BuildContext context, String title, String message) {
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
    super.dispose();
  }
}

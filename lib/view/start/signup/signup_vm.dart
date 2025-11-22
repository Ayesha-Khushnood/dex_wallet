import 'package:flutter/material.dart';
import '../../../data/base_vm.dart';
import '../../../data/repos/auth_repo.dart';

class SignupVM extends BaseVM {
  final AuthRepo _authRepo = AuthRepo();
  
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  bool get acceptTerms => _acceptTerms;
  
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }
  
  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }
  
  void toggleAcceptTerms(bool? value) {
    _acceptTerms = value ?? false;
    notifyListeners();
  }
  
  Future<void> signup(BuildContext context) async {
    if (!_validateInputs(context)) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      print('🔄 Starting signup process...');
      
      final response = await _authRepo.register(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
      );
      
      if (response.isSuccess) {
        print('✅ Registration successful!');
        
        // DON'T save auth token yet - user needs to verify email first
        print('📧 User needs to verify email before authentication');
        
        // Navigate to email verification (user must verify email first)
        // The backend should have already sent the OTP during registration
        Navigator.pushReplacementNamed(
          context, 
          "/email_verification",
          arguments: emailController.text.trim(),
        );
      } else {
        print('❌ Registration failed: ${response.message}');
        
        // Check if it's an "OTP already sent" error
        if (response.message.toLowerCase().contains('otp already sent') || 
            response.message.toLowerCase().contains('verification otp already sent')) {
          // This is actually a success case - user exists and OTP was sent
          print('📧 OTP already sent, redirecting to email verification');
          Navigator.pushReplacementNamed(
            context, 
            "/email_verification",
            arguments: emailController.text.trim(),
          );
        } else {
          _showErrorDialog(context, 'Registration Failed', response.message);
        }
      }
    } catch (e) {
      print('💥 Exception during signup: $e');
      
      // Check if it's an "OTP already sent" error in the exception
      if (e.toString().toLowerCase().contains('otp already sent') || 
          e.toString().toLowerCase().contains('verification otp already sent')) {
        // This is actually a success case - user exists and OTP was sent
        print('📧 OTP already sent (in exception), redirecting to email verification');
        Navigator.pushReplacementNamed(
          context, 
          "/email_verification",
          arguments: emailController.text.trim(),
        );
      } else {
        _showErrorDialog(context, 'Error', 'An unexpected error occurred: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void navigateToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/login");
  }

  
  bool _validateInputs(BuildContext context) {
    if (usernameController.text.trim().isEmpty) {
      _showErrorDialog(context, 'Validation Error', 'Please enter a username.');
      return false;
    }
    
    if (firstNameController.text.trim().isEmpty) {
      _showErrorDialog(context, 'Validation Error', 'Please enter your first name.');
      return false;
    }
    
    if (lastNameController.text.trim().isEmpty) {
      _showErrorDialog(context, 'Validation Error', 'Please enter your last name.');
      return false;
    }
    
    if (emailController.text.trim().isEmpty) {
      _showErrorDialog(context, 'Validation Error', 'Please enter your email address.');
      return false;
    }
    
    if (!_isValidEmail(emailController.text.trim())) {
      _showErrorDialog(context, 'Validation Error', 'Please enter a valid email address.');
      return false;
    }
    
    if (passwordController.text.isEmpty) {
      _showErrorDialog(context, 'Validation Error', 'Please enter your password.');
      return false;
    }
    
    if (passwordController.text.length < 6) {
      _showErrorDialog(context, 'Validation Error', 'Password must be at least 6 characters long.');
      return false;
    }
    
    if (confirmPasswordController.text.isEmpty) {
      _showErrorDialog(context, 'Validation Error', 'Please confirm your password.');
      return false;
    }
    
    if (passwordController.text != confirmPasswordController.text) {
      _showErrorDialog(context, 'Validation Error', 'Passwords do not match.');
      return false;
    }
    
    if (!_acceptTerms) {
      _showErrorDialog(context, 'Validation Error', 'Please accept the Terms and Conditions.');
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
    usernameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}

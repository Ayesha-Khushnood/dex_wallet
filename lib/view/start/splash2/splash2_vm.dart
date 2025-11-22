import 'package:flutter/material.dart';
import '../../../data/base_vm.dart';
import '../../../services/auth_service.dart';

/// ViewModel for Splash2Screen
class Splash2VM extends BaseVM {
  final AuthService _authService = AuthService();

  /// Waits for 2 seconds, then navigates based on authentication status
  Future<void> startSplash(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Check if PIN is set (this determines if user has completed setup)
    final isPinSet = await _authService.isPinSet();
    
    if (isPinSet) {
      // User has completed setup - go to PIN verification
      Navigator.pushReplacementNamed(context, "/pin_verification");
    } else {
      // User hasn't completed setup - check if first time
      final isFirstTime = await _authService.isFirstTime();
      
      if (isFirstTime) {
        // First time user - go to create PIN first
        Navigator.pushReplacementNamed(context, "/create_pin");
      } else {
        // Returning user without PIN - go to create PIN
        Navigator.pushReplacementNamed(context, "/create_pin");
      }
    }
  }
}

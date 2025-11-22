import '../../../data/base_vm.dart';
import 'package:flutter/material.dart';

class OnboardingVM extends BaseVM {
  /// Called when user taps "Get Started"
  void onGetStarted(BuildContext context) {
    // Navigate to Splash screen
    Navigator.pushReplacementNamed(context, "/splash");
  }
}

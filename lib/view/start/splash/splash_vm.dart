import 'package:flutter/material.dart';
import '../../../data/base_vm.dart';

/// ViewModel for SplashScreen
class SplashVM extends BaseVM {
  /// Waits for 2 seconds, then navigates to Splash2
  Future<void> startSplash(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pushReplacementNamed(context, "/splash2");
  }
}

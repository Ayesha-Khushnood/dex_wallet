import '../../../data/base_vm.dart';
import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

class CreatePinVM extends BaseVM {
  final TextEditingController pinController = TextEditingController();
  final FocusNode pinFocusNode = FocusNode();
  final AuthService _authService = AuthService();

  String _pin = '';
  bool _isLoading = false;

  // getters
  String get pin => _pin;
  bool get isPinComplete => _pin.length == 4;
  bool get isLoading => _isLoading;


  void setPin(String value) {
    _pin = value;
    notifyListeners();
  }

  void clearPin() {
    _pin = '';
    pinController.clear();
    notifyListeners();
  }


  Future<void> continueWithPin(BuildContext context) async {
    if (!isPinComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a 4-digit PIN")),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
              // Check if user is authenticated
              final isAuthenticated = await _authService.isAuthenticated();
              
              if (!isAuthenticated) {
                print('❌ User not authenticated, cannot create PIN');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please login first to create a PIN"),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pushReplacementNamed(context, "/login");
                return;
              }
              
              // User is authenticated, save PIN to backend
              final pinSaved = await _authService.setPin(_pin);
              if (!pinSaved) throw Exception('Failed to save PIN');
              print('✅ PIN set successfully with backend sync');
              
              // Mark first time setup as complete
              await _authService.markFirstTimeComplete();
              
              // Navigate directly to main app (skip wallet home screen)
              Navigator.pushReplacementNamed(context, "/mainContainer");
    } catch (e) {
      print('❌ Error in PIN setup: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error setting up PIN: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  @override
  void dispose() {
    pinController.dispose();
    pinFocusNode.dispose();
    super.dispose();
  }
}

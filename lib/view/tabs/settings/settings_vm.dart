import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/base_vm.dart';
import '../../../services/auth_service.dart';
import '../../../services/wallet_service.dart';
import '../../../data/repos/auth_repo.dart';
import '../main_wallet/wallet_home/wallet_home_vm.dart';

class SettingsVM extends BaseVM {
  final AuthService _authService = AuthService();
  final AuthRepo _authRepo = AuthRepo();
  
  bool _darkTheme = false;
  bool _askPin = false;
  bool _biometricEnabled = false;
  bool _isBiometricAvailable = false;

  final String _selectedLanguage = 'English';
  final String _selectedCurrency = 'USD';

  bool get darkTheme => _darkTheme;
  bool get askPin => _askPin;
  bool get biometricEnabled => _biometricEnabled;
  bool get isBiometricAvailable => _isBiometricAvailable;
  String get selectedLanguage => _selectedLanguage;
  String get selectedCurrency => _selectedCurrency;

  SettingsVM() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _biometricEnabled = await _authService.isBiometricEnabled();
    _isBiometricAvailable = await _authService.isBiometricAvailable();
    _askPin = await _authService.isAskPinEnabled();
    notifyListeners();
  }

  void toggleDarkTheme() {
    _darkTheme = !_darkTheme;
    notifyListeners();
  }

  Future<void> toggleAskPin() async {
    _askPin = !_askPin;
    await _authService.setAskPinEnabled(_askPin);
    notifyListeners();
  }

  Future<void> toggleBiometric(BuildContext context) async {
    if (!_isBiometricAvailable) {
      return;
    }
    
    if (!_biometricEnabled) {
      // User is trying to enable biometric - need to register it
      try {
        final result = await _authService.registerBiometric();
        if (result) {
          _biometricEnabled = true;
          await _authService.setBiometricEnabled(_biometricEnabled);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Biometric authentication enabled successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Biometric registration failed. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error enabling biometric authentication."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // User is disabling biometric
      _biometricEnabled = false;
      await _authService.setBiometricEnabled(_biometricEnabled);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Biometric authentication disabled."),
          backgroundColor: Colors.orange,
        ),
      );
    }
    
    notifyListeners();
  }

  Future<void> lockWallet(BuildContext context) async {
    // Navigate to PIN verification screen
    Navigator.pushReplacementNamed(context, "/pin_verification");
  }

  Future<void> logout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      print('🔄 Starting logout process...');
      
      // Call logout API
      final response = await _authRepo.logout();
      
      if (response.isSuccess) {
        print('✅ Logout API call successful');
      } else {
        print('⚠️ Logout API call failed: ${response.message}');
        // Continue with local logout even if API fails
      }
      
      // Clear all local authentication data
      await _authService.clearAuthData();
      print('✅ Local authentication data cleared');
      
      // Clear wallet service data
      final walletService = Provider.of<WalletService>(context, listen: false);
      walletService.clearWalletData();
      print('✅ Wallet service data cleared');
      
      // Reset wallet home VM if it exists
      try {
        final walletHomeVM = Provider.of<WalletHomeVM>(context, listen: false);
        walletHomeVM.reset();
        print('✅ Wallet home VM reset');
      } catch (e) {
        print('ℹ️ Wallet home VM not found, skipping reset');
      }
      
      // Navigate to login screen
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context, 
          "/login", 
          (Route<dynamic> route) => false,
        );
      }
      
    } catch (e) {
      print('❌ Error during logout: $e');
      
      // Even if there's an error, clear local data and navigate to login
      await _authService.clearAuthData();
      
      // Clear wallet service data
      final walletService = Provider.of<WalletService>(context, listen: false);
      walletService.clearWalletData();
      print('✅ Wallet service data cleared (error case)');
      
      // Reset wallet home VM if it exists
      try {
        final walletHomeVM = Provider.of<WalletHomeVM>(context, listen: false);
        walletHomeVM.reset();
        print('✅ Wallet home VM reset (error case)');
      } catch (e) {
        print('ℹ️ Wallet home VM not found, skipping reset (error case)');
      }
      
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context, 
          "/login", 
          (Route<dynamic> route) => false,
        );
      }
    }
  }
}

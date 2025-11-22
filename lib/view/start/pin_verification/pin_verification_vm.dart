import '../../../data/base_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/wallet_service.dart';

class PinVerificationVM extends BaseVM {
  final TextEditingController pinController = TextEditingController();
  final FocusNode pinFocusNode = FocusNode();
  final AuthService _authService = AuthService();

  String _pin = '';
  String _errorMessage = '';
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  String _biometricType = 'Biometric';
  IconData _biometricIcon = Icons.fingerprint;

  String get pin => _pin;
  String get errorMessage => _errorMessage;
  bool get isBiometricAvailable => _isBiometricAvailable;
  bool get isBiometricEnabled => _isBiometricEnabled;
  String get biometricType => _biometricType;
  IconData get biometricIcon => _biometricIcon;

  PinVerificationVM() {
    _initializeBiometric();
    _checkPinStatus();
  }

  Future<void> _initializeBiometric() async {
    try {
      print('🔍 PinVerificationVM - Checking biometric availability...');
      _isBiometricAvailable = await _authService.isBiometricAvailable();
      _isBiometricEnabled = await _authService.isBiometricEnabled();
      print('📱 PinVerificationVM - Biometric available: $_isBiometricAvailable');
      print('📱 PinVerificationVM - Biometric enabled: $_isBiometricEnabled');
      
      if (_isBiometricAvailable) {
        final biometrics = await _authService.getAvailableBiometrics();
        print('🔐 PinVerificationVM - Available biometrics: $biometrics');
        
        if (biometrics.contains(BiometricType.fingerprint)) {
          _biometricType = 'Fingerprint';
          _biometricIcon = Icons.fingerprint;
        } else if (biometrics.contains(BiometricType.face)) {
          _biometricType = 'Face ID';
          _biometricIcon = Icons.face;
        } else if (biometrics.contains(BiometricType.iris)) {
          _biometricType = 'Iris';
          _biometricIcon = Icons.visibility;
        } else {
          // Handle weak/strong biometric types
          _biometricType = 'Biometric';
          _biometricIcon = Icons.security;
        }
        print('✅ PinVerificationVM - Biometric type set to: $_biometricType');
      } else {
        print('❌ PinVerificationVM - Biometric not available');
      }
    } catch (e) {
      print('🚨 PinVerificationVM - Error initializing biometric: $e');
      _isBiometricAvailable = false;
    }
    
    notifyListeners();
  }

  Future<void> _checkPinStatus() async {
    try {
      print('🔍 PinVerificationVM - Checking PIN status...');
      final isPinSet = await _authService.isPinSet();
      print('🔍 PinVerificationVM - PIN is set: $isPinSet');
      
      if (!isPinSet) {
        print('⚠️ PinVerificationVM - No PIN found! User needs to create a PIN first.');
        _errorMessage = "No PIN found. Please create a PIN first.";
        notifyListeners();
      }
    } catch (e) {
      print('🚨 PinVerificationVM - Error checking PIN status: $e');
    }
  }

  void setPin(String value) {
    print('🔢 PinVerificationVM - Setting PIN: $value (length: ${value.length})');
    _pin = value;
    _errorMessage = '';
    notifyListeners();

    // Auto-verify when PIN is complete (exactly 4 digits)
    if (_pin.length == 4) {
      print('🔢 PinVerificationVM - PIN complete, starting verification...');
      // Add a small delay to ensure UI updates
      Future.delayed(const Duration(milliseconds: 100), () {
        _verifyPin();
      });
    }
  }

  Future<void> _verifyPin() async {
    print('🔐 PinVerificationVM - Verifying PIN: $_pin');
    
    // Store context before async operations
    final context = pinFocusNode.context;
    if (context == null) {
      print('❌ PinVerificationVM - Context is null, cannot proceed');
      return;
    }
    
    final isValid = await _authService.verifyPin(_pin);
    print('🔐 PinVerificationVM - PIN verification result: $isValid');
    
    if (isValid) {
      // Ensure authentication token is initialized for API calls
      await _authService.initializeAuthToken();
      print('✅ PIN verified and auth token initialized');
      
      // Double-check that token is set in DioClient
      final token = await _authService.getAuthToken();
      if (token != null && token.isNotEmpty) {
        print('🔑 Token found and will be used for API calls');
      } else {
        print('⚠️ No token found after PIN verification');
      }
      
      // Initialize wallet service before navigation
      final walletService = Provider.of<WalletService>(context, listen: false);
      if (!walletService.hasInitialized) {
        await walletService.initializeWalletData();
        print('✅ Wallet service initialized with wallet data');
      } else {
        print('✅ Wallet service already initialized');
      }
      
      // Check if context is still mounted before navigation
      if (context.mounted) {
        // Navigate to main wallet
        Navigator.pushReplacementNamed(context, "/mainContainer");
      } else {
        print('❌ PinVerificationVM - Context is no longer mounted, cannot navigate');
      }
    } else {
      print('❌ PinVerificationVM - PIN verification failed');
      _errorMessage = "Invalid PIN. Please try again.";
      _pin = '';
      pinController.clear();
      notifyListeners();
      
      // Haptic feedback for wrong PIN
      HapticFeedback.vibrate();
    }
  }

  /// Manual PIN verification (called by button)
  Future<void> verifyPinManually(BuildContext context) async {
    if (_pin.length != 4) {
      _errorMessage = "Please enter a 4-digit PIN";
      notifyListeners();
      return;
    }
    
    print('🔐 PinVerificationVM - Manual PIN verification triggered');
    await _verifyPin();
  }

  /// Navigate to create PIN screen
  void navigateToCreatePin(BuildContext context) {
    print('🔐 PinVerificationVM - Navigating to create PIN screen');
    Navigator.pushReplacementNamed(context, "/create_pin");
  }

  Future<void> authenticateWithBiometric(BuildContext context) async {
    try {
      print('🔐 PinVerificationVM - Attempting biometric authentication...');
      
      // If biometric is not enabled, try to register it first
      if (!_isBiometricEnabled) {
        print('🔐 PinVerificationVM - Biometric not enabled, attempting registration...');
        final registered = await _authService.registerBiometric();
        if (registered) {
          await _authService.setBiometricEnabled(true);
          _isBiometricEnabled = true;
          print('✅ PinVerificationVM - Biometric registered and enabled');
          
          // Initialize wallet service before navigation
          final walletService = Provider.of<WalletService>(context, listen: false);
          if (!walletService.hasInitialized) {
            await walletService.initializeWalletData();
            print('✅ Wallet service initialized with wallet data');
          } else {
            print('✅ Wallet service already initialized');
          }
          
          // Check if context is still mounted before navigation
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, "/mainContainer");
          } else {
            print('❌ PinVerificationVM - Context is no longer mounted, cannot navigate');
          }
          return;
        } else {
          _errorMessage = "Biometric registration failed";
          notifyListeners();
          return;
        }
      }
      
      // If biometric is enabled, authenticate
      final isAuthenticated = await _authService.authenticateWithBiometric();
      if (isAuthenticated) {
        print('✅ PinVerificationVM - Biometric authentication successful');
        
        // Ensure authentication token is initialized for API calls
        await _authService.initializeAuthToken();
        print('✅ Auth token initialized after biometric authentication');
        
        // Initialize wallet service before navigation
        final walletService = Provider.of<WalletService>(context, listen: false);
        if (!walletService.hasInitialized) {
          await walletService.initializeWalletData();
          print('✅ Wallet service initialized with wallet data');
        } else {
          print('✅ Wallet service already initialized');
        }
        
        // Check if context is still mounted before navigation
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, "/mainContainer");
        } else {
          print('❌ PinVerificationVM - Context is no longer mounted, cannot navigate');
        }
      } else {
        print('❌ PinVerificationVM - Biometric authentication failed');
        _errorMessage = "Biometric authentication failed";
        notifyListeners();
      }
    } catch (e) {
      print('🚨 PinVerificationVM - Biometric authentication error: $e');
      _errorMessage = "Biometric authentication error";
      notifyListeners();
    }
  }

  void showForgotPinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            "Reset PIN",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "To reset your PIN, you'll need to clear all app data and set up your wallet again. This action cannot be undone.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.orange),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _authService.clearAuthData();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/",
                  (route) => false,
                );
              },
              child: const Text(
                "Reset",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    pinController.dispose();
    pinFocusNode.dispose();
    super.dispose();
  }
}

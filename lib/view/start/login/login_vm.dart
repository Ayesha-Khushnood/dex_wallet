import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/base_vm.dart';
import '../../../data/repos/auth_repo.dart';
import '../../../data/repos/wallet_repo.dart';
import '../../../services/auth_service.dart';
import '../../../services/wallet_service.dart';
import '../../../data/model/body/wallet_list_item_model.dart';

class LoginVM extends BaseVM {
  final AuthRepo _authRepo = AuthRepo();
  final AuthService _authService = AuthService();
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isPasswordVisible => _isPasswordVisible;
  
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }
  
  Future<void> login(BuildContext context) async {
    if (!_validateInputs(context)) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      print('🔄 Starting login process...');
      
      final response = await _authRepo.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      
      if (response.isSuccess) {
        print('✅ Login successful!');
        
        // Extract token and PIN from response
        final token = _extractTokenFromResponse(response.data);
        final pin = _extractPinFromResponse(response.data);
        
        if (token != null) {
          await _authService.setAuthToken(token);
          print('🔑 Auth token set successfully');
          
          // Check if PIN came with login response
          if (pin != null) {
            print('🔐 PIN found in login response, saving locally');
            await _authService.setPinLocally(pin);
            print('✅ PIN saved from login response');
          } else {
            print('ℹ️ No PIN in login response, checking local PIN');
            // Check if PIN exists locally first
            final localPin = await _authService.getPin();
            if (localPin != null) {
              print('✅ Local PIN found, but NOT syncing to backend');
              print('ℹ️ PIN will be synced when user creates their first wallet');
            } else {
              print('❌ No local PIN found - user will need to create PIN');
            }
          }
        }
        
        // Check if user has only one wallet - if so, go directly to PIN verification
        // If multiple wallets, show wallet selection
        await _checkWalletAndNavigate(context);
      } else {
        print('❌ Login failed: ${response.message}');
        _showErrorDialog(context, 'Login Failed', response.message);
      }
    } catch (e) {
      print('💥 Exception during login: $e');
      _showErrorDialog(context, 'Error', 'An unexpected error occurred: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void forgotPassword(BuildContext context) {
    // Navigate to forgot password screen
    Navigator.pushNamed(context, "/forgot_password");
  }
  
  void navigateToSignUp(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/signup");
  }
  
  bool _validateInputs(BuildContext context) {
    if (emailController.text.trim().isEmpty) {
      _showErrorDialog(context, 'Validation Error', 'Please enter your email address.');
      return false;
    }
    
    if (passwordController.text.isEmpty) {
      _showErrorDialog(context, 'Validation Error', 'Please enter your password.');
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
  
  String? _extractTokenFromResponse(dynamic responseData) {
    try {
      if (responseData is Map<String, dynamic>) {
        // Check if response has the expected structure: { success, message, data: { user, token } }
        if (responseData['data'] != null && responseData['data'] is Map<String, dynamic>) {
          final data = responseData['data'] as Map<String, dynamic>;
          return data['token'];
        }
        
        // Fallback: try direct token field names
        return responseData['token'] ?? 
               responseData['accessToken'] ?? 
               responseData['access_token'] ??
               responseData['authToken'];
      }
    } catch (e) {
      print('⚠️ Could not extract token from response: $e');
    }
    return null;
  }

  String? _extractPinFromResponse(dynamic responseData) {
    try {
      print('🔍 Checking login response for PIN...');
      print('🔍 Response data: $responseData');
      
      if (responseData is Map<String, dynamic>) {
        // Check if response has the expected structure: { success, message, data: { user, token, pin } }
        if (responseData['data'] != null && responseData['data'] is Map<String, dynamic>) {
          final data = responseData['data'] as Map<String, dynamic>;
          print('🔍 Data keys: ${data.keys}');
          
          // Try different possible PIN field names
          final pin = data['walletPin'] ?? 
                     data['pin'] ?? 
                     data['wallet_pin'] ??
                     data['userPin'] ??
                     data['user_pin'];
          
          if (pin != null) {
            print('✅ PIN found in login response: ${pin.substring(0, 1)}***');
            return pin;
          } else {
            print('ℹ️ No PIN field found in login response data');
          }
        }
        
        // Fallback: try direct PIN field names in root response
        final pin = responseData['walletPin'] ?? 
                   responseData['pin'] ?? 
                   responseData['wallet_pin'] ??
                   responseData['userPin'] ??
                   responseData['user_pin'];
        
        if (pin != null) {
          print('✅ PIN found in root response: ${pin.substring(0, 1)}***');
          return pin;
        } else {
          print('ℹ️ No PIN field found in root response');
        }
      }
    } catch (e) {
      print('⚠️ Could not extract PIN from response: $e');
    }
    return null;
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

  /// Check if user has a wallet and navigate accordingly
  Future<void> _checkWalletAndNavigate(BuildContext context) async {
    try {
      print('🔍 Checking if user has existing wallet...');
      
      // Import WalletRepo to check for existing wallets
      final walletRepo = WalletRepo();
      final response = await walletRepo.getWalletList();
      
      if (response.isSuccess) {
        print('✅ Wallet list retrieved successfully');
        
        // Parse wallet list from response
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          if (data['data'] != null && data['data'] is List) {
            final walletList = (data['data'] as List);
            
            if (walletList.isNotEmpty) {
              print('✅ User has existing wallet, checking wallet count...');
              // Initialize wallet service with the retrieved data
              await _initializeWalletService(context, walletList);
              
              if (walletList.length == 1) {
                print('✅ User has only one wallet, going directly to PIN verification');
                // User has only one wallet, go directly to PIN verification
                Navigator.pushReplacementNamed(context, "/pin_verification");
              } else {
                print('✅ User has multiple wallets, going directly to PIN verification');
                // Even with multiple wallets, go directly to PIN verification
                // The wallet selection will happen in the main app
                Navigator.pushReplacementNamed(context, "/pin_verification");
              }
            } else {
              print('ℹ️ User has no wallet, redirecting to wallet home');
              // User has no wallet, go to wallet home to create one
              Navigator.pushReplacementNamed(context, "/walletHome");
            }
          } else {
            print('ℹ️ No wallet data found, redirecting to wallet home');
            Navigator.pushReplacementNamed(context, "/walletHome");
          }
        } else {
          print('ℹ️ Invalid response format, redirecting to wallet home');
          Navigator.pushReplacementNamed(context, "/walletHome");
        }
      } else {
        print('❌ Failed to check wallet list: ${response.message}');
        
        // Check if it's a server/network issue
        if (response.message.toLowerCase().contains('bad request') || 
            response.message.toLowerCase().contains('server error') ||
            response.message.toLowerCase().contains('network')) {
          print('🌐 Server/network issue detected, defaulting to wallet home');
        }
        
        // If we can't check, default to wallet home
        Navigator.pushReplacementNamed(context, "/walletHome");
      }
    } catch (e) {
      print('💥 Exception checking wallet: $e');
      
      // Check if it's a network/server issue
      if (e.toString().toLowerCase().contains('400') || 
          e.toString().toLowerCase().contains('bad request') ||
          e.toString().toLowerCase().contains('html')) {
        print('🌐 Network/server issue detected, defaulting to wallet home');
      }
      
      // If there's an error, default to wallet home
      Navigator.pushReplacementNamed(context, "/walletHome");
    }
  }
  
  
  /// Initialize wallet service with retrieved wallet data
  Future<void> _initializeWalletService(BuildContext context, List<dynamic> walletList) async {
    try {
      print('🔄 LoginVM - Initializing wallet service with ${walletList.length} wallets...');
      final walletService = Provider.of<WalletService>(context, listen: false);
      
      // Parse wallet data
      final parsedWallets = walletList.map((wallet) => WalletListItemModel.fromJson(wallet)).toList();
      
      // Set wallet data in the service
      walletService.setWalletList(parsedWallets);
      if (parsedWallets.isNotEmpty) {
        walletService.setMainWallet(parsedWallets.first.address);
      }
      
      print('✅ LoginVM - Wallet service initialized with ${parsedWallets.length} wallets');
    } catch (e) {
      print('❌ LoginVM - Error initializing wallet service: $e');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

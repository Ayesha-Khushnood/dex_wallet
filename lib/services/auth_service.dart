import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/shared_preference_keys.dart';
import '../data/data_sources/dio/dio_client.dart';
import '../data/repos/auth_repo.dart';

class AuthService {
  static const String _pinKey = 'user_pin';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _isFirstTimeKey = 'is_first_time';
  static const String _askPinKey = 'ask_pin_every_time';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final AuthRepo _authRepo = AuthRepo();
  
  /// Check if this is the first time user is opening the app
  Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstTimeKey) ?? true;
  }
  
  /// Mark that user has completed first time setup
  Future<void> markFirstTimeComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstTimeKey, false);
  }
  
  /// Check if PIN is set
  Future<bool> isPinSet() async {
    try {
      print('🔍 AuthService - Checking PIN storage...');
      print('🔍 AuthService - PIN key: $_pinKey');
      
      // Try secure storage first
      final securePin = await _secureStorage.read(key: _pinKey);
      print('🔍 AuthService - Secure storage PIN: ${securePin != null ? "***" : "null"}');
      
      if (securePin != null && securePin.isNotEmpty) {
        print('✅ AuthService - PIN found in secure storage');
        return true;
      }
      
      // Fallback to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final prefsPin = prefs.getString(_pinKey);
      print('🔍 AuthService - SharedPreferences PIN: ${prefsPin != null ? "***" : "null"}');
      
      if (prefsPin != null && prefsPin.isNotEmpty) {
        print('✅ AuthService - PIN found in SharedPreferences');
        return true;
      }
      
      print('❌ AuthService - No PIN found in any storage');
      return false;
    } catch (e) {
      print('🚨 AuthService - Error checking PIN: $e');
      return false;
    }
  }
  
  /// Test secure storage functionality
  Future<void> _testSecureStorage() async {
    try {
      print('🧪 AuthService - Testing secure storage...');
      
      // Write test data
      await _secureStorage.write(key: 'test_secure_storage', value: 'test_value');
      print('✅ AuthService - Test write successful');
      
      // Read test data
      final testValue = await _secureStorage.read(key: 'test_secure_storage');
      print('🔍 AuthService - Test read: ${testValue ?? "null"}');
      
      if (testValue == 'test_value') {
        print('✅ AuthService - Secure storage is working correctly');
      } else {
        print('❌ AuthService - Secure storage test failed! Expected: test_value, Got: ${testValue ?? "null"}');
      }
      
      // Clean up test data
      await _secureStorage.delete(key: 'test_secure_storage');
      print('🧹 AuthService - Test data cleaned up');
      
    } catch (e) {
      print('🚨 AuthService - Secure storage test failed: $e');
    }
  }
  
  /// Set user PIN (both local and backend)
  Future<bool> setPin(String pin) async {
    try {
      print('🔐 AuthService - Setting PIN locally and on backend...');
      print('🔐 AuthService - PIN to save: ${pin.substring(0, 1)}***');
      print('🔐 AuthService - PIN key: $_pinKey');
      
      // Save to both secure storage and SharedPreferences
      await _secureStorage.write(key: _pinKey, value: pin);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pinKey, pin);
      print('✅ AuthService - PIN saved to both storage methods');
      
      // Verify the PIN was actually saved
      final securePin = await _secureStorage.read(key: _pinKey);
      final prefsPin = prefs.getString(_pinKey);
      print('🔍 AuthService - Secure verification: ${securePin != null ? securePin.substring(0, 1) + "***" : "null"}');
      print('🔍 AuthService - Prefs verification: ${prefsPin != null ? prefsPin.substring(0, 1) + "***" : "null"}');
      
      if (securePin == pin || prefsPin == pin) {
        print('✅ AuthService - PIN verification successful');
      } else {
        print('❌ AuthService - PIN verification failed!');
      }
      
      // Save to backend
      final response = await _authRepo.setupWalletPin(walletPin: pin);
      if (response.isSuccess) {
        print('✅ AuthService - PIN saved to backend');
        return true;
      } else {
        // Check if PIN already exists (400 error)
        if (response.message.contains('already set')) {
          print('ℹ️ AuthService - PIN already exists on backend, local PIN saved');
          return true;
        } else {
          print('❌ AuthService - Failed to save PIN to backend: ${response.message}');
          // Keep local PIN even if backend fails
          return true;
        }
      }
    } catch (e) {
      print('🚨 AuthService - Error setting PIN: $e');
      return false;
    }
  }
  
  /// Set user PIN locally only (for unauthenticated users)
  Future<void> setPinLocally(String pin) async {
    try {
      print('🔐 AuthService - Setting PIN locally only...');
      await _secureStorage.write(key: _pinKey, value: pin);
      print('✅ AuthService - PIN saved locally');
    } catch (e) {
      print('🚨 AuthService - Error setting PIN locally: $e');
      rethrow;
    }
  }
  
  /// Sync local PIN to backend (after user authenticates)
  Future<bool> syncPinToBackend() async {
    try {
      print('🔐 AuthService - Syncing local PIN to backend...');
      
      final localPin = await _secureStorage.read(key: _pinKey);
      if (localPin == null || localPin.isEmpty) {
        print('❌ AuthService - No local PIN found to sync');
        return false;
      }
      
      final response = await _authRepo.setupWalletPin(walletPin: localPin);
      if (response.isSuccess) {
        print('✅ AuthService - Local PIN synced to backend');
        return true;
      } else {
        print('❌ AuthService - Failed to sync PIN to backend: ${response.message}');
        return false;
      }
    } catch (e) {
      print('🚨 AuthService - Error syncing PIN to backend: $e');
      return false;
    }
  }
  
  /// Verify PIN (check local first, then backend if needed)
  Future<bool> verifyPin(String pin) async {
    try {
      print('🔐 AuthService - Verifying PIN: $pin');
      
      // First check local PIN
      final storedPin = await _secureStorage.read(key: _pinKey);
      print('🔐 AuthService - Local stored PIN: ${storedPin != null ? '***' : 'null'}');
      
      if (storedPin != null && storedPin == pin) {
        print('✅ AuthService - PIN verified locally');
        return true;
      }
      
      // If no local PIN, try to verify against backend by attempting to change PIN
      // This is a workaround since there's no dedicated PIN verification endpoint
      if (storedPin == null) {
        print('🔐 AuthService - No local PIN, attempting backend verification...');
        try {
          // Try to change PIN with the same PIN (this will verify if PIN is correct)
          final response = await _authRepo.changeWalletPin(
            currentPin: pin,
            newPin: pin, // Same PIN to just verify
          );
          
          if (response.isSuccess) {
            print('✅ AuthService - PIN verified against backend');
            // Save the PIN locally for future use
            await _secureStorage.write(key: _pinKey, value: pin);
            print('✅ AuthService - PIN saved locally after backend verification');
            return true;
          } else {
            print('❌ AuthService - Backend PIN verification failed: ${response.message}');
            return false;
          }
        } catch (e) {
          print('🚨 AuthService - Backend PIN verification error: $e');
          return false;
        }
      }
      
      // If local PIN doesn't match
      print('❌ AuthService - Local PIN mismatch');
      return false;
    } catch (e) {
      print('🚨 AuthService - Error verifying PIN: $e');
      return false;
    }
  }
  
  /// Get stored PIN
  Future<String?> getPin() async {
    try {
      // Try secure storage first
      final securePin = await _secureStorage.read(key: _pinKey);
      if (securePin != null && securePin.isNotEmpty) {
        return securePin;
      }
      
      // Fallback to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final prefsPin = prefs.getString(_pinKey);
      if (prefsPin != null && prefsPin.isNotEmpty) {
        return prefsPin;
      }
      
      return null;
    } catch (e) {
      print('🚨 AuthService - Error getting PIN: $e');
      return null;
    }
  }

  /// Clear user PIN (for testing)
  Future<void> clearPin() async {
    try {
      await _secureStorage.delete(key: _pinKey);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pinKey);
      print('🗑️ AuthService - PIN cleared from both storage methods');
    } catch (e) {
      print('AuthService - Error clearing PIN: $e');
      rethrow;
    }
  }
  
  /// Change PIN (both local and backend)
  Future<bool> changePin(String currentPin, String newPin) async {
    try {
      print('🔐 AuthService - Changing PIN locally and on backend...');
      
      // Update on backend first (requires current PIN for verification)
      final response = await _authRepo.changeWalletPin(
        currentPin: currentPin,
        newPin: newPin,
      );
      
      if (response.isSuccess) {
        print('✅ AuthService - PIN updated on backend');
        
        // Update locally after successful backend update
        await _secureStorage.write(key: _pinKey, value: newPin);
        print('✅ AuthService - PIN updated locally');
        
        return true;
      } else {
        print('❌ AuthService - Failed to update PIN on backend: ${response.message}');
        return false;
      }
    } catch (e) {
      print('🚨 AuthService - Error changing PIN: $e');
      return false;
    }
  }

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      return isAvailable && isDeviceSupported;
    } catch (e) {
      print(' AuthService - Error checking biometric availability: $e');
      return false;
    }
  }
  
  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      print(' AuthService - Available biometrics: $biometrics');
      return biometrics;
    } catch (e) {
      print('AuthService - Error getting biometrics: $e');
      return [];
    }
  }
  
  /// Check if biometric is enabled
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }
  
  /// Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }
  
  /// Authenticate with biometric
  Future<bool> authenticateWithBiometric() async {
    try {
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) return false;
      
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;
      
      final result = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your wallet',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      
      return result;
    } catch (e) {
      return false;
    }
  }

  /// Register biometric (for first-time setup)
  Future<bool> registerBiometric() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;
      
      final result = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to enable biometric login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      
      if (result) {
        await setBiometricEnabled(true);
      }
      
      return result;
    } catch (e) {
      return false;
    }
  }

  // ========== API TOKEN MANAGEMENT ==========

  /// Store user authentication token
  Future<bool> setAuthToken(String token) async {
    try {
      print('🔑 AuthService - Setting auth token: ${token.substring(0, 20)}...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(SharedPreferenceKey.userToken, token);
      print('✅ AuthService - Token stored in SharedPreferences');
      
      // Set token in DioClient for immediate use
      DioClient.instance.setAuthToken(token);
      print('✅ AuthService - Token set in DioClient');
      
      return true;
    } catch (e) {
      print('💥 AuthService - Error setting auth token: $e');
      return false;
    }
  }

  /// Get stored authentication token
  Future<String?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(SharedPreferenceKey.userToken);
    } catch (e) {
      print('AuthService - Error getting auth token: $e');
      return null;
    }
  }

  /// Clear authentication token
  Future<void> clearAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(SharedPreferenceKey.userToken);
      
      // Clear token from DioClient
      DioClient.instance.clearAuthToken();
    } catch (e) {
      print('AuthService - Error clearing auth token: $e');
    }
  }

  /// Initialize authentication token on app startup
  Future<void> initializeAuthToken() async {
    try {
      final token = await getAuthToken();
      print('🔍 AuthService - Retrieved token from storage: ${token != null ? '${token.substring(0, 20)}...' : 'null'}');
      if (token != null && token.isNotEmpty) {
        DioClient.instance.setAuthToken(token);
        print('✅ AuthService - Auth token initialized and set in DioClient');
      } else {
        print('❌ AuthService - No auth token found in storage');
      }
    } catch (e) {
      print('💥 AuthService - Error initializing auth token: $e');
    }
  }

  /// Check if user is authenticated (has valid token)
  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }
  
  /// Check if "Ask PIN every time" is enabled
  Future<bool> isAskPinEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_askPinKey) ?? false;
  }
  
  /// Set "Ask PIN every time" preference
  Future<void> setAskPinEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_askPinKey, enabled);
  }

  /// Clear all authentication data (for logout/reset)
  Future<void> clearAuthData() async {
    try {
      // DON'T delete the PIN - it's associated with the wallet and should persist
      // await _secureStorage.delete(key: _pinKey); // ❌ REMOVED
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_biometricEnabledKey);
      await prefs.remove(_isFirstTimeKey);
      await prefs.remove(_askPinKey);
      await prefs.remove(SharedPreferenceKey.userToken);
      
      // Clear token from DioClient
      DioClient.instance.clearAuthToken();
      
      print('✅ AuthService - Authentication data cleared (PIN preserved)');
    } catch (e) {
      print('🚨 AuthService - Error clearing auth data: $e');
    }
  }
}

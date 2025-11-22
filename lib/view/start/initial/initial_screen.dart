import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../theme/theme_manager.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    print('🚀 InitialScreen - initState() called');
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    // Wait a moment for the app to initialize
    await Future.delayed(const Duration(milliseconds: 500));
    
    // TEMPORARY: Clear all data for testing (remove this in production)
    // await _authService.clearAuthData();
    
    // First check authentication status - this is the most important check
    final isAuthenticated = await _authService.isAuthenticated();
    final isPinSet = await _authService.isPinSet();
    
    print('🔍 InitialScreen - isAuthenticated: $isAuthenticated');
    print('🔍 InitialScreen - isPinSet: $isPinSet');
    
    if (isAuthenticated) {
      // User is authenticated - check if they have a PIN
      if (isPinSet) {
        // User has a PIN - go to PIN verification
        print('✅ InitialScreen - Going to PIN verification (authenticated user with PIN)');
        if (mounted) {
          Navigator.pushReplacementNamed(context, "/pin_verification");
        }
      } else {
        // User is authenticated but no PIN - go to create PIN
        print('⚠️ InitialScreen - Going to create PIN (authenticated user without PIN)');
        if (mounted) {
          Navigator.pushReplacementNamed(context, "/create_pin");
        }
      }
    } else {
      // User is not authenticated - check if first time
      final isFirstTime = await _authService.isFirstTime();
      
      if (isFirstTime) {
        // First time user - go to onboarding
        print('🆕 InitialScreen - Going to onboarding (first time user)');
        if (mounted) {
          Navigator.pushReplacementNamed(context, "/onboarding");
        }
      } else {
        // Returning user who needs to login
        print('🔐 InitialScreen - Going to login (returning user)');
        if (mounted) {
          Navigator.pushReplacementNamed(context, "/login");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 InitialScreen - build() called');
    final themeManager = context.watch<ThemeManager>();
    
    return Scaffold(
      backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                themeManager.currentTheme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Loading...",
              style: themeManager.currentTheme.textTheme.bodyLarge?.copyWith(
                color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

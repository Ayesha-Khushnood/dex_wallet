import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../util/size_extension.dart';
import '../../../helper/sb_helper.dart';
import '../../../theme/theme_manager.dart';
import '../../../widgets/app_button.dart';
import 'login_vm.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    
    return ChangeNotifierProvider(
      create: (context) => LoginVM(),
      child: Consumer<LoginVM>(
        builder: (context, vm, child) {
          return Scaffold(
            backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SB.h(4.h),
                    
                    // Logo/Title
                    Center(
                      child: Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 6.sp,
                          fontWeight: FontWeight.bold,
                          color: themeManager.currentTheme.colorScheme.primary,
                        ),
                      ),
                    ),
                    
                    SB.h(1.h),
                    
                    Center(
                      child: Text(
                        'Sign in to your account',
                        style: TextStyle(
                          fontSize: 3.sp,
                          color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                    
                    SB.h(4.h),
                    
                    // Email Field
                    _buildTextField(
                      controller: vm.emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      themeManager: themeManager,
                    ),
                    
                    SB.h(2.h),
                    
                    // Password Field
                    _buildTextField(
                      controller: vm.passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      obscureText: vm.isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          vm.isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        onPressed: vm.togglePasswordVisibility,
                      ),
                      themeManager: themeManager,
                    ),
                    
                    SB.h(2.h),
                    
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => vm.forgotPassword(context),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: themeManager.currentTheme.colorScheme.primary,
                            fontSize: 2.5.sp,
                          ),
                        ),
                      ),
                    ),
                    
                    SB.h(3.h),
                    
                    // Login Button
                    AppButton(
                      text: 'Sign In',
                      onTap: vm.isLoading ? null : () => vm.login(context),
                      isEnabled: !vm.isLoading,
                    ),
                    
                    SB.h(3.h),
                    
                    // Sign Up Link
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              fontSize: 2.5.sp,
                              color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          TextButton(
                            onPressed: () => vm.navigateToSignUp(context),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 2.5.sp,
                                fontWeight: FontWeight.w600,
                                color: themeManager.currentTheme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ThemeManager themeManager,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 3.sp,
            fontWeight: FontWeight.w500,
            color: themeManager.currentTheme.colorScheme.onSurface,
          ),
        ),
        SB.h(0.5.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: TextStyle(
            fontSize: 3.sp,
            color: themeManager.currentTheme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.5),
            ),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: themeManager.currentTheme.colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: themeManager.currentTheme.colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: themeManager.currentTheme.colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: themeManager.currentTheme.colorScheme.surface,
          ),
        ),
      ],
    );
  }
}

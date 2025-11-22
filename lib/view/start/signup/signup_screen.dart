import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../util/size_extension.dart';
import '../../../helper/sb_helper.dart';
import '../../../theme/theme_manager.dart';
import '../../../widgets/app_button.dart';
import 'signup_vm.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    
    return ChangeNotifierProvider(
      create: (context) => SignupVM(),
      child: Consumer<SignupVM>(
        builder: (context, vm, child) {
          return Scaffold(
            backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SB.h(2.h),
                    
                    // Back Button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: themeManager.currentTheme.colorScheme.onSurface,
                      ),
                    ),
                    
                    SB.h(2.h),
                    
                    // Title
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 6.sp,
                        fontWeight: FontWeight.bold,
                        color: themeManager.currentTheme.colorScheme.primary,
                      ),
                    ),
                    
                    SB.h(1.h),
                    
                    Text(
                      'Sign up to get started',
                      style: TextStyle(
                        fontSize: 3.sp,
                        color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    
                    SB.h(4.h),
                    
                    // Username Field
                    _buildTextField(
                      controller: vm.usernameController,
                      label: 'Username',
                      hint: 'Choose a username',
                      themeManager: themeManager,
                    ),
                    
                    SB.h(2.h),
                    
                    // First Name Field
                    _buildTextField(
                      controller: vm.firstNameController,
                      label: 'First Name',
                      hint: 'Enter your first name',
                      themeManager: themeManager,
                    ),
                    
                    SB.h(2.h),
                    
                    // Last Name Field
                    _buildTextField(
                      controller: vm.lastNameController,
                      label: 'Last Name',
                      hint: 'Enter your last name',
                      themeManager: themeManager,
                    ),
                    
                    SB.h(2.h),
                    
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
                    
                    // Confirm Password Field
                    _buildTextField(
                      controller: vm.confirmPasswordController,
                      label: 'Confirm Password',
                      hint: 'Confirm your password',
                      obscureText: vm.isConfirmPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          vm.isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        onPressed: vm.toggleConfirmPasswordVisibility,
                      ),
                      themeManager: themeManager,
                    ),
                    
                    SB.h(3.h),
                    
                    // Terms and Conditions
                    Row(
                      children: [
                        Checkbox(
                          value: vm.acceptTerms,
                          onChanged: vm.toggleAcceptTerms,
                          activeColor: themeManager.currentTheme.colorScheme.primary,
                        ),
                        Expanded(
                          child: Text(
                            'I agree to the Terms and Conditions',
                            style: TextStyle(
                              fontSize: 2.5.sp,
                              color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SB.h(3.h),
                    
                    // Sign Up Button
                    AppButton(
                      text: 'Sign Up',
                      onTap: vm.isLoading ? null : () => vm.signup(context),
                      isEnabled: !vm.isLoading,
                    ),
                    
                    SB.h(2.h),
                    
                    
                    // Login Link
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: TextStyle(
                              fontSize: 2.5.sp,
                              color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          TextButton(
                            onPressed: () => vm.navigateToLogin(context),
                            child: Text(
                              'Sign In',
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

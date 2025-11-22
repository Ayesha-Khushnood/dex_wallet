import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../helper/sb_helper.dart';
import '../../../theme/theme_manager.dart';
import '../../../util/size_extension.dart';
import 'reset_password_vm.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String email;
  
  const ResetPasswordScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    
    return Scaffold(
      backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: themeManager.currentTheme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Consumer<ResetPasswordVM>(
            builder: (context, vm, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SB.h(4.h),
                  
                  // Title
                  Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 6.sp,
                      fontWeight: FontWeight.bold,
                      color: themeManager.currentTheme.colorScheme.onSurface,
                    ),
                  ),
                  
                  SB.h(1.h),
                  
                  // Subtitle
                  Text(
                    'Enter the verification code sent to your email and create a new password.',
                    style: TextStyle(
                      fontSize: 3.sp,
                      color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  
                  SB.h(0.5.h),
                  
                  // Email Display
                  Center(
                    child: Text(
                      email,
                      style: TextStyle(
                        fontSize: 3.sp,
                        fontWeight: FontWeight.w600,
                        color: themeManager.currentTheme.primaryColor,
                      ),
                    ),
                  ),
                  
                  SB.h(4.h),
                  
                  // OTP Field
                  _buildTextField(
                    controller: vm.otpController,
                    label: 'Verification Code',
                    hint: 'Enter 6-digit code',
                    keyboardType: TextInputType.number,
                    themeManager: themeManager,
                  ),
                  
                  SB.h(2.h),
                  
                  // New Password Field
                  _buildTextField(
                    controller: vm.newPasswordController,
                    label: 'New Password',
                    hint: 'Enter new password',
                    obscureText: !vm.isNewPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        vm.isNewPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      onPressed: vm.toggleNewPasswordVisibility,
                    ),
                    themeManager: themeManager,
                  ),
                  
                  SB.h(2.h),
                  
                  // Confirm Password Field
                  _buildTextField(
                    controller: vm.confirmPasswordController,
                    label: 'Confirm New Password',
                    hint: 'Re-enter new password',
                    obscureText: !vm.isConfirmPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        vm.isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      onPressed: vm.toggleConfirmPasswordVisibility,
                    ),
                    themeManager: themeManager,
                  ),
                  
                  SB.h(4.h),
                  
                  // Reset Password Button
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: vm.isLoading ? null : () => vm.resetPassword(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeManager.currentTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: vm.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Reset Password',
                              style: TextStyle(fontSize: 2.5.sp),
                            ),
                    ),
                  ),
                  
                  SB.h(2.h),
                  
                  // Resend OTP
                  Center(
                    child: TextButton(
                      onPressed: vm.isResending ? null : () => vm.resendOTP(context),
                      child: vm.isResending
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  themeManager.currentTheme.primaryColor,
                                ),
                              ),
                            )
                          : Text(
                              'Resend Code',
                              style: TextStyle(
                                color: themeManager.currentTheme.primaryColor,
                                fontSize: 2.5.sp,
                              ),
                            ),
                    ),
                  ),
                  
                  SB.h(2.h),
                  
                  // Back to Login
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context, 
                        "/login", 
                        (route) => false,
                      ),
                      child: Text(
                        'Back to Login',
                        style: TextStyle(
                          color: themeManager.currentTheme.primaryColor,
                          fontSize: 3.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ThemeManager themeManager,
    TextInputType keyboardType = TextInputType.text,
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
        SB.h(1.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: TextStyle(color: themeManager.currentTheme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.5)),
            filled: true,
            fillColor: themeManager.currentTheme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../helper/sb_helper.dart';
import '../../../theme/theme_manager.dart';
import '../../../util/size_extension.dart';
import 'forgot_password_vm.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
          child: Consumer<ForgotPasswordVM>(
            builder: (context, vm, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SB.h(4.h),
                  
                  // Title
                  Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 6.sp,
                      fontWeight: FontWeight.bold,
                      color: themeManager.currentTheme.colorScheme.onSurface,
                    ),
                  ),
                  
                  SB.h(1.h),
                  
                  // Subtitle
                  Text(
                    'Enter your email address and we\'ll send you a verification code to reset your password.',
                    style: TextStyle(
                      fontSize: 3.sp,
                      color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  
                  SB.h(6.h),
                  
                  // Email Field
                  _buildTextField(
                    controller: vm.emailController,
                    label: 'Email Address',
                    hint: 'Enter your email address',
                    keyboardType: TextInputType.emailAddress,
                    themeManager: themeManager,
                  ),
                  
                  SB.h(4.h),
                  
                  // Send OTP Button
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: vm.isLoading ? null : () => vm.sendPasswordResetOTP(context),
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
                              'Send Verification Code',
                              style: TextStyle(fontSize: 2.5.sp),
                            ),
                    ),
                  ),
                  
                  SB.h(4.h),
                  
                  // Back to Login
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Back to Login',
                        style: TextStyle(
                          color: themeManager.currentTheme.primaryColor,
                          fontSize: 2.5.sp,
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
          ),
        ),
      ],
    );
  }
}

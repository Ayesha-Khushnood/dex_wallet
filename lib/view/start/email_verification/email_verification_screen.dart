import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../util/size_extension.dart';
import '../../../helper/sb_helper.dart';
import '../../../theme/theme_manager.dart';
import 'email_verification_vm.dart';

class EmailVerificationScreen extends StatelessWidget {
  final String email;
  
  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    
    return ChangeNotifierProvider(
      create: (context) => EmailVerificationVM(email: email),
      child: Consumer<EmailVerificationVM>(
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
                    
                    // Icon
                    Center(
                      child: Icon(
                        Icons.email_outlined,
                        size: 8.w,
                        color: themeManager.currentTheme.colorScheme.primary,
                      ),
                    ),
                    
                    SB.h(3.h),
                    
                    // Title
                    Center(
                      child: Text(
                        'Verify Your Email',
                        style: TextStyle(
                          fontSize: 4.sp,
                          fontWeight: FontWeight.bold,
                          color: themeManager.currentTheme.colorScheme.primary,
                        ),
                      ),
                    ),
                    
                    SB.h(1.h),
                    
                    // Description
                    Center(
                      child: Text(
                        'We\'ve sent a verification code to',
                        style: TextStyle(
                          fontSize: 2.5.sp,
                          color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                    
                    SB.h(0.5.h),
                    
                    Center(
                      child: Text(
                        email,
                        style: TextStyle(
                          fontSize: 2.5.sp,
                          fontWeight: FontWeight.w600,
                          color: themeManager.currentTheme.colorScheme.primary,
                        ),
                      ),
                    ),
                    
                    SB.h(4.h),
                    
                    // OTP Input Field
                    _buildOTPField(
                      controller: vm.otpController,
                      themeManager: themeManager,
                    ),
                    
                    SB.h(2.h),
                    
                    // Resend OTP
                    Center(
                      child: TextButton(
                        onPressed: vm.isResending ? null : () => vm.resendOTP(context),
                        child: vm.isResending
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    themeManager.currentTheme.colorScheme.primary,
                                  ),
                                ),
                              )
                            : Text(
                                'Resend OTP',
                                style: TextStyle(
                                  color: themeManager.currentTheme.colorScheme.primary,
                                  fontSize: 2.sp,
                                ),
                              ),
                      ),
                    ),
                    
                    SB.h(3.h),
                    
                    // Verify Button
                    SizedBox(
                      width: double.infinity,
                      height: 6.h,
                      child: ElevatedButton(
                        onPressed: vm.isLoading ? null : () => vm.verifyEmail(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeManager.currentTheme.colorScheme.primary,
                          foregroundColor: themeManager.currentTheme.colorScheme.onPrimary,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    themeManager.currentTheme.colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Text(
                                'Verify Email',
                                style: TextStyle(
                                  fontSize: 2.5.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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

  Widget _buildOTPField({
    required TextEditingController controller,
    required ThemeManager themeManager,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Verification Code',
          style: TextStyle(
            fontSize: 2.5.sp,
            fontWeight: FontWeight.w500,
            color: themeManager.currentTheme.colorScheme.onSurface,
          ),
        ),
        SB.h(0.5.h),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 2.5.sp,
            fontWeight: FontWeight.bold,
            color: themeManager.currentTheme.colorScheme.onSurface,
            letterSpacing: 2,
          ),
          decoration: InputDecoration(
            hintText: '000000',
            hintStyle: TextStyle(
              color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.3),
              fontSize: 2.5.sp,
              letterSpacing: 2,
            ),
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

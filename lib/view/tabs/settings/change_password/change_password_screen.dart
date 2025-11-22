import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../helper/sb_helper.dart';
import '../../../../theme/theme_manager.dart';
import '../../../../util/size_extension.dart';
import 'change_password_vm.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late ChangePasswordVM _vm;

  @override
  void initState() {
    super.initState();
    _vm = ChangePasswordVM();
  }

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
        title: Text(
          'Change Password',
          style: TextStyle(
            color: themeManager.currentTheme.colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SB.h(2.h),
              
              // Title
              Text(
                'Change Your Password',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: themeManager.currentTheme.colorScheme.onSurface,
                ),
              ),
              
              SB.h(1.h),
              
              // Subtitle
              Text(
                'Enter your current password and choose a new one.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              
              SB.h(4.h),
              
              // Current Password Field
              _buildPasswordField(
                controller: _vm.currentPasswordController,
                label: 'Current Password',
                hint: 'Enter your current password',
                isVisible: _vm.isCurrentPasswordVisible,
                onToggleVisibility: _vm.toggleCurrentPasswordVisibility,
                themeManager: themeManager,
              ),
              
              SB.h(3.h),
              
              // New Password Field
              _buildPasswordField(
                controller: _vm.newPasswordController,
                label: 'New Password',
                hint: 'Enter your new password',
                isVisible: _vm.isNewPasswordVisible,
                onToggleVisibility: _vm.toggleNewPasswordVisibility,
                themeManager: themeManager,
              ),
              
              SB.h(3.h),
              
              // Confirm Password Field
              _buildPasswordField(
                controller: _vm.confirmPasswordController,
                label: 'Confirm New Password',
                hint: 'Re-enter your new password',
                isVisible: _vm.isConfirmPasswordVisible,
                onToggleVisibility: _vm.toggleConfirmPasswordVisibility,
                themeManager: themeManager,
              ),
              
              SB.h(4.h),
              
              // Password Requirements
              _buildPasswordRequirements(themeManager),
              
              SB.h(4.h),
              
              // Change Password Button
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: _vm.isLoading ? null : () => _vm.changePassword(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeManager.currentTheme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _vm.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Change Password',
                          style: TextStyle(fontSize: 18.sp),
                        ),
                ),
              ),
              
              SB.h(2.h),
              
              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: OutlinedButton(
                  onPressed: _vm.isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: themeManager.currentTheme.colorScheme.outline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: themeManager.currentTheme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required ThemeManager themeManager,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: themeManager.currentTheme.colorScheme.onSurface,
          ),
        ),
        SB.h(1.h),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          style: TextStyle(color: themeManager.currentTheme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.5),
            ),
            filled: true,
            fillColor: themeManager.currentTheme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: themeManager.currentTheme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: themeManager.currentTheme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: themeManager.currentTheme.colorScheme.primary,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility_off : Icons.visibility,
                color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.6),
              ),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements(ThemeManager themeManager) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: themeManager.currentTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: themeManager.currentTheme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: themeManager.currentTheme.colorScheme.onSurface,
            ),
          ),
          SB.h(1.h),
          _buildRequirement(
            'At least 6 characters long',
            themeManager,
          ),
          _buildRequirement(
            'Different from your current password',
            themeManager,
          ),
          _buildRequirement(
            'Must match the confirmation',
            themeManager,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, ThemeManager themeManager) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: themeManager.currentTheme.colorScheme.primary,
          ),
          SB.w(2.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }
}

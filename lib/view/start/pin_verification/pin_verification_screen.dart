import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dex/util/size_extension.dart';
import 'package:dex/helper/sb_helper.dart';
import 'package:dex/theme/theme_manager.dart';
import 'pin_verification_vm.dart';

class PinVerificationScreen extends StatelessWidget {
  const PinVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PinVerificationVM>();
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SB.h(4.h),

              Text(
                "Enter Your PIN",
                style: themeManager.currentTheme.textTheme.headlineMedium?.copyWith(
                  fontSize: 6.sp,
                  fontWeight: FontWeight.bold,
                  color: themeManager.currentTheme.colorScheme.onSurface,
                ),
              ),

              SB.h(1.h),

              Text(
                "Enter your PIN to access your wallet",
                style: TextStyle(
                  fontSize: 3.5.sp,
                  color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              SB.h(4.h),

              // PIN boxes
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(vm.pinFocusNode);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final filled = index < vm.pin.length;
                    final display = filled ? '*' : ""; // mask entered PIN
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: filled 
                            ? themeManager.currentTheme.colorScheme.primary
                            : themeManager.currentTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: filled
                            ? null
                            : Border.all(
                                color: themeManager.currentTheme.colorScheme.outline.withOpacity(0.5),
                              ),
                      ),
                      child: Center(
                        child: Text(
                          display,
                          style: TextStyle(
                            fontSize: 6.sp,
                            fontWeight: FontWeight.bold,
                            color: filled 
                                ? themeManager.currentTheme.colorScheme.onPrimary
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Hidden TextField
              Opacity(
                opacity: 0.0,
                child: TextField(
                  focusNode: vm.pinFocusNode,
                  controller: vm.pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  autofocus: true,
                  obscureText: true,
                  obscuringCharacter: '•',
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    counterText: "",
                    border: InputBorder.none,
                  ),
                  onChanged: vm.setPin,
                ),
              ),

              SB.h(2.h),

              // Error message display
              if (vm.errorMessage.isNotEmpty)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        vm.errorMessage,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 3.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // Show Create PIN button if no PIN is stored
                      if (vm.errorMessage.contains("No PIN found"))
                        Column(
                          children: [
                            SB.h(2.h),
                            ElevatedButton(
                              onPressed: () => vm.navigateToCreatePin(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeManager.currentTheme.colorScheme.primary,
                                foregroundColor: themeManager.currentTheme.colorScheme.onPrimary,
                                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                              ),
                              child: Text(
                                'Create PIN',
                                style: TextStyle(fontSize: 3.sp),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

              if (vm.errorMessage.isNotEmpty) SB.h(2.h),

              // Manual Verify Button (if PIN is 4 digits)
              if (vm.pin.length == 4)
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  child: ElevatedButton(
                    onPressed: () => vm.verifyPinManually(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeManager.currentTheme.colorScheme.primary,
                      foregroundColor: themeManager.currentTheme.colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Verify PIN',
                      style: TextStyle(
                        fontSize: 4.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              SB.h(2.h),

              // Biometric authentication button
              if (vm.isBiometricAvailable)
                Column(
                  children: [
                    GestureDetector(
                      onTap: () => vm.authenticateWithBiometric(context),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: themeManager.currentTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: themeManager.currentTheme.colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              vm.biometricIcon,
                              color: themeManager.currentTheme.colorScheme.primary,
                              size: 6.w,
                            ),
                            SB.w(2.w),
                            Text(
                              vm.isBiometricEnabled 
                                ? "Use ${vm.biometricType}"
                                : "Enable ${vm.biometricType}",
                              style: TextStyle(
                                color: themeManager.currentTheme.colorScheme.onSurface,
                                fontSize: 3.5.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SB.h(2.h),
                  ],
                ),

              // Error message
              if (vm.errorMessage.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: themeManager.currentTheme.colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: themeManager.currentTheme.colorScheme.error.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    vm.errorMessage,
                    style: TextStyle(
                      color: themeManager.currentTheme.colorScheme.error,
                      fontSize: 3.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              SB.h(4.h),

              // Forgot PIN button
              TextButton(
                onPressed: () => vm.showForgotPinDialog(context),
                child: Text(
                  "Forgot PIN?",
                  style: TextStyle(
                    color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 3.5.sp,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              SB.h(2.h),
            ],
          ),
        ),
      ),
    );
  }
}

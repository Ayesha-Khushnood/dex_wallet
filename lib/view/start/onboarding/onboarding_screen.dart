import 'package:dex/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../util/color_resources.dart';
import '../../../util/size_extension.dart';
import '../../../theme/theme_manager.dart';
import 'onboarding_vm.dart';
import 'package:dex/helper/sb_helper.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingVM>();
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              /// ✅ Logo
              Center(
                child: SvgPicture.asset(
                  "assets/svgs/logo.svg",
                  height: 15.h,
                  colorFilter: themeManager.isDarkMode 
                    ? null // Use original colors in dark theme
                    : ColorFilter.mode(
                        AppColors.primary, // Use primary color in light theme
                        BlendMode.srcIn,
                      ),
                  placeholderBuilder: (BuildContext context) => Container(
                    height: 15.h,
                    width: 15.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              /// ✅ Heading text
              Text(
                "Feel The\nEase Of\nTransacting",
                style: themeManager.currentTheme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 6.sp,
                  height: 1.0,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.left,
              ),

              SB.h(3.h),


              AppButton(
                text: "Get Started",
                onTap: () => vm.onGetStarted(context),
              ),

              SB.h(3.h),

              /// ✅ Footer
              Text.rich(
                TextSpan(
                  text: 'By tapping "Get Started" you agree and consent to our ',
                  style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 2.5.sp,
                    height: 1.0,
                    letterSpacing: 0.5,
                  ),
                  children: [
                    TextSpan(
                      text: "Terms of Service",
                      style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                        fontSize: 2.5.sp,
                        height: 1.0,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const TextSpan(text: " and "),
                    TextSpan(
                      text: "Privacy Policy",
                      style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                        fontSize: 2.5.sp,
                        height: 1.0,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              SB.h(4.h),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dex/util/size_extension.dart';
import 'package:dex/util/color_resources.dart';
import 'package:dex/helper/sb_helper.dart';
// Note: This dialog now uses Theme.of(context) directly to avoid requiring a Provider scope

class ComingSoonDialog extends StatelessWidget {
  final String title;
  final String description;
  final String iconPath;
  final Color? iconColor;

  const ComingSoonDialog({
    super.key,
    required this.title,
    required this.description,
    required this.iconPath,
    this.iconColor,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String description,
    required String iconPath,
    Color? iconColor,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ComingSoonDialog(
        title: title,
        description: description,
        iconPath: iconPath,
        iconColor: iconColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: theme.cardColor,
      child: Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: iconColor ?? AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.w),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  width: 10.w,
                  height: 10.w,
                  color: iconColor ?? AppColors.primary,
                ),
              ),
            ),
            
            SB.h(4.h),
            
            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 5.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            SB.h(2.h),
            
            // Description
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 3.8.sp,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            SB.h(4.h),
            
            // Coming Soon Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 4.sp,
                    color: AppColors.primary,
                  ),
                  SB.w(1.w),
                  Text(
                    "Coming Soon",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 3.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            SB.h(4.h),
            
            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Got it",
                  style: TextStyle(
                    fontSize: 4.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


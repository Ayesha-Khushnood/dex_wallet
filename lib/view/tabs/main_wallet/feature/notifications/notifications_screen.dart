import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../util/color_resources.dart';
import '../../../../../util/size_extension.dart';
import '../../../../../helper/sb_helper.dart';
import '../../../../../theme/theme_manager.dart';
import '../../../../bottomNav/bottom_nav.dart';
import 'notifications_vm.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationsVM>();
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
      bottomNavigationBar: const AppBottomNav(),
      appBar: AppBar(
        backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary, size: 6.w),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Notifications",
          style: TextStyle(
            color: themeManager.currentTheme.colorScheme.onSurface,
            fontSize: 5.sp,
            fontWeight: FontWeight.bold,
            fontFamily: "Rubik",
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.light_mode, color: AppColors.primary),
            onPressed: () => themeManager.forceLightTheme(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          itemCount: vm.notifications.length,
          separatorBuilder: (context, index) => Divider(
            color: themeManager.currentTheme.dividerTheme.color,
            height: 2.h,
            thickness: 1,
          ),
          itemBuilder: (context, index) {
            final notification = vm.notifications[index];
            return _buildNotificationItem(notification, themeManager);
          },
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification, ThemeManager themeManager) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date (if available)
          if (notification.date != null) ...[
            Text(
              notification.date!,
              style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                fontSize: 3.sp,
              ),
            ),
            SB.h(1.h),
          ],
          
          // Title
          Text(
            notification.title,
            style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
              fontSize: 4.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SB.h(0.8.h),
          
          // Description
          Text(
            notification.description,
            style: themeManager.currentTheme.textTheme.bodyMedium?.copyWith(
              fontSize: 3.5.sp,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}


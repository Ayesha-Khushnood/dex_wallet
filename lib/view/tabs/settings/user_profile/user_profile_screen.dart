import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../helper/sb_helper.dart';
import '../../../../theme/theme_manager.dart';
import '../../../../util/size_extension.dart';
import '../../../../services/user_profile_service.dart';
import 'user_profile_vm.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProfileVM(),
      child: Consumer<UserProfileService>(
        builder: (context, profileService, child) {
          return const _UserProfileContent();
        },
      ),
    );
  }
}

class _UserProfileContent extends StatelessWidget {
  const _UserProfileContent();

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final vm = Provider.of<UserProfileVM>(context);

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
          'User Profile',
          style: TextStyle(
            color: themeManager.currentTheme.colorScheme.onSurface,
            fontSize: 5.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (vm.hasUser && !vm.isEditMode)
            IconButton(
              icon: Icon(
                Icons.edit,
                color: themeManager.currentTheme.colorScheme.primary,
              ),
              onPressed: vm.toggleEditMode,
            ),
        ],
      ),
      body: SafeArea(
        child: Consumer<UserProfileService>(
          builder: (context, profileService, child) {
            if (profileService.hasUser) {
              return _buildProfileContent(context, vm, themeManager);
            } else if (profileService.isLoading) {
              return _buildLoadingState(themeManager);
            } else if (profileService.error != null) {
              return _buildErrorState(vm, themeManager, profileService.error!);
            } else {
              return _buildErrorState(vm, themeManager, 'No user data available');
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfileVM vm, ThemeManager themeManager) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(vm, themeManager),

          SB.h(4.h),

          // Profile Information
          _buildProfileInfo(context, vm, themeManager),

          SB.h(4.h),

          // Account Status
          _buildAccountStatus(vm, themeManager),

          SB.h(4.h),

          // Action Buttons
          if (vm.isEditMode) _buildEditActions(vm, themeManager),

          SB.h(4.h),

          // Security Actions
          _buildSecurityActions(context, themeManager),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProfileVM vm, ThemeManager themeManager) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeManager.currentTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeManager.currentTheme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 8.w,
            backgroundColor: themeManager.currentTheme.colorScheme.primary,
            child: Text(
              vm.user!.displayName.isNotEmpty
                  ? vm.user!.displayName[0].toUpperCase()
                  : 'U',
              style: TextStyle(
                color: Colors.white,
                fontSize: 5.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SB.w(4.w),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.user!.displayName,
                  style: TextStyle(
                    fontSize: 5.sp,
                    fontWeight: FontWeight.bold,
                    color: themeManager.currentTheme.colorScheme.onSurface,
                  ),
                ),
                SB.h(0.5.h),
                Text(
                  vm.user!.email,
                  style: TextStyle(
                    fontSize: 3.sp,
                    color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                SB.h(0.5.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: vm.getVerificationColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: vm.getVerificationColor()),
                      ),
                      child: Text(
                        vm.getVerificationStatus(),
                        style: TextStyle(
                          fontSize: 3.sp,
                          color: vm.getVerificationColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context, UserProfileVM vm, ThemeManager themeManager) {
    return Container(
      width: double.infinity, // 👈 same as account status
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeManager.currentTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeManager.currentTheme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Information',
            style: TextStyle(
              fontSize: 4.sp,
              fontWeight: FontWeight.bold,
              color: themeManager.currentTheme.colorScheme.onSurface,
            ),
          ),

          SB.h(2.h),

          // Username
          _buildInfoField(
            'Username',
            vm.isEditMode
                ? _buildEditableField(context, vm.usernameController, 'Enter username')
                : Text(
              vm.user!.username,
              style: TextStyle(
                fontSize: 3.sp,
                color: themeManager.currentTheme.colorScheme.onSurface,
              ),
            ),
            themeManager,
          ),

          SB.h(1.5.h),

          // First Name
          _buildInfoField(
            'First Name',
            vm.isEditMode
                ? _buildEditableField(context, vm.firstNameController, 'Enter first name')
                : Text(
              vm.user!.firstName,
              style: TextStyle(
                fontSize: 3.sp,
                color: themeManager.currentTheme.colorScheme.onSurface,
              ),
            ),
            themeManager,
          ),

          SB.h(1.5.h),

          // Last Name
          _buildInfoField(
            'Last Name',
            vm.isEditMode
                ? _buildEditableField(context, vm.lastNameController, 'Enter last name')
                : Text(
              vm.user!.lastName,
              style: TextStyle(
                fontSize: 3.sp,
                color: themeManager.currentTheme.colorScheme.onSurface,
              ),
            ),
            themeManager,
          ),

          SB.h(1.5.h),

          // Email
          _buildInfoField(
            'Email',
            Text(
              vm.user!.email,
              style: TextStyle(
                fontSize: 3.sp,
                color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            themeManager,
          ),

          SB.h(1.5.h),

          // Role
          _buildInfoField(
            'Role',
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: themeManager.currentTheme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                vm.user!.role.toUpperCase(),
                style: TextStyle(
                  fontSize: 2.5.sp,
                  color: themeManager.currentTheme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            themeManager,
          ),
        ],
      ),
    );
  }


  Widget _buildAccountStatus(UserProfileVM vm, ThemeManager themeManager) {
    return Container(
      width: double.infinity, // 👈 same as profile info
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeManager.currentTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeManager.currentTheme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Status',
            style: TextStyle(
              fontSize: 4.sp,
              fontWeight: FontWeight.bold,
              color: themeManager.currentTheme.colorScheme.onSurface,
            ),
          ),

          SB.h(2.h),

          _buildStatusField('Account Status', vm.user!.isActive ? 'Active' : 'Inactive', themeManager),
          SB.h(1.5.h),
          _buildStatusField('Email Verified', vm.getVerificationStatus(), themeManager),
          SB.h(1.5.h),
          _buildStatusField('Last Login', vm.formatDate(vm.user!.lastLogin), themeManager),
          SB.h(1.5.h),
          _buildStatusField('Member Since', vm.formatDate(vm.user!.createdAt), themeManager),
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, Widget child, ThemeManager themeManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 3.sp,
            fontWeight: FontWeight.w500,
            color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        SB.h(0.5.h),
        child,
      ],
    );
  }

  Widget _buildStatusField(String label, String value, ThemeManager themeManager) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 3.sp,
            color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 3.sp,
            fontWeight: FontWeight.w500,
            color: themeManager.currentTheme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(BuildContext context, TextEditingController controller, String hint) {
    final themeManager = Provider.of<ThemeManager>(context);
    return TextFormField(
      controller: controller,
      style: TextStyle(
        color: themeManager.currentTheme.colorScheme.onSurface,
      ),
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
        contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
      ),
    );
  }

  Widget _buildEditActions(UserProfileVM vm, ThemeManager themeManager) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: vm.isUpdating ? null : vm.cancelEdit,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: themeManager.currentTheme.colorScheme.outline),
              padding: EdgeInsets.symmetric(vertical: 2.h),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: themeManager.currentTheme.colorScheme.onSurface,
              ),
            ),
          ),
        ),

        SB.w(3.w),

        Expanded(
          child: ElevatedButton(
            onPressed: vm.isUpdating ? null : vm.updateUserProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeManager.currentTheme.colorScheme.primary,
              padding: EdgeInsets.symmetric(vertical: 2.h),
            ),
            child: vm.isUpdating
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Save Changes',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityActions(BuildContext context, ThemeManager themeManager) {
    return Container(
      width: double.infinity, // 👈 same as other containers
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeManager.currentTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeManager.currentTheme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security',
            style: TextStyle(
              fontSize: 4.sp,
              fontWeight: FontWeight.bold,
              color: themeManager.currentTheme.colorScheme.onSurface,
            ),
          ),

          SB.h(3.h),

          // Change Password Button
          InkWell(
            onTap: () => Navigator.pushNamed(context, '/change_password'),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: themeManager.currentTheme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: themeManager.currentTheme.colorScheme.primary,
                    size: 24,
                  ),

                  SB.w(3.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Change Password',
                          style: TextStyle(
                            fontSize: 3.sp,
                            fontWeight: FontWeight.w600,
                            color: themeManager.currentTheme.colorScheme.onSurface,
                          ),
                        ),
                        SB.h(0.5.h),
                        Text(
                          'Update your account password',
                          style: TextStyle(
                            fontSize: 2.5.sp,
                            color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    Icons.arrow_forward_ios,
                    color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.5),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeManager themeManager) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: themeManager.currentTheme.colorScheme.primary,
          ),
          SB.h(2.h),
          Text(
            'Loading profile...',
            style: TextStyle(
              fontSize: 4.sp,
              fontWeight: FontWeight.bold,
              color: themeManager.currentTheme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(UserProfileVM vm, ThemeManager themeManager, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 20.w,
            color: themeManager.currentTheme.colorScheme.error,
          ),
          SB.h(2.h),
          Text(
            'Failed to load profile',
            style: TextStyle(
              fontSize: 4.sp,
              fontWeight: FontWeight.bold,
              color: themeManager.currentTheme.colorScheme.onSurface,
            ),
          ),
          SB.h(1.h),
          Text(
            error,
            style: TextStyle(
              fontSize: 3.sp,
              color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SB.h(3.h),
          ElevatedButton(
            onPressed: () => UserProfileService.instance.loadUserProfile(forceRefresh: true),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:dex/util/size_extension.dart';
import '../../../../util/color_resources.dart';
import '../../../../helper/sb_helper.dart';
import '../../../../theme/theme_manager.dart';
import '../../../../widgets/coming_soon_dialog.dart';
import 'settings_vm.dart';

class SettingsWrapper extends StatelessWidget {
  const SettingsWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsVM(),
      child: const SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SettingsVM>(context);
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- Wallet ----------------
                Text(
                  "Wallet",
                  style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                    fontSize: 4.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SB.h(2.h),
                 _buildTile("assets/svgs/setting/address.svg", "Address Book",
                     trailing: Icon(Icons.chevron_right, 
                         color: themeManager.currentTheme.colorScheme.onSurface),
                     onTap: () => ComingSoonDialog.show(
                       context,
                       title: "Address Book",
                       description: "Save and manage your frequently used wallet addresses for quick access.",
                       iconPath: "assets/svgs/setting/address.svg",
                     ),
                     themeManager: themeManager),
                 _buildTile(
                   "assets/svgs/setting/theme.svg",
                   "Dark & Light Theme",
                   trailing: Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Text(
                         themeManager.themeModeString,
                         style: TextStyle(
                           color: themeManager.currentTheme.colorScheme.onSurface,
                           fontSize: 3.5.sp,
                         ),
                       ),
                       const SizedBox(width: 8),
                       Switch(
                         value: themeManager.isDarkMode,
                         onChanged: (_) => themeManager.toggleTheme(),
                         activeColor: AppColors.primary,
                       ),
                     ],
                   ),
                   themeManager: themeManager,
                 ),
                 _buildTile("assets/svgs/setting/wallet.svg", "Wallet Connect",
                     trailing: Icon(Icons.chevron_right, 
                         color: themeManager.currentTheme.colorScheme.onSurface),
                     onTap: () => ComingSoonDialog.show(
                       context,
                       title: "Wallet Connect",
                       description: "Connect your wallet to dApps and DeFi platforms seamlessly.",
                       iconPath: "assets/svgs/setting/wallet.svg",
                     ),
                     themeManager: themeManager),

                SB.h(3.h),

                // ---------------- Account ----------------
                Text(
                  "Account",
                  style: TextStyle(
                    color: themeManager.currentTheme.colorScheme.onSurface,
                    fontSize: 4.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SB.h(2.h),
                 _buildTile("assets/svgs/setting/language.svg", "User Profile",
                     trailing: Icon(Icons.chevron_right, 
                         color: themeManager.currentTheme.colorScheme.onSurface),
                     onTap: () => Navigator.pushNamed(context, "/user_profile"),
                     themeManager: themeManager),

                SB.h(3.h),

                // ---------------- Localization ----------------
                Text(
                  "Localization",
                  style: TextStyle(
                    color: themeManager.currentTheme.colorScheme.onSurface,
                    fontSize: 4.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SB.h(2.h),
                 _buildTile("assets/svgs/setting/language.svg", "Change Language",
                     trailing: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Text(vm.selectedLanguage,
                             style: TextStyle(color: themeManager.currentTheme.colorScheme.onSurface)),
                         Icon(Icons.chevron_right, 
                             color: themeManager.currentTheme.colorScheme.onSurface),
                       ],
                     ),
                     onTap: () => ComingSoonDialog.show(
                       context,
                       title: "Change Language",
                       description: "Select your preferred language for the app interface.",
                       iconPath: "assets/svgs/setting/language.svg",
                     ),
                     themeManager: themeManager),
                 _buildTile("assets/svgs/setting/currency.svg", "Currency",
                     trailing: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Text(vm.selectedCurrency,
                             style: TextStyle(color: themeManager.currentTheme.colorScheme.onSurface)),
                         Icon(Icons.chevron_right, 
                             color: themeManager.currentTheme.colorScheme.onSurface),
                       ],
                     ),
                     onTap: () => ComingSoonDialog.show(
                       context,
                       title: "Currency Settings",
                       description: "Change your preferred currency for displaying prices and values.",
                       iconPath: "assets/svgs/setting/currency.svg",
                     ),
                     themeManager: themeManager),

                SB.h(3.h),

                // ---------------- Security ----------------
                Text(
                  "Security",
                  style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                    fontSize: 4.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SB.h(2.h),
                 _buildTile("assets/svgs/setting/backup.svg", "Backup Wallet",
                     trailing: Icon(Icons.chevron_right, 
                         color: themeManager.currentTheme.colorScheme.onSurface),
                     onTap: () => ComingSoonDialog.show(
                       context,
                       title: "Backup Wallet",
                       description: "Export your wallet's seed phrase and private keys for secure backup.",
                       iconPath: "assets/svgs/setting/backup.svg",
                     ),
                     themeManager: themeManager),
                 _buildTile("assets/svgs/setting/import.svg",
                     "Import & Export Wallet with Private key",
                     trailing: Icon(Icons.chevron_right, 
                         color: themeManager.currentTheme.colorScheme.onSurface),
                     onTap: () => ComingSoonDialog.show(
                       context,
                       title: "Import & Export Wallet",
                       description: "Import existing wallets or export your wallet data using private keys.",
                       iconPath: "assets/svgs/setting/import.svg",
                     ),
                     themeManager: themeManager),
                 _buildTile("assets/svgs/setting/pin.svg", "Always Ask Pin",
                     trailing: Switch(
                       value: vm.askPin,
                       onChanged: (_) async => await vm.toggleAskPin(),
                       activeColor: AppColors.primary,
                     ),
                     themeManager: themeManager),
                 if (vm.isBiometricAvailable)
                   _buildTile("assets/svgs/setting/face.svg", "Activate Face ID / Biometric",
                       trailing: Switch(
                         value: vm.biometricEnabled,
                         onChanged: (_) => vm.toggleBiometric(context),
                         activeColor: AppColors.primary,
                       ),
                       themeManager: themeManager),
                 _buildTile("assets/svgs/setting/pin.svg", "Lock Wallet",
                     trailing: Icon(Icons.chevron_right, 
                         color: themeManager.currentTheme.colorScheme.onSurface),
                     onTap: () => vm.lockWallet(context),
                     themeManager: themeManager),
                 _buildTile("assets/svgs/setting/import.svg", "Logout",
                     trailing: Icon(Icons.logout, 
                         color: Colors.red),
                     onTap: () => vm.logout(context),
                     themeManager: themeManager),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(String iconPath, String title, {required Widget trailing, required ThemeManager themeManager, VoidCallback? onTap}) {
    
    Widget tileContent = Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: themeManager.isDarkMode 
                ? const Color(0xFF3A1E15) 
                : AppColors.primaryLight.withOpacity(0.2), // Light primary background for light theme
            radius: 5.w,
            child: SvgPicture.asset(
              iconPath,
              width: 5.w,
              height: 5.w,
              color: themeManager.currentTheme.colorScheme.onSurface,
            ),
          ),
          SB.w(3.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: themeManager.currentTheme.colorScheme.onSurface, 
                fontSize: 4.sp
              ),
            ),
          ),
          trailing,
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: tileContent,
      );
    } else {
      return tileContent;
    }
  }
}

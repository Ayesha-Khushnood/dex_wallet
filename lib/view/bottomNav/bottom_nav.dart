import 'package:dex/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_manager.dart';
import '../../view/bottomNav/bottom_nav_vm.dart';

class AppBottomNav extends StatelessWidget {
  final ValueChanged<int>? onTap;
  const AppBottomNav({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<BottomNavVM>(context);
    final themeManager = Provider.of<ThemeManager>(context);

    return BottomNavigationBar(
      backgroundColor: themeManager.currentTheme.bottomNavigationBarTheme.backgroundColor,
      type: BottomNavigationBarType.fixed,
      currentIndex: vm.currentIndex,
      selectedItemColor: themeManager.currentTheme.bottomNavigationBarTheme.selectedItemColor,
      unselectedItemColor: themeManager.currentTheme.bottomNavigationBarTheme.unselectedItemColor,
      selectedLabelStyle: TextStyle(
        fontFamily: "Rubik",
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: "Rubik",
        fontWeight: FontWeight.w400,
        fontSize: 12,
      ),
      onTap: (index) {
        if (onTap != null) {
          onTap!(index);
        } else {
          vm.setIndex(index);
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: _buildSvgIcon("assets/svgs/wallet_home/home.svg", vm.currentIndex == 0, themeManager),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: _buildSvgIcon("assets/svgs/wallet_home/market.svg", vm.currentIndex == 1, themeManager),
          label: "Market",
        ),
        BottomNavigationBarItem(
          icon: _buildSvgIcon("assets/svgs/wallet_home/explore.svg", vm.currentIndex == 2, themeManager),
          label: "Explore",
        ),
        BottomNavigationBarItem(
          icon: _buildSvgIcon("assets/svgs/wallet_home/swap.svg", vm.currentIndex == 3, themeManager),
          label: "Swap",
        ),
        BottomNavigationBarItem(
          icon: _buildSvgIcon("assets/svgs/wallet_home/setting.svg", vm.currentIndex == 4, themeManager),
          label: "Setting",
        ),
      ],
    );
  }

  Widget _buildSvgIcon(String assetPath, bool isSelected, ThemeManager themeManager) {
    return SvgPicture.asset(
      assetPath,
      height: 22,
      width: 22,
      colorFilter: ColorFilter.mode(
        isSelected ? AppColors.primary : themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.6),
        BlendMode.srcIn,
      ),
    );
  }
}

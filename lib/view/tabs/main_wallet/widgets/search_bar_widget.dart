import 'package:dex/util/size_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../../helper/sb_helper.dart';
import '../../../../util/color_resources.dart';
import '../../../../theme/theme_manager.dart';


class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    
    return Row(
      children: [
        Expanded(


          child: TextField(
            style: themeManager.currentTheme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: "BTC",
              hintStyle: themeManager.currentTheme.textTheme.bodyLarge?.copyWith(
                color: themeManager.currentTheme.hintColor,
              ),
              filled: true,
              fillColor: themeManager.currentTheme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 5.w),
              isDense: true,
            ),
          ),
        ),
        SB.w(4.w),
        _iconButton("assets/svgs/main_wallet/search_bar/icon_more.svg", context),
        SB.w(3.w),
        _iconButton("assets/svgs/main_wallet/search_bar/icon_bell.svg", context),
        SB.w(3.w),
        _iconButton("assets/svgs/main_wallet/search_bar/icon_scan.svg", context),
      ],
    );
  }

  Widget _iconButton(String asset, [BuildContext? context]) {
    final themeManager = Provider.of<ThemeManager>(context!);
    
    return GestureDetector(
      onTap: () {
        if (asset.contains("icon_scan.svg")) {
          Navigator.pushNamed(context, "/receive");
        } else if (asset.contains("icon_bell.svg")) {
          Navigator.pushNamed(context, "/notifications");
        } else if (asset.contains("icon_more.svg")) {
          Navigator.pushNamed(context, "/network");
        }
      },
      child: SvgPicture.asset(
        asset, 
        width: 5.w, 
        height: 3.h,
        colorFilter: themeManager.isDarkMode 
          ? null // Use original colors in dark theme
          : ColorFilter.mode(
              AppColors.primary, // Use primary color in light theme
              BlendMode.srcIn,
            ),
      ),
    );
  }
}

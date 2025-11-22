import 'package:dex/util/size_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:dex/helper/sb_helper.dart';
import 'package:dex/theme/theme_manager.dart';

class CoinTileWidget extends StatelessWidget {
  final String icon, name, symbol, price, count, amount;
  final VoidCallback? onTap; // Add onTap callback

  const CoinTileWidget({
    super.key,
    required this.icon,
    required this.name,
    required this.symbol,
    required this.price,
    required this.count,
    required this.amount,
    this.onTap, // Optional onTap
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return GestureDetector(
      onTap: onTap, // Make tile clickable
      child: Row(
        children: [
          SvgPicture.asset(icon, height: 7.w, width: 7.w),
          SB.w(3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                    fontSize: 4.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SB.h(0.5.h),
                Text(
                  price,
                  style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                    fontSize: 3.sp,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                count,
                style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                  fontSize: 4.5.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SB.h(0.5.h),
              Text(
                amount,
                style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                  fontSize: 2.5.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

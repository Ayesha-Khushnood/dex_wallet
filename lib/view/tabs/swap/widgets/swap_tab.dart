import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:dex/util/size_extension.dart';
import '../../../../util/color_resources.dart';
import '../../../../helper/sb_helper.dart';
import '../../../../theme/theme_manager.dart';
import '../../../../widgets/coming_soon_dialog.dart';

class SwapTab extends StatelessWidget {
  const SwapTab({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    
    return Scaffold(
      backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    children: [
                      _swapCard(
                        "ETH",
                        "Ethereum",
                        "assets/svgs/wallet_home/ethereum.svg",
                        true,
                        themeManager,
                      ),
                      SizedBox(height: 1.5.h),
                      _swapCard(
                        "SOL",
                        "Solana",
                        "assets/svgs/wallet_home/solana.svg",
                        false,
                        themeManager,
                      ),
                    ],
                  ),
                  Positioned(
                    top: 105, // adjust to overlap both cards
                    left: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 5.w,
                      backgroundColor: AppColors.deepBlue,
                      child: Icon(
                        Icons.swap_horiz,
                        color: AppColors.primary,
                        size: 6.w,
                      ),
                    ),
                  ),
                ],
              ),

              // Continue button
              SB.h(3.h),
              Container(
                width: double.infinity,
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(50),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Continue",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 4.5.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _swapCard(
      String symbol,
      String network,
      String iconPath,
      bool isFrom,
      ThemeManager themeManager,
      ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.w),
      decoration: BoxDecoration(
        color: themeManager.currentTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isFrom ? "From" : "To",
                style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                  fontSize: 3.5.sp,
                ),
              ),
              SB.w(2.w),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(network,
                      style: themeManager.currentTheme.textTheme.bodyLarge?.copyWith(
                        fontSize: 3.5.sp,
                      )),
                  Icon(Icons.arrow_drop_down, 
                      color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.6)),
                ],
              ),
              const Spacer(),
              if (isFrom)
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: themeManager.currentTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    "BUY",
                    style: TextStyle(
                      color: themeManager.currentTheme.colorScheme.onSurface, 
                      fontSize: 3.2.sp,
                    ),
                  ),
                ),
            ],
          ),
          SB.h(1.5.h),
          Row(
            children: [
              ClipOval(
                child: Container(
                  width: 9.w,
                  height: 9.w,
                  color: themeManager.currentTheme.colorScheme.surface,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SvgPicture.asset(iconPath),
                  ),
                ),
              ),
              SB.w(3.w),
              Text(
                symbol,
                style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                  fontSize: 4.5.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "0",
                    style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                      fontSize: 4.5.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "\$0.00",
                    style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                      fontSize: 3.2.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!isFrom) ...[
            SB.h(1.5.h),
            Divider(color: themeManager.currentTheme.dividerTheme.color, thickness: 1),
            SB.h(1.h),
            Text(
              "1 ETH ≈ \$67399.41 SOL",
              style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                fontSize: 3.sp,
              ),
            )
          ]
        ],
      ),
    );
  }
}

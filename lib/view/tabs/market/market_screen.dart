import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../util/size_extension.dart';
import '../../../helper/sb_helper.dart';
import '../../../theme/theme_manager.dart';
import 'market_vm.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MarketVM>();
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Market Statistics",
                  style: themeManager.currentTheme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 4.5.sp,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: vm.cryptoList.length,
                separatorBuilder: (context, index) => Divider(
                  color: themeManager.currentTheme.dividerTheme.color,
                  height: 1,
                  thickness: 0.5,
                ),
                itemBuilder: (context, index) {
                  final crypto = vm.cryptoList[index];
                  return _buildCryptoItem(crypto, themeManager);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCryptoItem(CryptoItem crypto, ThemeManager themeManager) {
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          SizedBox(
            width: 10.w,
            height: 10.w,
            child: SvgPicture.asset(
              crypto.icon,
              fit: BoxFit.contain,
            ),
          ),
          SB.w(3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crypto.name,
                  style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 3.8.sp,
                  ),
                ),
                SB.h(0.3.h),
                Row(
                  children: [
                    Text(
                      crypto.price,
                      style: themeManager.currentTheme.textTheme.bodyMedium?.copyWith(
                        fontSize: 2.8.sp,
                      ),
                    ),
                    SB.w(1.5.w),
                    Text(
                      crypto.change,
                      style: TextStyle(
                        fontFamily: "Rubik",
                        fontSize: 2.8.sp,
                        color: crypto.isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                crypto.quantity,
                style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 3.8.sp,
                ),
              ),
              SB.h(0.3.h),
              Text(
                crypto.totalValue,
                style: themeManager.currentTheme.textTheme.bodyMedium?.copyWith(
                  fontSize: 2.8.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

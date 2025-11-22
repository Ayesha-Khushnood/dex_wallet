import 'package:dex/util/size_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../helper/sb_helper.dart';
import '../../../../theme/theme_manager.dart';

class WalletBalanceWidget extends StatelessWidget {
  final String title;
  final String balance;
  const WalletBalanceWidget({
    super.key,
    required this.title,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: themeManager.currentTheme.textTheme.titleMedium?.copyWith(
            fontSize: 3.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SB.h(0.8.h),
        Text(
          balance,
          style: themeManager.currentTheme.textTheme.displayMedium?.copyWith(
            fontSize: 8.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

import 'package:dex/util/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dex/util/size_extension.dart';
import 'package:provider/provider.dart';
import '../../../../helper/sb_helper.dart';
import '../../../../theme/theme_manager.dart';

class WalletAddressWidget extends StatelessWidget {
  final String? walletAddress;
  final bool isLoading;
  final VoidCallback? onTap;

  const WalletAddressWidget({
    super.key,
    required this.walletAddress,
    required this.isLoading,
    this.onTap,
  });

  /// Truncate address to show first 6 and last 4 characters
  String _truncateAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeManager.currentTheme.cardColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Wallet icon
          Icon(
            Icons.account_balance_wallet,
            color: AppColors.primary,
            size: 5.w,
          ),
          SB.w(3.w),
          
          // Address content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoading)
                  Row(
                    children: [
                      SizedBox(
                        width: 4.w,
                        height: 4.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      SB.w(2.w),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          color: themeManager.currentTheme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                          fontSize: 3.sp,
                        ),
                      ),
                    ],
                  )
                else if (walletAddress != null)
                  Text(
                    _truncateAddress(walletAddress!),
                    style: TextStyle(
                      color: themeManager.currentTheme.textTheme.bodyMedium?.color,
                      fontSize: 3.sp,
                      fontFamily: 'monospace',
                    ),
                  )
                else
                  Text(
                    'Please login to view wallet',
                    style: TextStyle(
                      color: themeManager.currentTheme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontSize: 3.sp,
                    ),
                  ),
              ],
            ),
          ),
          
          // Copy button
          if (walletAddress != null)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: walletAddress!));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 4.w,
                        ),
                        SB.w(2.w),
                        const Text('Address copied!'),
                      ],
                    ),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.copy,
                  color: AppColors.primary,
                  size: 4.w,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

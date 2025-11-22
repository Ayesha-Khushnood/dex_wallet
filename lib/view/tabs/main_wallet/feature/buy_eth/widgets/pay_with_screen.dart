import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../../../../util/color_resources.dart';
import '../../../../../../util/size_extension.dart';
import '../../../../../../helper/sb_helper.dart';
import '../../../../../../theme/theme_manager.dart';
import 'pay_with_vm.dart';

class PayWithScreen extends StatelessWidget {
  const PayWithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PayWithVM>();
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.primary,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Pay with",
          style: TextStyle(
            color: themeManager.currentTheme.colorScheme.onSurface,
            fontFamily: "Rubik",
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SB.h(1.h),

            // Payment options list
            _buildPaymentOption(
              context,
              vm,
              "Google Pay",
              "assets/svgs/buyETH/google_pay.svg",
              themeManager,
            ),
            SB.h(2.h),
            _buildPaymentOption(
              context,
              vm,
              "Apple Pay",
              "assets/svgs/buyETH/apple_pay.svg",
              themeManager,
            ),
            SB.h(2.h),
            _buildPaymentOption(
              context,
              vm,
              "Credit / Debit",
              "assets/svgs/buyETH/visa.svg",
              themeManager,
            ),
            SB.h(2.h),
            _buildPaymentOption(
              context,
              vm,
              "Paypal",
              "assets/svgs/buyETH/paypal.svg",
              themeManager,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
      BuildContext context,
      PayWithVM vm,
      String displayName,
      String iconPath,
      ThemeManager themeManager,
      ) {
    return GestureDetector(
      onTap: () {
        // Return selected payment method
        Navigator.pop(context, displayName);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.2.h),
        decoration: BoxDecoration(
          color: themeManager.currentTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            /// Circle icon
            Container(
              width: 9.w,
              height: 9.w,
              decoration: BoxDecoration(
                color: themeManager.currentTheme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.all(1.5.w),
                child: SvgPicture.asset(
                  iconPath,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            SB.w(3.w),

            /// Payment name
            Expanded(
              child: Text(
                displayName,
                style: TextStyle(
                  color: themeManager.currentTheme.colorScheme.onSurface,
                  fontFamily: "Rubik",
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

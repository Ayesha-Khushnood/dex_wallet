import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:dex/util/size_extension.dart';
import 'package:dex/helper/sb_helper.dart';
import 'package:dex/util/color_resources.dart';
import 'package:dex/widgets/app_button.dart';
import 'package:dex/theme/theme_manager.dart';
import 'package:dex/widgets/coming_soon_dialog.dart';

class BuyEthScreen extends StatefulWidget {
  const BuyEthScreen({super.key});

  @override
  State<BuyEthScreen> createState() => _BuyEthScreenState();
}

class _BuyEthScreenState extends State<BuyEthScreen> {
  final TextEditingController _amountController =
      TextEditingController(text: "\$1500.0");
  String _selectedPaymentMethod = "Google Pay";

  @override
  Widget build(BuildContext context) {
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
        centerTitle: true,
        title: const Text(
          "BUY ETH",
          style: TextStyle(
            color: AppColors.primary,
            fontFamily: "Rubik",
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: themeManager.currentTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(6),
            child: SvgPicture.asset(
              "assets/svgs/buyETH/australia.svg",
              width: 24,
              height: 18,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Column(
          children: [
            SB.h(10.h),

            /// ===== Amount Input =====
            TextField(
              controller: _amountController,
              textAlign: TextAlign.center,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: themeManager.currentTheme.colorScheme.onSurface,
                fontFamily: "Rubik",
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "\$0.00",
                hintStyle: TextStyle(
                  color: themeManager.currentTheme.hintColor,
                ),
              ),
            ),

            SB.h(1.h),

            /// ===== ETH Equivalent =====
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "≈ 0.053195 ",
                  style: TextStyle(
                    fontSize: 3.sp,
                    color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.6),
                    fontFamily: "Rubik",
                  ),
                ),
                Icon(
                  Icons.swap_vert, 
                  color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ],
            ),

            const Spacer(),

            /// ===== Payment Method Option =====
            GestureDetector(
              onTap: () async {
                final result = await Navigator.pushNamed(context, "/pay_with");
                if (result != null && result is String) {
                  setState(() {
                    _selectedPaymentMethod = result;
                  });
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: themeManager.currentTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
                    width: 1,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      _getPaymentIcon(_selectedPaymentMethod),
                      width: 7.w,
                    ),
                    SB.w(3.w),
                    Expanded(
                      child: Text(
                        _selectedPaymentMethod,
                        style: TextStyle(
                          color: themeManager.currentTheme.colorScheme.onSurface,
                          fontFamily: "Rubik",
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.6),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),

            SB.h(3.h),

            /// ===== Buy Button =====
            AppButton(
              text: "Buy with $_selectedPaymentMethod",
              onTap: () => ComingSoonDialog.show(
                context,
                title: "Buy Cryptocurrency",
                description: "Purchase cryptocurrency directly with your preferred payment method. This feature will be available soon.",
                iconPath: "assets/svgs/buyETH/google_pay.svg",
              ),
            ),

            SB.h(4.h),
          ],
        ),
      ),
    );
  }

  String _getPaymentIcon(String paymentMethod) {
    switch (paymentMethod) {
      case "Google Pay":
        return "assets/svgs/buyETH/google_pay.svg";
      case "Apple Pay":
        return "assets/svgs/buyETH/apple_pay.svg";
      case "Credit / Debit":
        return "assets/svgs/buyETH/visa.svg";
      case "Paypal":
        return "assets/svgs/buyETH/paypal.svg";
      default:
        return "assets/svgs/buyETH/google_pay.svg";
    }
  }
}
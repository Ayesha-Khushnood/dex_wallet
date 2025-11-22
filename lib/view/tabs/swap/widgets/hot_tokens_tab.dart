import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:dex/util/size_extension.dart';
import '../../../../helper/sb_helper.dart';
import '../../../../theme/theme_manager.dart';

class HotTokensTab extends StatelessWidget {
  const HotTokensTab({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = [
      {
        "name": "Bitcoin",
        "icon": "assets/svgs/wallet_home/bitcoin.svg",
        "price": "99,284.01",
        "last": "68,908.00",
        "change": "+68.3%"
      },
      {
        "name": "Ethereum",
        "icon": "assets/svgs/wallet_home/ethereum.svg",
        "price": "99,284.01",
        "last": "68,908.00",
        "change": "+68.3%"
      },
      {
        "name": "Solana",
        "icon": "assets/svgs/wallet_home/solana.svg",
        "price": "99,284.01",
        "last": "68,908.00",
        "change": "+68.3%"
      },
    ];

    final themeManager = Provider.of<ThemeManager>(context);
    
    return Scaffold(
      backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header Row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text("Token /24H Volume",
                        style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                            fontSize: 3.5.sp)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text("Last Price",
                        style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                            fontSize: 3.5.sp),
                        textAlign: TextAlign.center),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text("24H %",
                        style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                            fontSize: 3.5.sp),
                        textAlign: TextAlign.right),
                  ),
                ],
              ),
            ),

            // Token List
            Expanded(
              child: ListView.builder(
                itemCount: 12,
                itemBuilder: (context, index) {
                  final token = tokens[index % tokens.length];
                  return Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Row(
                            children: [
                              ClipOval(
                                child: Container(
                                  width: 8.w,
                                  height: 8.w,
                                  color: themeManager.currentTheme.colorScheme.surface,
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: SvgPicture.asset(token["icon"]!),
                                  ),
                                ),
                              ),
                              SB.w(3.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(token["name"]!,
                                      style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                                          fontSize: 4.5.sp)),
                                  Text("\$${token["price"]}",
                                      style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                                          fontSize: 3.5.sp)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text("\$${token["last"]}",
                              style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                                  fontSize: 3.5.sp),
                              textAlign: TextAlign.center),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(token["change"]!,
                              style: TextStyle(
                                  color: Colors.green, fontSize: 3.5.sp),
                              textAlign: TextAlign.right),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

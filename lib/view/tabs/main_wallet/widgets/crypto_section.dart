import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dex/util/size_extension.dart';
import 'package:dex/helper/sb_helper.dart';
import 'package:dex/util/color_resources.dart';
import 'package:dex/theme/theme_manager.dart';
import 'coin_tile_widget.dart';
import '../../../../services/chain_data_provider.dart';
import '../../../../data/model/body/supported_chain_model.dart';

class CryptoSection extends StatelessWidget {
  const CryptoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final supportedChains = ChainDataProvider.getSupportedChains();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with underline
        Row(
          children: [
            Text(
              "Crypto",
              style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                fontSize: 4.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SB.w(2.w),
            Container(
              width: 20,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),

        SB.h(2.h),

        // Dynamic chain list
        Column(
          children: supportedChains.map((chain) {
            return Column(
              children: [
                CoinTileWidget(
                  icon: chain.iconPath,
                  name: chain.chainName,
                  symbol: chain.nativeCurrencySymbol,
                  price: "\$ 99,284.01", // You can add real-time prices later
                  count: "1.23",
                  amount: "\$ 68,908.00",
                  onTap: () => _navigateToChainMarket(context, chain),
                ),
                SB.h(1.h),
              ],
            );
          }).toList(),
        ),

        SB.h(2.h),

        // Manage Crypto text
        Text(
          "Manage Crypto",
          style: themeManager.currentTheme.textTheme.titleMedium?.copyWith(
            fontSize: 3.sp,
          ),
        ),
      ],
    );
  }
  
  void _navigateToChainMarket(BuildContext context, SupportedChainModel chain) {
    Navigator.pushNamed(
      context, 
      "/chain_market",
      arguments: chain, // Pass chain data
    );
  }
}

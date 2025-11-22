import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dex/util/size_extension.dart';
import 'package:dex/helper/sb_helper.dart';
import 'package:dex/util/color_resources.dart';
import 'package:dex/theme/theme_manager.dart';
import 'coin_tile_widget.dart';
import '../../../../services/chain_data_provider.dart';
import '../../../../data/model/body/supported_chain_model.dart';

class CryptoNFTTabSection extends StatefulWidget {
  const CryptoNFTTabSection({super.key});

  @override
  State<CryptoNFTTabSection> createState() => _CryptoNFTTabSectionState();
}

class _CryptoNFTTabSectionState extends State<CryptoNFTTabSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Listen for tab changes
    _tabController.addListener(() {
      if (_tabController.index == 1) { // NFT tab is index 1
        // Navigate to Bitcoin market screen when NFT tab is selected
        Navigator.pushNamed(context, "/bitcoin_market");
        // Switch back to Crypto tab (index 0) after navigation
        Future.microtask(() {
          _tabController.animateTo(0);
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab bar
        TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          labelColor: themeManager.currentTheme.colorScheme.onSurface,
          unselectedLabelColor: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.6),
          labelStyle: TextStyle(
            fontSize: 4.sp,
            fontWeight: FontWeight.bold,
            fontFamily: "Rubik",
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 4.sp,
            fontWeight: FontWeight.normal,
            fontFamily: "Rubik",
          ),
          tabs: const [
            Tab(text: "Crypto"),
            Tab(text: "NFT's"),
          ],
        ),

        SB.h(2.h),

        // Tab bar view
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Crypto tab content
              _buildCryptoTab(themeManager),
              // NFT tab content
              _buildNFTTab(themeManager),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCryptoTab(ThemeManager themeManager) {
    final supportedChains = ChainDataProvider.getSupportedChains();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dynamic chain list
        Expanded(
          child: ListView(
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
        ),

        // Manage Crypto text - Flexible height
        Padding(
          padding: EdgeInsets.symmetric(vertical: 1.h),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Manage Crypto",
              style: themeManager.currentTheme.textTheme.titleMedium?.copyWith(
                fontSize: 3.sp,
              ),
            ),
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

  Widget _buildNFTTab(ThemeManager themeManager) {
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: themeManager.currentTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          "Loading Bitcoin Market...",
          style: themeManager.currentTheme.textTheme.bodyLarge?.copyWith(
            fontSize: 16,
          ),
        ),
      ),
    );
  }

}

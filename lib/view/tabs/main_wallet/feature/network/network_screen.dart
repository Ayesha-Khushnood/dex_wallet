import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../util/color_resources.dart';
import '../../../../../../util/size_extension.dart';
import '../../../../../../helper/sb_helper.dart';
import '../../../../../../theme/theme_manager.dart';
import '../../../../../../services/chain_data_provider.dart';
import '../../../../../../data/model/body/supported_chain_model.dart';

class NetworkScreen extends StatelessWidget {
  const NetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final supportedChains = ChainDataProvider.getSupportedChains();

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
          "Supported Chains",
          style: TextStyle(
            color: themeManager.currentTheme.colorScheme.onSurface,
            fontFamily: "Rubik",
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Column(
            children: [
              SB.h(2.h),

              // Header
              _buildHeader(themeManager),

              SB.h(2.h),

              // Chain List
              Expanded(
                child: ListView.builder(
                  itemCount: supportedChains.length,
                  itemBuilder: (context, index) {
                    final chain = supportedChains[index];
                    return _buildChainItem(chain, themeManager);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeManager themeManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Supported Chains",
          style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SB.h(0.5.h),
        Text(
          "Tap on any chain to view its market details",
          style: themeManager.currentTheme.textTheme.bodyMedium?.copyWith(
            color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildChainItem(SupportedChainModel chain, ThemeManager themeManager) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => _navigateToChainMarket(context, chain),
        child: Container(
          margin: EdgeInsets.only(bottom: 1.h),
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: themeManager.currentTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Chain Icon with color
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: Color(int.parse(chain.color.replaceFirst('#', '0xFF'))),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    chain.nativeCurrencySymbol.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              SB.w(3.w),

              // Chain Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chain.chainName,
                      style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SB.h(0.2.h),
                    Text(
                      '${chain.nativeCurrencySymbol} • Chain ID: ${chain.chainIdNumber}',
                      style: themeManager.currentTheme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // Arrow icon to indicate clickable
              Icon(
                Icons.arrow_forward_ios,
                color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.6),
                size: 16,
              ),
            ],
          ),
        ),
      ),
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

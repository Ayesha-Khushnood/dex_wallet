import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../../../util/color_resources.dart';
import '../../../../../util/size_extension.dart';
import '../../../../../helper/sb_helper.dart';
import '../../../../../theme/theme_manager.dart';
import 'receive_crypto_vm.dart';

class ReceiveCryptoScreen extends StatelessWidget {
  const ReceiveCryptoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReceiveCryptoVM>();
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeManager.currentTheme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: vm.searchController,
                style: themeManager.currentTheme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: "Search crypto...",
                  hintStyle: themeManager.currentTheme.textTheme.bodyLarge?.copyWith(
                    color: themeManager.currentTheme.hintColor,
                  ),
                  filled: true,
                  fillColor: themeManager.currentTheme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 4.w),
                  isDense: true,
                ),
              ),
            ),
            SB.w(2.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: themeManager.currentTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "All Networks",
                    style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                      fontSize: 3.sp,
                    ),
                  ),
                  SB.w(1.w),
                  Icon(
                    Icons.keyboard_arrow_down, 
                    color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.6), 
                    size: 4.w,
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : vm.error != null
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48.w,
                          ),
                          SB.h(2.h),
                          Text(
                            vm.error!,
                            style: themeManager.currentTheme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          SB.h(2.h),
                          ElevatedButton(
                            onPressed: () {
                              // Trigger a refresh by calling the public method
                              vm.loadCryptoData();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Popular Section
                        Text(
                          "Popular",
                          style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                            fontSize: 4.5.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SB.h(2.h),
                        _buildPopularSection(vm, context, themeManager),

                        SB.h(3.h),

                        // All Crypto Section
                        Text(
                          "All Crypto",
                          style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                            fontSize: 4.5.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SB.h(2.h),
                        _buildAllCryptoSection(vm, context, themeManager),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildPopularSection(ReceiveCryptoVM vm, BuildContext context, ThemeManager themeManager) {
    final popularCrypto = vm.allCryptoList.take(2).toList();
    
    if (popularCrypto.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Row(
      children: [
        Expanded(
          child: _buildCryptoCard(
            iconPath: popularCrypto[0].iconPath,
            name: popularCrypto[0].symbol,
            fullName: popularCrypto[0].name,
            onTap: () => vm.selectCrypto(popularCrypto[0].symbol, context),
            themeManager: themeManager,
          ),
        ),
        if (popularCrypto.length > 1) ...[
          SB.w(2.w),
          Expanded(
            child: _buildCryptoCard(
              iconPath: popularCrypto[1].iconPath,
              name: popularCrypto[1].symbol,
              fullName: popularCrypto[1].name,
              onTap: () => vm.selectCrypto(popularCrypto[1].symbol, context),
              themeManager: themeManager,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCryptoCard({
    required String iconPath,
    required String name,
    required String fullName,
    required VoidCallback onTap,
    ThemeManager? themeManager,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: themeManager?.currentTheme.colorScheme.surface ?? Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeManager?.currentTheme.dividerTheme.color ?? Colors.grey[700]!,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                iconPath,
                fit: BoxFit.contain,
              ),
            ),
            SB.h(1.h),
            Text(
              name,
              style: themeManager?.currentTheme.textTheme.titleMedium?.copyWith(
                fontSize: 3.5.sp,
                fontWeight: FontWeight.bold,
              ) ?? TextStyle(
                color: Colors.white,
                fontSize: 3.5.sp,
                fontWeight: FontWeight.bold,
                fontFamily: "Rubik",
              ),
            ),
            Text(
              fullName,
              style: themeManager?.currentTheme.textTheme.bodySmall?.copyWith(
                fontSize: 2.5.sp,
              ) ?? TextStyle(
                color: Colors.white54,
                fontSize: 2.5.sp,
                fontFamily: "Rubik",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCryptoSection(ReceiveCryptoVM vm, BuildContext context, ThemeManager themeManager) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vm.cryptoList.length,
      separatorBuilder: (context, index) => SB.h(1.5.h),
      itemBuilder: (context, index) {
        final crypto = vm.cryptoList[index];
        return _buildCryptoListItem(crypto, vm, context, themeManager);
      },
    );
  }

  Widget _buildCryptoListItem(CryptoItem crypto, ReceiveCryptoVM vm, BuildContext context, ThemeManager themeManager) {
    return GestureDetector(
      onTap: () => vm.selectCrypto(crypto.symbol, context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          children: [
            // Crypto Icon
            SizedBox(
              width: 10.w,
              height: 10.w,
              child: SvgPicture.asset(
                crypto.iconPath,
                fit: BoxFit.contain,
              ),
            ),
            SB.w(3.w),
            
            // Crypto Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crypto.name,
                    style: themeManager.currentTheme.textTheme.titleMedium?.copyWith(
                      fontSize: 4.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SB.h(0.3.h),
                  Row(
                    children: [
                      Text(
                        "\$${crypto.price}",
                        style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                          fontSize: 3.sp,
                        ),
                      ),
                      SB.w(1.5.w),
                      Text(
                        crypto.change,
                        style: TextStyle(
                          color: crypto.change.startsWith('+') ? Colors.green : Colors.red,
                          fontSize: 3.sp,
                          fontFamily: "Rubik",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Holdings
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  crypto.holdings,
                  style: themeManager.currentTheme.textTheme.titleMedium?.copyWith(
                    fontSize: 3.5.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "\$${crypto.holdingsValue}",
                  style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                    fontSize: 3.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

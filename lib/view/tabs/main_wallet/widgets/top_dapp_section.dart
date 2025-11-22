import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dex/util/size_extension.dart';
import '../../../../helper/sb_helper.dart';
import '../../../../theme/theme_manager.dart';
import '../../../../services/dapp_service.dart';
import '../../../../data/model/dapp_model.dart';

class TopDappSection extends StatelessWidget {
  const TopDappSection({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final popularDApps = DAppService.getPopularDApps();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Top dApp",
              style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                fontSize: 4.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Icon(Icons.more_horiz, color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.6), size: 5.w),
          ],
        ),
        SB.h(2.h),
        SizedBox(
          height: 11.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: popularDApps.length,
            separatorBuilder: (_, __) => SizedBox(width: 2.5.w),
            itemBuilder: (context, index) {
              final dapp = popularDApps[index];
              return GestureDetector(
                onTap: () => _openDAppInBrowser(context, dapp),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 38.w,
                    height: 11.h,
                    color: Colors.white,
                    child: Image.asset(
                      dapp.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.apps,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SB.h(1.h),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => _openAllDAppsInBrowser(context),
            child: Text(
              "View all",
              style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                fontSize: 3.sp,
                color: themeManager.currentTheme.colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Open dApp in in-app browser
  void _openDAppInBrowser(BuildContext context, DAppModel dapp) {
    print('🚀 Opening dApp: ${dapp.name} - ${dapp.url}');
    
    Navigator.pushNamed(
      context,
      '/browser',
      arguments: {
        'url': dapp.url,
        'title': dapp.name,
      },
    );
  }

  /// Open all dApps page in browser
  void _openAllDAppsInBrowser(BuildContext context) {
    print('🚀 Opening all dApps page');
    
    // For now, open Uniswap as the main dApp hub
    Navigator.pushNamed(
      context,
      '/browser',
      arguments: {
        'url': 'https://app.uniswap.org/?chain=sepolia',
        'title': 'DeFi Hub',
      },
    );
  }
}

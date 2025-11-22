import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:dex/util/size_extension.dart';
import '../../../../helper/sb_helper.dart';
import '../../../../theme/theme_manager.dart';
import '../../../../config/blockchain_config.dart';

class ActionButtonsRow extends StatelessWidget {
  const ActionButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _actionCircle("assets/svgs/main_wallet/action_buttons/send.svg", "Send", context),
        _actionCircle("assets/svgs/main_wallet/action_buttons/receive.svg", "Receive", context),
        _actionCircle("assets/svgs/main_wallet/action_buttons/buy.svg", "Buy", context),
        _actionCircle("assets/svgs/main_wallet/action_buttons/sell.svg", "Sell", context),
        _actionCircle("assets/svgs/main_wallet/action_buttons/history.svg", "History", context),
      ],
    );
  }

  Widget _actionCircle(String asset, String label, BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    
    return GestureDetector(
      onTap: () {
        switch (label) {
          case "Receive":
            Navigator.pushNamed(context, "/receive_crypto");
            break;
          case "Send":
            // Navigate to send screen with default Ethereum Sepolia chain
            Navigator.pushNamed(
              context, 
              "/send",
              arguments: {
                'chainId': 'ethereum',
                'chainName': 'Ethereum Sepolia',
                'chainType': 'evm',
                'chainIdNumber': 11155111,
                'rpcUrl': BlockchainConfig.ethereumSepoliaRpc,
                'blockExplorer': 'https://sepolia.etherscan.io',
                'nativeCurrencyName': 'Ethereum',
                'nativeCurrencySymbol': 'ETH',
                'decimals': 18,
                'isActive': true,
                'iconPath': 'assets/svgs/wallet_home/ethereum.svg',
                'color': '#627EEA',
              }
            );
            break;
          case "Buy":
            Navigator.pushNamed(context, "/buy_eth");
            break;
          case "Sell":
            Navigator.pushNamed(context, "/receive");
            break;
            case "History":
              Navigator.pushNamed(context, "/history");
              break;
        }
      },
      child: Column(
        children: [
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeManager.isDarkMode ? const Color(0xFF121212) : const Color(0xFFE0E0E0),
            ),
            child: Center(
              child: SvgPicture.asset(asset, width: 6.w, height: 6.w),
            ),
          ),
          SB.h(0.8.h),
          Text(
            label,
            style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
              fontSize: 3.sp,
            ),
          ),
        ],
      ),
    );
  }
}

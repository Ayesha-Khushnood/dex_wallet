import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../util/size_extension.dart';
import '../../../helper/sb_helper.dart';
import '../../../theme/theme_manager.dart';
import '../../../services/wallet_service.dart';
import 'main_wallet_vm.dart';

// widgets import
import 'widgets/search_bar_widget.dart';
import 'widgets/wallet_balance_widget.dart';
import 'widgets/action_buttons_row.dart';
import 'widgets/top_dapp_section.dart';
import 'widgets/crypto_nft_tab_section.dart';
import 'widgets/wallet_address_widget.dart';

class MainWalletScreen extends StatefulWidget {
  const MainWalletScreen({super.key});

  @override
  State<MainWalletScreen> createState() => _MainWalletScreenState();
}

class _MainWalletScreenState extends State<MainWalletScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh balance when app becomes active
      _refreshBalance();
    }
  }

  void _refreshBalance() {
    final vm = Provider.of<MainWalletVM>(context, listen: false);
    // Only refresh if not already refreshing
    if (!vm.isRefreshing) {
      vm.forceRefreshBalance();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final walletService = Provider.of<WalletService>(context);

    // Get wallet address from arguments if provided, otherwise use cached address
    final walletAddress = ModalRoute.of(context)?.settings.arguments as String? ?? walletService.walletAddress;
    
    print('🚨🚨🚨 MainWalletScreen BUILD CALLED 🚨🚨🚨');
    print('🔍 MainWalletScreen - WalletService walletAddress: ${walletService.walletAddress}');
    print('🔍 MainWalletScreen - Final walletAddress: $walletAddress');
    print('🔍 MainWalletScreen - WalletService hasWallet: ${walletService.hasWallet}');
    print('🚨🚨🚨 MainWalletScreen BUILD END 🚨🚨🚨');
    
    return ChangeNotifierProvider(
      create: (context) {
        final vm = MainWalletVM.instance;
        if (walletAddress != null) {
          // Set the wallet address directly from cache
          print('🔍 MainWalletScreen - Setting wallet address: $walletAddress');
          vm.setWalletAddress(walletAddress);
        } else {
          print('❌ MainWalletScreen - No wallet address available!');
        }
        return vm;
      },
      child: Consumer<MainWalletVM>(
        builder: (context, vm, child) {
          // Note: Balance refresh is handled by periodic timer and lifecycle events
          
          return Scaffold(
            backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SearchBarWidget(),
                      SB.h(2.h),
                      Consumer<MainWalletVM>(
                        builder: (context, vm, child) {
                          return WalletBalanceWidget(
                            title: "Main wallet",
                            balance: vm.isLoadingBalance 
                              ? "Loading..." 
                              : vm.totalBalance,
                          );
                        },
                      ),
                      SB.h(0.1.h),
                      WalletAddressWidget(
                        walletAddress: vm.walletAddress,
                        isLoading: vm.isLoadingWallet,
                      ),
                      SB.h(1.5.h),
                      const ActionButtonsRow(),
                      SB.h(1.5.h),
                      const TopDappSection(),
                      SB.h(0.1.h),
                      
                      // Crypto/NFT Tab section with fixed height
                      SizedBox(
                        height: 25.h,
                        child: const CryptoNFTTabSection(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}


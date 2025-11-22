import 'package:dex/util/size_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../../helper/sb_helper.dart';
import '../../../../util/color_resources.dart';
import '../../../../theme/theme_manager.dart';
import '../../../../widgets/coming_soon_dialog.dart';
import '../../../bottomNav/bottom_nav_vm.dart';
import 'wallet_home_vm.dart';

class WalletHomeScreen extends StatefulWidget {
  const WalletHomeScreen({super.key});

  @override
  State<WalletHomeScreen> createState() => _WalletHomeScreenState();
}

class _WalletHomeScreenState extends State<WalletHomeScreen> {
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Remove initialization from initState - will be handled in Consumer
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => BottomNavVM()),
        ChangeNotifierProvider(create: (_) => WalletHomeVM()),
      ],
      child: Consumer<WalletHomeVM>(
        builder: (context, vm, child) {
          // Initialize wallet home VM when Consumer builds (once only)
          if (!_hasInitialized && !vm.hasInitialized) {
            _hasInitialized = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !vm.hasInitialized) {
                try {
                  vm.initialize(context);
                } catch (e) {
                  print('❌ Error initializing wallet home VM: $e');
                  _hasInitialized = false;
                }
              }
            });
          }
          
          return Scaffold(
            backgroundColor: AppColors.black,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
            /// 🔹 Top Section (Coins + Heading together)
            SizedBox(
              height: 45.h,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  /// Ethereum (center)
                  Positioned(
                    top: 13.h,
                    right: 23.w,
                    child: _buildGlowingCircleIcon(
                      "assets/svgs/wallet_home/hero_section/ether.png",
                      radius: 17.w,
                      glowColor: AppColors.glow,
                    ),
                  ),

                  /// Binance (top-left)
                  Positioned(
                    top: 3.h,
                    left: 29.w,
                    child: _buildGlowingCircleIcon(
                      "assets/svgs/wallet_home/hero_section/binance.png",
                      radius: 8.5.w,
                      glowColor: AppColors.glow,
                    ),
                  ),

                  /// Solana (top-right)
                  Positioned(
                    top: 3.h,
                    right: 30.w,
                    child: _buildGlowingCircleIcon(
                      "assets/svgs/wallet_home/hero_section/solana.png",
                      radius: 7.5.w,
                      glowColor: AppColors.glow,
                    ),
                  ),

                  /// Polygon (left-center)
                  Positioned(
                    top: 14.h,
                    left: 17.w,
                    child: _buildGlowingCircleIcon(
                      "assets/svgs/wallet_home/hero_section/polygon.png",
                      radius: 10.5.w,
                        glowColor: AppColors.glow,                    ),
                  ),

                  /// Heading (just below Ethereum)
                  Positioned(
                    top: 32.h,
                    child: Text(
                      "Master Your Crypto With\nEase And Security",
                      style: TextStyle(
                        fontFamily: "Rubik",
                        fontSize: 5.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),


            /// 🔹 Wallet Cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                children: [
                  // Show different cards based on whether user has existing wallets
                  if (vm.hasExistingWallets) ...[
                    // User has existing wallets - prioritize viewing them
                    _buildWalletCard(
                      icon: Icons.list,
                      title: "View my wallets",
                      subtitle: "Access your existing wallets",
                      onTap: () => vm.showWalletList(context),
                    ),
                    SB.h(2.h),
                    _buildWalletCard(
                      icon: Icons.add,
                      title: "Create a new wallet",
                      subtitle: "Generate an additional crypto wallet",
                      onTap: () => vm.generateWallet(context),
                      isLoading: vm.isGeneratingWallet,
                    ),
                    SB.h(2.h),
                    _buildWalletCard(
                      icon: Icons.download,
                      title: "Add existing wallet",
                      subtitle: "Import, restore or view only",
                      onTap: () => ComingSoonDialog.show(
                        context,
                        title: "Add Existing Wallet",
                        description: "Import your existing wallet using seed phrase, private key, or view-only mode.",
                        iconPath: "assets/svgs/setting/import.svg",
                      ),
                    ),
                  ] else ...[
                    // User has no existing wallets - prioritize creating one
                    _buildWalletCard(
                      icon: Icons.add,
                      title: "Create a new wallet",
                      subtitle: "Generate your first crypto wallet",
                      onTap: () => vm.generateWallet(context),
                      isLoading: vm.isGeneratingWallet,
                    ),
                    SB.h(2.h),
                    _buildWalletCard(
                      icon: Icons.download,
                      title: "Add existing wallet",
                      subtitle: "Import, restore or view only",
                      onTap: () => ComingSoonDialog.show(
                        context,
                        title: "Add Existing Wallet",
                        description: "Import your existing wallet using seed phrase, private key, or view-only mode.",
                        iconPath: "assets/svgs/setting/import.svg",
                      ),
                    ),
                    SB.h(2.h),
                    _buildWalletCard(
                      icon: Icons.list,
                      title: "View my wallets",
                      subtitle: "See all your created wallets",
                      onTap: () => vm.showWalletList(context),
                    ),
                  ],
                ],
              ),
            ),

            SB.h(2.h),

            /// 🔹 Debug Section (Temporary)

            /// 🔹 Market Stats Heading (FIXED)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Market Statistics",
                  style: TextStyle(
                    fontFamily: "Rubik",
                    fontWeight: FontWeight.w900,
                    fontSize: 4.5.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SB.h(1.h),

            /// 🔹 Coin List
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                children: [
                  _buildCoinTile(
                    icon: "assets/svgs/wallet_home/bitcoin.svg",
                    name: "Bitcoin",
                    symbol: "BTC",
                    price: "USDC 99,284.01",
                    change: "+68.3%",
                    isPositive: true,
                  ),
                  _buildCoinTile(
                    icon: "assets/svgs/wallet_home/ethereum.svg",
                    name: "Ethereum",
                    symbol: "ETH",
                    price: "USDC 24,933.56",
                    change: "+32.1%",
                    isPositive: true,
                  ),
                  _buildCoinTile(
                    icon: "assets/svgs/wallet_home/solana.svg",
                    name: "Solana",
                    symbol: "SOL",
                    price: "USDC 10,015.90",
                    change: "-9.0%",
                    isPositive: false,
                  ),
                  SB.h(10.h),
                ],
              ),
            ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 🔹 Glowing circle widget
  Widget _buildGlowingCircleIcon(String asset,
      {double radius = 7, Color glowColor = Colors.white}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.black.withOpacity(0.8),
        child: Image.asset(asset, height: radius * 1.6),
      ),
    );
  }

  /// 🔹 Wallet action card
  Widget _buildWalletCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 5.w,
              backgroundColor: Colors.white,
              child: isLoading 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : Icon(icon, color: AppColors.primary, size: 20),
            ),
            SB.w(4.w),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: "Rubik",
                      fontWeight: FontWeight.bold,
                      fontSize: 4.sp,
                      color: Colors.white,
                    ),
                  ),
                  SB.h(0.5.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: "Rubik",
                      fontSize: 3.sp,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// 🔹 Coin tile
  Widget _buildCoinTile({
    required String icon,
    required String name,
    required String symbol,
    required String price,
    required String change,
    required bool isPositive,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          SvgPicture.asset(icon, height: 9.w, width: 9.w),
          SB.w(4.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontFamily: "Rubik",
                  fontWeight: FontWeight.bold,
                  fontSize: 3.5.sp,
                  color: Colors.white,
                ),
              ),
              Text(
                symbol,
                style: TextStyle(
                  fontFamily: "Rubik",
                  fontSize: 3.sp,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontFamily: "Rubik",
                  fontWeight: FontWeight.bold,
                  fontSize: 3.5.sp,
                  color: Colors.white,
                ),
              ),
              Text(
                change,
                style: TextStyle(
                  fontFamily: "Rubik",
                  fontSize: 3.sp,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}

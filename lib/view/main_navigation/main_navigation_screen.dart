import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_manager.dart';
import '../bottomNav/bottom_nav.dart';
import '../bottomNav/bottom_nav_vm.dart';
import '../tabs/main_wallet/main_wallet_screen.dart';
import '../tabs/market/market_screen.dart';
import '../tabs/explore/explore_screen.dart';
import '../tabs/swap/swap_screen.dart';
import '../tabs/settings/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int? initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialIndex ?? 0;
    _pageController = PageController(initialPage: initialIndex);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
    
    // Set the initial index in the BottomNavVM
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<BottomNavVM>(context, listen: false);
      vm.setIndex(initialIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    final vm = Provider.of<BottomNavVM>(context, listen: false);
    if (vm.currentIndex != index) {
      vm.setIndex(index);
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<BottomNavVM>(context);
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: PageView(
          controller: _pageController,
          physics: const ClampingScrollPhysics(),
          onPageChanged: (index) {
            vm.setIndex(index);
          },
          children: const [
            MainWalletScreen(),
            MarketScreen(),
            ExploreScreen(),
            SwapScreen(),
            SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        onTap: _onTabTapped,
      ),
    );
  }
}

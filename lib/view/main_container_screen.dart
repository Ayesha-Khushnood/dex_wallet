import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../view/bottomNav/bottom_nav.dart';
import '../view/bottomNav/bottom_nav_vm.dart';

// Import all tab screens
import 'tabs/main_wallet/main_wallet_screen.dart';
import 'tabs/market/market_screen.dart';
import 'tabs/explore/explore_screen.dart';
import 'tabs/swap/swap_screen.dart';
import 'tabs/settings/settings_screen.dart';

class MainContainerScreen extends StatefulWidget {
  const MainContainerScreen({super.key});

  @override
  State<MainContainerScreen> createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> {
  late PageController _pageController;

  // Lazy loading screens for better performance
  List<Widget> get _screens => [
    const MainWalletScreen(),
    const MarketScreen(),
    const ExploreScreen(),
    const SwapScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Set initial tab index and navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      // Get initial tab index from route arguments
      final initialIndex = ModalRoute.of(context)?.settings.arguments as int? ?? 0;
      
      // Set the initial tab in bottom nav
      final bottomNavVM = Provider.of<BottomNavVM>(context, listen: false);
      bottomNavVM.setIndex(initialIndex);
      
      // Navigate to initial page if needed
      if (_pageController.hasClients && _pageController.page != initialIndex) {
        _pageController.animateToPage(
          initialIndex,
          duration: const Duration(milliseconds: 200), // Faster animation
          curve: Curves.easeOutQuart, // Smoother curve
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    final bottomNavVM = Provider.of<BottomNavVM>(context, listen: false);
    bottomNavVM.setIndex(index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 150), // Much faster tab switching
      curve: Curves.easeOutQuart, // Smoother curve
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final bottomNavVM = Provider.of<BottomNavVM>(context);

    return Scaffold(
      backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
      body: PageView(
        controller: _pageController,
        physics: const ClampingScrollPhysics(), // Better performance
        onPageChanged: (index) {
          bottomNavVM.setIndex(index);
        },
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNav(
        onTap: _onTabTapped,
      ),
    );
  }
}

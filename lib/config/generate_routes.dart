import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import your screens here
import '../view/tabs/main_wallet/wallet_home/wallet_home_screen.dart';
import '../view/tabs/main_wallet/main_wallet_screen.dart';
import '../view/start/onboarding/onboarding_screen.dart';
import '../view/start/splash/splash_screen.dart';
import '../view/start/splash2/splash2_screen.dart';
import '../view/start/login/login_screen.dart';
import '../view/start/signup/signup_screen.dart';
import '../view/start/email_verification/email_verification_screen.dart';
import '../view/start/forgot_password/forgot_password_screen.dart';
import '../view/start/reset_password/reset_password_screen.dart';
import '../view/start/create_pin/create_pin_screen.dart';
import '../view/start/pin_verification/pin_verification_screen.dart';
import '../view/start/initial/initial_screen.dart';
import '../view/tabs/market/market_screen.dart';
import '../view/tabs/explore/explore_screen.dart';
import '../view/tabs/swap/swap_screen.dart';
import '../view/tabs/settings/settings_screen.dart';
import '../view/main_container_screen.dart';
import '../view/tabs/main_wallet/feature/receive/receive_screen.dart';
import '../view/tabs/main_wallet/feature/notifications/notifications_screen.dart';
import '../view/common/browser/browser_screen.dart';
import '../view/tabs/main_wallet/feature/send/send_screen.dart';
import '../view/tabs/main_wallet/feature/send/send_vm.dart';
import '../view/tabs/main_wallet/feature/receive_crypto/receive_crypto_screen.dart';
import '../view/tabs/main_wallet/feature/receive_crypto/receive_crypto_vm.dart';
import '../view/tabs/main_wallet/feature/history/history_vm.dart';
import '../view/tabs/main_wallet/bitcoin_market/bitcoin_market_vm.dart';
import '../view/tabs/main_wallet/feature/send/widgets/review_vm.dart';
import '../view/tabs/main_wallet/feature/send/widgets/success_vm.dart';
import '../view/tabs/main_wallet/feature/buy_eth/buy_eth_screen.dart';
import '../view/tabs/main_wallet/feature/buy_eth/widgets/pay_with_screen.dart';
import '../view/tabs/main_wallet/feature/buy_eth/widgets/pay_with_vm.dart';
import '../view/tabs/main_wallet/feature/history/history_screen.dart';
import '../view/tabs/main_wallet/feature/send/widgets/review_screen.dart';
import '../view/tabs/main_wallet/feature/send/widgets/success_screen.dart';
import '../view/tabs/main_wallet/bitcoin_market/bitcoin_market_screen.dart';
import '../view/tabs/main_wallet/feature/network/network_screen.dart';
import '../view/tabs/main_wallet/chain_market/chain_market_screen.dart';
import '../view/tabs/main_wallet/chain_market/chain_market_vm.dart';
import '../view/tabs/settings/user_profile/user_profile_screen.dart';
import '../services/user_profile_service.dart';
import '../services/web3_provider_service.dart';
import '../view/tabs/settings/change_password/change_password_screen.dart';
import '../view/main_navigation/main_navigation_screen.dart';
import '../services/wallet_service.dart';
import 'page_transitions.dart';

// Import ViewModels for on-demand creation
import '../view/start/onboarding/onboarding_vm.dart';
import '../view/start/splash/splash_vm.dart';
import '../view/start/splash2/splash2_vm.dart';
import '../view/start/login/login_vm.dart';
import '../view/start/signup/signup_vm.dart';
import '../view/start/email_verification/email_verification_vm.dart';
import '../view/start/forgot_password/forgot_password_vm.dart';
import '../view/start/reset_password/reset_password_vm.dart';
import '../view/start/create_pin/create_pin_vm.dart';
import '../view/start/pin_verification/pin_verification_vm.dart';
import '../view/tabs/main_wallet/feature/receive_bitcoin/receive_bitcoin_vm.dart';
import '../view/tabs/main_wallet/feature/receive/receive_vm.dart';
import '../view/tabs/main_wallet/feature/notifications/notifications_vm.dart';
import '../theme/theme_manager.dart';
import '../view/bottomNav/bottom_nav_vm.dart';
import '../view/tabs/market/market_vm.dart';
import '../view/tabs/explore/explore_vm.dart';
import '../view/tabs/swap/swap_vm.dart';
import '../view/tabs/settings/settings_vm.dart';
import '../view/tabs/main_wallet/main_wallet_vm.dart';

// Helper function to wrap screens with their providers
Widget _wrapWithProvider<T extends ChangeNotifier>(Widget screen, T Function() createVM) {
  return ChangeNotifierProvider<T>(
    create: (_) => createVM(),
    child: screen,
  );
}

// Helper function to wrap screens with all necessary providers
Widget _wrapWithAllProviders(Widget screen) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeManager()),
      ChangeNotifierProvider(create: (_) => BottomNavVM()),
      ChangeNotifierProvider.value(value: WalletService()), // Use singleton instance
      ChangeNotifierProvider.value(value: MainWalletVM.instance), // Use singleton instance
      ChangeNotifierProvider.value(value: Web3ProviderServiceSimple()),// Use singleton instance
      ChangeNotifierProvider(create: (_) => MarketVM()),
      ChangeNotifierProvider(create: (_) => ExploreVM()),
      ChangeNotifierProvider(create: (_) => SwapVm()),
      ChangeNotifierProvider(create: (_) => SettingsVM()),
      ChangeNotifierProvider(create: (_) => SendVM()),
      ChangeNotifierProvider(create: (_) => ReceiveCryptoVM()),
      ChangeNotifierProvider(create: (_) => ReceiveBitcoinVM()),
      ChangeNotifierProvider(create: (_) => ReceiveVM()),
      ChangeNotifierProvider(create: (_) => NotificationsVM()),
      ChangeNotifierProvider.value(value: HistoryVM.instance),
      ChangeNotifierProvider(create: (_) => BitcoinMarketVM()),
      ChangeNotifierProvider(create: (_) => SuccessVM()),
      ChangeNotifierProvider(create: (_) => PayWithVM()),
      ChangeNotifierProvider.value(value: UserProfileService.instance),
    ],
    child: screen,
  );
}

// import '../ui/screens/home/home_screen.dart';
// import '../ui/screens/wallet/wallet_home_screen.dart';
// etc...

class GenerateRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return PageTransitions.fadeTransition(_wrapWithAllProviders(const InitialScreen()));
      case '/onboarding':
        return PageTransitions.fadeTransition(
            _wrapWithAllProviders(_wrapWithProvider(const OnboardingScreen(), () => OnboardingVM()))
        );
      case "/splash":
        return PageTransitions.fadeTransition(
            _wrapWithAllProviders(_wrapWithProvider(const SplashScreen(), () => SplashVM()))
        );
      case "/splash2":
        return PageTransitions.slideFromRight(
            _wrapWithAllProviders(_wrapWithProvider(const Splash2Screen(), () => Splash2VM()))
        );
      case "/create_pin":
        return PageTransitions.slideFromRight(
            _wrapWithAllProviders(_wrapWithProvider(const CreatePinScreen(), () => CreatePinVM()))
        );
      case "/login":
        return PageTransitions.slideFromRight(
            _wrapWithAllProviders(_wrapWithProvider(const LoginScreen(), () => LoginVM()))
        );
      case "/signup":
        return PageTransitions.slideFromRight(
            _wrapWithAllProviders(_wrapWithProvider(const SignupScreen(), () => SignupVM()))
        );
      case "/email_verification":
        final email = settings.arguments as String? ?? '';
        return PageTransitions.slideFromRight(
            _wrapWithAllProviders(_wrapWithProvider(EmailVerificationScreen(email: email), () => EmailVerificationVM(email: email)))
        );
      case "/forgot_password":
        return PageTransitions.slideFromRight(
            _wrapWithAllProviders(_wrapWithProvider(const ForgotPasswordScreen(), () => ForgotPasswordVM()))
        );
      case "/reset_password":
        final email = settings.arguments as String? ?? '';
        return PageTransitions.slideFromRight(
            _wrapWithAllProviders(_wrapWithProvider(ResetPasswordScreen(email: email), () => ResetPasswordVM(email: email)))
        );
      case "/pin_verification":
        return PageTransitions.slideFromRight(
            _wrapWithAllProviders(_wrapWithProvider(const PinVerificationScreen(), () => PinVerificationVM()))
        );
      case '/mainNavigation':
        return PageTransitions.fadeTransition(_wrapWithAllProviders(const MainNavigationScreen()));
      case '/mainNavigation/swap':
        return PageTransitions.fadeTransition(_wrapWithAllProviders(const MainNavigationScreen(initialIndex: 3)));
      case '/mainNavigation/settings':
        return PageTransitions.fadeTransition(_wrapWithAllProviders(const MainNavigationScreen(initialIndex: 4)));
      case '/walletHome':
        return PageTransitions.fadeTransition(_wrapWithAllProviders(const WalletHomeScreen()));
      case '/mainContainer':
        return PageTransitions.fadeTransition(_wrapWithAllProviders(const MainContainerScreen()));
      case '/mainWallet':
        return PageTransitions.bottomNavTransition(_wrapWithAllProviders(const MainWalletScreen()));
      case '/market':
        return PageTransitions.bottomNavTransition(_wrapWithAllProviders(const MarketScreen()));
      case '/explore':
        return PageTransitions.bottomNavTransition(_wrapWithAllProviders(const ExploreScreen()));
      case '/swap':
        return PageTransitions.bottomNavTransition(_wrapWithAllProviders(const SwapScreen()));
      case '/settings':
        return PageTransitions.bottomNavTransition(_wrapWithAllProviders(const SettingsScreen()));
      case '/receive':
        return PageTransitions.slideFromBottom(
            _wrapWithAllProviders(const ReceiveScreen())
        );
      case '/notifications':
        return PageTransitions.slideFromRight(
            _wrapWithAllProviders(const NotificationsScreen())
        );
      case '/send':
        return PageTransitions.slideFromBottom(
            _wrapWithAllProviders(const SendScreen())
        );
      case '/receive_crypto':
        return PageTransitions.slideFromBottom(
            _wrapWithAllProviders(const ReceiveCryptoScreen())
        );
      case '/buy_eth':
        return PageTransitions.slideFromRight(
            _wrapWithAllProviders(const BuyEthScreen())
        );
      case '/pay_with':
        return PageTransitions.slideFromRight(
            _wrapWithAllProviders(const PayWithScreen())
        );
      case '/history':
        return PageTransitions.slideFromRight(
            _wrapWithAllProviders(const HistoryScreen())
        );
      case '/browser':
        return PageTransitions.slideFromRight(
          _wrapWithAllProviders(const BrowserScreen()),
          settings: settings,
        );
      case '/review':
        return PageTransitions.slideFromRight(
          ChangeNotifierProvider(
              create: (_) => ReviewVM(),
              child: _wrapWithAllProviders(const ReviewScreen())
          ),
          settings: settings,
        );
      case '/success':
        return PageTransitions.scaleTransition(
          ChangeNotifierProvider(
            create: (_) => SuccessVM(),
            child: _wrapWithAllProviders(const SuccessScreen()),
          ),
          settings: settings,
        );
      case '/bitcoin_market':
        return PageTransitions.slideFromRight(
            _wrapWithAllProviders(const BitcoinMarketScreen())
        );
      case '/network':
        return PageTransitions.slideFromRight(
            _wrapWithAllProviders(const NetworkScreen())
        );
      case '/user_profile':
        return PageTransitions.slideFromRight(
            _wrapWithAllProviders(const UserProfileScreen())
        );
      case '/change_password':
        return PageTransitions.slideFromRight(
            _wrapWithAllProviders(const ChangePasswordScreen())
        );
      case '/chain_market':
        final chain = settings.arguments as dynamic;
        return PageTransitions.slideFromRight(
            ChangeNotifierProvider(
                create: (_) => ChainMarketVM(),
                child: _wrapWithAllProviders(ChainMarketScreen(chain: chain))
            )
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                'No route defined',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        );
    }
  }
}

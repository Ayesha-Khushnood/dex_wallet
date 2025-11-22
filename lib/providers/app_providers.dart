import 'package:provider/provider.dart';

// Import all ViewModels
import '../view/bottomNav/bottom_nav_vm.dart';
import '../view/tabs/market/market_vm.dart';
import '../view/tabs/explore/explore_vm.dart';
import '../view/tabs/swap/swap_vm.dart';
import '../view/tabs/settings/settings_vm.dart';
import '../view/tabs/main_wallet/main_wallet_vm.dart';
import '../view/start/onboarding/onboarding_vm.dart';
import '../view/start/splash/splash_vm.dart';
import '../view/start/splash2/splash2_vm.dart';
import '../view/start/create_pin/create_pin_vm.dart';
import '../view/start/pin_verification/pin_verification_vm.dart';
import '../view/tabs/main_wallet/wallet_home/wallet_home_vm.dart';
import '../view/tabs/main_wallet/feature/receive_bitcoin/receive_bitcoin_vm.dart';
import '../view/tabs/main_wallet/feature/notifications/notifications_vm.dart';
import '../view/tabs/main_wallet/feature/send/send_vm.dart';
import '../view/tabs/main_wallet/feature/receive_crypto/receive_crypto_vm.dart';
import '../view/tabs/main_wallet/feature/buy_eth/buy_eth_vm.dart';
import '../view/tabs/main_wallet/feature/history/history_vm.dart';
import '../view/tabs/main_wallet/feature/send/widgets/review_vm.dart';
import '../view/tabs/main_wallet/feature/send/widgets/success_vm.dart';
import '../view/tabs/main_wallet/bitcoin_market/bitcoin_market_vm.dart';
import '../theme/theme_manager.dart';
import '../services/wallet_service.dart';
import '../services/user_profile_service.dart';
import '../services/web3_provider_service.dart';

class AppProviders {
  static List<ChangeNotifierProvider> get providers => [
    // Essential providers at startup
    ChangeNotifierProvider(create: (_) => ThemeManager()),
    ChangeNotifierProvider(create: (_) => BottomNavVM()),

    // Core services
    ChangeNotifierProvider(create: (_) => WalletService()),
    ChangeNotifierProvider.value(value: UserProfileService.instance),
    ChangeNotifierProvider.value(value: Web3ProviderServiceSimple()),

    // Core tab providers - needed for bottom navigation
    ChangeNotifierProvider(create: (_) => MarketVM()),
    ChangeNotifierProvider(create: (_) => ExploreVM()),
    ChangeNotifierProvider(create: (_) => SwapVm()),
    ChangeNotifierProvider(create: (_) => SettingsVM()),
    ChangeNotifierProvider.value(value: MainWalletVM.instance),
  ];

  static List<ChangeNotifierProvider> get onDemandProviders => [
    // On-demand providers for specific screens
    ChangeNotifierProvider(create: (_) => OnboardingVM()),
    ChangeNotifierProvider(create: (_) => SplashVM()),
    ChangeNotifierProvider(create: (_) => Splash2VM()),
    ChangeNotifierProvider(create: (_) => CreatePinVM()),
    ChangeNotifierProvider(create: (_) => PinVerificationVM()),
    ChangeNotifierProvider(create: (_) => WalletHomeVM()),
    ChangeNotifierProvider(create: (_) => ReceiveBitcoinVM()),
    ChangeNotifierProvider(create: (_) => NotificationsVM()),
    ChangeNotifierProvider(create: (_) => SendVM()),
    ChangeNotifierProvider(create: (_) => ReceiveCryptoVM()),
    ChangeNotifierProvider(create: (_) => BuyEthVM()),
    ChangeNotifierProvider.value(value: HistoryVM.instance),
    ChangeNotifierProvider(create: (_) => ReviewVM()),
    ChangeNotifierProvider(create: (_) => SuccessVM()),
    ChangeNotifierProvider(create: (_) => BitcoinMarketVM()),
  ];
}

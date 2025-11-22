import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/generate_routes.dart';
import 'providers/app_providers.dart';
import 'theme/dark_theme.dart';
import 'util/size_extension.dart';
import 'services/auth_service.dart';
import 'services/wallet_service.dart';
import 'services/user_profile_service.dart';
import 'services/web3_provider_service.dart';
import 'config/env_config.dart';

void main() async {
  print('🚀 Main - Starting app initialization...');
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Environment variables loaded successfully');
  } catch (e) {
    print('⚠️ Warning: Could not load .env file: $e');
    print('⚠️ Using default values. Make sure .env file exists in the root directory.');
  }

  // Initialize authentication token
  print('🔐 Main - Initializing auth service...');
  final authService = AuthService();
  await authService.initializeAuthToken();

  print('🔍 Main - Checking authentication status...');
  final isAuthenticated = await authService.isAuthenticated();
  print('🔍 Main - Authentication status: $isAuthenticated');

  // Initialize services if user is authenticated
  if (isAuthenticated) {
    print('🔍 Main - User is authenticated, initializing services...');

    // Initialize wallet service
    print('💰 Main - Initializing wallet service...');
    final walletService = WalletService();
    await walletService.initializeWalletData();

    print('🔗 Main - Initializing Web3ProviderService with WalletKit...');
    // Initialize Web3ProviderService with WalletKit
    final web3Service = Web3ProviderServiceSimple();
    await web3Service.initializeWalletKit(
      projectId: EnvConfig.walletKitProjectId,
      metadataName: 'DEX Wallet',
      metadataDescription: 'Your Gateway to Web3',
      metadataUrl: 'https://dex-wallet.com',
    );

    print('🔗 Main - Making wallet discoverable...');
    // Make the wallet discoverable by dApps
    await web3Service.makeWalletDiscoverable();

    print('🔗 Main - Registering wallet for discovery...');
    // Register wallet with ReownWalletKit discovery system
    await web3Service.registerWalletForDiscovery();

    print('✅ Main - Web3ProviderService initialized successfully');

    // Pre-load user profile for better UX
    print('👤 Main - Loading user profile...');
    final profileService = UserProfileService.instance;
    await profileService.loadUserProfile();
    print('✅ Main - User profile pre-loaded');
  } else {
    print('❌ Main - User is not authenticated, skipping Web3ProviderService initialization');
  }

  print('🎯 Main - Starting app...');
  print('🎯 Main - Initial route will be: /');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: DarkTheme.themeData, // Use static theme initially
        initialRoute: "/", // Start with splash
        onGenerateRoute: GenerateRoutes.generateRoute,

        /// ✅ Initialize SizeConfig for responsive design
        builder: (context, child) {
          SizeConfig.init(context);
          return child!;
        },
      ),
    );
  }
}




import '../config/env_config.dart';

class ApiEndPoints {
  static String get baseUrl => EnvConfig.apiBaseUrl;
  
  // Test endpoint (for when ngrok is offline)
  static const String testEndpoint = 'https://jsonplaceholder.typicode.com/posts/1';

  // Authentication APIs
  static const String register = 'auth/register';
  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  
  // Email Verification APIs
  static const String sendEmailVerificationOTP = 'auth/send-verification-otp';
  static const String verifyEmail = 'auth/verify-email';
  
  // Password Reset APIs
  static const String forgotPassword = 'auth/forgot-password';
  static const String resetPassword = 'auth/reset-password';
  
  // User Profile APIs
  static const String getUserProfile = 'auth/profile';
  static const String updateUserProfile = 'auth/profile';
  static const String changePassword = 'auth/change-password';
  
  // Wallet PIN APIs
  static const String setupWalletPin = 'auth/setup-wallet-pin';
  static const String changeWalletPin = 'auth/change-wallet-pin';

  // Wallet APIs
  static const String generate = 'wallet/generate';
  static const String walletList = 'wallet/list';
  static String retrieveWallet(String address) => 'wallet/retrieve/$address';
  static String walletTransactions(String address) => 'wallet/transactions/$address';

  // Payments
  static const String createPaymentIntent = 'stripe/create-payment-intent';
  static String walletBalance({required String walletAddress}) =>
      'token/zktc-balance/$walletAddress';
  static String getActivity({
    required String page,
    required String limit,
    required String status,
  }) =>
      'payments/dashboard/recent-activity?page=$page&limit=$limit&status=$status';

  static String connectExternalWallet = "wallets/connect-external";
  static String processTokenToWallet = "payments/contract/process-tokens";
  static String disconnectExternalWallet({required String walletAddress}) => "wallets/$walletAddress";
  static String getSystemWalletAddress = "wallets/system-wallet";
  static String getTokenRate = "token-rates/all-rates";
  static String getSupportedTokens = 'token-rates/supported-tokens';
  static String getSingleTokenRate({required String symbol})=> 'token-rates/rate/$Symbol';
  static const String getContractTokenPrice = 'payments/contract/token-price';
  static const String getRemainingDCOSupply = 'payments/contract/remaining-supply';
}

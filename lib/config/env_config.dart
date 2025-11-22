import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration helper
/// Provides access to environment variables loaded from .env file
class EnvConfig {
  EnvConfig._();

  /// Reown WalletKit Project ID
  static String get walletKitProjectId {
    return dotenv.env['WALLETKIT_PROJECT_ID'] ?? 
           'REPLACE_WITH_YOUR_WALLETKIT_PROJECT_ID';
  }

  /// Infura Project ID
  static String get infuraProjectId {
    return dotenv.env['INFURA_PROJECT_ID'] ?? 
           'REPLACE_WITH_YOUR_INFURA_PROJECT_ID';
  }

  /// Backend API Base URL
  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? 
           'https://dex-backend-swart.vercel.app/api/';
  }

  /// Get Infura RPC URL for a specific network
  static String getInfuraRpcUrl(String network) {
    final projectId = infuraProjectId;
    return 'https://$network.infura.io/v3/$projectId';
  }
}


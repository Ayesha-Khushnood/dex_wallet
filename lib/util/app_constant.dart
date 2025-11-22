
/// ✅ String Extensions for Asset Paths
extension AssetPath on String {
  String get toPngPath => "assets/images/$this.png";
  String get toJpgPath => "assets/images/$this.jpg";
  String get toSvgPath => "assets/svgs/$this.svg";
  String get toGifPath => "assets/gifs/$this.gif";
}

/// ✅ Centralized Asset Constants
class AppAssets {
  // PNGs
  static const String wave = "assets/images/wave.png";

  // SVGs
  static const String logo = "assets/svgs/logo.svg";

  // Example: Add more as needed
  static const String background = "assets/images/background.png";
}

class AppConstants {
  static const String networkServerError = 'No internet connection or either server is down.';
}

// class AppConstants {
//   AppConstants._();
//   static String networkServerError =
//       'No internet connection or either server is down.';
//
//   static String walletAddress = '';
//   static String systemWalletAddress = '';
//
//   static String getTokenImage(String token) {
//     switch (token) {
//       case 'USDT':
//         return 'usdt'.toSvgPath;
//       case 'USDC':
//         return 'usdc'.toPngPath;
//       case 'ETH':
//         return 'ethereum'.toPngPath;
//       case 'SOL':
//         return 'solana'.toPngPath;
//       case 'BTC':
//         return 'bitcoin'.toPngPath;
//       default:
//         return 'zktc'.toSvgPath;
//     }
//   }
//
//   static WalletNetworkType networkType = WalletNetworkType.testnet;
//
//   static String getEthScanUrl(String hash) {
//     if (networkType == WalletNetworkType.testnet) {
//       return 'https://sepolia.etherscan.io/tx/$hash';
//     } else {
//       return 'https://etherscan.io/tx/$hash';
//     }
//   }
//
//   static String getEthScanUrlForAddress(String address) {
//     if (networkType == WalletNetworkType.testnet) {
//       return 'https://sepolia.etherscan.io/address/$address';
//     } else {
//       return 'https://etherscan.io/address/$address';
//     }
//   }
//
//   static const String vestingDisclaimer = '''
// Before proceeding, please note:
// 1- Your tokens will be locked.
// 2- You will not be able to transfer or sell them until the lock period ends.
// ''';
// }

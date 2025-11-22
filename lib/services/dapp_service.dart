import '../data/model/dapp_model.dart';

class DAppService {
  static final List<DAppModel> _popularDApps = [
     DAppModel(
      id: 'uniswap_testnet',
      name: 'Uniswap (Testnet)',
      description: 'DEX on Sepolia Testnet',
      url: 'https://app.uniswap.org/?chain=sepolia',
      imagePath: 'assets/svgs/main_wallet/top_dApp/uniswap.png',
      category: 'DeFi',
      isPopular: true,
      rating: 4.8,
    ),
    DAppModel(
      id: 'opensea',
      name: 'OpenSea',
      description: 'NFT Marketplace',
      url: 'https://opensea.io',
      imagePath: 'assets/svgs/main_wallet/top_dApp/opensea.png',
      category: 'NFT',
      isPopular: true,
      rating: 4.7,
    ),
    DAppModel(
      id: 'compound',
      name: 'Compound',
      description: 'Lending Protocol',
      url: 'https://app.compound.finance',
      imagePath: 'assets/svgs/main_wallet/top_dApp/compound.png',
      category: 'DeFi',
      isPopular: true,
      rating: 4.6,
    ),
    DAppModel(
      id: 'aave',
      name: 'Aave',
      description: 'Lending & Borrowing',
      url: 'https://app.aave.com',
      imagePath: 'assets/svgs/main_wallet/top_dApp/aave.png',
      category: 'DeFi',
      isPopular: true,
      rating: 4.5,
    ),
    DAppModel(
      id: 'curve',
      name: 'Curve',
      description: 'Stablecoin Exchange',
      url: 'https://curve.fi',
      imagePath: 'assets/svgs/main_wallet/top_dApp/curve.png',
      category: 'DeFi',
      isPopular: true,
      rating: 4.4,
    ),
    DAppModel(
      id: '1inch',
      name: '1inch',
      description: 'DEX Aggregator',
      url: 'https://app.1inch.io',
      imagePath: 'assets/svgs/main_wallet/top_dApp/1inch.png',
      category: 'DeFi',
      isPopular: true,
      rating: 4.3,
    ),
    DAppModel(
      id: 'ens',
      name: 'ENS',
      description: 'Ethereum Name Service',
      url: 'https://app.ens.domains',
      imagePath: 'assets/svgs/main_wallet/top_dApp/ens.png',
      category: 'Utility',
      isPopular: true,
      rating: 4.2,
    ),
    DAppModel(
      id: 'rarible',
      name: 'Rarible',
      description: 'NFT Marketplace',
      url: 'https://rarible.com',
      imagePath: 'assets/svgs/main_wallet/top_dApp/rarible.png',
      category: 'NFT',
      isPopular: true,
      rating: 4.1,
    ),
    DAppModel(
      id: 'uniswap_testnet',
      name: 'Uniswap (Testnet)',
      description: 'DEX on Sepolia Testnet',
      url: 'https://app.uniswap.org/?chain=sepolia',
      imagePath: 'assets/svgs/main_wallet/top_dApp/uniswap.png',
      category: 'DeFi',
      isPopular: true,
      rating: 4.8,
    ),
  ];

  static final List<DAppModel> _gamingDApps = [
    DAppModel(
      id: 'axie',
      name: 'Axie Infinity',
      description: 'Play-to-Earn Game',
      url: 'https://axieinfinity.com',
      imagePath: 'assets/svgs/main_wallet/top_dApp/axie.png',
      category: 'Gaming',
      isPopular: true,
      rating: 4.5,
    ),
    DAppModel(
      id: 'ethermon',
      name: 'Ethermon',
      description: 'Monster Battle Game',
      url: 'https://ethermon.io',
      imagePath: 'assets/svgs/main_wallet/top_dApp/ethermon.png',
      category: 'Gaming',
      isPopular: true,
      rating: 4.4,
    ),
    DAppModel(
      id: 'forza',
      name: 'Forza Horizon',
      description: 'Racing Game',
      url: 'https://forza.net',
      imagePath: 'assets/svgs/main_wallet/top_dApp/forza.png',
      category: 'Gaming',
      isPopular: true,
      rating: 4.3,
    ),
  ];

  static final List<DAppModel> _allDApps = [
    ..._popularDApps,
    ..._gamingDApps,
  ];

  /// Get popular dApps
  static List<DAppModel> getPopularDApps() {
    return _popularDApps.take(3).toList();
  }

  /// Get all dApps
  static List<DAppModel> getAllDApps() {
    return _allDApps;
  }

  /// Get dApps by category
  static List<DAppModel> getDAppsByCategory(String category) {
    return _allDApps.where((dapp) => dapp.category == category).toList();
  }

  /// Get gaming dApps
  static List<DAppModel> getGamingDApps() {
    return _gamingDApps;
  }

  /// Get DeFi dApps
  static List<DAppModel> getDeFiDApps() {
    return _allDApps.where((dapp) => dapp.category == 'DeFi').toList();
  }

  /// Get NFT dApps
  static List<DAppModel> getNFTDApps() {
    return _allDApps.where((dapp) => dapp.category == 'NFT').toList();
  }

  /// Search dApps
  static List<DAppModel> searchDApps(String query) {
    if (query.isEmpty) return _allDApps;
    
    return _allDApps.where((dapp) {
      return dapp.name.toLowerCase().contains(query.toLowerCase()) ||
             dapp.description.toLowerCase().contains(query.toLowerCase()) ||
             dapp.category.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Get dApp by ID
  static DAppModel? getDAppById(String id) {
    try {
      return _allDApps.firstWhere((dapp) => dapp.id == id);
    } catch (e) {
      return null;
    }
  }
}

import 'dart:developer';
import 'env_config.dart';

/// Blockchain network types
enum WalletNetworkType {
  mainnet,
  testnet,
}

/// Supported blockchain types
enum ChainType {
  ethereum,
  bsc,
  polygon,
  arbitrum,
  optimism,
}

/// Blockchain configuration for EVM and BSC chains
class BlockchainConfig {
  BlockchainConfig._();

  // Network configuration
  static WalletNetworkType networkType = WalletNetworkType.testnet;
  static ChainType chainType = ChainType.ethereum;

  // Chain IDs
  static const int ethereumMainnetChainId = 1;
  static const int ethereumSepoliaChainId = 11155111;
  static const int bscMainnetChainId = 56;
  static const int bscTestnetChainId = 97;
  static const int polygonMainnetChainId = 137;
  static const int polygonMumbaiChainId = 80001;
  static const int arbitrumMainnetChainId = 42161;
  static const int arbitrumSepoliaChainId = 421614;
  static const int optimismMainnetChainId = 10;
  static const int optimismSepoliaChainId = 11155420;

  // RPC URLs - Infura (using environment variables)
  static String get infuraProjectId => EnvConfig.infuraProjectId;
  
  static String get ethereumMainnetRpc => EnvConfig.getInfuraRpcUrl('mainnet');
  static String get ethereumSepoliaRpc => EnvConfig.getInfuraRpcUrl('sepolia');
  static const String bscMainnetRpc = 'https://bsc-dataseed.binance.org/';
  static const String bscTestnetRpc = 'https://data-seed-prebsc-1-s1.binance.org:8545/';
  static String get polygonMainnetRpc => EnvConfig.getInfuraRpcUrl('polygon-mainnet');
  static String get polygonMumbaiRpc => EnvConfig.getInfuraRpcUrl('polygon-mumbai');
  static String get arbitrumMainnetRpc => EnvConfig.getInfuraRpcUrl('arbitrum-mainnet');
  static String get arbitrumSepoliaRpc => EnvConfig.getInfuraRpcUrl('arbitrum-sepolia');
  static String get optimismMainnetRpc => EnvConfig.getInfuraRpcUrl('optimism-mainnet');
  static String get optimismSepoliaRpc => EnvConfig.getInfuraRpcUrl('optimism-sepolia');

  // Block Explorers
  static const String ethereumMainnetExplorer = 'https://etherscan.io';
  static const String ethereumSepoliaExplorer = 'https://sepolia.etherscan.io';
  static const String bscMainnetExplorer = 'https://bscscan.com';
  static const String bscTestnetExplorer = 'https://testnet.bscscan.com';
  static const String polygonMainnetExplorer = 'https://polygonscan.com';
  static const String polygonMumbaiExplorer = 'https://mumbai.polygonscan.com';
  static const String arbitrumMainnetExplorer = 'https://arbiscan.io';
  static const String arbitrumSepoliaExplorer = 'https://sepolia.arbiscan.io';
  static const String optimismMainnetExplorer = 'https://optimistic.etherscan.io';
  static const String optimismSepoliaExplorer = 'https://sepolia-optimism.etherscan.io';

  // Get current chain ID based on network type and chain type
  static int getCurrentChainId() {
    switch (chainType) {
      case ChainType.ethereum:
        return networkType == WalletNetworkType.testnet 
            ? ethereumSepoliaChainId 
            : ethereumMainnetChainId;
      case ChainType.bsc:
        return networkType == WalletNetworkType.testnet 
            ? bscTestnetChainId 
            : bscMainnetChainId;
      case ChainType.polygon:
        return networkType == WalletNetworkType.testnet 
            ? polygonMumbaiChainId 
            : polygonMainnetChainId;
      case ChainType.arbitrum:
        return networkType == WalletNetworkType.testnet 
            ? arbitrumSepoliaChainId 
            : arbitrumMainnetChainId;
      case ChainType.optimism:
        return networkType == WalletNetworkType.testnet 
            ? optimismSepoliaChainId 
            : optimismMainnetChainId;
    }
  }

  // Get current RPC URL based on network type and chain type
  static String getCurrentRpcUrl() {
    log("Network Type: $networkType, Chain Type: $chainType");
    
    String rpcUrl;
    switch (chainType) {
      case ChainType.ethereum:
        rpcUrl = networkType == WalletNetworkType.testnet 
            ? ethereumSepoliaRpc 
            : ethereumMainnetRpc;
        break;
      case ChainType.bsc:
        rpcUrl = networkType == WalletNetworkType.testnet 
            ? bscTestnetRpc 
            : bscMainnetRpc;
        break;
      case ChainType.polygon:
        rpcUrl = networkType == WalletNetworkType.testnet 
            ? polygonMumbaiRpc 
            : polygonMainnetRpc;
        break;
      case ChainType.arbitrum:
        rpcUrl = networkType == WalletNetworkType.testnet 
            ? arbitrumSepoliaRpc 
            : arbitrumMainnetRpc;
        break;
      case ChainType.optimism:
        rpcUrl = networkType == WalletNetworkType.testnet 
            ? optimismSepoliaRpc 
            : optimismMainnetRpc;
        break;
    }
    
    log("Selected RPC URL: $rpcUrl");
    return rpcUrl;
  }

  // Get current block explorer URL
  static String getCurrentBlockExplorer() {
    switch (chainType) {
      case ChainType.ethereum:
        return networkType == WalletNetworkType.testnet 
            ? ethereumSepoliaExplorer 
            : ethereumMainnetExplorer;
      case ChainType.bsc:
        return networkType == WalletNetworkType.testnet 
            ? bscTestnetExplorer 
            : bscMainnetExplorer;
      case ChainType.polygon:
        return networkType == WalletNetworkType.testnet 
            ? polygonMumbaiExplorer 
            : polygonMainnetExplorer;
      case ChainType.arbitrum:
        return networkType == WalletNetworkType.testnet 
            ? arbitrumSepoliaExplorer 
            : arbitrumMainnetExplorer;
      case ChainType.optimism:
        return networkType == WalletNetworkType.testnet 
            ? optimismSepoliaExplorer 
            : optimismMainnetExplorer;
    }
  }

  // ChainId helpers
  static String getEip155ChainId() {
    return 'eip155:${getCurrentChainId()}';
  }

  // Get native currency symbol
  static String getNativeCurrencySymbol() {
    switch (chainType) {
      case ChainType.ethereum:
      case ChainType.arbitrum:
      case ChainType.optimism:
        return 'ETH';
      case ChainType.bsc:
        return 'BNB';
      case ChainType.polygon:
        return 'MATIC';
    }
  }

  // Get native currency name
  static String getNativeCurrencyName() {
    switch (chainType) {
      case ChainType.ethereum:
        return 'Ethereum';
      case ChainType.bsc:
        return 'Binance Coin';
      case ChainType.polygon:
        return 'Polygon';
      case ChainType.arbitrum:
        return 'Ethereum';
      case ChainType.optimism:
        return 'Ethereum';
    }
  }

  // Contract addresses per network (extend as needed)
  static String getUsdtContractAddress() {
    switch (chainType) {
      case ChainType.ethereum:
        return networkType == WalletNetworkType.testnet
            ? '0x2D3a71430Bf19edf7B6Df82Ed921d02e40c39Fa8'
            : '0xdAC17F958D2ee523a2206206994597C13D831ec7';
      case ChainType.bsc:
        return networkType == WalletNetworkType.testnet
            ? '0x337610d27c682E347C9cD60BD4b3b107C9d34dDd'
            : '0x55d398326f99059fF775485246999027B3197955';
      case ChainType.polygon:
        return networkType == WalletNetworkType.testnet
            ? '0x2c852e740B62308c46DD29B982FBb650D063Bd07'
            : '0xc2132D05D31c914a87C6611C10748AEb04B58e8F';
      case ChainType.arbitrum:
        return networkType == WalletNetworkType.testnet
            ? '0xfd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9'
            : '0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9';
      case ChainType.optimism:
        return networkType == WalletNetworkType.testnet
            ? '0x94b008aA00579c1307B0EF2c499aD98a8ce58e58'
            : '0x94b008aA00579c1307B0EF2c499aD98a8ce58e58';
    }
  }

  static String getUsdcContractAddress() {
    switch (chainType) {
      case ChainType.ethereum:
        return networkType == WalletNetworkType.testnet
            ? '0x07865c6E87B9F70255377e024ace6630C1Eaa37F'
            : '0xA0b86a33E6441b8c4C8C0e4b8b2c4F4F4F4F4F4F';
      case ChainType.bsc:
        return networkType == WalletNetworkType.testnet
            ? '0x64544969ed7EBf5f083679233325356EbE738930'
            : '0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d';
      case ChainType.polygon:
        return networkType == WalletNetworkType.testnet
            ? '0x0FA8781a83E46826621b3BC094Ea2A0212e71B23'
            : '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174';
      case ChainType.arbitrum:
        return networkType == WalletNetworkType.testnet
            ? '0xfd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9'
            : '0xaf88d065e77c8cC2239327C5EDb3A432268e5831';
      case ChainType.optimism:
        return networkType == WalletNetworkType.testnet
            ? '0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85'
            : '0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85';
    }
  }

  // Wallet app schemes and universal links for deep linking
  static const Map<String, Map<String, String>> walletDeepLinks = {
    'MetaMask': {
      'scheme': 'metamask',
      'universal': 'https://metamask.app.link',
    },
    'Coinbase Wallet': {
      'scheme': 'cbwallet',
      'universal': 'https://go.cb-w.com',
    },
    'Trust Wallet': {
      'scheme': 'trust',
      'universal': 'https://link.trustwallet.com',
    },
    'Binance Wallet': {
      'scheme': 'binance',
      'universal': 'https://www.binance.com',
    },
    'Phantom': {
      'scheme': 'phantom',
      'universal': 'https://phantom.app/ul',
    },
    'WalletConnect': {
      'scheme': 'wc',
      'universal': 'https://walletconnect.com/app',
    },
  };

  // Set network type
  static void setNetworkType(WalletNetworkType type) {
    networkType = type;
    log("Network type set to: $networkType");
  }

  // Set chain type
  static void setChainType(ChainType type) {
    chainType = type;
    log("Chain type set to: $chainType");
  }

  // Get current network info
  static Map<String, dynamic> getCurrentNetworkInfo() {
    return {
      'chainId': getCurrentChainId(),
      'chainName': '${getNativeCurrencyName()} ${networkType == WalletNetworkType.testnet ? 'Testnet' : 'Mainnet'}',
      'rpcUrls': [getCurrentRpcUrl()],
      'blockExplorerUrls': [getCurrentBlockExplorer()],
      'nativeCurrency': {
        'name': getNativeCurrencyName(),
        'symbol': getNativeCurrencySymbol(),
        'decimals': 18,
      },
    };
  }

  // Get all supported networks
  static List<Map<String, dynamic>> getAllSupportedNetworks() {
    List<Map<String, dynamic>> networks = [];
    
    for (var chain in ChainType.values) {
      for (var network in WalletNetworkType.values) {
        // Store current values
        final currentChain = chainType;
        final currentNetwork = networkType;
        
        // Set temporary values
        chainType = chain;
        networkType = network;
        
        networks.add({
          'chainType': chain,
          'networkType': network,
          'chainId': getCurrentChainId(),
          'chainName': '${getNativeCurrencyName()} ${network == WalletNetworkType.testnet ? 'Testnet' : 'Mainnet'}',
          'rpcUrl': getCurrentRpcUrl(),
          'blockExplorer': getCurrentBlockExplorer(),
          'nativeCurrency': {
            'name': getNativeCurrencyName(),
            'symbol': getNativeCurrencySymbol(),
            'decimals': 18,
          },
        });
        
        // Restore original values
        chainType = currentChain;
        networkType = currentNetwork;
      }
    }
    
    return networks;
  }

  /// Get RPC URL for specific chain and network
  static String getRpcUrl(ChainType chain, WalletNetworkType network) {
    switch (chain) {
      case ChainType.ethereum:
        return network == WalletNetworkType.mainnet ? ethereumMainnetRpc : ethereumSepoliaRpc;
      case ChainType.bsc:
        return network == WalletNetworkType.mainnet ? bscMainnetRpc : bscTestnetRpc;
      case ChainType.polygon:
        return network == WalletNetworkType.mainnet ? polygonMainnetRpc : polygonMumbaiRpc;
      case ChainType.arbitrum:
        return network == WalletNetworkType.mainnet ? arbitrumMainnetRpc : arbitrumSepoliaRpc;
      case ChainType.optimism:
        return network == WalletNetworkType.mainnet ? optimismMainnetRpc : optimismSepoliaRpc;
    }
  }

  /// Get Chain ID for specific chain and network
  static int getChainId(ChainType chain, WalletNetworkType network) {
    switch (chain) {
      case ChainType.ethereum:
        return network == WalletNetworkType.mainnet ? ethereumMainnetChainId : ethereumSepoliaChainId;
      case ChainType.bsc:
        return network == WalletNetworkType.mainnet ? bscMainnetChainId : bscTestnetChainId;
      case ChainType.polygon:
        return network == WalletNetworkType.mainnet ? polygonMainnetChainId : polygonMumbaiChainId;
      case ChainType.arbitrum:
        return network == WalletNetworkType.mainnet ? arbitrumMainnetChainId : arbitrumSepoliaChainId;
      case ChainType.optimism:
        return network == WalletNetworkType.mainnet ? optimismMainnetChainId : optimismSepoliaChainId;
    }
  }

  /// Get Block Explorer URL for specific chain and network
  static String getBlockExplorer(ChainType chain, WalletNetworkType network) {
    switch (chain) {
      case ChainType.ethereum:
        return network == WalletNetworkType.mainnet ? ethereumMainnetExplorer : ethereumSepoliaExplorer;
      case ChainType.bsc:
        return network == WalletNetworkType.mainnet ? bscMainnetExplorer : bscTestnetExplorer;
      case ChainType.polygon:
        return network == WalletNetworkType.mainnet ? polygonMainnetExplorer : polygonMumbaiExplorer;
      case ChainType.arbitrum:
        return network == WalletNetworkType.mainnet ? arbitrumMainnetExplorer : arbitrumSepoliaExplorer;
      case ChainType.optimism:
        return network == WalletNetworkType.mainnet ? optimismMainnetExplorer : optimismSepoliaExplorer;
    }
  }
}


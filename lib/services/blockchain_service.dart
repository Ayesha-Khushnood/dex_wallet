import 'dart:developer';
import '../config/blockchain_config.dart';

/// Service for managing blockchain operations (EVM & BSC)
class BlockchainService {
  static final BlockchainService _instance = BlockchainService._internal();
  factory BlockchainService() => _instance;
  BlockchainService._internal();

  String? _walletAddress;

  // Getters
  String? get walletAddress => _walletAddress;
  String get currentNetwork => '${BlockchainConfig.getNativeCurrencyName()} ${BlockchainConfig.networkType == WalletNetworkType.testnet ? 'Testnet' : 'Mainnet'}';
  int get currentChainId => BlockchainConfig.getCurrentChainId();
  String get currentRpcUrl => BlockchainConfig.getCurrentRpcUrl();
  String get currentBlockExplorer => BlockchainConfig.getCurrentBlockExplorer();

  /// Set wallet address
  void setWalletAddress(String address) {
    _walletAddress = address;
    log('📍 Wallet address set: ${address.substring(0, 10)}...');
  }

  /// Set network type (mainnet/testnet)
  void setNetworkType(WalletNetworkType networkType) {
    BlockchainConfig.setNetworkType(networkType);
    log('🌐 Network type set to: $networkType');
  }

  /// Set chain type (ethereum, bsc, polygon, etc.)
  void setChainType(ChainType chainType) {
    BlockchainConfig.setChainType(chainType);
    log('🔗 Chain type set to: $chainType');
  }

  /// Get current network information
  Map<String, dynamic> getCurrentNetworkInfo() {
    return BlockchainConfig.getCurrentNetworkInfo();
  }

  /// Get all supported networks
  List<Map<String, dynamic>> getAllSupportedNetworks() {
    return BlockchainConfig.getAllSupportedNetworks();
  }

  /// Get USDT contract address for current network
  String getUsdtContractAddress() {
    return BlockchainConfig.getUsdtContractAddress();
  }

  /// Get USDC contract address for current network
  String getUsdcContractAddress() {
    return BlockchainConfig.getUsdcContractAddress();
  }

  /// Get wallet deep links
  Map<String, Map<String, String>> getWalletDeepLinks() {
    return BlockchainConfig.walletDeepLinks;
  }

  /// Get EIP-155 chain ID
  String getEip155ChainId() {
    return BlockchainConfig.getEip155ChainId();
  }

  /// Get native currency symbol
  String getNativeCurrencySymbol() {
    return BlockchainConfig.getNativeCurrencySymbol();
  }

  /// Get native currency name
  String getNativeCurrencyName() {
    return BlockchainConfig.getNativeCurrencyName();
  }

  /// Clear wallet data
  void clearWalletData() {
    _walletAddress = null;
    log('🗑️ Blockchain service data cleared');
  }

  /// Check if wallet is initialized
  bool get isInitialized => _walletAddress != null;

  /// Get network display name
  String getNetworkDisplayName() {
    return '${getNativeCurrencyName()} ${BlockchainConfig.networkType == WalletNetworkType.testnet ? 'Testnet' : 'Mainnet'}';
  }

  /// Get chain type display name
  String getChainTypeDisplayName() {
    switch (BlockchainConfig.chainType) {
      case ChainType.ethereum:
        return 'Ethereum';
      case ChainType.bsc:
        return 'Binance Smart Chain';
      case ChainType.polygon:
        return 'Polygon';
      case ChainType.arbitrum:
        return 'Arbitrum';
      case ChainType.optimism:
        return 'Optimism';
    }
  }

  /// Get network type display name
  String getNetworkTypeDisplayName() {
    return BlockchainConfig.networkType == WalletNetworkType.testnet ? 'Testnet' : 'Mainnet';
  }

  /// Switch to specific chain and network
  void switchToNetwork(ChainType chain, WalletNetworkType network) {
    BlockchainConfig.setChainType(chain);
    BlockchainConfig.setNetworkType(network);
    log('🔄 Switched to: ${chain.name} ${network.name}');
    log('📍 RPC URL: ${BlockchainConfig.getRpcUrl(chain, network)}');
    log('🔗 Chain ID: ${BlockchainConfig.getChainId(chain, network)}');
  }

  /// Get network info for specific chain and network
  Map<String, dynamic> getNetworkInfo(ChainType chain, WalletNetworkType network) {
    return {
      'chainType': chain.name,
      'networkType': network.name,
      'chainId': BlockchainConfig.getChainId(chain, network),
      'rpcUrl': BlockchainConfig.getRpcUrl(chain, network),
      'blockExplorer': BlockchainConfig.getBlockExplorer(chain, network),
      'nativeCurrency': {
        'name': BlockchainConfig.getNativeCurrencyName(),
        'symbol': BlockchainConfig.getNativeCurrencySymbol(),
        'decimals': 18,
      },
    };
  }

  /// Test connection to a specific network
  Future<bool> testNetworkConnection(ChainType chain, WalletNetworkType network) async {
    try {
      final rpcUrl = BlockchainConfig.getRpcUrl(chain, network);
      log('🧪 Testing connection to: ${chain.name} ${network.name}');
      log('🔗 RPC URL: $rpcUrl');
      
      // Here you would typically make an HTTP request to test the connection
      // For now, we'll just log the URL
      log('✅ Network connection test initiated');
      return true;
    } catch (e) {
      log('❌ Network connection test failed: $e');
      return false;
    }
  }
}


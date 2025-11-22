import 'package:flutter/material.dart';
import '../../../../../data/base_vm.dart';
import '../../../../../services/wallet_service.dart';
import '../../../../../services/market_data_service.dart';
import '../../../../../data/model/body/supported_chain_model.dart';
import '../../../../../config/blockchain_config.dart';
import '../receive/receive_screen.dart';

class ReceiveCryptoVM extends BaseVM {
  final List<CryptoItem> _cryptoList = [];
  final List<CryptoItem> _filteredCryptoList = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  
  // Supported chains for receiving
  final List<SupportedChainModel> _supportedChains = [
    SupportedChainModel(
      chainId: 'ethereum',
      chainName: 'Ethereum Sepolia',
      chainType: 'evm',
      chainIdNumber: 11155111,
      rpcUrl: BlockchainConfig.ethereumSepoliaRpc,
      blockExplorer: 'https://sepolia.etherscan.io',
      nativeCurrencyName: 'Ethereum',
      nativeCurrencySymbol: 'ETH',
      decimals: 18,
      isActive: true,
      iconPath: 'assets/svgs/wallet_home/ethereum.svg',
      color: '#627EEA',
    ),
    SupportedChainModel(
      chainId: 'bsc',
      chainName: 'BSC Testnet',
      chainType: 'evm',
      chainIdNumber: 97,
      rpcUrl: 'https://data-seed-prebsc-1-s1.binance.org:8545/',
      blockExplorer: 'https://testnet.bscscan.com',
      nativeCurrencyName: 'BNB',
      nativeCurrencySymbol: 'BNB',
      decimals: 18,
      isActive: true,
      iconPath: 'assets/svgs/wallet_home/ethereum.svg', // Use Ethereum icon as fallback
      color: '#F3BA2F',
    ),
    SupportedChainModel(
      chainId: 'polygon',
      chainName: 'Polygon Mumbai',
      chainType: 'evm',
      chainIdNumber: 80001,
      rpcUrl: BlockchainConfig.polygonMumbaiRpc,
      blockExplorer: 'https://mumbai.polygonscan.com',
      nativeCurrencyName: 'Polygon',
      nativeCurrencySymbol: 'MATIC',
      decimals: 18,
      isActive: true,
      iconPath: 'assets/svgs/wallet_home/ethereum.svg', // Use Ethereum icon as fallback
      color: '#8247E5',
    ),
    SupportedChainModel(
      chainId: 'arbitrum',
      chainName: 'Arbitrum Sepolia',
      chainType: 'evm',
      chainIdNumber: 421614,
      rpcUrl: BlockchainConfig.arbitrumSepoliaRpc,
      blockExplorer: 'https://sepolia.arbiscan.io',
      nativeCurrencyName: 'Ethereum',
      nativeCurrencySymbol: 'ETH',
      decimals: 18,
      isActive: true,
      iconPath: 'assets/svgs/wallet_home/ethereum.svg',
      color: '#28A0F0',
    ),
    SupportedChainModel(
      chainId: 'optimism',
      chainName: 'Optimism Sepolia',
      chainType: 'evm',
      chainIdNumber: 11155420,
      rpcUrl: BlockchainConfig.optimismSepoliaRpc,
      blockExplorer: 'https://sepolia-optimism.etherscan.io',
      nativeCurrencyName: 'Ethereum',
      nativeCurrencySymbol: 'ETH',
      decimals: 18,
      isActive: true,
      iconPath: 'assets/svgs/wallet_home/ethereum.svg',
      color: '#FF0420',
    ),
  ];

  List<CryptoItem> get cryptoList => _filteredCryptoList;
  List<CryptoItem> get allCryptoList => _cryptoList;
  TextEditingController get searchController => _searchController;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ReceiveCryptoVM() {
    print('🚀 ReceiveCryptoVM - Constructor called');
    loadCryptoData();
    _searchController.addListener(_filterCrypto);
  }

  Future<void> loadCryptoData() async {
    print('🔍 ReceiveCryptoVM - loadCryptoData() called');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔍 ReceiveCryptoVM - Loading crypto data...');
      
      // Get wallet service to get current wallet address
      final walletService = WalletService();
      final walletAddress = walletService.walletList.isNotEmpty 
          ? walletService.walletList.first.address 
          : '0x0000000000000000000000000000000000000000';
      
      // Get market data service for real prices
      
      // Create crypto items for supported chains
      final cryptoItems = <CryptoItem>[];
      
      for (final chain in _supportedChains) {
        try {
          // Get real market data for this chain
          final marketData = await MarketDataService.getChainPriceData(chain.chainId);
          
          cryptoItems.add(CryptoItem(
            name: chain.chainName,
            symbol: chain.nativeCurrencySymbol,
            iconPath: _getIconPath(chain.chainId),
            price: marketData?['price']?.toStringAsFixed(2) ?? "0.00",
            change: marketData?['priceChange24h'] != null 
                ? (marketData!['priceChange24h'] >= 0 
                    ? "+${marketData['priceChange24h'].toStringAsFixed(1)}%" 
                    : "${marketData['priceChange24h'].toStringAsFixed(1)}%")
                : "0.0%",
            holdings: _getHoldingsForChain(chain.chainId),
            holdingsValue: _getHoldingsValueForChain(chain.chainId, marketData?['price']?.toDouble() ?? 0.0),
            chain: chain,
            walletAddress: walletAddress,
          ));
          
          print('✅ ReceiveCryptoVM - Loaded ${chain.nativeCurrencySymbol} data');
        } catch (e) {
          print('⚠️ ReceiveCryptoVM - Error loading ${chain.nativeCurrencySymbol}: $e');
          // Add with fallback data
          cryptoItems.add(CryptoItem(
            name: chain.chainName,
            symbol: chain.nativeCurrencySymbol,
            iconPath: _getIconPath(chain.chainId),
            price: "0.00",
            change: "0.0%",
            holdings: "0",
            holdingsValue: "0.00",
            chain: chain,
            walletAddress: walletAddress,
          ));
        }
      }
      
      _cryptoList.clear();
      _cryptoList.addAll(cryptoItems);
      _filteredCryptoList.clear();
      _filteredCryptoList.addAll(_cryptoList);
      
      print('✅ ReceiveCryptoVM - Loaded ${_cryptoList.length} crypto items');
      
    } catch (e) {
      print('❌ ReceiveCryptoVM - Error loading crypto data: $e');
      _error = 'Failed to load crypto data: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getIconPath(String chainId) {
    switch (chainId) {
      case 'ethereum':
        return "assets/svgs/wallet_home/ethereum.svg";
      case 'bsc':
        return "assets/svgs/wallet_home/ethereum.svg"; // Use Ethereum icon as fallback
      case 'polygon':
        return "assets/svgs/wallet_home/ethereum.svg"; // Use Ethereum icon as fallback
      case 'arbitrum':
        return "assets/svgs/wallet_home/ethereum.svg"; // Use Ethereum icon as fallback
      case 'optimism':
        return "assets/svgs/wallet_home/ethereum.svg"; // Use Ethereum icon as fallback
      default:
        return "assets/svgs/wallet_home/ethereum.svg";
    }
  }

  String _getHoldingsForChain(String chainId) {
    // For now, return mock data. In a real app, this would fetch from blockchain
    switch (chainId) {
      case 'ethereum':
        return "0.027"; // Real ETH balance from MainWalletVM
      case 'bsc':
        return "0.0"; // BNB balance
      case 'polygon':
        return "0.0"; // MATIC balance
      case 'arbitrum':
        return "0.0"; // ETH balance on Arbitrum
      case 'optimism':
        return "0.0"; // ETH balance on Optimism
      default:
        return "0.0";
    }
  }

  String _getHoldingsValueForChain(String chainId, double price) {
    final holdings = double.tryParse(_getHoldingsForChain(chainId)) ?? 0.0;
    return (holdings * price).toStringAsFixed(2);
  }

  void _filterCrypto() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredCryptoList.clear();
      _filteredCryptoList.addAll(_cryptoList);
    } else {
      _filteredCryptoList.clear();
      _filteredCryptoList.addAll(_cryptoList.where((crypto) {
        return crypto.name.toLowerCase().contains(query) ||
               crypto.symbol.toLowerCase().contains(query);
      }));
    }
    notifyListeners();
  }

  void selectCrypto(String symbol, BuildContext context) {
    print('🔍 ReceiveCryptoVM - Selecting crypto: $symbol');
    print('🔍 ReceiveCryptoVM - Available cryptos: ${_cryptoList.length}');
    
    if (_cryptoList.isEmpty) {
      print('❌ ReceiveCryptoVM - No crypto items available');
      return;
    }
    
    // Find the crypto item by symbol
    CryptoItem? cryptoItem;
    try {
      cryptoItem = _cryptoList.firstWhere(
        (crypto) => crypto.symbol == symbol,
      );
    } catch (e) {
      print('⚠️ ReceiveCryptoVM - Crypto $symbol not found, using first available');
      cryptoItem = _cryptoList.first;
    }
    
    if (cryptoItem == null) {
      print('❌ ReceiveCryptoVM - Failed to get crypto item');
      return;
    }
    
    print('✅ ReceiveCryptoVM - Selected crypto: ${cryptoItem.symbol}');
    print('🔍 ReceiveCryptoVM - Chain: ${cryptoItem.chain?.chainName}');
    
    // Navigate to the generic receive screen with crypto data
    print('🔍 ReceiveCryptoVM - Navigating with arguments:');
    print('  - Crypto: ${cryptoItem.symbol}');
    print('  - Chain: ${cryptoItem.chain?.chainName}');
    print('  - Address: ${cryptoItem.walletAddress}');
    
    Navigator.pushNamed(
      context,
      '/receive',
      arguments: {
        'cryptoSymbol': cryptoItem.symbol,
        'cryptoName': cryptoItem.name,
        'cryptoIcon': cryptoItem.iconPath,
        'walletAddress': cryptoItem.walletAddress,
        'chainId': cryptoItem.chain?.chainId,
        'chainName': cryptoItem.chain?.chainName,
        'chainType': cryptoItem.chain?.chainType,
        'chainIdNumber': cryptoItem.chain?.chainIdNumber,
        'rpcUrl': cryptoItem.chain?.rpcUrl,
        'blockExplorer': cryptoItem.chain?.blockExplorer,
        'nativeCurrencyName': cryptoItem.chain?.nativeCurrencyName,
        'nativeCurrencySymbol': cryptoItem.chain?.nativeCurrencySymbol,
        'decimals': cryptoItem.chain?.decimals,
        'isActive': cryptoItem.chain?.isActive,
        'iconPath': cryptoItem.chain?.iconPath,
        'color': cryptoItem.chain?.color,
      },
    );
  }

  void searchCrypto(String query) {
    _searchController.text = query;
    _filterCrypto();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class CryptoItem {
  final String name;
  final String symbol;
  final String iconPath;
  final String price;
  final String change;
  final String holdings;
  final String holdingsValue;
  final SupportedChainModel? chain;
  final String walletAddress;

  CryptoItem({
    required this.name,
    required this.symbol,
    required this.iconPath,
    required this.price,
    required this.change,
    required this.holdings,
    required this.holdingsValue,
    this.chain,
    required this.walletAddress,
  });
}

import 'package:flutter/material.dart';
import '../../../../../data/base_vm.dart';
import '../../../../../data/model/body/supported_chain_model.dart';
import '../../../../../services/market_data_service.dart';
import '../../../../../config/blockchain_config.dart';

class SendVM extends BaseVM {
  final TextEditingController _cryptoAmountController = TextEditingController();
  final TextEditingController _usdAmountController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  String _selectedPercentage = "25%";
  String _fee = "0.00";
  String _youWillGet = "0.00";
  String _cryptoAmount = "0.00";
  String _usdAmount = "0.00";
  String _walletBalance = "0.00";
  double _currentPrice = 0.0;
  
  SupportedChainModel? _chain;

  TextEditingController get cryptoAmountController => _cryptoAmountController;
  TextEditingController get usdAmountController => _usdAmountController;
  TextEditingController get addressController => _addressController;
  String get selectedPercentage => _selectedPercentage;
  String get fee => _fee;
  String get youWillGet => _youWillGet;
  String get cryptoAmount => _cryptoAmount;
  String get usdAmount => _usdAmount;
  String get walletBalance => _walletBalance;
  double get currentPrice => _currentPrice;
  SupportedChainModel? get chain => _chain;
  
  /// Check if current address is valid
  bool get isAddressValid {
    String address = _addressController.text.trim();
    return _isValidEthereumAddress(address);
  }

  /// Initialize with chain data
  void initializeWithChain(SupportedChainModel chain) {
    print('🔗 SendVM - Initializing with chain: ${chain.chainName}');
    // Find the matching chain from our supported chains list to ensure object equality
    _chain = getSupportedChains().firstWhere(
      (supportedChain) => supportedChain.chainId == chain.chainId,
      orElse: () => getSupportedChains().first,
    );
    _loadMarketData();
    _loadWalletBalance();
    notifyListeners();
  }

  /// Switch to a different chain
  void switchChain(SupportedChainModel newChain) {
    print('🔄 SendVM - Switching to chain: ${newChain.chainName}');
    _chain = newChain;
    _loadMarketData();
    // Don't reset wallet balance when switching chains - keep the current balance
    // _loadWalletBalance(); // Removed to prevent balance reset
    notifyListeners();
  }

  /// Get all supported chains for selection
  List<SupportedChainModel> getSupportedChains() {
    return [
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
        iconPath: 'assets/svgs/wallet_home/ethereum.svg',
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
        iconPath: 'assets/svgs/wallet_home/ethereum.svg',
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
  }

  /// Load current market price for the chain
  Future<void> _loadMarketData() async {
    if (_chain == null) return;

    try {
      final priceData = await MarketDataService.getChainPriceData(_chain!.chainId);
      if (priceData != null) {
        _currentPrice = priceData['price'] ?? 0.0;
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error loading market data: $e');
    }
  }

  /// Load wallet balance from the main wallet VM
  void _loadWalletBalance() {
    // Get the real wallet balance from MainWalletVM
    // This will be updated when the SendVM is initialized
    _walletBalance = "0.00"; // Will be updated by the parent
    notifyListeners();
  }
  
  /// Update wallet balance from external source (MainWalletVM)
  void updateWalletBalance(String balance) {
    _walletBalance = balance;
    notifyListeners();
  }
  
  /// Update address validation (called from UI)
  void updateAddressValidation() {
    notifyListeners();
  }

  void selectPercentage(String percentage) {
    _selectedPercentage = percentage;
    _calculateAmounts();
    notifyListeners();
  }

  void updateCryptoAmount(String amount) {
    print('💰 SendVM - Updating crypto amount: $amount');
    _cryptoAmount = amount;
    _calculateUsdAmount();
    _calculateAmounts();
    print('💰 SendVM - USD amount calculated: $_usdAmount');
    notifyListeners();
  }

  void updateUsdAmount(String amount) {
    _usdAmount = amount;
    _calculateCryptoAmount();
    _calculateAmounts();
    notifyListeners();
  }

  void _calculateAmounts() {
    // Calculate fee and amount you will get based on selected percentage
    double percentage = double.parse(_selectedPercentage.replaceAll('%', '')) / 100;
    double amount = double.tryParse(_cryptoAmount) ?? 0.0;

    // Dynamic fee calculation based on chain
    double feeRate = _getFeeRate();
    _fee = (amount * feeRate).toStringAsFixed(6);
    _youWillGet = (amount * percentage - double.parse(_fee)).toStringAsFixed(6);
  }

  /// Get fee rate based on chain type
  double _getFeeRate() {
    if (_chain == null) return 0.001; // Default 0.1%

    // Different chains have different fee structures
    switch (_chain!.chainId) {
      case 'ethereum': return 0.001; // 0.1% for Ethereum
      case 'bsc': return 0.0005; // 0.05% for BSC (lower fees)
      case 'polygon': return 0.0003; // 0.03% for Polygon (very low fees)
      case 'arbitrum': return 0.0008; // 0.08% for Arbitrum
      case 'optimism': return 0.0008; // 0.08% for Optimism
      default: return 0.001; // Default 0.1%
    }
  }

  void _calculateUsdAmount() {
    if (_currentPrice == 0.0) {
      // Use fallback price if current price is not available
      _currentPrice = 2000.0; // Fallback ETH price
    }

    double cryptoAmount = double.tryParse(_cryptoAmount) ?? 0.0;
    _usdAmount = (cryptoAmount * _currentPrice).toStringAsFixed(2);
    _usdAmountController.text = _usdAmount;
  }

  void _calculateCryptoAmount() {
    if (_currentPrice == 0.0) {
      // Use fallback price if current price is not available
      _currentPrice = 2000.0; // Fallback ETH price
    }

    double usdAmount = double.tryParse(_usdAmount) ?? 0.0;
    _cryptoAmount = (usdAmount / _currentPrice).toStringAsFixed(6);
    _cryptoAmountController.text = _cryptoAmount;
  }

  /// Set address from QR scan
  void setAddressFromQR(String address) {
    // Clean the address (remove any extra text or formatting)
    String cleanAddress = address.trim();
    
    // Basic validation for Ethereum address format
    if (_isValidEthereumAddress(cleanAddress)) {
      _addressController.text = cleanAddress;
      notifyListeners();
    } else {
      // If it's not a valid address, still set it but show a warning
      _addressController.text = cleanAddress;
      notifyListeners();
    }
  }

  /// Basic validation for Ethereum address format
  bool _isValidEthereumAddress(String address) {
    // Check if it starts with 0x and is 42 characters long
    if (address.startsWith('0x') && address.length == 42) {
      // Check if the rest are valid hex characters
      String hexPart = address.substring(2);
      return RegExp(r'^[0-9a-fA-F]+$').hasMatch(hexPart);
    }
    return false;
  }

  void reviewTransaction(BuildContext context) {
    print('🔍 SendVM - Review transaction called');
    print('🔍 SendVM - Chain: ${_chain?.chainName ?? "null"}');
    print('🔍 SendVM - Address: ${_addressController.text}');
    print('🔍 SendVM - Amount: $_cryptoAmount');
    
    // Validate transaction data
    if (_chain == null) {
      print('❌ SendVM - No chain selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a chain first"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter recipient address"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isValidEthereumAddress(_addressController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid Ethereum address"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_cryptoAmount.isEmpty || double.tryParse(_cryptoAmount) == null || double.parse(_cryptoAmount) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid amount"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to review screen with transaction data
    final transactionData = {
      'chain': _chain,
      'amount': _cryptoAmount,
      'toAddress': _addressController.text.trim(),
      'usdAmount': _usdAmount,
      'currentPrice': _currentPrice,
    };
    
    print('🔍 SendVM - Navigating to review with data: $transactionData');
    print('🔍 SendVM - Chain data: ${_chain?.chainName}');
    print('🔍 SendVM - Amount: $_cryptoAmount');
    print('🔍 SendVM - To Address: ${_addressController.text.trim()}');
    print('🔍 SendVM - USD Amount: $_usdAmount');
    print('🔍 SendVM - Current Price: $_currentPrice');
    
    // Use Navigator.pushNamed with the route system
    Navigator.pushNamed(
      context, 
      "/review",
      arguments: transactionData,
    );
  }

  @override
  void dispose() {
    _cryptoAmountController.dispose();
    _usdAmountController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
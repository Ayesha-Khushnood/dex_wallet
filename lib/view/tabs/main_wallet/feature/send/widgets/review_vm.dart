import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:provider/provider.dart';
import '../../../../../../data/base_vm.dart';
import '../../../../../../data/model/body/supported_chain_model.dart';
import '../../../../../../services/transaction_service.dart';
import '../../../../../../services/wallet_service.dart';
import '../../../../../../services/auth_service.dart';
import '../../../../../../data/repos/wallet_repo.dart';
import 'package:dex/view/tabs/main_wallet/feature/history/history_vm.dart';
import '../../../../../../data/model/body/wallet_retrieval_model.dart';
import '../../../main_wallet_vm.dart';

class ReviewVM extends BaseVM {
  SupportedChainModel? _chain;
  String _amount = "0.00";
  String _toAddress = "";
  String _fromAddress = "";
  String _transactionFee = "0.00";
  String _maxTotal = "0.00";
  String _usdAmount = "0.00";
  double _currentPrice = 0.0;
  bool _isLoading = false;
  String? _error;
  bool _hasInitialized = false;

  // Getters
  SupportedChainModel? get chain => _chain;
  String get amount => _amount;
  String get toAddress => _toAddress;
  String get fromAddress => _fromAddress;
  String get transactionFee => _transactionFee;
  String get maxTotal => _maxTotal;
  String get usdAmount => _usdAmount;
  double get currentPrice => _currentPrice;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize transaction data
  void initializeTransaction(Map<String, dynamic> transactionData) {
    if (_hasInitialized) {
      print('🔍 ReviewVM - Already initialized, skipping...');
      return;
    }
    
    print('🔍 ReviewVM - Initializing transaction data...');
    _chain = transactionData['chain'] as SupportedChainModel?;
    _amount = transactionData['amount'] ?? "0.00";
    _toAddress = transactionData['toAddress'] ?? "";
    _usdAmount = transactionData['usdAmount'] ?? "0.00";
    _currentPrice = transactionData['currentPrice'] ?? 0.0;
    
    // Get real wallet address from WalletService
    _getWalletAddress();
    
    _calculateFees();
    _hasInitialized = true;
    notifyListeners();
  }

  /// Get wallet address from WalletService
  void _getWalletAddress() {
    try {
      final walletService = WalletService();
      print('🔍 ReviewVM - WalletService initialized: ${walletService.hasInitialized}');
      print('🔍 ReviewVM - WalletService hasWallet: ${walletService.hasWallet}');
      print('🔍 ReviewVM - WalletService walletList length: ${walletService.walletList.length}');
      print('🔍 ReviewVM - WalletService walletAddress: ${walletService.walletAddress}');
      
      if (walletService.walletList.isNotEmpty) {
        _fromAddress = walletService.walletList.first.address;
        print('🔍 ReviewVM - Using wallet address from list: $_fromAddress');
      } else if (walletService.walletAddress != null) {
        _fromAddress = walletService.walletAddress!;
        print('🔍 ReviewVM - Using cached wallet address: $_fromAddress');
      } else {
        print('⚠️ ReviewVM - No wallets found, using demo address');
        _fromAddress = "0xcb0c48ec53d9a07c25af672eefe64c3868f56be4"; // Fallback demo address
      }
    } catch (e) {
      print('❌ ReviewVM - Error getting wallet address: $e');
      _fromAddress = "0xcb0c48ec53d9a07c25af672eefe64c3868f56be4"; // Fallback demo address
    }
  }

  /// Try to initialize wallet service if not initialized
  Future<void> _tryInitializeWalletService() async {
    try {
      final walletService = WalletService();
      print('🔍 ReviewVM - WalletService state before initialization:');
      print('🔍 ReviewVM - hasInitialized: ${walletService.hasInitialized}');
      print('🔍 ReviewVM - hasWallet: ${walletService.hasWallet}');
      print('🔍 ReviewVM - walletList length: ${walletService.walletList.length}');
      print('🔍 ReviewVM - walletAddress: ${walletService.walletAddress}');
      
      if (!walletService.hasInitialized) {
        print('🔄 ReviewVM - WalletService not initialized, trying to initialize...');
        await walletService.initializeWalletData();
      } else if (!walletService.hasWallet) {
        print('🔄 ReviewVM - WalletService initialized but no wallet, force reinitializing...');
        await walletService.forceReinitialize();
      }
      
      print('🔍 ReviewVM - After initialization - hasWallet: ${walletService.hasWallet}');
      print('🔍 ReviewVM - After initialization - walletList length: ${walletService.walletList.length}');
      print('🔍 ReviewVM - After initialization - walletAddress: ${walletService.walletAddress}');
    } catch (e) {
      print('❌ ReviewVM - Error initializing wallet service: $e');
    }
  }

  /// Calculate transaction fees
  void _calculateFees() {
    if (_chain == null) return;

    double amountValue = double.tryParse(_amount) ?? 0.0;
    double feeRate = _getFeeRate();
    
    _transactionFee = (amountValue * feeRate).toStringAsFixed(6);
    _maxTotal = (amountValue + double.parse(_transactionFee)).toStringAsFixed(6);
  }

  /// Get fee rate based on chain type
  double _getFeeRate() {
    if (_chain == null) return 0.001; // Default 0.1%

    switch (_chain!.chainId) {
      case 'ethereum': return 0.001; // 0.1% for Ethereum
      case 'bsc': return 0.0005; // 0.05% for BSC (lower fees)
      case 'polygon': return 0.0003; // 0.03% for Polygon (very low fees)
      case 'arbitrum': return 0.0008; // 0.08% for Arbitrum
      case 'optimism': return 0.0008; // 0.08% for Optimism
      default: return 0.001; // Default 0.1%
    }
  }

  /// Copy address to clipboard
  void copyAddress(String address) {
    Clipboard.setData(ClipboardData(text: address));
    // You could show a snackbar here if needed
  }

  /// Send transaction
  Future<void> sendTransaction(BuildContext context) async {
    if (_chain == null) {
      _error = "No chain selected";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🚀 ReviewVM - Starting real blockchain transaction...');
      print('🔍 ReviewVM - Chain: ${_chain!.chainName}');
      print('🔍 ReviewVM - RPC URL: ${_chain!.rpcUrl}');
      print('🔍 ReviewVM - Amount: $_amount');
      print('🔍 ReviewVM - To Address: $_toAddress');
      print('🔍 ReviewVM - From Address: $_fromAddress');
      
      // Try to initialize wallet service if needed
      await _tryInitializeWalletService();
      
      // Re-get wallet address after potential initialization
      _getWalletAddress();
      print('🔍 ReviewVM - Final from address: $_fromAddress');
      
      // Initialize TransactionService with chain RPC URL
      final transactionService = TransactionService();
      transactionService.initializeClient(_chain!.rpcUrl);
      print('✅ ReviewVM - TransactionService initialized');
      
      // Check wallet balance first
      print('🔍 ReviewVM - Checking wallet balance...');
      final balance = await transactionService.getBalance(_fromAddress);
      final balanceInWei = balance.getInWei;
      final balanceInEth = balance.getInEther;
      print('🔍 ReviewVM - Current balance in Wei: ${balanceInWei.toString()}');
      print('🔍 ReviewVM - Current balance in ETH: ${balanceInEth.toString()} ETH');
      
      // Convert balance to double for display
      final balanceInEthDouble = balanceInWei / BigInt.from(1e18.toInt());
      print('🔍 ReviewVM - Current balance in ETH (double): ${balanceInEthDouble.toString()} ETH');
      
      // Convert amount to EtherAmount
      final amountDouble = double.parse(_amount);
      final amountInWeiValue = (amountDouble * 1e18).round();
      print('🔍 ReviewVM - Amount double: $amountDouble');
      print('🔍 ReviewVM - Amount in Wei calculation: $amountInWeiValue');
      
      final amountInWei = EtherAmount.fromBigInt(
        EtherUnit.wei, 
        BigInt.from(amountInWeiValue)
      );
      
      print('🔍 ReviewVM - Amount in Wei (EtherAmount): ${amountInWei.getInWei.toString()}');
      print('🔍 ReviewVM - Amount in ETH (EtherAmount): ${amountInWei.getInEther.toString()}');
      
      // Get gas price and estimate gas
      print('🔍 ReviewVM - Getting gas price...');
      final gasPrice = await transactionService.getGasPrice();
      print('🔍 ReviewVM - Raw gas price: $gasPrice');
      
      print('🔍 ReviewVM - Estimating gas limit...');
      final gasLimit = await transactionService.estimateGas(
        from: _fromAddress,
        to: _toAddress,
        value: amountInWei,
      );
      
      // Calculate total cost (amount + gas fees)
      final gasFee = gasPrice * BigInt.from(gasLimit);
      final totalCost = amountInWei.getInWei + gasFee;
      
      print('🔍 ReviewVM - Gas Price: ${(gasPrice ~/ BigInt.from(1000000000)).toString()} Gwei');
      print('🔍 ReviewVM - Gas Limit: $gasLimit');
      print('🔍 ReviewVM - Gas Fee in Wei: ${gasFee.toString()}');
      print('🔍 ReviewVM - Amount in Wei: ${amountInWei.getInWei.toString()}');
      print('🔍 ReviewVM - Total Cost in Wei: ${totalCost.toString()}');
      print('🔍 ReviewVM - Balance in Wei: ${balanceInWei.toString()}');
      
      // Check if wallet has sufficient balance (compare in Wei)
      if (balanceInWei < totalCost) {
        final balanceInEthDisplay = balanceInWei / BigInt.from(1e18.toInt());
        final totalCostInEthDisplay = totalCost / BigInt.from(1e18.toInt());
        throw Exception("Insufficient balance. Required: ${totalCostInEthDisplay.toString()} ETH, Available: ${balanceInEthDisplay.toString()} ETH");
      }
      
      // Get private key from wallet
      print('🔍 ReviewVM - Retrieving private key...');
      final privateKey = await _getPrivateKey();
      if (privateKey == null) {
        throw Exception("Could not retrieve private key - check wallet setup");
      }
      print('✅ ReviewVM - Private key retrieved (length: ${privateKey.length})');
      
      // Validate private key format
      if (!privateKey.startsWith('0x')) {
        throw Exception("Invalid private key format - must start with 0x");
      }
      
      if (privateKey.length != 66) {
        throw Exception("Invalid private key length - expected 66 characters, got ${privateKey.length}");
      }
      
      // Sign transaction
      print('🔍 ReviewVM - Signing transaction...');
      print('🔍 ReviewVM - Chain ID for signing: ${_chain?.chainIdNumber}');
      print('🔍 ReviewVM - Chain name: ${_chain?.chainName}');
      final signedTransaction = await transactionService.signTransaction(
        privateKey: privateKey,
        to: _toAddress,
        value: amountInWei,
        gasPrice: gasPrice,
        gasLimit: gasLimit,
        chainId: _chain?.chainIdNumber,
      );
      
      print('✅ ReviewVM - Transaction signed successfully');
      
      // Send transaction to blockchain
      print('🔍 ReviewVM - Sending transaction to blockchain...');
      final transactionHash = await transactionService.sendRawTransaction(signedTransaction);
      
      print('🎉 ReviewVM - Transaction sent to blockchain: $transactionHash');
      
      // Refresh wallet balance after successful transaction (with delay)
      try {
        print('🔄 ReviewVM - Scheduling wallet balance refresh...');
        final mainWalletVM = Provider.of<MainWalletVM>(context, listen: false);
        
        // Add a delay to allow blockchain to process the transaction
        Future.delayed(const Duration(seconds: 3), () async {
          print('🔄 ReviewVM - Refreshing wallet balance after delay...');
          await mainWalletVM.forceRefreshBalance();
          print('✅ ReviewVM - Wallet balance refreshed after delay');
        });
        
        // Also refresh immediately (in case transaction is already confirmed)
        await mainWalletVM.forceRefreshBalance();
        print('✅ ReviewVM - Wallet balance refreshed immediately');
        
        // Mark transaction history as stale so it refreshes when user views it
        try {
          HistoryVM.instance.markTransactionsStale();
          print('🔄 ReviewVM - Transaction history marked as stale');
        } catch (e) {
          print('⚠️ ReviewVM - Could not mark transactions as stale: $e');
        }
      } catch (e) {
        print('⚠️ ReviewVM - Could not refresh balance: $e');
      }
      
    // Navigate to success screen
      Navigator.pushReplacementNamed(
        context,
        "/success",
        arguments: {
          'chain': _chain,
          'amount': _amount,
          'toAddress': _toAddress,
          'fromAddress': _fromAddress,
          'transactionHash': transactionHash,
          'usdAmount': _usdAmount,
        },
      );
      
    } catch (e) {
      print('❌ ReviewVM - Transaction failed: $e');
      _error = "Transaction failed: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get private key from wallet
  Future<String?> _getPrivateKey() async {
    try {
      print('🔍 ReviewVM - Initializing WalletService...');
      final walletService = WalletService();
      print('🔍 ReviewVM - WalletService initialized, checking wallet list...');
      
      if (walletService.walletList.isEmpty) {
        print('❌ ReviewVM - No wallets available in WalletService');
        print('🔍 ReviewVM - WalletService walletList length: ${walletService.walletList.length}');
        return null;
      }
      
      final wallet = walletService.walletList.first;
      print('🔍 ReviewVM - Found wallet: ${wallet.address}');
      print('🔍 ReviewVM - Retrieving private key for wallet: ${wallet.address}');
      
      // Get PIN from AuthService
      print('🔍 ReviewVM - Initializing AuthService...');
      final authService = AuthService();
      print('🔍 ReviewVM - Getting PIN from AuthService...');
      final pin = await authService.getPin();
      if (pin == null) {
        print('❌ ReviewVM - No PIN available from AuthService');
        return null;
      }
      print('✅ ReviewVM - PIN retrieved successfully');
      
      // Retrieve wallet data with private key
      print('🔍 ReviewVM - Initializing WalletRepo...');
      final walletRepo = WalletRepo();
      print('🔍 ReviewVM - Calling retrieveWallet...');
      final response = await walletRepo.retrieveWallet(
        address: wallet.address,
        walletPin: pin,
      );
      
      print('🔍 ReviewVM - WalletRepo response received');
      print('🔍 ReviewVM - Response success: ${response.isSuccess}');
      print('🔍 ReviewVM - Response data: ${response.data}');
      print('🔍 ReviewVM - Response error: ${response.error}');
      
      if (response.isSuccess && response.data != null) {
        // The API response has nested data structure
        final responseData = response.data as Map<String, dynamic>;
        final walletDataJson = responseData['data'] as Map<String, dynamic>;
        
        print('🔍 ReviewVM - Parsing wallet data from: $walletDataJson');
        final walletData = WalletRetrievalModel.fromJson(walletDataJson);
        print('✅ ReviewVM - Private key retrieved successfully');
        print('🔍 ReviewVM - Private key: ${walletData.privateKey}');
        print('🔍 ReviewVM - Private key length: ${walletData.privateKey.length}');
        return walletData.privateKey;
      } else {
        print('❌ ReviewVM - Failed to retrieve wallet data: ${response.error}');
        return null;
      }
    } catch (e) {
      print('❌ ReviewVM - Error retrieving private key: $e');
      print('❌ ReviewVM - Error stack trace: ${StackTrace.current}');
      return null;
    }
  }

  /// Format address for display
  String formatAddress(String address) {
    if (address.length <= 10) return address;
    return "${address.substring(0, 6)}...${address.substring(address.length - 4)}";
  }

  /// Get asset name
  String get asset => _chain?.nativeCurrencySymbol ?? "ETH";
}
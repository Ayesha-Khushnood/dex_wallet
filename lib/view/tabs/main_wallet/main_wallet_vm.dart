import '../../../data/base_vm.dart';
import '../../../data/repos/wallet_repo.dart';
import '../../../data/model/body/wallet_list_item_model.dart';
import '../../../services/auth_service.dart';
import '../../../config/blockchain_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class MainWalletVM extends BaseVM {
  static MainWalletVM? _instance;
  static MainWalletVM get instance {
    if (_instance == null || _instance!.disposed) {
      _instance = MainWalletVM._internal();
    }
    return _instance!;
  }
  
  MainWalletVM._internal();
  
  final WalletRepo _walletRepo = WalletRepo();
  
  String? _walletAddress;
  bool _isLoadingWallet = false;
  String _totalBalance = "0.00 ETH";
  bool _isLoadingBalance = false;
  double? _cachedEthBalance; // Cache the actual ETH balance
  DateTime? _lastBalanceUpdate; // Track when balance was last updated
  Timer? _balanceRefreshTimer; // Timer for periodic balance refresh
  bool _isRefreshing = false; // Guard to prevent multiple simultaneous refreshes
  
  String? get walletAddress => _walletAddress;
  bool get isLoadingWallet => _isLoadingWallet;
  String get totalBalance => _totalBalance;
  bool get isLoadingBalance => _isLoadingBalance;
  bool get isRefreshing => _isRefreshing;
  double? get cachedEthBalance => _cachedEthBalance;
  
  /// Set wallet address directly (from cache)
  void setWalletAddress(String address) {
    _walletAddress = address;
    _isLoadingWallet = false;
    print('✅ Set wallet address from cache: ${address.substring(0, 10)}...');
    _loadPersistedBalance(); // Load persisted balance first
    
    // Defer balance loading and notifyListeners to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // Check if VM is still mounted
      _loadWalletBalance(); // Load balance when wallet address is set
      _startPeriodicRefresh(); // Start periodic balance refresh
      if (!mounted) return; // Check again before notifying
      notifyListeners(); // Notify listeners after build is complete
    });
  }
  
  /// Load specific wallet address (when user selects from wallet list)
  Future<void> loadSpecificWallet(String address) async {
    if (_isLoadingWallet) return;
    
    _isLoadingWallet = true;
    _walletAddress = address;
    notifyListeners();
    
    print('✅ Loaded specific wallet address: $address');
  }

  /// Load wallet address from API
  Future<void> loadWalletAddress() async {
    if (_isLoadingWallet) return;
    
    // Add a small delay to prevent overflow during screen transitions
    await Future.delayed(const Duration(milliseconds: 100));
    
    _isLoadingWallet = true;
    notifyListeners();
    
    try {
      print('🔄 Loading wallet address...');
      
      // Check if user is authenticated first
      final authService = AuthService();
      final isAuthenticated = await authService.isAuthenticated();
      
      if (!isAuthenticated) {
        print('❌ User not authenticated, cannot load wallet data');
        _isLoadingWallet = false;
        notifyListeners();
        return;
      }
      
      final response = await _walletRepo.getWalletList();
      if (response.isSuccess) {
        print('✅ Wallet list retrieved successfully');
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          if (data['data'] != null && data['data'] is List) {
            final walletList = (data['data'] as List)
                .map((wallet) => WalletListItemModel.fromJson(wallet))
                .toList();
            
            if (walletList.isNotEmpty) {
              _walletAddress = walletList.first.address;
              print('✅ Wallet address loaded: ${_walletAddress?.substring(0, 10)}...');
            } else {
              print('ℹ️ No wallets found');
            }
          }
        }
      } else {
        print('❌ Failed to load wallet address: ${response.message}');
      }
    } catch (e) {
      print('💥 Exception loading wallet address: $e');
    } finally {
      _isLoadingWallet = false;
      notifyListeners();
    }
  }
  
  /// Called when user taps Send
  void onSend(BuildContext context) {
    Navigator.pushNamed(context, "/send");
  }

  /// Called when user taps Receive
  void onReceive(BuildContext context) {
    Navigator.pushNamed(context, "/receive");
  }

  /// Called when user taps Buy
  void onBuy(BuildContext context) {
    Navigator.pushNamed(context, "/buyEth");
  }

  /// Called when user taps Swap
  void onSwap(BuildContext context) {
    Navigator.pushNamed(context, "/swap");
  }

  /// Called when user taps History
  void onHistory(BuildContext context) {
    Navigator.pushNamed(context, "/history");
  }

  /// Called when user taps Notifications
  void onNotifications(BuildContext context) {
    Navigator.pushNamed(context, "/notifications");
  }

  /// Load real wallet balance from blockchain
  Future<void> _loadWalletBalance() async {
    if (_walletAddress == null || _isLoadingBalance || _isRefreshing || !mounted) return;
    
    // Check if we have a recent cached balance (within 30 seconds)
    if (_cachedEthBalance != null && _lastBalanceUpdate != null) {
      final timeSinceUpdate = DateTime.now().difference(_lastBalanceUpdate!);
      if (timeSinceUpdate.inSeconds < 30) {
        print('💰 MainWalletVM - Using cached balance: $_cachedEthBalance ETH');
        _updateUSDValue(_cachedEthBalance!);
        return;
      }
    }
    
    _isLoadingBalance = true;
    _isRefreshing = true;
    if (mounted) notifyListeners();
    
    try {
      print('💰 MainWalletVM - Loading real wallet balance...');
      
      // Direct HTTP call to get balance (more reliable than web3dart)
      final balanceInWei = await _getBalanceDirectly(_walletAddress!);
      
      print('🔍 MainWalletVM - Raw balance in Wei: $balanceInWei');
      print('🔍 MainWalletVM - Previous cached balance: $_cachedEthBalance ETH');
      
      // Convert Wei to ETH properly
      // Divide Wei by 1e18 to get ETH
      final balanceInEth = balanceInWei.toDouble() / 1e18;
      
      // Check if balance has actually changed
      if (_cachedEthBalance != null) {
        final difference = (balanceInEth - _cachedEthBalance!).abs();
        print('🔍 MainWalletVM - Balance difference: $difference ETH');
        if (difference < 0.000001) { // Less than 0.000001 ETH difference
          print('🔍 MainWalletVM - Balance unchanged, using cached value');
          _updateUSDValue(_cachedEthBalance!);
          return;
        }
      }
      
      // Cache the ETH balance
      _cachedEthBalance = balanceInEth;
      _lastBalanceUpdate = DateTime.now();
      
      print('💰 MainWalletVM - ETH Balance: $balanceInEth ETH');
      
      // Persist the balance for stability
      await _persistBalance(balanceInEth);
      
      // Update USD value
      await _updateUSDValue(balanceInEth);
      
    } catch (e) {
      print('❌ MainWalletVM - Error loading balance: $e');
      // Use fallback balance if real fetch fails
      _totalBalance = "0.00 ETH";
    } finally {
      _isLoadingBalance = false;
      _isRefreshing = false;
      if (mounted) notifyListeners();
    }
  }

  /// Update display value (ETH only)
  Future<void> _updateUSDValue(double ethBalance) async {
    try {
      // Show only ETH values to avoid USD fluctuations
      _totalBalance = "${ethBalance.toStringAsFixed(6)} ETH";
      
      print('💰 MainWalletVM - ETH Balance: $_totalBalance');
      if (mounted) notifyListeners(); // Notify listeners after balance update
    } catch (e) {
      print('❌ MainWalletVM - Error updating balance: $e');
      // Fallback to ETH only
      _totalBalance = "${ethBalance.toStringAsFixed(6)} ETH";
      if (mounted) notifyListeners(); // Notify listeners even on error
    }
  }

  /// Refresh wallet balance
  Future<void> refreshBalance() async {
    await _loadWalletBalance();
  }

  /// Force refresh wallet balance (called after transactions)
  Future<void> forceRefreshBalance() async {
    if (_isRefreshing) {
      print('🔄 MainWalletVM - Already refreshing, skipping...');
      return;
    }
    
    print('🔄 MainWalletVM - Force refreshing balance...');
    // Clear cache to force fresh fetch
    _cachedEthBalance = null;
    _lastBalanceUpdate = null;
    
    // Clear persisted balance to force fresh fetch
    if (_walletAddress != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final balanceKey = 'balance_${_walletAddress}';
        final timestampKey = 'balance_timestamp_${_walletAddress}';
        await prefs.remove(balanceKey);
        await prefs.remove(timestampKey);
        print('🔄 MainWalletVM - Cleared persisted balance');
      } catch (e) {
        print('⚠️ MainWalletVM - Error clearing persisted balance: $e');
      }
    }
    
    await _loadWalletBalance();
  }

  /// Get balance directly via HTTP (more reliable than web3dart)
  Future<double> _getBalanceDirectly(String address) async {
    try {
      print('🔍 MainWalletVM - Getting balance via direct HTTP call...');
      
      final rpcUrl = BlockchainConfig.ethereumSepoliaRpc;
      
      final requestBody = {
        "jsonrpc": "2.0",
        "method": "eth_getBalance",
        "params": [address, "latest"],
        "id": 1
      };
      
      final response = await http.post(
        Uri.parse(rpcUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hexBalance = data['result'] as String;
        
        print('🔍 MainWalletVM - Raw hex balance: $hexBalance');
        
        // Convert hex to decimal
        final balanceInWei = int.parse(hexBalance.substring(2), radix: 16).toDouble();
        
        print('🔍 MainWalletVM - Direct HTTP balance: $balanceInWei Wei');
        print('🔍 MainWalletVM - Balance in ETH: ${balanceInWei / 1e18} ETH');
        return balanceInWei;
      } else {
        print('❌ MainWalletVM - HTTP call failed: ${response.statusCode}');
        return 0.0;
      }
    } catch (e) {
      print('❌ MainWalletVM - Error in direct HTTP call: $e');
      return 0.0;
    }
  }

  /// Start periodic balance refresh
  void _startPeriodicRefresh() {
    _balanceRefreshTimer?.cancel(); // Cancel existing timer
    _balanceRefreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (_walletAddress != null && !_isRefreshing) {
        print('🔄 MainWalletVM - Periodic balance refresh...');
        _loadWalletBalance();
      }
    });
  }

  /// Stop periodic balance refresh
  void _stopPeriodicRefresh() {
    _balanceRefreshTimer?.cancel();
    _balanceRefreshTimer = null;
  }

  /// Load persisted balance from SharedPreferences
  Future<void> _loadPersistedBalance() async {
    if (_walletAddress == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final balanceKey = 'balance_${_walletAddress}';
      final timestampKey = 'balance_timestamp_${_walletAddress}';
      
      final persistedBalance = prefs.getDouble(balanceKey);
      final persistedTimestamp = prefs.getInt(timestampKey);
      
      if (persistedBalance != null && persistedTimestamp != null) {
        final persistedDate = DateTime.fromMillisecondsSinceEpoch(persistedTimestamp);
        final timeSinceUpdate = DateTime.now().difference(persistedDate);
        
        // Use persisted balance if it's less than 5 minutes old
        if (timeSinceUpdate.inMinutes < 5) {
          print('💰 MainWalletVM - Using persisted balance: $persistedBalance ETH');
          _cachedEthBalance = persistedBalance;
          _lastBalanceUpdate = persistedDate;
          await _updateUSDValue(persistedBalance);
          return;
        } else {
          print('💰 MainWalletVM - Persisted balance too old, will fetch fresh');
        }
      }
    } catch (e) {
      print('❌ MainWalletVM - Error loading persisted balance: $e');
    }
  }

  /// Save balance to SharedPreferences
  Future<void> _persistBalance(double balance) async {
    if (_walletAddress == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final balanceKey = 'balance_${_walletAddress}';
      final timestampKey = 'balance_timestamp_${_walletAddress}';
      
      await prefs.setDouble(balanceKey, balance);
      await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
      
      print('💰 MainWalletVM - Persisted balance: $balance ETH');
    } catch (e) {
      print('❌ MainWalletVM - Error persisting balance: $e');
    }
  }

  @override
  void dispose() {
    _stopPeriodicRefresh();
    // Reset the singleton instance when disposed
    if (_instance == this) {
      _instance = null;
    }
    super.dispose();
  }
}
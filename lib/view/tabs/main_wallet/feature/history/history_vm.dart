import '../../../../../data/base_vm.dart';
import '../../../../../services/wallet_service.dart';
import 'package:flutter/material.dart';
import '../../../../../data/data_sources/dio/dio_client.dart';
import '../../../../../util/api_end_points.dart';
import '../../../../../services/chain_data_provider.dart';
import '../../../../../data/model/body/supported_chain_model.dart';

class TransactionItem {
  final String cryptoName;
  final String cryptoIcon;
  final String amount;
  final String date;
  final String type; // "Sent" or "Received"
  final Color typeColor;
  final String hash;
  final String fromAddress;
  final String toAddress;
  final String status;
  final String blockNumber;

  TransactionItem({
    required this.cryptoName,
    required this.cryptoIcon,
    required this.amount,
    required this.date,
    required this.type,
    required this.typeColor,
    required this.hash,
    required this.fromAddress,
    required this.toAddress,
    required this.status,
    required this.blockNumber,
  });
}

class HistoryVM extends BaseVM {
  static HistoryVM? _instance;
  static HistoryVM get instance {
    _instance ??= HistoryVM._internal();
    return _instance!;
  }
  
  HistoryVM._internal() {
    _searchController.addListener(_filterTransactions);
    // Don't automatically load transactions - let the screen trigger it
  }
  
  final TextEditingController _searchController = TextEditingController();
  List<TransactionItem> _allTransactions = [];
  List<TransactionItem> _filteredTransactions = [];
  bool _isLoading = false;
  String? _error;
  bool _hasInitialized = false;
  
  // Cache for transaction history
  List<TransactionItem>? _cachedTransactions;
  DateTime? _lastTransactionUpdate;
  static const Duration _cacheExpiry = Duration(minutes: 5); // Cache for 5 minutes
  bool _isLoadingTransactions = false; // Guard to prevent multiple simultaneous loads
  SupportedChainModel _currentChain = ChainDataProvider.getSupportedChains().first; // default sepolia

  TextEditingController get searchController => _searchController;
  List<TransactionItem> get transactions => _filteredTransactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  SupportedChainModel get currentChain => _currentChain;

  /// Map current chain to backend network key
  String _backendNetworkForChain(SupportedChainModel chain) {
    final name = (chain.chainName).toLowerCase();
    final id = (chain.chainId).toLowerCase();
    if (name.contains('sepolia')) return 'sepolia';
    if (id == 'bsc') return 'bsc';
    if (id == 'polygon') return 'polygon';
    if (id == 'arbitrum') return 'arbitrum';
    if (id == 'optimism') return 'optimism';
    // default to ethereum mainnet
    return 'ethereum';
  }
  /// Allow external screens (like send screen or a network selector) to set current chain
  void setCurrentChain(SupportedChainModel chain) {
    _currentChain = chain;
    // Invalidate cache per-chain
    _cachedTransactions = null;
    _lastTransactionUpdate = null;
    _hasInitialized = false;
    notifyListeners();
  }


  /// Force refresh transactions (called when app starts or user refreshes)
  Future<void> forceRefreshTransactions() async {
    print('🔄 HistoryVM - Force refreshing transactions...');
    _hasInitialized = false; // Reset initialization flag
    _cachedTransactions = null; // Clear cache
    _lastTransactionUpdate = null;
    await loadTransactions();
  }

  Future<void> loadTransactions() async {
    // Prevent multiple simultaneous loads
    if (_isLoadingTransactions) {
      print('🔍 HistoryVM - Already loading transactions, skipping...');
      return;
    }
    
    // Check if we have valid cached data first
    if (_cachedTransactions != null && _lastTransactionUpdate != null) {
      final cacheAge = DateTime.now().difference(_lastTransactionUpdate!);
      if (cacheAge < _cacheExpiry) {
        print('📦 HistoryVM - Using cached transactions (age: ${cacheAge.inSeconds}s)');
        _allTransactions = List.from(_cachedTransactions!);
        _filteredTransactions = List.from(_allTransactions);
        _hasInitialized = true;
        notifyListeners();
        return;
      } else {
        print('⏰ HistoryVM - Cache expired (age: ${cacheAge.inSeconds}s), fetching fresh data');
      }
    }
    
    // If no cache or cache expired, check if we already have data loaded
    if (_hasInitialized && _allTransactions.isNotEmpty) {
      print('🔍 HistoryVM - Already have data loaded, skipping API call...');
      return;
    }
    
    _isLoadingTransactions = true;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔍 HistoryVM - Loading transaction history...');
      
      // Get wallet address from WalletService
      final walletService = WalletService();
      if (walletService.walletList.isEmpty) {
        throw Exception('No wallet found');
      }
      
      final walletAddress = walletService.walletList.first.address;
      print('🔍 HistoryVM - Wallet address: $walletAddress');
      
      // Fetch transaction history from backend
      final dio = DioClient.instance.dio;
      final response = await dio.get(
        ApiEndPoints.walletTransactions(walletAddress),
        queryParameters: {
          'network': _backendNetworkForChain(_currentChain),
          'limit': 100,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Backend returned ${response.statusCode}');
      }
      final data = response.data;
      final List<dynamic> rawTransactions = data is Map && data['data'] is List ? data['data'] : <dynamic>[];
      print('🔍 HistoryVM - Raw transactions from backend: ${rawTransactions.length}');
      
      // Convert to TransactionItem objects
      _allTransactions = rawTransactions.map((tx) {
        final from = (tx['from'] ?? '') as String;
        final to = (tx['to'] ?? '') as String;
        final status = (tx['status'] ?? 'success') as String;
        final hash = (tx['hash'] ?? '') as String;
        final valueStr = (tx['value'] ?? '0').toString();
        final timestampStr = (tx['timestamp'] ?? '').toString();
        final blockNumber = (tx['blockNumber'] ?? '').toString();

        // Amount: backend may return human value (e.g., 0.1) or wei. If it contains a decimal, use directly.
        String amount;
        if (valueStr.contains('.')) {
          amount = valueStr;
        } else {
          // assume wei string
          try {
            final valueInWei = BigInt.parse(valueStr);
            final valueInEth = valueInWei / BigInt.from(1000000000000000000);
            amount = valueInEth.toString();
          } catch (_) {
            amount = '0';
          }
        }

        // Date: backend example shows ISO8601 string
        String formattedDate;
        try {
          final date = DateTime.tryParse(timestampStr);
          if (date != null) {
            formattedDate = '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
          } else {
            formattedDate = timestampStr;
          }
        } catch (_) {
          formattedDate = timestampStr;
        }

        final isSent = from.toLowerCase() == walletAddress.toLowerCase();
        final type = isSent ? 'Sent' : 'Received';
        final typeColor = isSent ? Colors.red : Colors.green;

        return TransactionItem(
          cryptoName: _currentChain.nativeCurrencyName,
          cryptoIcon: _currentChain.iconPath,
          amount: amount,
          date: formattedDate,
          type: type,
          typeColor: typeColor,
          hash: hash,
          fromAddress: from,
          toAddress: to,
          status: status,
          blockNumber: blockNumber,
        );
      }).toList();
      
      _filteredTransactions = List.from(_allTransactions);
      
      // Cache the transactions
      _cachedTransactions = List.from(_allTransactions);
      _lastTransactionUpdate = DateTime.now();
      
      print('✅ HistoryVM - Loaded ${_allTransactions.length} transactions');
      
    } catch (e) {
      print('❌ HistoryVM - Error loading transactions: $e');
      _error = 'Failed to load transactions: ${e.toString()}';
      
      // Fallback to empty list
      _allTransactions = [];
      _filteredTransactions = [];
    } finally {
      _isLoadingTransactions = false;
      _isLoading = false;
      _hasInitialized = true;
      notifyListeners();
    }
  }

  void _filterTransactions() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredTransactions = List.from(_allTransactions);
    } else {
      _filteredTransactions = _allTransactions.where((transaction) {
        return transaction.cryptoName.toLowerCase().contains(query) ||
               transaction.type.toLowerCase().contains(query) ||
               transaction.hash.toLowerCase().contains(query);
      }).toList();
    }
    notifyListeners();
  }

  /// Refresh transaction history
  Future<void> refreshTransactions() async {
    await forceRefreshTransactions();
  }
  
  /// Check if transactions need refresh (called after new transactions)
  void markTransactionsStale() {
    print('🔄 HistoryVM - Marking transactions as stale (new transaction detected)');
    _cachedTransactions = null;
    _lastTransactionUpdate = null;
    _hasInitialized = false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

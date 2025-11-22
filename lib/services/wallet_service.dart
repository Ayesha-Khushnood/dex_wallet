import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:crypto/crypto.dart';
import 'package:hex/hex.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../data/repos/wallet_repo.dart';
import '../data/model/body/wallet_list_item_model.dart';
import '../config/blockchain_config.dart';

/// Unified Wallet Service
/// Manages both backend wallet data and blockchain operations
class WalletService extends ChangeNotifier {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal() {
    _isDisposed = false;
  }
  
  bool _isDisposed = false;
  final WalletRepo _walletRepo = WalletRepo();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Backend/UI state
  String? _cachedWalletAddress;
  List<WalletListItemModel> _cachedWalletList = [];
  bool _isLoading = false;
  bool _hasInitialized = false;
  String? _lastErrorMessage;

  // Blockchain state
  Web3Client? _web3Client;
  Credentials? _credentials;
  EthereumAddress? _blockchainAddress;
  int _chainId = 11155111; // Sepolia testnet default

  // Backend Getters
  String? get walletAddress => _cachedWalletAddress;
  List<WalletListItemModel> get walletList => _cachedWalletList;
  bool get isLoading => _isLoading;
  bool get hasInitialized => _hasInitialized;
  bool get hasWallet => _cachedWalletAddress != null && _cachedWalletAddress!.isNotEmpty;
  String? get lastErrorMessage => _lastErrorMessage;

  // Blockchain Getters
  bool get isConnected => _credentials != null && _blockchainAddress != null;
  String? get blockchainAddress => _blockchainAddress?.hex;
  int get chainId => _chainId;
  Web3Client? get web3Client => _web3Client;

  // ========== BACKEND/UI METHODS ==========

  /// Initialize wallet data (call this once when user enters the app)
  Future<void> initializeWalletData() async {
    if (_hasInitialized || _isDisposed) {
      print('🔄 WalletService - Already initialized or disposed, skipping...');
      return;
    }

    print('🚀 WalletService - Initializing wallet data...');
    _isLoading = true;
    if (!_isDisposed) notifyListeners();

    try {
      // Get wallet list from backend
      final walletList = await _getWalletList();
      _cachedWalletList = walletList;
      _lastErrorMessage = null;
      
      // If user has wallets, use the first one as the main wallet
      if (walletList.isNotEmpty) {
        _cachedWalletAddress = walletList.first.address;
        print('✅ WalletService - Main wallet address cached: ${_cachedWalletAddress!.substring(0, 10)}...');
        print('📊 WalletService - Total wallets cached: ${walletList.length}');
        
        // Try to load blockchain wallet from storage for this address
        await _syncBlockchainWallet(_cachedWalletAddress!);
      } else {
        _cachedWalletAddress = null;
        print('ℹ️ WalletService - No wallets found');
      }
      
      _hasInitialized = true;
    } catch (e) {
      print('❌ WalletService - Error initializing wallet data: $e');
      _cachedWalletAddress = null;
      _cachedWalletList = [];
      _lastErrorMessage = e.toString();
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  /// Sync blockchain wallet for a given address
  Future<void> _syncBlockchainWallet(String address) async {
    try {
      print('🔗 WalletService - Syncing blockchain wallet for address: $address');
      
      // Try to load private key from storage
      final loaded = await loadWalletFromStorage();
      
      if (loaded && _blockchainAddress != null) {
        // Check if loaded wallet address matches the backend address
        if (_blockchainAddress!.hex.toLowerCase() == address.toLowerCase()) {
          print('✅ WalletService - Blockchain wallet synced with backend address');
        } else {
          print('⚠️ WalletService - Stored wallet address (${_blockchainAddress!.hex}) does NOT match backend address ($address)');
          print('⚠️ WalletService - Clearing wrong private key. Please retrieve wallet details with PIN to save correct private key.');
          // Clear the wrong private key from storage
          await clearStoredWallet();
          // Initialize with address only for balance checking
          await createWalletWithAddress(address);
        }
      } else {
        // No private key stored, initialize with address only
        print('⚠️ WalletService - No private key found, initializing address-only wallet');
        await createWalletWithAddress(address);
      }
    } catch (e) {
      print('⚠️ WalletService - Failed to sync blockchain wallet: $e');
      // Fallback: create address-only wallet
      try {
        await createWalletWithAddress(address);
      } catch (e2) {
        print('❌ WalletService - Failed to create address-only wallet: $e2');
      }
    }
  }

  /// Get wallet list from API
  Future<List<WalletListItemModel>> _getWalletList() async {
    try {
      print('📋 WalletService - Fetching wallet list...');
      final response = await _walletRepo.getWalletList();
      
      print('🔍 WalletService - API Response received');
      print('🔍 WalletService - Response success: ${response.isSuccess}');
      
      if (response.isSuccess) {
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          if (data['data'] != null && data['data'] is List) {
            final walletList = (data['data'] as List)
                .map((wallet) => WalletListItemModel.fromJson(wallet))
                .toList();
            print('✅ WalletService - Retrieved ${walletList.length} wallets');
            _lastErrorMessage = null;
            return walletList;
          }
        }
      } else {
        print('❌ WalletService - Failed to get wallet list: ${response.message}');
        _lastErrorMessage = response.message;
      }
    } catch (e) {
      print('💥 WalletService - Exception getting wallet list: $e');
      _lastErrorMessage = e.toString();
    }
    return [];
  }

  /// Save private key from backend to secure storage and initialize blockchain wallet
  Future<bool> savePrivateKeyFromBackend(String privateKey, String expectedAddress) async {
    try {
      print('💾 WalletService: Saving private key from backend...');
      
      // Normalize the private key
      String normalizedKey = privateKey.trim();
      if (!normalizedKey.startsWith('0x') && !normalizedKey.startsWith('0X')) {
        normalizedKey = '0x$normalizedKey';
      }
      normalizedKey = normalizedKey.replaceAll(RegExp(r'\s+'), '');
      
      // Validate hex format and length
      final without0x = normalizedKey.substring(2);
      if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(without0x) || without0x.length != 64) {
        print('❌ WalletService: Invalid private key format');
        return false;
      }
      
      // Save to secure storage
      await _secureStorage.write(key: 'wallet_private_key', value: normalizedKey);
      print('✅ WalletService: Private key saved to storage');
      
      // Initialize blockchain wallet with this private key
      await initializeWithPrivateKey(normalizedKey);
      
      // Verify address matches
      if (_blockchainAddress?.hex.toLowerCase() != expectedAddress.toLowerCase()) {
        print('⚠️ WalletService: Private key address (${_blockchainAddress?.hex}) does not match expected ($expectedAddress)');
        // Still return true as we saved it
      } else {
        print('✅ WalletService: Private key address matches backend address perfectly!');
      }
      
      // Update cached address to ensure consistency
      _cachedWalletAddress = _blockchainAddress?.hex ?? expectedAddress;
      
      print('✅ WalletService: Wallet fully initialized with credentials - transactions can now be signed!');
      print('📍 Final address: $_cachedWalletAddress');
      print('🔐 Has credentials: ${_credentials != null}');
      print('🔗 Chain ID: $_chainId');
      
      notifyListeners();
      
      return true;
    } catch (e) {
      print('❌ WalletService: Failed to save private key from backend: $e');
      return false;
    }
  }

  /// Set wallet list directly (used during login)
  void setWalletList(List<WalletListItemModel> wallets) {
    if (_isDisposed) return;
    _cachedWalletList = wallets;
    if (wallets.isNotEmpty) {
      _cachedWalletAddress = wallets.first.address;
      _syncBlockchainWallet(_cachedWalletAddress!);
    }
    print('🔄 WalletService - Wallet list set with ${wallets.length} wallets');
    notifyListeners();
  }

  /// Set a specific wallet as the main wallet
  void setMainWallet(String address) {
    if (_isDisposed) return;
    _cachedWalletAddress = address;
    print('🔄 WalletService - Main wallet updated: ${address.substring(0, 10)}...');
    _syncBlockchainWallet(address);
    notifyListeners();
  }

  /// Add a new wallet to the cache
  void addWallet(WalletListItemModel wallet) {
    if (_isDisposed) return;
    _cachedWalletList.add(wallet);
    if (_cachedWalletAddress == null) {
      _cachedWalletAddress = wallet.address;
      _syncBlockchainWallet(wallet.address);
    }
    print('➕ WalletService - New wallet added: ${wallet.address.substring(0, 10)}...');
    notifyListeners();
  }

  /// Refresh wallet data (call this when user creates a new wallet)
  Future<void> refreshWalletData() async {
    print('🔄 WalletService - Refreshing wallet data...');
    _hasInitialized = false;
    _cachedWalletAddress = null;
    _cachedWalletList = [];
    await initializeWalletData();
  }

  /// Force reinitialize wallet data (for debugging)
  Future<void> forceReinitialize() async {
    print('🔄 WalletService - Force reinitializing wallet data...');
    _hasInitialized = false;
    _cachedWalletAddress = null;
    _cachedWalletList = [];
    _isLoading = false;
    await initializeWalletData();
  }

  /// Get wallet by address
  WalletListItemModel? getWalletByAddress(String address) {
    try {
      return _cachedWalletList.firstWhere(
        (wallet) => wallet.address.toLowerCase() == address.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Clear all cached data (call this on logout)
  void clearWalletData() {
    if (_isDisposed) return;
    print('🗑️ WalletService - Clearing wallet data...');
    _cachedWalletAddress = null;
    _cachedWalletList = [];
    _hasInitialized = false;
    _isLoading = false;
    
    // Clear blockchain state
    _credentials = null;
    _blockchainAddress = null;
    _web3Client = null;
    
    _isDisposed = false;
    notifyListeners();
  }

  @override
  void dispose() {
    print('⚠️ WalletService - Attempted to dispose singleton, ignoring...');
    _isDisposed = true;
    super.dispose();
  }

  // ========== BLOCKCHAIN METHODS ==========

  /// Initialize with existing private key
  Future<void> initializeWithPrivateKey(String privateKey) async {
    try {
      print('🔐 WalletService: Initializing with private key...');

      // Normalize key: trim, strip 0x, remove whitespace
      String cleanPrivateKey = privateKey.trim();
      print('🔐 WalletService: Raw key length: ${cleanPrivateKey.length}');
      print('🔐 WalletService: Raw key starts with 0x: ${cleanPrivateKey.startsWith('0x') || cleanPrivateKey.startsWith('0X')}');
      
      if (cleanPrivateKey.startsWith('0x') || cleanPrivateKey.startsWith('0X')) {
        cleanPrivateKey = cleanPrivateKey.substring(2);
      }
      cleanPrivateKey = cleanPrivateKey.replaceAll(RegExp(r'\s+'), '');
      
      print('🔐 WalletService: Cleaned key length: ${cleanPrivateKey.length}');
      print('🔐 WalletService: Cleaned key (first 10 chars): ${cleanPrivateKey.substring(0, cleanPrivateKey.length > 10 ? 10 : cleanPrivateKey.length)}...');
      
      // Validate hex format and even length (should be 64 hex chars)
      final isHex = RegExp(r'^[0-9a-fA-F]+$').hasMatch(cleanPrivateKey);
      print('🔐 WalletService: Is valid hex: $isHex');
      print('🔐 WalletService: Length is even: ${cleanPrivateKey.length % 2 == 0}');
      print('🔐 WalletService: Length is 64: ${cleanPrivateKey.length == 64}');
      
      if (!isHex || cleanPrivateKey.length % 2 != 0 || cleanPrivateKey.length != 64) {
        print('❌ WalletService: Private key validation failed - isHex: $isHex, length: ${cleanPrivateKey.length}, isEven: ${cleanPrivateKey.length % 2 == 0}');
        throw FormatException('Invalid private key format (must be 64 hex chars, even-length). Got ${cleanPrivateKey.length} chars, isHex: $isHex');
      }

      // Create credentials from private key
      _credentials = EthPrivateKey.fromHex(cleanPrivateKey);
      _blockchainAddress = await _credentials!.extractAddress();

      // Initialize Web3 client
      _web3Client = Web3Client(
        BlockchainConfig.getCurrentRpcUrl(),
        http.Client(),
      );

      print('✅ WalletService: Wallet initialized');
      print('📍 Address: ${_blockchainAddress!.hex}');
      print('🔗 Chain ID: $_chainId');

      notifyListeners();
    } catch (e) {
      print('❌ WalletService: Failed to initialize: $e');
      rethrow;
    }
  }

  /// Create new wallet with private key generation
  Future<Map<String, String>> createNewWallet() async {
    try {
      print('🆕 WalletService: Creating new wallet...');

      // Generate new private key
      final privateKey = EthPrivateKey.createRandom(Random.secure());
      final address = await privateKey.extractAddress();

      // Store private key securely as hex with 0x prefix
      final pkBytes = privateKey.privateKey;
      final pkHex = HEX.encode(pkBytes);
      await _secureStorage.write(
        key: 'wallet_private_key',
        value: '0x$pkHex',
      );

      // Initialize with new credentials
      _credentials = privateKey;
      _blockchainAddress = address;
      _cachedWalletAddress = address.hex;

      // Initialize Web3 client
      _web3Client = Web3Client(
        BlockchainConfig.getCurrentRpcUrl(),
        http.Client(),
      );

      print('✅ WalletService: New wallet created');
      print('📍 Address: ${address.hex}');

      notifyListeners();

      return {
        'address': address.hex,
        'privateKey': '0x$pkHex',
      };
    } catch (e) {
      print('❌ WalletService: Failed to create wallet: $e');
      rethrow;
    }
  }

  /// Create wallet with specific address (for balance checking only)
  Future<void> createWalletWithAddress(String address) async {
    try {
      print('🆕 WalletService: Creating wallet with address: $address');

      _blockchainAddress = EthereumAddress.fromHex(address);

      // Initialize Web3 client for balance checking
      final rpcUrl = BlockchainConfig.getCurrentRpcUrl();
      _web3Client = Web3Client(rpcUrl, http.Client());

      print('✅ WalletService: Wallet created with provided address');
      print('📍 Address: $_blockchainAddress');

      notifyListeners();
    } catch (e) {
      print('❌ WalletService: Failed to create wallet with address: $e');
      rethrow;
    }
  }

  /// Load wallet from secure storage
  Future<bool> loadWalletFromStorage() async {
    try {
      print('📂 WalletService: Loading wallet from storage...');

      var privateKeyHex = await _secureStorage.read(key: 'wallet_private_key');
      if (privateKeyHex == null || privateKeyHex.isEmpty) {
        print('⚠️ WalletService: No wallet found in storage');
        return false;
      }

      print('📂 WalletService: Found stored private key');
      print('📂 WalletService: Private key length: ${privateKeyHex.length}');
      
      // Check if stored as JSON array (incorrect format)
      String normalizedKey;
      bool needsSave = false;
      
      if (privateKeyHex.trim().startsWith('[')) {
        print('⚠️ WalletService: Private key stored as JSON array, converting...');
        try {
          final decoded = jsonDecode(privateKeyHex) as List;
          print('📂 WalletService: Array has ${decoded.length} elements');
          
          List<int> intList = [];
          for (var element in decoded) {
            if (element is int) {
              intList.add(element);
            } else if (element is String) {
              int? parsed = int.tryParse(element, radix: 16) ?? int.tryParse(element);
              if (parsed == null) {
                print('❌ WalletService: Invalid array element: $element');
                return false;
              }
              intList.add(parsed);
            } else {
              print('❌ WalletService: Invalid array element type: ${element.runtimeType}');
              return false;
            }
          }
          
          final bytes = Uint8List.fromList(intList);
          print('📂 WalletService: Converted to ${bytes.length} bytes');
          
          Uint8List finalBytes;
          if (bytes.length == 33) {
            finalBytes = bytes.sublist(0, 32);
          } else if (bytes.length == 64) {
            finalBytes = bytes.sublist(0, 32);
          } else if (bytes.length != 32) {
            print('❌ WalletService: Invalid byte length: ${bytes.length}');
            return false;
          } else {
            finalBytes = bytes;
          }
          
          normalizedKey = '0x${HEX.encode(finalBytes)}';
          needsSave = true;
        } catch (e) {
          print('❌ WalletService: Failed to parse JSON array: $e');
          return false;
        }
      } else {
        normalizedKey = privateKeyHex.trim();
        if (!normalizedKey.startsWith('0x') && !normalizedKey.startsWith('0X')) {
          normalizedKey = '0x$normalizedKey';
          needsSave = true;
        }
        normalizedKey = normalizedKey.replaceAll(RegExp(r'\s+'), '');
        
        final without0x = normalizedKey.substring(2);
        if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(without0x) || without0x.length != 64) {
          print('❌ WalletService: Invalid hex format or length');
          return false;
        }
      }
      
      // Save corrected format if needed
      if (needsSave) {
        try {
          await _secureStorage.write(key: 'wallet_private_key', value: normalizedKey);
          print('✅ WalletService: Corrected format saved');
        } catch (e) {
          print('⚠️ WalletService: Failed to save corrected format: $e');
        }
      }

      // Initialize with the normalized key
      await initializeWithPrivateKey(normalizedKey);
      
      print('✅ WalletService: Wallet loaded and initialized successfully');
      print('📍 Final wallet address: ${_blockchainAddress?.hex}');
      
      // Sync with cached address if available
      if (_cachedWalletAddress != null && _blockchainAddress != null) {
        if (_cachedWalletAddress!.toLowerCase() != _blockchainAddress!.hex.toLowerCase()) {
          print('⚠️ WalletService: Cached address ($_cachedWalletAddress) differs from blockchain address (${_blockchainAddress!.hex})');
        }
      }
      
      return true;
    } catch (e, stackTrace) {
      print('❌ WalletService: Failed to load wallet: $e');
      print('📂 Stack trace: $stackTrace');
      return false;
    }
  }

  /// Get balance for address (with fallback)
  Future<String> getBalance(String address) async {
    try {
      // Try to use credentials if available
      if (_web3Client != null && _credentials != null) {
        try {
          final targetAddress = EthereumAddress.fromHex(address);
          final balance = await _web3Client!.getBalance(targetAddress);
          final hexBalance = '0x${balance.getInWei.toRadixString(16)}';
          print('💰 WalletService: Balance retrieved: $hexBalance');
          return hexBalance;
        } catch (e) {
          print('⚠️ WalletService: getBalance with credentials failed: $e');
        }
      }
      
      // Fallback: Use address-only balance check
      if (_web3Client != null) {
        try {
          final addressObj = EthereumAddress.fromHex(address);
          final balance = await _web3Client!.getBalance(addressObj);
          final hexBalance = '0x${balance.getInWei.toRadixString(16)}';
          print('💰 WalletService: Balance retrieved (address-only): $hexBalance');
          return hexBalance;
        } catch (e) {
          print('❌ WalletService: getBalance failed: $e');
        }
      }
      
      print('❌ WalletService: No Web3 client available');
      return '0x0';
    } catch (e) {
      print('❌ WalletService: getBalance exception: $e');
      return '0x0';
    }
  }

  /// Send transaction
  Future<String> sendTransaction({
    required String to,
    required String value,
    String? data,
    String? gasLimit,
    String? gasPrice,
  }) async {
    if (_web3Client == null || _credentials == null) {
      throw Exception('Wallet not initialized');
    }

    try {
      print('📤 WalletService: Sending transaction...');
      
      final toAddress = EthereumAddress.fromHex(to);
      final valueWei = EtherAmount.fromBigInt(
        EtherUnit.wei,
        BigInt.parse(value.startsWith('0x') ? value.substring(2) : value, radix: 16),
      );

      final gasPriceWei = gasPrice != null
          ? EtherAmount.fromBigInt(
              EtherUnit.wei,
              BigInt.parse(gasPrice.startsWith('0x') ? gasPrice.substring(2) : gasPrice, radix: 16),
            )
          : await _web3Client!.getGasPrice();

      final gasLimitBigInt = gasLimit != null
          ? BigInt.parse(gasLimit.startsWith('0x') ? gasLimit.substring(2) : gasLimit, radix: 16)
          : BigInt.from(21000);

      final transaction = Transaction(
        to: toAddress,
        value: valueWei,
        gasPrice: gasPriceWei,
        maxGas: gasLimitBigInt.toInt(),
        data: data != null ? Uint8List.fromList(HexDecoder().convert(data.startsWith('0x') ? data.substring(2) : data)) : null,
      );

      final txHash = await _web3Client!.sendTransaction(_credentials!, transaction, chainId: _chainId);

      print('✅ WalletService: Transaction sent successfully');
      print('🔗 Transaction Hash: $txHash');

      return txHash;
    } catch (e) {
      print('❌ WalletService: Failed to send transaction: $e');
      rethrow;
    }
  }

  /// Sign message
  Future<String> signMessage(String message) async {
    if (_credentials == null) {
      throw Exception('Wallet not initialized');
    }

    try {
      print('✍️ WalletService: Signing message...');
      
      final messageBytes = utf8.encode(message);
      final messageHash = Uint8List.fromList(sha256.convert(Uint8List.fromList([
        ...utf8.encode('\x19Ethereum Signed Message:\n${messageBytes.length}'),
        ...messageBytes,
      ])).bytes);

      final signature = await _credentials!.signPersonalMessage(messageHash);
      final signatureHex = '0x${signature.map((b) => b.toRadixString(16).padLeft(2, '0')).join('')}';

      print('✅ WalletService: Message signed successfully');
      return signatureHex;
    } catch (e) {
      print('❌ WalletService: Failed to sign message: $e');
      rethrow;
    }
  }

  /// Sign typed data (EIP-712)
  Future<String> signTypedData(String typedDataJson) async {
    if (_credentials == null) {
      throw Exception('Wallet not initialized');
    }

    try {
      print('📝 WalletService: Signing typed data...');
      
      final messageHash = Uint8List.fromList(sha256.convert(utf8.encode(typedDataJson)).bytes);
      final signature = await _credentials!.signPersonalMessage(messageHash);
      final signatureHex = '0x${signature.map((b) => b.toRadixString(16).padLeft(2, '0')).join('')}';

      print('✅ WalletService: Typed data signed successfully');
      return signatureHex;
    } catch (e) {
      print('❌ WalletService: Failed to sign typed data: $e');
      rethrow;
    }
  }

  /// Switch chain
  Future<void> switchChain(int newChainId) async {
    try {
      print('🔄 WalletService: Switching chain to $newChainId...');
      _chainId = newChainId;

      String rpcUrl;
      switch (newChainId) {
        case 1:
          rpcUrl = BlockchainConfig.getRpcUrl(ChainType.ethereum, WalletNetworkType.mainnet);
          break;
        case 137:
          rpcUrl = BlockchainConfig.getRpcUrl(ChainType.polygon, WalletNetworkType.mainnet);
          break;
        case 56:
          rpcUrl = BlockchainConfig.getRpcUrl(ChainType.bsc, WalletNetworkType.mainnet);
          break;
        default:
          rpcUrl = BlockchainConfig.getCurrentRpcUrl();
      }

      _web3Client = Web3Client(rpcUrl, http.Client());
      print('✅ WalletService: Chain switched to $newChainId');
      
      notifyListeners();
    } catch (e) {
      print('❌ WalletService: Failed to switch chain: $e');
      rethrow;
    }
  }

  /// Get transaction receipt
  Future<TransactionReceipt?> getTransactionReceipt(String txHash) async {
    if (_web3Client == null) {
      throw Exception('Wallet not initialized');
    }

    try {
      print('📋 WalletService: Getting transaction receipt for $txHash...');
      final receipt = await _web3Client!.getTransactionReceipt(txHash);
      
      if (receipt != null) {
        print('✅ WalletService: Transaction confirmed');
      } else {
        print('⏳ WalletService: Transaction pending...');
      }

      return receipt;
    } catch (e) {
      print('❌ WalletService: Failed to get transaction receipt: $e');
      return null;
    }
  }

  /// Clear stored wallet
  Future<void> clearStoredWallet() async {
    try {
      print('🗑️ WalletService: Clearing stored wallet...');
      await _secureStorage.delete(key: 'wallet_private_key');
      _credentials = null;
      _blockchainAddress = null;
      _web3Client = null;
      print('✅ WalletService: Stored wallet cleared');
      notifyListeners();
    } catch (e) {
      print('❌ WalletService: Failed to clear stored wallet: $e');
    }
  }
}

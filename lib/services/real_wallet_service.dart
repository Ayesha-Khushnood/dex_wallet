import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:web3dart/web3dart.dart';
import 'package:crypto/crypto.dart';
import 'package:hex/hex.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/blockchain_config.dart';

/// Real Wallet Service - Handles actual blockchain transactions
class RealWalletService {
  static final RealWalletService _instance = RealWalletService._internal();
  factory RealWalletService() => _instance;
  RealWalletService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Web3Client? _web3Client;
  Credentials? _credentials;
  EthereumAddress? _address;
  int _chainId = 1; // Ethereum mainnet

  // Getters
  bool get isConnected => _credentials != null && _address != null;
  String? get walletAddress => _address?.hex;
  int get chainId => _chainId;
  Web3Client? get web3Client => _web3Client;

  /// Initialize with existing private key
  Future<void> initializeWithPrivateKey(String privateKey) async {
    try {
      print('🔐 RealWalletService: Initializing with private key...');

      // Normalize key: trim, strip 0x, remove whitespace
      String cleanPrivateKey = privateKey.trim();
      if (cleanPrivateKey.startsWith('0x') || cleanPrivateKey.startsWith('0X')) {
        cleanPrivateKey = cleanPrivateKey.substring(2);
      }
      cleanPrivateKey = cleanPrivateKey.replaceAll(RegExp(r'\s+'), '');

      // Validate hex format and even length (should be 64 hex chars)
      final isHex = RegExp(r'^[0-9a-fA-F]+$').hasMatch(cleanPrivateKey);
      if (!isHex || cleanPrivateKey.length % 2 != 0 || cleanPrivateKey.length != 64) {
        throw const FormatException('Invalid private key format (must be 64 hex chars, even-length)');
      }

      // Create credentials from private key
      _credentials = EthPrivateKey.fromHex(cleanPrivateKey);
      _address = await _credentials!.extractAddress();

      // Initialize Web3 client
      _web3Client = Web3Client(
        BlockchainConfig.getCurrentRpcUrl(),
        http.Client(),
      );

      print('✅ RealWalletService: Wallet initialized');
      print('📍 Address: ${_address!.hex}');
      print('🔗 Chain ID: $_chainId');

    } catch (e) {
      print('❌ RealWalletService: Failed to initialize: $e');
      rethrow;
    }
  }

  /// Create new wallet with private key generation
  Future<Map<String, String>> createNewWallet() async {
    try {
      print('🆕 RealWalletService: Creating new wallet...');

      // Generate new private key
      final privateKey = EthPrivateKey.createRandom(Random.secure());
      final address = await privateKey.extractAddress();

      // Store private key securely as hex with 0x prefix
      final pkBytes = privateKey.privateKey; // Uint8List
      final pkHex = HEX.encode(pkBytes);
      await _secureStorage.write(
        key: 'wallet_private_key',
        value: '0x$pkHex',
      );

      // Initialize with new credentials
      _credentials = privateKey;
      _address = address;

      // Initialize Web3 client
      _web3Client = Web3Client(
        BlockchainConfig.getCurrentRpcUrl(),
        http.Client(),
      );

      print('✅ RealWalletService: New wallet created');
      print('📍 Address: ${address.hex}');

      return {
        'address': address.hex,
        'privateKey': '0x$pkHex',
      };

    } catch (e) {
      print('❌ RealWalletService: Failed to create wallet: $e');
      rethrow;
    }
  }

  /// Create wallet with specific address (for Web3ProviderService)
  Future<void> createWalletWithAddress(String address) async {
    try {
      print('🆕 RealWalletService: Creating wallet with address: $address');

      // Set the address directly (this is for balance checking only)
      _address = EthereumAddress.fromHex(address);
      // Note: _isConnected is a getter that returns _credentials != null && _address != null
      // Since we're only setting _address, isConnected will return false
      // This is fine for balance checking purposes

      // Initialize Web3 client for balance checking
      final rpcUrl = BlockchainConfig.getCurrentRpcUrl();
      print('🔗 RealWalletService: Using RPC URL: $rpcUrl');
      print('🔗 RealWalletService: Network Type: ${BlockchainConfig.networkType}');
      print('🔗 RealWalletService: Chain Type: ${BlockchainConfig.chainType}');
      print('🔗 RealWalletService: Chain ID: ${BlockchainConfig.getCurrentChainId()}');

      _web3Client = Web3Client(
        rpcUrl,
        http.Client(),
      );

      print('✅ RealWalletService: Wallet created with provided address');
      print('📍 Address: $_address');

    } catch (e) {
      print('❌ RealWalletService: Failed to create wallet with address: $e');
      rethrow;
    }
  }

  /// Save private key to secure storage (from backend)
  Future<bool> savePrivateKeyToStorage(String privateKey) async {
    try {
      print('💾 RealWalletService: Saving private key to storage...');
      
      // Normalize the private key first
      String normalizedKey = privateKey.trim();
      
      // Ensure it has 0x prefix
      if (!normalizedKey.startsWith('0x') && !normalizedKey.startsWith('0X')) {
        normalizedKey = '0x$normalizedKey';
      }
      
      // Remove any whitespace
      normalizedKey = normalizedKey.replaceAll(RegExp(r'\s+'), '');
      
      // Validate hex format and length
      final without0x = normalizedKey.substring(2);
      if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(without0x)) {
        print('❌ RealWalletService: Invalid hex format in private key');
        return false;
      }
      
      if (without0x.length != 64) {
        print('❌ RealWalletService: Invalid private key length: ${without0x.length} (expected 64)');
        return false;
      }
      
      // Save to secure storage
      await _secureStorage.write(key: 'wallet_private_key', value: normalizedKey);
      print('✅ RealWalletService: Private key saved to storage successfully');
      
      return true;
    } catch (e) {
      print('❌ RealWalletService: Failed to save private key: $e');
      return false;
    }
  }

  /// Load wallet from secure storage
  Future<bool> loadWalletFromStorage() async {
    try {
      print('📂 RealWalletService: Loading wallet from storage...');

      var privateKeyHex = await _secureStorage.read(key: 'wallet_private_key');
      if (privateKeyHex == null || privateKeyHex.isEmpty) {
        print('⚠️ RealWalletService: No wallet found in storage (null or empty)');
        return false;
      }

      // Log private key info for debugging (but don't log the actual key)
      print('📂 RealWalletService: Found stored private key');
      print('📂 RealWalletService: Private key length: ${privateKeyHex.length}');
      print('📂 RealWalletService: Private key starts with 0x: ${privateKeyHex.startsWith('0x')}');
      print('📂 RealWalletService: Private key starts with [: ${privateKeyHex.trim().startsWith('[')}');
      
      // Check if stored as JSON array (incorrect format)
      String normalizedKey;
      bool needsSave = false; // Track if we need to save the corrected format
      
      if (privateKeyHex.trim().startsWith('[')) {
        print('⚠️ RealWalletService: Private key stored as JSON array, converting...');
        try {
          // Try to parse as JSON array
          final decoded = jsonDecode(privateKeyHex) as List;
          print('📂 RealWalletService: Array has ${decoded.length} elements');
          
          // Validate and convert array elements to integers
          List<int> intList = [];
          for (var element in decoded) {
            if (element is int) {
              intList.add(element);
            } else if (element is String) {
              // Try to parse as hex or decimal
              int? parsed = int.tryParse(element, radix: 16) ?? int.tryParse(element);
              if (parsed == null) {
                print('❌ RealWalletService: Invalid array element: $element');
                return false;
              }
              intList.add(parsed);
            } else {
              print('❌ RealWalletService: Invalid array element type: ${element.runtimeType}');
              return false;
            }
          }
          
          // Convert array to Uint8List, then to hex
          final bytes = Uint8List.fromList(intList);
          print('📂 RealWalletService: Converted to ${bytes.length} bytes (should be 32)');
          
          // Handle different byte lengths
          Uint8List finalBytes;
          if (bytes.length == 33) {
            print('⚠️ RealWalletService: Array has 33 bytes, taking first 32');
            finalBytes = bytes.sublist(0, 32);
          } else if (bytes.length == 64) {
            // Sometimes stored as 64 byte array (uncompressed)
            print('⚠️ RealWalletService: Array has 64 bytes, taking first 32');
            finalBytes = bytes.sublist(0, 32);
          } else if (bytes.length != 32) {
            print('❌ RealWalletService: Invalid byte length: ${bytes.length} (expected 32, 33, or 64)');
            print('📂 RealWalletService: First few bytes: ${bytes.sublist(0, bytes.length > 10 ? 10 : bytes.length)}');
            return false;
          } else {
            finalBytes = bytes;
          }
          
          normalizedKey = '0x${HEX.encode(finalBytes)}';
          print('✅ RealWalletService: Converted array format to hex: ${normalizedKey.length} chars (${normalizedKey.length - 2} hex digits)');
          
          // Mark that we need to save the corrected format
          needsSave = true;
        } catch (e) {
          print('❌ RealWalletService: Failed to parse JSON array format: $e');
          print('📂 RealWalletService: Raw key preview: ${privateKeyHex.substring(0, privateKeyHex.length > 50 ? 50 : privateKeyHex.length)}...');
          return false;
        }
      } else {
        // Already in hex format, but normalize it
        normalizedKey = privateKeyHex.trim();
        
        // Ensure it has 0x prefix
        if (!normalizedKey.startsWith('0x') && !normalizedKey.startsWith('0X')) {
          normalizedKey = '0x$normalizedKey';
          needsSave = true; // Save normalized version
        }
        
        // Remove any whitespace
        normalizedKey = normalizedKey.replaceAll(RegExp(r'\s+'), '');
        
        // Validate hex format
        final without0x = normalizedKey.substring(2);
        if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(without0x)) {
          print('❌ RealWalletService: Stored private key contains invalid hex characters');
          print('📂 RealWalletService: Key preview: ${normalizedKey.substring(0, normalizedKey.length > 10 ? 10 : normalizedKey.length)}...');
          return false;
        }
        
        // Check length (should be 66 chars with 0x = 64 hex digits)
        if (without0x.length != 64) {
          print('❌ RealWalletService: Invalid hex length: ${without0x.length} (expected 64)');
          print('📂 RealWalletService: Key preview: ${normalizedKey.substring(0, normalizedKey.length > 10 ? 10 : normalizedKey.length)}...');
          return false;
        }
      }
      
      // Validate final format before initializing
      final cleanKey = normalizedKey.trim().replaceAll(RegExp(r'\s+'), '');
      final without0x = cleanKey.substring(2);
      
      if (without0x.length != 64) {
        print('❌ RealWalletService: Final key has wrong length: ${without0x.length} (expected 64)');
        return false;
      }
      
      if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(without0x)) {
        print('❌ RealWalletService: Final key contains invalid hex characters');
        return false;
      }
      
      // Save the corrected/normalized format back to storage if needed
      if (needsSave) {
        print('💾 RealWalletService: Saving corrected private key format to storage...');
        try {
          await _secureStorage.write(key: 'wallet_private_key', value: normalizedKey);
          print('✅ RealWalletService: Corrected format saved successfully');
        } catch (e) {
          print('⚠️ RealWalletService: Failed to save corrected format (non-fatal): $e');
          // Continue anyway - the normalized key is in memory
        }
      }

      // Initialize with the normalized key
      print('🔐 RealWalletService: Initializing with normalized private key...');
      await initializeWithPrivateKey(normalizedKey);
      
      print('✅ RealWalletService: Wallet loaded and initialized successfully');
      print('📍 Final wallet address: ${_address?.hex}');
      
      return true;

    } catch (e, stackTrace) {
      print('❌ RealWalletService: Failed to load wallet: $e');
      print('📂 Stack trace: $stackTrace');
      return false;
    }
  }

  /// Get real balance from blockchain
  Future<String> getRealBalance([String? address]) async {
    if (_web3Client == null || _credentials == null) {
      throw Exception('Wallet not initialized');
    }

    try {
      final targetAddress = address != null
          ? EthereumAddress.fromHex(address)
          : _address!;

      final balance = await _web3Client!.getBalance(targetAddress);
      final balanceInWei = balance.getInWei;

      print('💰 RealWalletService: Balance: ${balanceInWei} wei');
      return '0x${balanceInWei.toRadixString(16)}';

    } catch (e) {
      print('❌ RealWalletService: Failed to get balance: $e');
      rethrow;
    }
  }

  /// Send real transaction
  Future<String> sendRealTransaction({
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
      print('📤 RealWalletService: Sending real transaction...');
      print('📤 To: $to');
      print('📤 Value: $value');

      // Parse transaction parameters
      final toAddress = EthereumAddress.fromHex(to);
      final valueWei = EtherAmount.fromBigInt(
          EtherUnit.wei,
          BigInt.parse(value.startsWith('0x') ? value.substring(2) : value, radix: 16)
      );

      // Get gas price from network
      final gasPriceWei = gasPrice != null
          ? EtherAmount.fromBigInt(
          EtherUnit.wei,
          BigInt.parse(gasPrice.startsWith('0x') ? gasPrice.substring(2) : gasPrice, radix: 16)
      )
          : await _web3Client!.getGasPrice();

      // Estimate gas limit
      final gasLimitBigInt = gasLimit != null
          ? BigInt.parse(gasLimit.startsWith('0x') ? gasLimit.substring(2) : gasLimit, radix: 16)
          : BigInt.from(21000); // Default gas limit

      // Create transaction
      final transaction = Transaction(
        to: toAddress,
        value: valueWei,
        gasPrice: gasPriceWei,
        maxGas: gasLimitBigInt.toInt(),
        data: data != null ? Uint8List.fromList(HexDecoder().convert(data.startsWith('0x') ? data.substring(2) : data)) : null,
      );

      // Send transaction
      final txHash = await _web3Client!.sendTransaction(
        _credentials!,
        transaction,
        chainId: _chainId,
      );

      print('✅ RealWalletService: Transaction sent successfully');
      print('🔗 Transaction Hash: $txHash');

      return txHash;

    } catch (e) {
      print('❌ RealWalletService: Failed to send transaction: $e');
      rethrow;
    }
  }

  /// Sign real message
  Future<String> signRealMessage(String message) async {
    if (_credentials == null) {
      throw Exception('Wallet not initialized');
    }

    try {
      print('✍️ RealWalletService: Signing message...');
      print('✍️ Message: $message');

      // Convert message to bytes
      final messageBytes = utf8.encode(message);

      // Create Ethereum message hash
      final messageHash = Uint8List.fromList(sha256.convert(Uint8List.fromList([
        ...utf8.encode('\x19Ethereum Signed Message:\n${messageBytes.length}'),
        ...messageBytes,
      ])).bytes);

      // Sign the hash
      final signature = await _credentials!.signPersonalMessage(messageHash);
      final signatureHex = '0x${signature.map((b) => b.toRadixString(16).padLeft(2, '0')).join('')}';

      print('✅ RealWalletService: Message signed successfully');
      print('🔐 Signature: $signatureHex');

      return signatureHex;

    } catch (e) {
      print('❌ RealWalletService: Failed to sign message: $e');
      rethrow;
    }
  }

  /// Sign typed data (EIP-712)
  Future<String> signTypedData(String typedDataJson) async {
    if (_credentials == null) {
      throw Exception('Wallet not initialized');
    }

    try {
      print('📝 RealWalletService: Signing typed data...');

      // Parse typed data (for future EIP-712 implementation)
      // final typedData = json.decode(typedDataJson);

      // Sign typed data (simplified implementation)
      final messageHash = Uint8List.fromList(sha256.convert(utf8.encode(typedDataJson)).bytes);
      final signature = await _credentials!.signPersonalMessage(messageHash);
      final signatureHex = '0x${signature.map((b) => b.toRadixString(16).padLeft(2, '0')).join('')}';

      print('✅ RealWalletService: Typed data signed successfully');
      print('🔐 Signature: $signatureHex');

      return signatureHex;

    } catch (e) {
      print('❌ RealWalletService: Failed to sign typed data: $e');
      rethrow;
    }
  }

  /// Switch chain
  Future<void> switchChain(int newChainId) async {
    try {
      print('🔄 RealWalletService: Switching chain to $newChainId...');

      _chainId = newChainId;

      // Update Web3 client for different chain
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

      print('✅ RealWalletService: Chain switched to $newChainId');

    } catch (e) {
      print('❌ RealWalletService: Failed to switch chain: $e');
      rethrow;
    }
  }

  /// Get transaction receipt
  Future<TransactionReceipt?> getTransactionReceipt(String txHash) async {
    if (_web3Client == null) {
      throw Exception('Wallet not initialized');
    }

    try {
      print('📋 RealWalletService: Getting transaction receipt for $txHash...');

      final receipt = await _web3Client!.getTransactionReceipt(txHash);

      if (receipt != null) {
        print('✅ RealWalletService: Transaction confirmed');
        print('📊 Block Number: ${receipt.blockNumber}');
        print('⛽ Gas Used: ${receipt.gasUsed}');
      } else {
        print('⏳ RealWalletService: Transaction pending...');
      }

      return receipt;

    } catch (e) {
      print('❌ RealWalletService: Failed to get transaction receipt: $e');
      return null;
    }
  }

  /// Disconnect wallet
  Future<void> disconnect() async {
    try {
      print('🔌 RealWalletService: Disconnecting wallet...');

      _credentials = null;
      _address = null;
      _web3Client = null;

      print('✅ RealWalletService: Wallet disconnected');

    } catch (e) {
      print('❌ RealWalletService: Failed to disconnect: $e');
    }
  }

  /// Clear stored wallet
  Future<void> clearStoredWallet() async {
    try {
      print('🗑️ RealWalletService: Clearing stored wallet...');

      await _secureStorage.delete(key: 'wallet_private_key');

      _credentials = null;
      _address = null;
      _web3Client = null;

      print('✅ RealWalletService: Stored wallet cleared');

    } catch (e) {
      print('❌ RealWalletService: Failed to clear stored wallet: $e');
    }
  }

  /// Get balance for a specific address (for address-only wallets)
  Future<String> getBalanceForAddress(String address) async {
    try {
      print('🔍 RealWalletService: Getting balance for address: $address');

      if (_web3Client == null) {
        throw Exception('Web3 client not initialized');
      }

      final addressObj = EthereumAddress.fromHex(address);
      final balance = await _web3Client!.getBalance(addressObj);

      // Convert to hex string
      final hexBalance = '0x${balance.getInWei.toRadixString(16)}';

      print('✅ RealWalletService: Balance for $address: $hexBalance');
      return hexBalance;

    } catch (e) {
      print('❌ RealWalletService: Failed to get balance for address: $e');
      rethrow;
    }
  }
}

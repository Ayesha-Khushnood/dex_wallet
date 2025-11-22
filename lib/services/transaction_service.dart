import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:convert/convert.dart' as hex;
import '../config/blockchain_config.dart';

class TransactionService {
  static final TransactionService _instance = TransactionService._internal();
  factory TransactionService() => _instance;
  TransactionService._internal();

  Web3Client? _web3Client;

  /// Get Infura RPC URL for current network
  String _getInfuraUrl() {
    return BlockchainConfig.getCurrentRpcUrl();
  }

  /// Initialize Web3 client for a specific network
  void initializeClient(String rpcUrl) {
    _web3Client = Web3Client(rpcUrl, http.Client());
  }

  /// Get current gas price
  Future<BigInt> getGasPrice() async {
    if (_web3Client == null) {
      throw Exception('Web3 client not initialized');
    }

    try {
      print('🔍 TransactionService - Fetching gas price from network...');
      final gasPrice = await _web3Client!.getGasPrice();
      print('🔍 TransactionService - Raw gas price from network: ${gasPrice.getInWei}');
      
      // Ensure we have a valid gas price
      if (gasPrice.getInWei == BigInt.zero) {
        print('⚠️ TransactionService - Gas price is zero, using fallback');
        return EtherAmount.fromBigInt(EtherUnit.gwei, BigInt.from(20)).getInWei;
      }
      
      return gasPrice.getInWei;
    } catch (e) {
      print('❌ Error getting gas price: $e');
      // Return a default gas price if API fails
      final fallbackGasPrice = EtherAmount.fromBigInt(EtherUnit.gwei, BigInt.from(20)).getInWei;
      print('🔍 TransactionService - Using fallback gas price: $fallbackGasPrice');
      return fallbackGasPrice;
    }
  }

  /// Estimate gas limit for a transaction
  Future<int> estimateGas({
    required String from,
    required String to,
    required EtherAmount value,
    String? data,
  }) async {
    if (_web3Client == null) {
      throw Exception('Web3 client not initialized');
    }

    try {
      print('🔍 TransactionService - Estimating gas for transaction...');
      print('🔍 TransactionService - From: $from');
      print('🔍 TransactionService - To: $to');
      print('🔍 TransactionService - Value: ${value.getInEther} ETH');
      
      final fromAddress = EthereumAddress.fromHex(from);
      final toAddress = EthereumAddress.fromHex(to);

      final gasEstimate = await _web3Client!.estimateGas(
        sender: fromAddress,
        to: toAddress,
        value: value,
        data: data != null ? Uint8List.fromList(hex.hex.decode(data)) : null,
      );

      print('🔍 TransactionService - Raw gas estimate: $gasEstimate');

      // Add 20% buffer to gas estimate
      final gasWithBuffer = (gasEstimate * BigInt.from(120) ~/ BigInt.from(100)).toInt();
      print('🔍 TransactionService - Gas with buffer: $gasWithBuffer');
      
      return gasWithBuffer;
    } catch (e) {
      print('❌ Error estimating gas: $e');
      // Return a default gas limit if estimation fails
      print('🔍 TransactionService - Using fallback gas limit: 21000');
      return 21000; // Standard ETH transfer gas limit
    }
  }

  /// Sign a transaction
  Future<String> signTransaction({
    required String privateKey,
    required String to,
    required EtherAmount value,
    required BigInt gasPrice,
    required int gasLimit,
    String? data,
    int? nonce,
    int? chainId,
  }) async {
    try {
      print('🔍 TransactionService - Starting transaction signing...');
      print('🔍 TransactionService - Private key length: ${privateKey.length}');
      print('🔍 TransactionService - Private key starts with 0x: ${privateKey.startsWith('0x')}');
      print('🔍 TransactionService - To address: $to');
      print('🔍 TransactionService - Value: ${value.getInEther} ETH');
      print('🔍 TransactionService - Gas price: $gasPrice');
      print('🔍 TransactionService - Gas limit: $gasLimit');
      
      // Clean private key (remove 0x prefix if present)
      String cleanPrivateKey = privateKey;
      if (cleanPrivateKey.startsWith('0x')) {
        cleanPrivateKey = cleanPrivateKey.substring(2);
      }
      
      print('🔍 TransactionService - Clean private key length: ${cleanPrivateKey.length}');
      
      final credentials = EthPrivateKey.fromHex(cleanPrivateKey);
      final toAddress = EthereumAddress.fromHex(to);
      
      print('🔍 TransactionService - Credentials address: ${credentials.address.hex}');

      // Get nonce if not provided
      final txNonce = nonce ?? await _web3Client!.getTransactionCount(credentials.address);
      print('🔍 TransactionService - Transaction nonce: $txNonce');
      print('🔍 TransactionService - Chain ID: $chainId');

      final transaction = Transaction(
        to: toAddress,
        value: value,
        gasPrice: EtherAmount.fromBigInt(EtherUnit.wei, gasPrice),
        maxGas: gasLimit,
        nonce: txNonce,
        data: data != null ? Uint8List.fromList(hex.hex.decode(data)) : null,
      );

      print('🔍 TransactionService - Transaction object created, signing...');
      
      // Try to sign with explicit chain ID if provided
      final signedTx = chainId != null 
          ? await _web3Client!.signTransaction(credentials, transaction, chainId: chainId)
          : await _web3Client!.signTransaction(credentials, transaction);
      
      print('✅ TransactionService - Transaction signed successfully');
      
      return hex.hex.encode(signedTx);
    } catch (e) {
      print('❌ Error signing transaction: $e');
      print('❌ Error stack trace: ${StackTrace.current}');
      throw Exception('Failed to sign transaction: $e');
    }
  }

  /// Send raw transaction
  Future<String> sendRawTransaction(String signedTransaction) async {
    if (_web3Client == null) {
      throw Exception('Web3 client not initialized');
    }

    try {
      final txHash = await _web3Client!.sendRawTransaction(Uint8List.fromList(hex.hex.decode(signedTransaction)));
      return txHash;
    } catch (e) {
      print('❌ Error sending transaction: $e');
      throw Exception('Failed to send transaction: $e');
    }
  }

  /// Get current gas price in Gwei
  Future<double> getCurrentGasPrice() async {
    try {
      final gasPrice = await getGasPrice();
      // Convert Wei to Gwei
      final gwei = gasPrice ~/ BigInt.from(1000000000);
      return gwei.toDouble();
    } catch (e) {
      print('❌ Error getting current gas price: $e');
      return 20.0; // Default gas price in Gwei
    }
  }

  /// Calculate transaction fee in native currency
  Future<EtherAmount> calculateTransactionFee({
    required BigInt gasPrice,
    required int gasLimit,
  }) async {
    final feeInWei = gasPrice * BigInt.from(gasLimit);
    return EtherAmount.fromBigInt(EtherUnit.wei, feeInWei);
  }

  /// Get transaction receipt
  Future<TransactionReceipt?> getTransactionReceipt(String txHash) async {
    if (_web3Client == null) {
      throw Exception('Web3 client not initialized');
    }

    try {
      return await _web3Client!.getTransactionReceipt(txHash);
    } catch (e) {
      print('❌ Error getting transaction receipt: $e');
      return null;
    }
  }

  /// Wait for transaction confirmation
  Future<TransactionReceipt?> waitForTransactionConfirmation(
    String txHash, {
    int maxAttempts = 30,
    Duration interval = const Duration(seconds: 2),
  }) async {
    for (int i = 0; i < maxAttempts; i++) {
      final receipt = await getTransactionReceipt(txHash);
      if (receipt != null) {
        return receipt;
      }
      await Future.delayed(interval);
    }
    return null;
  }

  /// Get account balance
  Future<EtherAmount> getBalance(String address) async {
    if (_web3Client == null) {
      throw Exception('Web3 client not initialized');
    }

    try {
      final ethAddress = EthereumAddress.fromHex(address);
      return await _web3Client!.getBalance(ethAddress);
    } catch (e) {
      print('❌ Error getting balance: $e');
      throw Exception('Failed to get balance: $e');
    }
  }

  /// Get transaction count (nonce)
  Future<int> getTransactionCount(String address) async {
    if (_web3Client == null) {
      throw Exception('Web3 client not initialized');
    }

    try {
      final ethAddress = EthereumAddress.fromHex(address);
      return await _web3Client!.getTransactionCount(ethAddress);
    } catch (e) {
      print('❌ Error getting transaction count: $e');
      throw Exception('Failed to get transaction count: $e');
    }
  }

  /// Get transaction history for an address
  Future<List<Map<String, dynamic>>> getTransactionHistory(String address, {int limit = 20}) async {
    try {
      print('🔍 TransactionService - Fetching transaction history for: $address');
      
      // Try to get real transaction history using multiple approaches
      
      // Approach 1: Try with Etherscan API (without API key first)
      final transactions = await _fetchFromEtherscan(address, limit);
      if (transactions.isNotEmpty) {
        print('✅ TransactionService - Found ${transactions.length} real transactions from Etherscan');
        return transactions;
      }
      
      // Approach 2: Try with Alchemy API (if available)
      final alchemyTransactions = await _fetchFromAlchemy(address, limit);
      if (alchemyTransactions.isNotEmpty) {
        print('✅ TransactionService - Found ${alchemyTransactions.length} real transactions from Alchemy');
        return alchemyTransactions;
      }
      
      // Approach 3: Try with Infura API
      final infuraTransactions = await _fetchFromInfura(address, limit);
      if (infuraTransactions.isNotEmpty) {
        print('✅ TransactionService - Found ${infuraTransactions.length} real transactions from Infura');
        return infuraTransactions;
      }
      
      // If all APIs fail, return empty list
      print('⚠️ TransactionService - No real transaction history available from any API');
      return [];
      
    } catch (e) {
      print('❌ Error fetching transaction history: $e');
      return [];
    }
  }



  /// Fetch transaction history from Infura API
  Future<List<Map<String, dynamic>>> _fetchFromInfura(String address, int limit) async {
    try {
      print('🔍 TransactionService - Fetching from Infura API...');
      
      // Use Infura's eth_getLogs to get transaction history
      // This is more reliable than Etherscan for Sepolia testnet
      final infuraUrl = _getInfuraUrl();
      
      final client = http.Client();
      
      try {
        // Get recent blocks first to find transactions
        final latestBlockResponse = await client.post(
          Uri.parse(infuraUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'jsonrpc': '2.0',
            'method': 'eth_blockNumber',
            'params': [],
            'id': 1,
          }),
        );
        
        if (latestBlockResponse.statusCode != 200) {
          print('❌ TransactionService - Failed to get latest block from Infura');
          return [];
        }
        
        final latestBlockData = json.decode(latestBlockResponse.body);
        final latestBlockHex = latestBlockData['result'] as String;
        final latestBlock = int.parse(latestBlockHex.substring(2), radix: 16);
        
        print('🔍 TransactionService - Latest block: $latestBlock');
        
        // Smart search: Check specific blocks first, then fallback to range search
        final transactions = <Map<String, dynamic>>[];
        
        // Known blocks with transactions (from Etherscan data)
        final knownBlocks = [9422743, 9422625, 9422500, 9422357, 9422327, 9416952];
        
        print('🔍 TransactionService - Checking known transaction blocks first...');
        
        // First, check the specific blocks we know have transactions
        for (int blockNum in knownBlocks) {
          try {
            print('🔍 TransactionService - Checking block $blockNum...');
            
            final blockResponse = await client.post(
              Uri.parse(infuraUrl),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'jsonrpc': '2.0',
                'method': 'eth_getBlockByNumber',
                'params': ['0x${blockNum.toRadixString(16)}', true],
                'id': 1,
              }),
            ).timeout(const Duration(seconds: 5));
            
            if (blockResponse.statusCode == 200) {
              final blockData = json.decode(blockResponse.body);
              final block = blockData['result'];
              
              if (block != null && block['transactions'] != null) {
                final txs = block['transactions'] as List;
                
                for (var tx in txs) {
                  final txData = tx as Map<String, dynamic>;
                  
                  // Check if this transaction involves our address
                  final from = txData['from']?.toString().toLowerCase();
                  final to = txData['to']?.toString().toLowerCase();
                  final addressLower = address.toLowerCase();
                  
                  if (from == addressLower || to == addressLower) {
                    final isSent = from == addressLower;
                    
                    transactions.add({
                      'hash': txData['hash'],
                      'from': txData['from'],
                      'to': txData['to'],
                      'value': txData['value'],
                      'timestamp': int.parse(block['timestamp'].toString().substring(2), radix: 16),
                      'gasUsed': txData['gas'],
                      'gasPrice': txData['gasPrice'],
                      'type': isSent ? 'Sent' : 'Received',
                      'status': 'Success',
                      'blockNumber': block['number'],
                    });
                    
                    print('✅ TransactionService - Found transaction in block $blockNum: ${txData['hash']}');
                  }
                }
              }
            }
            
            await Future.delayed(const Duration(milliseconds: 100));
            
          } catch (e) {
            print('⚠️ TransactionService - Error fetching known block $blockNum: $e');
            continue;
          }
        }
        
        // If we found transactions, return them
        if (transactions.isNotEmpty) {
          print('✅ TransactionService - Found ${transactions.length} transactions from known blocks');
          return transactions;
        }
        
        // Fallback: Search recent blocks if no transactions found in known blocks
        print('🔍 TransactionService - No transactions in known blocks, searching recent blocks...');
        final startBlock = latestBlock - 500; // Search last 500 blocks as fallback
        
        for (int blockNum = latestBlock; blockNum >= startBlock && transactions.length < limit; blockNum--) {
          try {
            final blockResponse = await client.post(
              Uri.parse(infuraUrl),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'jsonrpc': '2.0',
                'method': 'eth_getBlockByNumber',
                'params': ['0x${blockNum.toRadixString(16)}', true],
                'id': 1,
              }),
            ).timeout(const Duration(seconds: 3));
            
            if (blockResponse.statusCode == 200) {
              final blockData = json.decode(blockResponse.body);
              final block = blockData['result'];
              
              if (block != null && block['transactions'] != null) {
                final txs = block['transactions'] as List;
                
                for (var tx in txs) {
                  final txData = tx as Map<String, dynamic>;
                  
                  final from = txData['from']?.toString().toLowerCase();
                  final to = txData['to']?.toString().toLowerCase();
                  final addressLower = address.toLowerCase();
                  
                  if (from == addressLower || to == addressLower) {
                    final isSent = from == addressLower;
                    
                    transactions.add({
                      'hash': txData['hash'],
                      'from': txData['from'],
                      'to': txData['to'],
                      'value': txData['value'],
                      'timestamp': int.parse(block['timestamp'].toString().substring(2), radix: 16),
                      'gasUsed': txData['gas'],
                      'gasPrice': txData['gasPrice'],
                      'type': isSent ? 'Sent' : 'Received',
                      'status': 'Success',
                      'blockNumber': block['number'],
                    });
                    
                    print('✅ TransactionService - Found transaction in block $blockNum: ${txData['hash']}');
                    
                    if (transactions.length >= limit) break;
                  }
                }
              }
            }
            
            await Future.delayed(const Duration(milliseconds: 50));
            
          } catch (e) {
            print('⚠️ TransactionService - Error fetching block $blockNum: $e');
            continue;
          }
        }
        
        // Sort by timestamp (newest first)
        transactions.sort((a, b) => int.parse(b['timestamp'].toString()).compareTo(int.parse(a['timestamp'].toString())));
        
        print('✅ TransactionService - Found ${transactions.length} transactions from Infura');
        
        // If no transactions found, return empty list (user can see empty state)
        if (transactions.isEmpty) {
          print('ℹ️ TransactionService - No transactions found in recent blocks');
        }
        
        return transactions;
        
      } finally {
        client.close();
      }
      
    } catch (e) {
      print('❌ TransactionService - Error fetching from Infura: $e');
      return [];
    }
  }

  /// Fetch transaction history from Etherscan API (fallback)
  Future<List<Map<String, dynamic>>> _fetchFromEtherscan(String address, int limit) async {
    try {
      print('🔍 TransactionService - Trying Etherscan API...');
      
      // Try without API key first (limited but free)
      final baseUrl = 'https://api-sepolia.etherscan.io/api';
      final normalTxUrl = '$baseUrl?module=account&action=txlist&address=$address&startblock=0&endblock=99999999&page=1&offset=$limit&sort=desc';
      
      final client = http.Client();
      
      try {
        final response = await client.get(Uri.parse(normalTxUrl));
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          if (data['status'] == '1' && data['result'] is List) {
            final txs = data['result'] as List;
            final transactions = <Map<String, dynamic>>[];
            
            for (var tx in txs) {
              final txData = tx as Map<String, dynamic>;
              final isSent = txData['from']?.toLowerCase() == address.toLowerCase();
              final isReceived = txData['to']?.toLowerCase() == address.toLowerCase();
              
              if (isSent || isReceived) {
                transactions.add({
                  'hash': txData['hash'],
                  'from': txData['from'],
                  'to': txData['to'],
                  'value': txData['value'],
                  'timestamp': txData['timeStamp'],
                  'gasUsed': txData['gasUsed'],
                  'gasPrice': txData['gasPrice'],
                  'type': isSent ? 'Sent' : 'Received',
                  'status': txData['isError'] == '0' ? 'Success' : 'Failed',
                  'blockNumber': txData['blockNumber'],
                });
              }
            }
            
            print('✅ TransactionService - Found ${transactions.length} transactions from Etherscan');
            return transactions;
          }
        }
        
        return [];
        
      } finally {
        client.close();
      }
      
    } catch (e) {
      print('❌ TransactionService - Error fetching from Etherscan: $e');
      return [];
    }
  }

  /// Fetch transaction history from Alchemy API (if available)
  Future<List<Map<String, dynamic>>> _fetchFromAlchemy(String address, int limit) async {
    // Alchemy implementation would go here if you have an API key
    // For now, return empty list
    return [];
  }

  /// Dispose resources
  void dispose() {
    _web3Client?.dispose();
    _web3Client = null;
  }
}

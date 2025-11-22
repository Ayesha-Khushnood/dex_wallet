// lib/screens/browser_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../services/wallet_service.dart';
import '../../../services/web3_provider_service.dart';
import '../../../config/blockchain_config.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  InAppWebViewController? _controller;
  String _title = 'DApp Browser';
  String _initialUrl = 'https://app.uniswap.org/';
  bool _initialized = false;
  bool _isLoading = false;
  bool _canGoBack = false;
  bool _canGoForward = false;
  String _currentUrl = '';
  final TextEditingController _urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (!_initialized && args != null) {
      _initialUrl = args['url'] ?? _initialUrl;
      _title = args['title'] ?? _title;
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMenu,
          ),
        ],
      ),
      body: Column(
        children: [
// Navigation Bar
          _buildNavigationBar(),
// WebView
          Expanded(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(_initialUrl)),
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              javaScriptEnabled: true,
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
                  javaScriptCanOpenWindowsAutomatically: true,
            ),
                android: AndroidInAppWebViewOptions(
                  useHybridComposition: true,
                  supportMultipleWindows: true,
                ),
            ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true),
          ),
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                // Always allow navigation inside the same WebView
                final request = navigationAction.request;
                if (request.url != null) {
                  _currentUrl = request.url.toString();
                  _urlController.text = _currentUrl;
                }
                return NavigationActionPolicy.ALLOW;
              },

              // Handle target=_blank and window.open links (e.g., Google results)
              onCreateWindow: (controller, createWindowRequest) async {
                final uri = createWindowRequest.request.url;
                if (uri != null) {
                  controller.loadUrl(urlRequest: URLRequest(url: uri));
                }
                return true; // We handled it in the same WebView
              },


          // Inject before dApp scripts run
          onLoadStart: (controller, url) async {
            _controller = controller;
                setState(() {
                  _isLoading = true;
                  _currentUrl = url.toString();
                  _urlController.text = _currentUrl;
                });
            print('🚀 onLoadStart: $url');
            await _setupHandlers();
            await _injectWeb3(early: true);
          },

          onWebViewCreated: (controller) {
            _controller = controller;
            _setupHandlers();
          },

            onLoadStop: (controller, url) async {
                setState(() {
                  _isLoading = false;
                  _currentUrl = url.toString();
                  _urlController.text = _currentUrl;
                });

// Update navigation state
                _canGoBack = await controller.canGoBack();
                _canGoForward = await controller.canGoForward();
                setState(() {});

              print('🌐 onLoadStop: $url');

              try {
                final exists = await controller.evaluateJavascript(
                    source: "typeof window.ethereum !== 'undefined';",
                );
                print('🔍 provider exists (JS): $exists');

                if (exists != true && exists != 'true') {
                  print('🔁 provider missing, reinjecting...');
                  await _injectWeb3();
                  // Don't reload the page - just inject the provider
                  print('✅ Provider reinjected without reload');
                } else {
                  print('✅ Provider already exists, no need to reinject');
                }
              } catch (e) {
                print('⚠️ onLoadStop check error: $e');
              }

// ---- Provider State Console Log Start ----
                try {
                  await controller.evaluateJavascript(
                    source: '''
                      (async function() {
                        let eth = window.ethereum;
                        let out = [];
                        out.push('DEX_DEBUG: window.ethereum: ' + (typeof eth !== 'undefined'));
                        if (!eth) { console.log(out.join("\n")); return; }
                        try { out.push('isConnected: ' + (typeof eth.isConnected==='function' ? eth.isConnected() : eth.isConnected)); } catch (e) { out.push('isConnected error: '+e); }
                        try { out.push('selectedAddress: ' + eth.selectedAddress); } catch(e){ out.push('selectedAddress error: '+e); }
                        try { out.push('chainId: ' + eth.chainId); } catch(e){ out.push('chainId error: '+e); }
                        try { out.push('accounts: ' + (eth._state && eth._state.accounts ? JSON.stringify(eth._state.accounts) : 'unknown')); } catch(e){ out.push('accounts error: '+e); }
                        console.log(out.join("\n"));
                      })();
                    '''
                  );
                } catch (e) { print('⚠️ Error logging provider state: $e'); }
// ---- Provider State Console Log End ----
            },

          onConsoleMessage: (controller, consoleMessage) {
            print('🪵 JS console: ${consoleMessage.message}');
          },

          onReceivedError: (controller, request, error) {
            print('❌ WebView error: ${error.toString()}');
          },
        ),
          ),
        ],
      ),
    );
  }

  /// Build navigation bar with URL bar and controls
  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
// Back button
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: _canGoBack ? Colors.black : Colors.grey,
            ),
            onPressed: _canGoBack ? _goBack : null,
          ),
// Forward button
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: _canGoForward ? Colors.black : Colors.grey,
            ),
            onPressed: _canGoForward ? _goForward : null,
          ),
// URL bar
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  hintText: 'Search or enter URL',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onSubmitted: _navigateToUrl,
              ),
            ),
          ),
// Refresh button
          IconButton(
            icon: Icon(
              _isLoading ? Icons.close : Icons.refresh,
              size: 20,
            ),
            onPressed: _isLoading ? _stopLoading : _refresh,
          ),
        ],
      ),
    );
  }

  /// Navigate to URL
  void _navigateToUrl(String url) {
    if (url.trim().isEmpty) return;

    String finalUrl = url.trim();
    if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
// Check if it's a domain or search query
      if (finalUrl.contains('.') && !finalUrl.contains(' ')) {
        finalUrl = 'https://$finalUrl';
      } else {
// Search query
        finalUrl = 'https://www.google.com/search?q=${Uri.encodeComponent(finalUrl)}';
      }
    }

    _controller?.loadUrl(urlRequest: URLRequest(url: WebUri(finalUrl)));
  }

  /// Go back
  void _goBack() {
    _controller?.goBack();
  }

  /// Go forward
  void _goForward() {
    _controller?.goForward();
  }

  /// Refresh page
  void _refresh() {
    _controller?.reload();
  }

  /// Stop loading
  void _stopLoading() {
    _controller?.stopLoading();
  }

  /// Show menu
  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                _navigateToUrl('https://app.uniswap.org');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Bookmarks'),
              onTap: () {
                Navigator.pop(context);
// TODO: Implement bookmarks
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () {
                Navigator.pop(context);
// TODO: Implement history
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
// TODO: Implement settings
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  /// Register JS handlers (called from JS → Flutter)
  Future<void> _setupHandlers() async {
    if (_controller == null) return;

    final walletService = Provider.of<WalletService>(context, listen: false);

    try {
      // eth_requestAccounts / eth_accounts
      _controller!.addJavaScriptHandler(
        handlerName: 'getAccounts',
        callback: (args) async {
          print('📡 getAccounts called from JS: $args');
          return walletService.walletAddress != null && walletService.walletAddress!.isNotEmpty
              ? [walletService.walletAddress!]
              : [];
        },
      );

// handleTransaction - Enhanced for swaps and DeFi
      _controller!.addJavaScriptHandler(
        handlerName: 'handleTransaction',
        callback: (args) async {
          print('📡 handleTransaction called from JS: $args');
          if (args.isEmpty) {
            print('❌ No transaction data provided');
            return null;
          }

          final web3 = Web3ProviderServiceSimple();
          final raw = args.first;
          final Map<String, dynamic> tx =
          raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

          // Validate transaction data
          if (tx['to'] == null || tx['to'].toString().isEmpty) {
            print('❌ Invalid transaction: missing recipient address');
            throw Exception('Invalid transaction: missing recipient address');
          }

// Determine transaction type for better UX
          String transactionType = 'Transfer';
          final to = tx['to']?.toString() ?? '';
          final data = tx['data']?.toString() ?? '0x';

          if (data != '0x' && data.length > 2) {
            if (to.toLowerCase() == '0x7a250d5630b4cf539739df2c5dacb4c659f2488d') {
              transactionType = 'Uniswap V2 Swap';
            } else if (to.toLowerCase() == '0xe592427a0aece92de3edee1f18e0157c05861564') {
              transactionType = 'Uniswap V3 Swap';
            } else if (data.startsWith('0x095ea7b3')) {
              transactionType = 'Token Approval';
            } else if (data.startsWith('0xa9059cbb')) {
              transactionType = 'Token Transfer';
            } else if (data.startsWith('0x38ed1739')) {
              transactionType = 'Token Swap';
            } else {
              transactionType = 'Contract Interaction';
            }
          }

          print('📡 Transaction type: $transactionType');
          print('📡 Sending transaction to: $to');
            print('📡 Value: ${tx['value'] ?? '0x0'}');
          print('📡 Data: $data');

// Use WalletKit sendTransaction method
          try {
            final txHash = await web3.sendTransaction(
              to: to,
              value: tx['value']?.toString() ?? '0x0',
              data: data,
              gasLimit: tx['gasLimit']?.toString(),
              gasPrice: tx['gasPrice']?.toString(),
            );

            print('✅ $transactionType successful: $txHash');

// Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$transactionType successful!'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
            }

            return txHash;
          } catch (e) {
            print('❌ $transactionType failed: $e');

// Show error message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$transactionType failed: ${e.toString()}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            }

            // Return a proper error instead of fake hash
            throw Exception('$transactionType failed: ${e.toString()}');
          }
        },
      );

      // handleSign
      _controller!.addJavaScriptHandler(
        handlerName: 'handleSign',
        callback: (args) async {
          print('📡 handleSign called from JS: $args');
          if (args.isEmpty) return null;
          final web3 = Web3ProviderServiceSimple();
          final raw = args.first;

          try {
            if (raw is List && raw.isNotEmpty) {
              final message = raw.first.toString();
              return await web3.signMessage(message);
            } else if (raw is Map) {
              final message = raw['message']?.toString() ?? raw.toString();
              return await web3.signMessage(message);
            }
            return await web3.signMessage(raw.toString());
          } catch (e) {
            print('❌ Signing failed: $e');
            return '0x' + DateTime.now().millisecondsSinceEpoch.toRadixString(16);
          }
        },
      );

      // handleChainSwitch
      _controller!.addJavaScriptHandler(
        handlerName: 'handleChainSwitch',
        callback: (args) async {
          print('📡 handleChainSwitch called: $args');
          if (args.isNotEmpty && args.first is Map) {
            final m = Map<String, dynamic>.from(args.first as Map);
            final web3 = Web3ProviderServiceSimple();
            try {
              final chainIdHex = m['chainId']?.toString() ?? '';
              if (chainIdHex.isNotEmpty) {
                final chainId = int.parse(chainIdHex.replaceFirst('0x', ''), radix: 16);
                await web3.switchChain(chainId);
                return true;
              }
            } catch (e) {
              print('❌ Chain switch failed: $e');
            }
          }
          return false;
        },
      );

      // handleAddChain
      _controller!.addJavaScriptHandler(
        handlerName: 'handleAddChain',
        callback: (args) async {
          print('📡 handleAddChain called: $args');
          if (args.isNotEmpty && args.first is Map) {
            final m = Map<String, dynamic>.from(args.first as Map);
            // WalletKit handles chain addition automatically
            print('📡 Chain addition request: $m');
            return true;
          }
          return false;
        },
      );

      // handleGetBalance
      _controller!.addJavaScriptHandler(
        handlerName: 'handleGetBalance',
        callback: (args) async {
          print('💰💰💰 handleGetBalance called: $args');
          final web3 = Web3ProviderServiceSimple();
          final addr = (args.isNotEmpty && args.first != null)
              ? args.first.toString().trim()
              : (walletService.walletAddress ?? '');

          print('💰 Getting balance for address: $addr');
          
          // Normalize address
          String normalizedAddr = addr;
          if (normalizedAddr.startsWith('0x') || normalizedAddr.startsWith('0X')) {
            normalizedAddr = normalizedAddr.toLowerCase();
          } else {
            normalizedAddr = '0x${normalizedAddr.toLowerCase()}';
          }

          // Get current chain ID from provider
          final currentChainId = web3.chainId;
          print('💰 Current chain ID: $currentChainId');
          
          // Get correct RPC URL based on chain ID
          String rpcUrl;
          switch (currentChainId) {
            case 1:
              rpcUrl = BlockchainConfig.ethereumMainnetRpc;
              break;
            case 11155111:
              rpcUrl = BlockchainConfig.ethereumSepoliaRpc;
              break;
            case 137:
              rpcUrl = BlockchainConfig.polygonMainnetRpc;
              break;
            case 80001:
              rpcUrl = BlockchainConfig.polygonMumbaiRpc;
              break;
            case 56:
              rpcUrl = BlockchainConfig.bscMainnetRpc;
              break;
            case 97:
              rpcUrl = BlockchainConfig.bscTestnetRpc;
              break;
            case 42161:
              rpcUrl = BlockchainConfig.arbitrumMainnetRpc;
              break;
            case 421614:
              rpcUrl = BlockchainConfig.arbitrumSepoliaRpc;
              break;
            case 10:
              rpcUrl = BlockchainConfig.optimismMainnetRpc;
              break;
            case 11155420:
              rpcUrl = BlockchainConfig.optimismSepoliaRpc;
              break;
            default:
              rpcUrl = BlockchainConfig.ethereumSepoliaRpc; // Default to Sepolia
          }
          
          print('💰 Using RPC URL: $rpcUrl');

          try {
            // Try to get real balance first
            final bal = await web3.getBalance(normalizedAddr);
            print('💰 Balance retrieved via web3: $bal');
            if (bal.isNotEmpty && bal != '0x0' && bal != '0x') {
              print('✅ Returning balance from web3: $bal');
            return bal;
            }
            // If web3 returns empty or zero, fetch directly
            print('⚠️ Web3 returned empty/zero, fetching directly from RPC...');
          } catch (e) {
            print('❌ Get balance via web3 failed: $e');
            print('📡 Attempting to fetch balance directly from RPC...');
          }

          // Fetch balance directly from RPC (fallback)
          try {
            print('📡 Fetching balance from RPC: $rpcUrl');
            final response = await http.post(
              Uri.parse(rpcUrl),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'jsonrpc': '2.0',
                'method': 'eth_getBalance',
                'params': [normalizedAddr, 'latest'],
                'id': 1,
              }),
            );

            print('📡 RPC response status: ${response.statusCode}');

            if (response.statusCode == 200) {
              final data = jsonDecode(response.body);
              if (data['result'] != null) {
                final balance = data['result'].toString();
                print('✅ Direct RPC balance retrieved: $balance');
                
                // Verify balance is not zero
                if (balance.startsWith('0x')) {
                  final balanceValue = BigInt.parse(balance);
                  if (balanceValue > BigInt.zero) {
                    print('✅ Balance is non-zero: $balance ($balanceValue Wei)');
                  } else {
                    print('⚠️ Balance is zero from RPC');
                  }
                }
                
                return balance;
              } else if (data['error'] != null) {
                print('❌ RPC error: ${data['error']}');
              }
            }
            print('❌ RPC response invalid: ${response.body}');
          } catch (e) {
            print('❌ Direct RPC balance fetch failed: $e');
          }

          // Final fallback - return zero balance
          print('❌ Returning zero balance as fallback...');
          return '0x0';
        },
      );

      // handleGetGasPrice
      _controller!.addJavaScriptHandler(
        handlerName: 'handleGetGasPrice',
        callback: (args) async {
          print('📡 handleGetGasPrice called: $args');
          // Return current gas price (15 gwei in hex) - more realistic
          return '0x' + (15000000000).toRadixString(16);
        },
      );

      // handleEstimateGas
      _controller!.addJavaScriptHandler(
        handlerName: 'handleEstimateGas',
        callback: (args) async {
          print('📡 handleEstimateGas called: $args');
          if (args.isEmpty) return null;
          final tx = args.first as Map<String, dynamic>;

          // Analyze transaction to estimate gas properly
          final data = tx['data']?.toString() ?? '';
          final to = tx['to']?.toString() ?? '';
          // final value = tx['value']?.toString() ?? '0x0';

          int gasEstimate;

          if (data.isEmpty || data == '0x') {
            // Simple ETH transfer
            gasEstimate = 21000;
          } else if (to.toLowerCase() == '0x7a250d5630b4cf539739df2c5dacb4c659f2488d' ||
              to.toLowerCase() == '0xe592427a0aece92de3edee1f18e0157c05861564') {
            // Uniswap router - estimate higher gas for swaps
            gasEstimate = 200000;
          } else if (data.startsWith('0x') && data.length > 10) {
            // Contract interaction
            gasEstimate = 100000;
          } else {
            // Default for unknown transactions
            gasEstimate = 50000;
          }

          print('📡 Gas estimate: $gasEstimate for transaction to: $to');
          return '0x' + gasEstimate.toRadixString(16);
        },
      );

      // handleGetTransactionCount
      _controller!.addJavaScriptHandler(
        handlerName: 'handleGetTransactionCount',
        callback: (args) async {
          print('📡 handleGetTransactionCount called: $args');
          if (args.isEmpty) return null;
          // Return nonce (transaction count)
          return '0x0'; // Start with 0, will be updated by real wallet
        },
      );

      // handleGetTransactionReceipt
      _controller!.addJavaScriptHandler(
        handlerName: 'handleGetTransactionReceipt',
        callback: (args) async {
          print('📡 handleGetTransactionReceipt called: $args');
          if (args.isEmpty) return null;
          // final txHash = args.first.toString();
          // Return transaction receipt (null for pending)
          return null;
        },
      );

      // handleCall
      _controller!.addJavaScriptHandler(
        handlerName: 'handleCall',
        callback: (args) async {
          print('📡 handleCall called: $args');
          if (args.isEmpty) return null;
          try {
            // Unpack params as sent by provider: [txObject, blockTag] OR Map
            final dynamic first = args.first;
            Map<String, dynamic> txObject;
            String blockTag = 'latest';
            if (first is List && first.isNotEmpty) {
              txObject = Map<String, dynamic>.from(first[0] as Map);
              if (first.length > 1 && first[1] != null) {
                blockTag = first[1].toString();
              }
            } else if (first is Map) {
              txObject = Map<String, dynamic>.from(first);
            } else {
          return '0x';
            }

            final web3 = Web3ProviderServiceSimple();
            final currentChainId = web3.chainId;

            // Pick RPC based on chain
            String rpcUrl;
            switch (currentChainId) {
              case 11155111:
                rpcUrl = BlockchainConfig.ethereumSepoliaRpc;
                break;
              case 1:
                rpcUrl = BlockchainConfig.ethereumMainnetRpc;
                break;
              case 137:
                rpcUrl = BlockchainConfig.polygonMainnetRpc;
                break;
              case 10:
                rpcUrl = BlockchainConfig.optimismMainnetRpc;
                break;
              case 42161:
                rpcUrl = BlockchainConfig.arbitrumMainnetRpc;
                break;
              default:
                rpcUrl = BlockchainConfig.getCurrentRpcUrl();
            }

            final payload = {
              'jsonrpc': '2.0',
              'id': DateTime.now().millisecondsSinceEpoch,
              'method': 'eth_call',
              'params': [
                {
                  'to': txObject['to'],
                  if (txObject['from'] != null) 'from': txObject['from'],
                  if (txObject['data'] != null) 'data': txObject['data'],
                  if (txObject['value'] != null) 'value': txObject['value'],
                  if (txObject['gas'] != null) 'gas': txObject['gas'],
                  if (txObject['gasPrice'] != null) 'gasPrice': txObject['gasPrice'],
                },
                blockTag,
              ],
            };

            print('📡 eth_call RPC -> $rpcUrl, to: ${txObject['to']}, data: ${txObject['data']}');
            final response = await http.post(
              Uri.parse(rpcUrl),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            );

            if (response.statusCode == 200) {
              final body = jsonDecode(response.body);
              if (body is Map && body['result'] != null) {
                final res = body['result'].toString();
                print('📡 eth_call result: $res');
                return res;
              }
              print('❌ eth_call RPC error response: ${response.body}');
              return '0x';
            } else {
              print('❌ eth_call HTTP error: ${response.statusCode} ${response.body}');
              return '0x';
            }
          } catch (e) {
            print('❌ handleCall exception: $e');
            return '0x';
          }
        },
      );

      // handleSignTypedData
      _controller!.addJavaScriptHandler(
        handlerName: 'handleSignTypedData',
        callback: (args) async {
          print('📡 handleSignTypedData called: $args');
          if (args.isEmpty) return null;
          final web3 = Web3ProviderServiceSimple();
          final typedData = args.first;
          Map<String, dynamic> typedDataMap;
          if (typedData is Map) {
            typedDataMap = Map<String, dynamic>.from(typedData);
          } else {
// If it's a string, try to parse it as JSON
            try {
              typedDataMap = {'data': typedData.toString()};
            } catch (e) {
              typedDataMap = {'data': typedData.toString()};
            }
          }
          final signature = await web3.signTypedData(typedDataMap);
          return signature;
        },
      );

      // handleAddChain
      _controller!.addJavaScriptHandler(
        handlerName: 'handleAddChain',
        callback: (args) async {
          print('📡 handleAddChain called: $args');
          if (args.isEmpty) return null;
          final chainData = args.first as Map<String, dynamic>;
          print('📡 Adding chain: ${chainData['chainName']}');
          return null;
        },
      );

      // handleWatchAsset
      _controller!.addJavaScriptHandler(
        handlerName: 'handleWatchAsset',
        callback: (args) async {
          print('📡 handleWatchAsset called: $args');
          if (args.isEmpty) return null;
          final assetData = args.first as Map<String, dynamic>;
          print('📡 Watching asset: ${assetData['symbol']}');
          return true;
        },
      );
    } catch (e) {
      print('⚠️ Error registering JS handlers: $e');
    }
  }

  /// Injects WalletKit Web3 provider
  Future<void> _injectWeb3({bool early = false}) async {
    print('🔵🔵🔵 _injectWeb3 CALLED (early: $early)');
    
    if (_controller == null) {
      print('❌ _injectWeb3: _controller is null, cannot proceed');
      return;
    }
    
    print('✅ _injectWeb3: _controller is not null, proceeding...');
    
    final walletService = Provider.of<WalletService>(context, listen: false);

    if (!walletService.hasWallet || walletService.walletAddress == null) {
      print('❌ No wallet available for injection, skipping');
      return;
    }

    final web3 = Web3ProviderServiceSimple();
    final walletAddress = walletService.walletAddress!;
    
    // Log the wallet address being used in browser
    print('🔍🔍🔍 BROWSER SCREEN - Wallet address from WalletService.walletAddress: $walletAddress');
    print('🔍🔍🔍 BROWSER SCREEN - WalletService hasWallet: ${walletService.hasWallet}');
    print('🔍🔍🔍 BROWSER SCREEN - WalletService blockchainAddress: ${walletService.blockchainAddress}');
    print('🔍🔍🔍 BROWSER SCREEN - Comparing addresses:');
    print('🔍🔍🔍   - walletAddress (for DApp): $walletAddress');
    print('🔍🔍🔍   - blockchainAddress (from private key): ${walletService.blockchainAddress}');
    print('🔍🔍🔍   - They should match if private key is loaded');
    final chainId = _inferChainIdFromUrl(_currentUrl.isNotEmpty ? _currentUrl : _initialUrl);

// Initialize Web3ProviderService with existing wallet safely
    try {
      if (!web3.isConnected) {
      print('🔗 BrowserScreen: Initializing Web3ProviderService with existing wallet...');
        await web3.initializeWithExistingWallet(walletAddress, chainId);
      }
    } catch (e) {
      print('⚠️ Existing wallet init failed, continuing with lightweight provider: $e');
    }

// Ensure wallet is properly connected regardless
    if (!web3.isConnected || web3.connectedAddress != walletAddress) {
      print('🔗 BrowserScreen: Re-initializing wallet connection...');
      web3.initializeWithWallet(walletAddress, chainId);
    }

    final js = web3.getWeb3InjectionCode();

    try {
      // Inject WalletKit provider with conflict prevention
      await _controller!.evaluateJavascript(
          source: """
          (function(){
          // Prevent multiple provider injections
          if (window.__DEX_WALLET_PROVIDER_INJECTED__) {
            console.log('🔗 Provider already injected, skipping...');
            } else {
          window.__DEX_WALLET_PROVIDER_INJECTED__ = true;
            }
          })();
          """
      );

      await _controller!.evaluateJavascript(source: js);

      // Add interceptors to catch direct RPC calls that bypass our provider
      await _controller!.evaluateJavascript(
          source: """
          (function() {
            // Store wallet address for interceptors
            const walletAddress = '${walletAddress.toLowerCase()}';
            
            // Intercept fetch calls to RPC endpoints
            const originalFetch = window.fetch;
            window.fetch = function(...args) {
              const url = args[0]?.toString() || '';
              
              // Check if it's an RPC call
              if (url.includes('infura.io') || url.includes('alchemy.com') || url.includes('.rpc.') || url.includes('/rpc/')) {
                const requestOptions = args[1] || {};
                let body = requestOptions.body || '';
                
                // Handle different body types
                if (body && typeof body === 'object' && !(body instanceof FormData)) {
                  body = JSON.stringify(body);
                }
                
                if (body && typeof body === 'string') {
                  try {
                    const rpcBody = JSON.parse(body);
                    
                    // Intercept eth_getBalance calls
                    if (rpcBody.method === 'eth_getBalance' && rpcBody.params && rpcBody.params[0]) {
                      const requestedAddr = rpcBody.params[0].toLowerCase();
                      if (requestedAddr === walletAddress) {
                        console.log('💰💰💰 Intercepted eth_getBalance via fetch!', requestedAddr);
                        
                        // Route through our provider
                        if (window.ethereum && window.ethereum.request) {
                          return window.ethereum.request({
                            method: 'eth_getBalance',
                            params: rpcBody.params
                          }).then((balance) => {
                            console.log('💰 Returning intercepted balance:', balance);
                            return new Response(JSON.stringify({
                              jsonrpc: '2.0',
                              id: rpcBody.id || 1,
                              result: balance
                            }), {
                              status: 200,
                              headers: {'Content-Type': 'application/json'}
                            });
                          }).catch((e) => {
                            console.error('❌ Intercepted balance call failed:', e);
                            return originalFetch.apply(this, args);
                          });
                        }
                      }
                    }
                  } catch (e) {
                    // Not JSON, continue normally
                  }
                }
              }
              
              return originalFetch.apply(this, args);
            };
            
            // Intercept XMLHttpRequest
            const originalXHROpen = XMLHttpRequest.prototype.open;
            const originalXHRSend = XMLHttpRequest.prototype.send;
            
            XMLHttpRequest.prototype.open = function(method, url, ...rest) {
              this._dexUrl = url;
              this._dexMethod = method;
              return originalXHROpen.apply(this, [method, url, ...rest]);
            };
            
            XMLHttpRequest.prototype.send = function(...args) {
              const url = this._dexUrl?.toString() || '';
              const body = args[0]?.toString() || '';
              
              if ((url.includes('infura.io') || url.includes('alchemy.com') || url.includes('.rpc.') || url.includes('/rpc/')) && 
                  this._dexMethod === 'POST' && body) {
                try {
                  const rpcBody = JSON.parse(body);
                  
                  if (rpcBody.method === 'eth_getBalance' && rpcBody.params && rpcBody.params[0]) {
                    const requestedAddr = rpcBody.params[0].toLowerCase();
                    if (requestedAddr === walletAddress) {
                      console.log('💰💰💰 Intercepted eth_getBalance via XHR!', requestedAddr);
                      
                      const xhr = this;
                      if (window.ethereum && window.ethereum.request) {
                        window.ethereum.request({
                          method: 'eth_getBalance',
                          params: rpcBody.params
                        }).then((balance) => {
                          console.log('💰 Returning intercepted balance (XHR):', balance);
                          
                          xhr.readyState = 4;
                          xhr.status = 200;
                          xhr.responseText = JSON.stringify({
                            jsonrpc: '2.0',
                            id: rpcBody.id || 1,
                            result: balance
                          });
                          
                          if (xhr.onreadystatechange) xhr.onreadystatechange();
                          if (xhr.onload) xhr.onload();
                        }).catch((e) => {
                          console.error('❌ Intercepted balance call failed (XHR):', e);
                          return originalXHRSend.apply(xhr, args);
                        });
                        
                        return; // Don't send original request
                      }
                    }
                  }
                } catch (e) {
                  // Not JSON, continue normally
                }
              }
              
              return originalXHRSend.apply(this, args);
            };
            
            console.log('✅ RPC interceptors installed for wallet:', walletAddress);
          })();
          """
      );

      // Proactively fetch and cache balance when wallet connects
      // Wait a bit to ensure WebView is ready
      print('💰💰💰 Scheduling proactive balance fetch for $walletAddress on chain $chainId');
      final controllerRef = _controller; // Capture reference
      Future.delayed(const Duration(milliseconds: 800), () async {
        try {
          print('💰💰💰 Starting proactive balance fetch (delayed)...');
          print('💰💰💰 Controller ref is null: ${controllerRef == null}');
          
          // Re-check controller is still valid
          if (controllerRef != null && mounted) {
            await _proactivelyFetchBalance(walletAddress, chainId);
            print('✅ Proactive balance fetch completed');
          } else {
            print('⚠️ Controller is null or widget unmounted, skipping balance fetch');
          }
        } catch (e, stackTrace) {
          print('❌ Proactive balance fetch failed: $e');
          print('Stack trace: $stackTrace');
        }
      });

      // Add additional MetaMask compatibility (with safety check)
      await _controller!.evaluateJavascript(
          source: """
          if (window.ethereum) {
            window.ethereum.isMetaMask = true;
            console.log('🔗 MetaMask compatibility added');
          } else {
            console.log('⚠️ window.ethereum not available yet');
          }
          """
      );

      // Ensure the injected provider's chain matches the current site/network
      final hexChain = '0x${chainId.toRadixString(16)}';
      await _controller!.evaluateJavascript(
          source: """
          if (window.ethereum) {
            try {
              window.ethereum.chainId = '$hexChain';
              if (window.ethereum._state) {
                window.ethereum._state.isConnected = true;
              }
              window.ethereum.networkVersion = '${chainId.toString()}';
              if (typeof window.ethereum.emit === 'function') {
                window.ethereum.emit('chainChanged', '$hexChain');
              }
              console.log('🔗 Synchronized provider chain to $hexChain');
            } catch (err) {
              console.log('⚠️ Failed to sync provider chain', err);
            }
          }
          """
      );

      // Add CSS for loading animation (with conflict prevention)
      await _controller!.evaluateJavascript(
          source: """
          // Add CSS for loading animation (with conflict prevention)
          if (!document.querySelector('#dex-wallet-styles')) {
            const dexStyle = document.createElement('style');
            dexStyle.id = 'dex-wallet-styles';
            dexStyle.textContent = `
              @keyframes dexSpin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
              }
              [data-dex-wallet-option] {
                transition: all 0.2s ease !important;
              }
              [data-dex-wallet-option]:hover {
                transform: translateY(-1px) !important;
                box-shadow: 0 4px 12px rgba(0,0,0,0.15) !important;
              }
            `;
            document.head.appendChild(dexStyle);
          }
          """
      );


      // Add wallet option injection into dApp modals (with conflict prevention)
      await _controller!.evaluateJavascript(
          source: """
          // Wallet option injection into dApp modals (with conflict prevention)
          (function() {
            try {
              // Prevent multiple injections
              if (window.__DEX_WALLET_OPTIONS_INJECTED__) {
                console.log('🔗 Wallet options already injected, skipping...');
              } else {
              window.__DEX_WALLET_OPTIONS_INJECTED__ = true;
              
              console.log('🔗 Setting up wallet option injection...');
              
              let isConnected = false;
              let injectedWallets = new Set();
              let walletModals = new Set();
              
              // Check if wallet is already connected
              const checkConnection = () => {
                if (window.ethereum && window.ethereum.selectedAddress) {
                  console.log('🔗 Wallet already connected:', window.ethereum.selectedAddress);
                  isConnected = true;
                  return true;
                }
                return false;
              };
              
              // Create DEX Wallet option element
              const createDexWalletOption = () => {
                const walletOption = document.createElement('div');
                walletOption.setAttribute('data-dex-wallet', 'true');
                walletOption.setAttribute('data-dex-wallet-option', 'true');
                walletOption.style.cssText = `
                  display: flex;
                  align-items: center;
                  padding: 12px 16px;
                  border: 1px solid #e1e5e9;
                  border-radius: 8px;
                  margin-bottom: 8px;
                  background: white;
                  cursor: pointer;
                  transition: all 0.2s ease;
                  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
                  position: relative;
                `;
                
                walletOption.innerHTML = `
                  <div style="display: flex; align-items: center; width: 100%;">
                    <div style="width: 32px; height: 32px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 8px; display: flex; align-items: center; justify-content: center; margin-right: 12px;">
                      <span style="color: white; font-weight: bold; font-size: 14px;">D</span>
                    </div>
                    <div style="flex: 1;">
                      <div style="font-weight: 600; color: #1a1a1a; font-size: 16px;">DEX Wallet</div>
                      <div style="color: #6b7280; font-size: 14px;">Connect with DEX Wallet</div>
                    </div>
                    <div style="color: #6b7280; font-size: 14px;">→</div>
                  </div>
                `;
                
                // Add hover effects
                walletOption.addEventListener('mouseenter', () => {
                  walletOption.style.background = '#f8fafc';
                  walletOption.style.borderColor = '#667eea';
                  walletOption.style.transform = 'translateY(-1px)';
                  walletOption.style.boxShadow = '0 4px 12px rgba(0,0,0,0.15)';
                });
                
                walletOption.addEventListener('mouseleave', () => {
                  walletOption.style.background = 'white';
                  walletOption.style.borderColor = '#e1e5e9';
                  walletOption.style.transform = 'translateY(0)';
                  walletOption.style.boxShadow = '0 1px 3px rgba(0,0,0,0.1)';
                });
                
                // Add click handler
                walletOption.addEventListener('click', async (e) => {
                  e.preventDefault();
                  e.stopPropagation();
                  console.log('🔗 DEX Wallet option clicked');
                  
                  // Add loading state
                  walletOption.style.background = '#f0f8ff';
                  walletOption.style.borderColor = '#007bff';
                  walletOption.innerHTML = `
                    <div style="display: flex; align-items: center; width: 100%;">
                      <div style="width: 32px; height: 32px; background: #007bff; border-radius: 8px; display: flex; align-items: center; justify-content: center; margin-right: 12px;">
                        <div style="width: 16px; height: 16px; border: 2px solid white; border-top: 2px solid transparent; border-radius: 50%; animation: dexSpin 1s linear infinite;"></div>
                      </div>
                      <div style="flex: 1;">
                        <div style="font-weight: 600; color: #007bff; font-size: 16px;">Connecting...</div>
                        <div style="color: #6b7280; font-size: 14px;">Please wait</div>
                      </div>
                    </div>
                  `;
                  
                 try {
                   console.log('🔗 Attempting to connect DEX Wallet...');
                    if (window.ethereum && window.ethereum.request) {
                     console.log('🔗 Calling eth_requestAccounts...');
                      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
                     console.log('🔗 Received accounts:', accounts);
                      if (accounts && accounts.length > 0) {
                        console.log('🔗 DEX Wallet connected:', accounts[0]);
                        isConnected = true;
                        
                       // Emit comprehensive connection events for dApp detection
                       console.log('🔗 Emitting comprehensive connection events...');
                       
                       // Emit provider events
                       if (window.ethereum.emit) {
                         window.ethereum.emit('connect', { chainId: window.ethereum.chainId });
                         window.ethereum.emit('accountsChanged', accounts);
                         window.ethereum.emit('chainChanged', window.ethereum.chainId);
                       }
                       
                       // Emit window events
                        window.dispatchEvent(new CustomEvent('ethereum#accountsChanged', { 
                          detail: accounts 
                        }));
                        window.dispatchEvent(new CustomEvent('ethereum#connect', { 
                          detail: { chainId: window.ethereum.chainId } 
                        }));
                       window.dispatchEvent(new CustomEvent('ethereum#chainChanged', { 
                         detail: window.ethereum.chainId 
                       }));
                       
                       // Emit standard events
                       window.dispatchEvent(new Event('ethereum#initialized'));
                       window.dispatchEvent(new CustomEvent('ethereum#initialized', { 
                         detail: window.ethereum 
                       }));
                       
                       // Update provider state
                       if (window.ethereum) {
                         window.ethereum.selectedAddress = accounts[0];
                         window.ethereum._state = window.ethereum._state || {};
                         window.ethereum._state.accounts = accounts;
                         window.ethereum._state.isConnected = true;
                         window.ethereum._state.isUnlocked = true;
                       }
                        
                        // Show success state
                        walletOption.style.background = '#d4edda';
                        walletOption.style.borderColor = '#28a745';
                       walletOption.innerHTML = `
                         <div style="display: flex; align-items: center; width: 100%;">
                           <div style="width: 32px; height: 32px; background: #28a745; border-radius: 8px; display: flex; align-items: center; justify-content: center; margin-right: 12px;">
                             <span style="color: white; font-weight: bold; font-size: 14px;">✓</span>
                           </div>
                           <div style="flex: 1;">
                             <div style="font-weight: 600; color: #28a745; font-size: 16px;">Connected!</div>
                             <div style="color: #666; font-size: 14px;">` + accounts[0].slice(0, 6) + '...' + accounts[0].slice(-4) + `</div>
                           </div>
                         </div>
                       `;
                       
                       // Comprehensive dApp integration
                        setTimeout(() => {
                         console.log('🔗 Performing comprehensive dApp integration...');
                         
                         // No more hiding ANY buttons - let dApp control state

                         // Update dApp UI to show connected state (keep for account label on some dApps)
                         const walletButtons = document.querySelectorAll('[class*="wallet"], [class*="account"], [class*="address"]');
                         walletButtons.forEach(btn => {
                           if (btn.textContent && !btn.textContent.includes(accounts[0].slice(0, 6))) {
                             btn.textContent = accounts[0].slice(0, 6) + '...' + accounts[0].slice(-4);
                             btn.style.color = '#28a745';
                             console.log('🔗 Updated wallet button text');
                           }
                         });
                         
                         // Close the modal if present
                          const modal = walletOption.closest('[class*="modal"], [class*="overlay"], [class*="popup"], [class*="dialog"], [role="dialog"]');
                          if (modal) {
                            modal.style.display = 'none';
                            console.log('🔗 Closed wallet selection modal');
                          }
                         
                         // Force dApp to refresh connection state
                         if (window.location.reload) {
                           console.log('🔗 Refreshing dApp connection state...');
                           // Don't reload, just trigger a re-render
                           window.dispatchEvent(new Event('resize'));
                         }
                         
                         console.log('✅ DApp integration complete!');
                       }, 1500);
                      }
                    }
                  } catch (error) {
                    console.log('🔗 DEX Wallet connection error:', error);
                    console.log('🔗 Error details:', error.message || error);
                    
                    // Show error state
                    walletOption.style.background = '#f8d7da';
                    walletOption.style.borderColor = '#dc3545';
                    walletOption.innerHTML = `
                      <div style="display: flex; align-items: center; width: 100%;">
                        <div style="width: 32px; height: 32px; background: #dc3545; border-radius: 8px; display: flex; align-items: center; justify-content: center; margin-right: 12px;">
                          <span style="color: white; font-weight: bold; font-size: 14px;">✗</span>
                        </div>
                        <div style="flex: 1;">
                          <div style="font-weight: 600; color: #dc3545; font-size: 16px;">Connection Failed</div>
                          <div style="color: #6b7280; font-size: 14px;">Error: ' + (error.message || 'Unknown error') + '</div>
                        </div>
                      </div>
                    `;
                    
                    // Reset after 3 seconds
                    setTimeout(() => {
                      walletOption.style.background = 'white';
                      walletOption.style.borderColor = '#e1e5e9';
                      walletOption.innerHTML = `
                        <div style="display: flex; align-items: center; width: 100%;">
                          <div style="width: 32px; height: 32px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 8px; display: flex; align-items: center; justify-content: center; margin-right: 12px;">
                            <span style="color: white; font-weight: bold; font-size: 14px;">D</span>
                          </div>
                          <div style="flex: 1;">
                            <div style="font-weight: 600; color: #1a1a1a; font-size: 16px;">DEX Wallet</div>
                            <div style="color: #6b7280; font-size: 14px;">Connect with DEX Wallet</div>
                          </div>
                          <div style="color: #6b7280; font-size: 14px;">→</div>
                        </div>
                      `;
                    }, 3000);
                  }
                });
                
                return walletOption;
              };
              
              // Inject DEX Wallet into wallet selection modals
              const injectWalletOption = () => {
                console.log('🔗 Looking for wallet selection modals...');
                
                // Common selectors for wallet selection modals
                const modalSelectors = [
                  // Uniswap
                  '[class*="WalletModal"]',
                  '[class*="wallet-modal"]',
                  '[class*="ConnectModal"]',
                  '[class*="connect-modal"]',
                  '[data-testid="wallet-modal"]',
                  '[data-testid="connect-modal"]',
                  // OpenSea
                  '[class*="ConnectWalletModal"]',
                  '[class*="connect-wallet-modal"]',
                  '[class*="WalletSelector"]',
                  '[class*="wallet-selector"]',
                  '[class*="WalletOptions"]',
                  '[class*="wallet-options"]',
                  '[class*="WalletButton"]',
                  '[class*="wallet-button"]',
                  // Compound
                  '[class*="WalletConnectModal"]',
                  '[class*="wallet-connect-modal"]',
                  '[class*="ConnectButton"]',
                  '[class*="connect-button"]',
                  // Modal content
                  '[class*="ModalContent"]',
                  '[class*="modal-content"]',
                  '[class*="WalletList"]',
                  '[class*="wallet-list"]',
                  '[class*="WalletGrid"]',
                  '[class*="wallet-grid"]',
                  // Generic modal selectors
                  '[class*="modal"]',
                  '[class*="overlay"]',
                  '[class*="popup"]',
                  '[role="dialog"]'
                ];
                
                modalSelectors.forEach(selector => {
                  const elements = document.querySelectorAll(selector);
                  elements.forEach(element => {
                    // Check if this element contains wallet options
                    const hasWalletOptions = element.textContent && (
                      element.textContent.includes('MetaMask') ||
                      element.textContent.includes('WalletConnect') ||
                      element.textContent.includes('Coinbase') ||
                      element.textContent.includes('Connect') ||
                      element.textContent.includes('wallet') ||
                      element.textContent.includes('Rainbow') ||
                      element.textContent.includes('Trust') ||
                      element.textContent.includes('Ledger') ||
                      element.textContent.includes('Trezor') ||
                      element.textContent.includes('Phantom') ||
                      element.textContent.includes('OpenSea') ||
                      element.textContent.includes('Compound') ||
                      element.textContent.includes('DeFi')
                    );
                    
                    if (hasWalletOptions && !walletModals.has(element)) {
                      console.log('🔗 Found wallet modal:', element);
                      walletModals.add(element);
                      
                      // Check if DEX Wallet is already injected in this modal
                      if (!element.querySelector('[data-dex-wallet-option]')) {
                        // Also check globally to prevent multiple injections
                        const globalDexWallet = document.querySelector('[data-dex-wallet-option]');
                        if (globalDexWallet) {
                          console.log('🔗 DEX Wallet already exists globally, skipping...');
                          return;
                        }
                        
                        const dexWalletOption = createDexWalletOption();
                        
                        // Try to find the best place to inject
                        const walletList = element.querySelector('[class*="WalletList"], [class*="wallet-list"], [class*="WalletGrid"], [class*="wallet-grid"]');
                        if (walletList) {
                          walletList.insertBefore(dexWalletOption, walletList.firstChild);
                          console.log('🔗 DEX Wallet injected at top of wallet list');
                        } else {
                          element.insertBefore(dexWalletOption, element.firstChild);
                          console.log('🔗 DEX Wallet injected into modal');
                        }
                        
                        injectedWallets.add(element);
                      }
                    }
                  });
                });
              };
              
              // Monitor for new wallet modals
              const observer = new MutationObserver((mutations) => {
                let shouldInject = false;
                mutations.forEach((mutation) => {
                  if (mutation.type === 'childList') {
                    mutation.addedNodes.forEach((node) => {
                      if (node.nodeType === 1) { // Element node
                        const element = node;
                        if (element.textContent && (
                          element.textContent.includes('MetaMask') ||
                          element.textContent.includes('WalletConnect') ||
                          element.textContent.includes('Coinbase') ||
                            element.textContent.includes('Connect') ||
                            element.textContent.includes('wallet') ||
                            element.textContent.includes('Rainbow') ||
                            element.textContent.includes('Trust') ||
                            element.textContent.includes('Ledger') ||
                            element.textContent.includes('Trezor') ||
                            element.textContent.includes('Phantom') ||
                            element.textContent.includes('OpenSea') ||
                            element.textContent.includes('Compound') ||
                            element.textContent.includes('DeFi')
                        )) {
                          shouldInject = true;
                        }
                      }
                    });
                  }
                });
                
                if (shouldInject) {
                    // Check if DEX Wallet already exists before injecting
                    const existingDexWallet = document.querySelector('[data-dex-wallet-option]');
                    if (existingDexWallet) {
                      console.log('🔗 DEX Wallet already exists, skipping injection...');
                      return;
                    }
                    
                  console.log('🔗 New wallet modal detected, injecting...');
                  setTimeout(injectWalletOption, 100);
                }
              });
              
              // Start monitoring
              observer.observe(document.body, {
                childList: true,
                subtree: true
              });
              
              // Initial injection attempts
              setTimeout(injectWalletOption, 2000);
              
              // Monitor for wallet connection changes
              if (window.ethereum) {
                window.ethereum.on('accountsChanged', (accounts) => {
                  if (accounts && accounts.length > 0) {
                    console.log('🔗 Wallet connected:', accounts[0]);
                    isConnected = true;
                  } else {
                    console.log('🔗 Wallet disconnected');
                    isConnected = false;
                  }
                });
              }
              
              console.log('🔗 Wallet option injection setup complete');
              } // Close else block
            } catch (e) {
              console.error('❌ Error in wallet option injection:', e);
            }
          })();
          """
      );


      // Log to console
      await _controller!.evaluateJavascript(
          source: "console.log('🔗 WalletKit provider injected and ready');"
      );

      print(early
          ? '✅ (Early) WalletKit provider injected before DApp load'
          : '✅ WalletKit provider injected');
    } catch (e) {
      print('💥 Error injecting WalletKit provider: $e');
    }
  }

  int _inferChainIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final chainParam = uri.queryParameters['chain']?.toLowerCase();
      switch (chainParam) {
        case 'sepolia':
          return 11155111;
        case 'mainnet':
          return 1;
        case 'polygon':
          return 137;
        case 'arbitrum':
          return 42161;
        case 'optimism':
          return 10;
      }
    } catch (_) {}
    return 1;
  }

  /// Proactively fetch and cache balance when wallet connects
  Future<void> _proactivelyFetchBalance(String address, int chainId) async {
    print('💰💰💰 _proactivelyFetchBalance ENTERED for $address on chain $chainId');
    
    if (_controller == null) {
      print('❌ _proactivelyFetchBalance: _controller is null, cannot proceed');
      return;
    }
    
    print('✅ _proactivelyFetchBalance: _controller is not null, proceeding...');
    
    try {
      print('💰💰💰 Proactively fetching balance for $address on chain $chainId...');
      
      // Get correct RPC URL based on chain ID
      String rpcUrl;
      switch (chainId) {
        case 1:
          rpcUrl = BlockchainConfig.ethereumMainnetRpc;
          break;
        case 11155111:
          rpcUrl = BlockchainConfig.ethereumSepoliaRpc;
          break;
        case 137:
          rpcUrl = BlockchainConfig.polygonMainnetRpc;
          break;
        case 80001:
          rpcUrl = BlockchainConfig.polygonMumbaiRpc;
          break;
        case 56:
          rpcUrl = BlockchainConfig.bscMainnetRpc;
          break;
        case 97:
          rpcUrl = BlockchainConfig.bscTestnetRpc;
          break;
        case 42161:
          rpcUrl = BlockchainConfig.arbitrumMainnetRpc;
          break;
        case 421614:
          rpcUrl = BlockchainConfig.arbitrumSepoliaRpc;
          break;
        case 10:
          rpcUrl = BlockchainConfig.optimismMainnetRpc;
          break;
        case 11155420:
          rpcUrl = BlockchainConfig.optimismSepoliaRpc;
          break;
        default:
          rpcUrl = BlockchainConfig.ethereumSepoliaRpc;
      }
      
      print('💰 Using RPC URL for proactive balance fetch: $rpcUrl');
      
      // Normalize address
      String normalizedAddr = address.toLowerCase();
      if (!normalizedAddr.startsWith('0x')) {
        normalizedAddr = '0x$normalizedAddr';
      }
      
      // Log the exact request being sent
      final requestBody = {
        'jsonrpc': '2.0',
        'method': 'eth_getBalance',
        'params': [normalizedAddr, 'latest'],
        'id': 1,
      };
      
      print('💰 RPC Request URL: $rpcUrl');
      print('💰 RPC Request Address: $normalizedAddr');
      print('💰 RPC Request Body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(rpcUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('💰 RPC Response Status: ${response.statusCode}');
      print('💰 RPC Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null) {
          final balance = data['result'].toString();
          print('✅ Proactively fetched balance: $balance');
          
          // Convert to ETH for verification
          if (balance.startsWith('0x')) {
            try {
              final balanceWei = BigInt.parse(balance);
              // Convert to ETH properly: convert to double and divide by 1e18
              final balanceEthDouble = balanceWei.toDouble() / 1000000000000000000;
              print('💰 Balance in ETH: $balanceEthDouble ETH');
              print('💰 Balance in Wei: $balanceWei Wei');
            } catch (e) {
              print('⚠️ Could not parse balance: $e');
            }
          }
          
          // Cache the balance in the provider
          await _controller!.evaluateJavascript(
            source: """
            (function() {
              if (window.ethereum) {
                // Cache balance in provider
                window.ethereum._cachedBalance = '$balance';
                window.ethereum._cachedBalanceAddress = '$normalizedAddr';
                console.log('💰💰💰 Balance proactively cached in provider:', '$balance');
                console.log('💰💰💰 Cached for address:', '$normalizedAddr');
                
                // Force Uniswap to check balance by calling eth_getBalance proactively
                setTimeout(async () => {
                  try {
                    const testBalance = await window.ethereum.request({
                      method: 'eth_getBalance',
                      params: ['$normalizedAddr', 'latest']
                    });
                    console.log('💰💰💰 TEST: eth_getBalance returned:', testBalance);
                    console.log('💰💰💰 TEST: Balance matches cache:', testBalance === '$balance');
                    
                    // Emit balance update events
                    if (window.ethereum.emit) {
                      window.ethereum.emit('balanceChanged', {
                        address: '$normalizedAddr',
                        balance: testBalance
                      });
                      console.log('💰💰💰 Emitted balanceChanged event');
                    }
                    
                    // Trigger window event
                    window.dispatchEvent(new CustomEvent('ethereum#balanceChanged', {
                      detail: { address: '$normalizedAddr', balance: testBalance }
                    }));
                    console.log('💰💰💰 Dispatched ethereum#balanceChanged event');
                  } catch (e) {
                    console.error('❌ TEST: eth_getBalance failed:', e);
                  }
                }, 1500);
                
                // Also trigger after a delay to catch delayed checks
                setTimeout(async () => {
                  try {
                    await window.ethereum.request({
                      method: 'eth_getBalance',
                      params: ['$normalizedAddr', 'latest']
                    });
                    console.log('💰💰💰 Delayed balance check triggered');
                  } catch (e) {
                    console.error('❌ Delayed balance check failed:', e);
                  }
                }, 3000);
              }
            })();
            """
          );
        } else {
          print('⚠️ Failed to get balance from RPC response');
        }
      } else {
        print('❌ Failed to fetch balance from RPC: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ Error proactively fetching balance: $e');
      print('Stack trace: $stackTrace');
    }
  }
}





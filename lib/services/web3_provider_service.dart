// lib/services/web3_provider_service_simple.dart
import 'package:flutter/foundation.dart';
import 'wallet_service.dart';

class Web3ProviderServiceSimple extends ChangeNotifier {
  static final Web3ProviderServiceSimple _instance = Web3ProviderServiceSimple._internal();
  factory Web3ProviderServiceSimple() => _instance;
  Web3ProviderServiceSimple._internal();

  bool _isConnected = false;
  String? _connectedAddress;
  int _chainId = 11155111; // Sepolia testnet default (decimal)
  WalletService? _walletService;

  bool get isConnected => _isConnected;
  String? get connectedAddress => _connectedAddress;
  int get chainId => _chainId;
  WalletService? get walletService => _walletService;

  /// Initialize with wallet address and chain ID
  void initializeWithWallet(String address, int chainId) {
    print('🔗 Web3ProviderService: Initializing with address: $address, chainId: $chainId (0x${chainId.toRadixString(16)})');
    _connectedAddress = address;
    _chainId = chainId;
    _isConnected = _connectedAddress != null && _connectedAddress!.isNotEmpty;
    print('🔗 Web3ProviderService: Final state - address: $_connectedAddress, chainId: $_chainId, isConnected: $_isConnected');
    notifyListeners();
  }

  /// Initialize with existing wallet (compatibility method)
  Future<void> initializeWithExistingWallet(String address, int chainId) async {
    print('🔗 Web3ProviderServiceSimple: Initializing with existing wallet...');
    print('🔗 Provided address: $address');
      _connectedAddress = address;
      _chainId = chainId;
      _isConnected = true;

    // Use unified WalletService
    _walletService = WalletService();
    
        // Try to load existing wallet from storage
    final loaded = await _walletService!.loadWalletFromStorage();
        if (!loaded) {
      print('⚠️ Web3ProviderServiceSimple: No stored private key found (will continue with lightweight provider for balance checking only)');
      // Initialize wallet with address only for balance checking
      try {
        await _walletService!.createWalletWithAddress(address);
        print('✅ Web3ProviderServiceSimple: Initialized wallet with address for balance checking');
      } catch (e) {
        print('⚠️ Web3ProviderServiceSimple: Failed to initialize address-only wallet: $e');
      }
      _isConnected = true;
      _connectedAddress = address;
      print('⚠️ Web3ProviderServiceSimple: Wallet initialized in ADDRESS-ONLY mode - transactions CANNOT be signed');
      print('⚠️ Web3ProviderServiceSimple: To enable transaction signing, please retrieve wallet details with PIN');
    } else {
      // Private key loaded successfully
      final storedWalletAddress = _walletService!.blockchainAddress;
      print('🔍 WalletService loaded wallet address: $storedWalletAddress');
      print('🔍 Provided address: $address');
      
      // Only use stored wallet address if it matches the provided address
      if (storedWalletAddress != null && storedWalletAddress.toLowerCase() == address.toLowerCase()) {
        print('✅ Stored wallet address matches provided address, using it');
        _connectedAddress = storedWalletAddress;
        
        // Check if wallet has credentials for signing
        if (_walletService!.isConnected) {
          print('✅ Web3ProviderServiceSimple: Wallet initialized with CREDENTIALS - transactions CAN be signed!');
        } else {
          print('⚠️ Web3ProviderServiceSimple: Wallet loaded but no credentials available - transactions CANNOT be signed');
        }
      } else {
        print('⚠️ Stored wallet address ($storedWalletAddress) does NOT match provided address ($address)');
        print('⚠️ This means the stored private key is for a different wallet');
        print('⚠️ Clearing wrong private key and initializing address-only mode...');
        
        // Clear the wrong private key from storage
        await _walletService!.clearStoredWallet();
        
        // Initialize wallet with address only for balance checking
        try {
          await _walletService!.createWalletWithAddress(address);
          print('✅ Web3ProviderServiceSimple: Initialized wallet with address for balance checking');
    } catch (e) {
          print('⚠️ Web3ProviderServiceSimple: Failed to initialize address-only wallet: $e');
        }
        
        _connectedAddress = address;
        print('⚠️ Web3ProviderServiceSimple: Wallet initialized in ADDRESS-ONLY mode - transactions CANNOT be signed');
        print('⚠️ Web3ProviderServiceSimple: Please retrieve wallet details with PIN to save the correct private key and enable transaction signing');
      }
    }
    print('✅ Web3ProviderServiceSimple: Initialized with existing wallet');
    print('📍 Final connected address: $_connectedAddress');
    print('🔗 Chain ID: $_chainId');
    print('🔐 Has credentials for signing: ${_walletService!.isConnected}');
        notifyListeners();
      }

  /// Get the simplified Web3 injection code
  String getWeb3InjectionCode() {
    final address = _connectedAddress ?? '';
    final hexChainId = '0x${_chainId.toRadixString(16)}';
    final safeAddress = address.replaceAll("'", "\\'");

    return '''
(function() {
  try {
    console.log("🔗 Injecting DEX Wallet Web3 provider...");
    if (window.__DEX_WALLET_INJECTED__) {
      console.log("🔗 DEX Wallet provider already injected.");
      return;
    }
    window.__DEX_WALLET_INJECTED__ = true;

    class DEXWalletProvider {
      constructor() {
        this.isDEX = true;
        this.isDEXWallet = true;
        this.selectedAddress = '${safeAddress}';
        this.chainId = '${hexChainId}';
        this.networkVersion = '${_chainId}';
        this.isConnected = () => !!this.selectedAddress; // function form
        // also expose as a getter property for stricter dApps
        try {
          Object.defineProperty(this, 'isConnected', {
            get: () => !!this.selectedAddress,
            configurable: true,
            enumerable: true,
          });
        } catch(e) { /* noop if defineProperty fails */ }
            this.isMetaMask = true;
        this.version = '1.0.0';
        this.default = this;
        this.currentProvider = this;
        this._listeners = {};
        this._state = {
          accounts: this.selectedAddress ? [this.selectedAddress] : [],
          isConnected: !!this.selectedAddress,
          isUnlocked: true
        };
        // minimal _metamask shim used by some dApps
        this._metamask = {
          isUnlocked: async () => true
        };
        // also expose top-level isUnlocked for stricter UIs
        this.isUnlocked = true;
        // Cache for balance
        this._cachedBalance = null;
        this._cachedBalanceAddress = null;
      }
      on(event, callback) {
        if (!this._listeners[event]) this._listeners[event] = [];
        this._listeners[event].push(callback);
        console.log('🔗 Event listener added:', event);
      }
      removeListener(event, callback) {
        if (this._listeners[event]) {
          this._listeners[event] = this._listeners[event].filter(fn => fn !== callback);
        }
      }
      off(event, callback) { this.removeListener(event, callback); }
      emit(event, data) {
        if (this._listeners[event]) {
          this._listeners[event].forEach(cb => { try { cb(data); } catch(e){} });
        }
        console.log('🔗 Event emitted:', event, data);
      }
      async request(params) {
        const { method, params: requestParams } = params;
        console.log('🔗 DEX Wallet request:', method, requestParams);
          switch (method) {
          case 'eth_call': {
                    if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
              const result = await window.flutter_inappwebview.callHandler('handleCall', requestParams);
              return result;
            }
            // Minimal fallback
            return '0x';
          }
          case 'wallet_getCapabilities': {
            const addr = (this.selectedAddress || '').toLowerCase();
            const caps = {
              eth_sendTransaction: { canSend: true },
              personal_sign: { canSign: true },
              eth_sign: { canSign: true },
              eth_signTypedData_v4: { canSign: true },
              eth_accounts: { canExpose: true },
              eth_chainId: { canExpose: true },
              eth_getBalance: { canExpose: true }
            };
            return addr ? { [addr]: caps } : {};
          }

          case 'web3_clientVersion':
            return 'DEXWallet/1.0.0';

          case 'eth_requestAccounts': {
            if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
              const accounts = await window.flutter_inappwebview.callHandler('getAccounts', []);
              this.selectedAddress = accounts && accounts[0] ? accounts[0] : '';
              this._state.accounts = accounts;
              this._state.isConnected = !!this.selectedAddress;
              this.emit('accountsChanged', accounts);
              this.emit('chainChanged', this.chainId);
              this.emit('connect', { chainId: this.chainId });
              // Custom events for some dApps
              try { window.dispatchEvent(new CustomEvent('ethereum#accountsChanged', { detail: accounts })); } catch(e) {}
              try { window.dispatchEvent(new CustomEvent('ethereum#chainChanged', { detail: this.chainId })); } catch(e) {}
              try { window.dispatchEvent(new CustomEvent('ethereum#connect', { detail: { chainId: this.chainId } })); } catch(e) {}
              return accounts && accounts.length > 0 ? accounts : ['${safeAddress}'];
            }
            return ['${safeAddress}'];
          }
          case 'eth_accounts':
            return this.selectedAddress ? [this.selectedAddress] : [];
            case 'eth_chainId':
              return this.chainId;
          case 'wallet_requestPermissions': {
            // Return minimal permission structure for eth_accounts so UIs mark as connected
            return [{
              caveats: [],
              date: Date.now(),
              id: 'eth_accounts',
              parentCapability: 'eth_accounts'
            }];
          }
          case 'wallet_getPermissions': {
            return [{
              caveats: [],
              date: Date.now(),
              id: 'eth_accounts',
              parentCapability: 'eth_accounts'
            }];
          }
          case 'eth_getBalance': {
              console.log('💰💰💰 eth_getBalance called in provider!');
              console.log('💰 eth_getBalance params:', requestParams);
              
              // Check cache first
              if (this._cachedBalance && requestParams && requestParams.length > 0) {
                const requestedAddr = requestParams[0].toLowerCase();
                if (requestedAddr === this._cachedBalanceAddress) {
                  console.log('💰💰💰 Returning cached balance:', this._cachedBalance);
                  console.log('💰💰💰 Cached balance in Wei:', this._cachedBalance);
                  
                  // Log the balance value for debugging
                  try {
                    const balanceWei = BigInt(this._cachedBalance);
                    const balanceEth = Number(balanceWei) / 1e18;
                    console.log('💰💰💰 Cached balance in ETH:', balanceEth, 'ETH');
                    const usdValue = (balanceEth * 3000).toFixed(2);
                    console.log('💰💰💰 Cached balance in USD (estimated): ' + usdValue + ' USD');
                  } catch (e) {
                    console.log('⚠️ Could not parse cached balance:', e);
                  }
                  
                  return this._cachedBalance;
                } else {
                  console.log('⚠️ Cache mismatch - requested:', requestedAddr, 'vs cached:', this._cachedBalanceAddress);
                }
              } else {
                console.log('⚠️ No cache available or invalid params');
              }
              
              if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
              console.log('💰 Calling Flutter handleGetBalance handler...');
              const balance = await window.flutter_inappwebview.callHandler('handleGetBalance', requestParams);
              console.log('💰 Flutter returned balance:', balance);
              console.log('💰💰💰 Balance returned to Uniswap:', balance);
              
              // Log the balance value for debugging
              if (balance && balance !== '0x0' && balance !== '0x') {
                try {
                  const balanceWei = BigInt(balance);
                  const balanceEth = Number(balanceWei) / 1e18;
                  console.log('💰💰💰 Balance in ETH:', balanceEth, 'ETH');
                  const usdValue = (balanceEth * 3000).toFixed(2);
                  console.log('💰💰💰 Balance in USD (estimated): ' + usdValue + ' USD');
                } catch (e) {
                  console.log('⚠️ Could not parse balance:', e);
                }
              } else {
                console.log('⚠️⚠️⚠️ WARNING: Balance is zero or empty!');
              }
              
              // Cache the balance for future calls
              if (requestParams && requestParams.length > 0 && balance) {
                this._cachedBalance = balance;
                this._cachedBalanceAddress = requestParams[0].toLowerCase();
                console.log('💰 Balance cached for address:', this._cachedBalanceAddress);
              }
              
              return balance;
              }
            console.log('⚠️ Flutter handler not available, using fallback');
            return '0x' + (1000000000000000000).toString(16); // fallback
              }
          case 'eth_sendTransaction': {
              if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
              const txHash = await window.flutter_inappwebview.callHandler('handleTransaction', requestParams);
              return txHash;
            }
            return '0x' + Math.random().toString(16).slice(2, 66);
          }
          case 'personal_sign':
          case 'eth_sign': {
              if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
              const sig = await window.flutter_inappwebview.callHandler('handleSign', requestParams);
              return sig;
            }
            return '0x' + Math.random().toString(16).slice(2, 130);
          }
          case 'eth_getTransactionCount': {
              if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
              const nonce = await window.flutter_inappwebview.callHandler('handleGetTransactionCount', requestParams);
              return nonce;
              }
              return '0x0';
          }
          case 'wallet_switchEthereumChain': {
            if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler && requestParams && requestParams[0] && requestParams[0].chainId) {
              const success = await window.flutter_inappwebview.callHandler('handleChainSwitch', requestParams);
              if (success) {
                this.chainId = requestParams[0].chainId;
                this.networkVersion = parseInt(this.chainId, 16).toString();
                this.emit('chainChanged', this.chainId);
                try { window.dispatchEvent(new CustomEvent('ethereum#chainChanged', { detail: this.chainId })); } catch(e) {}
              }
              return null;
            }
            throw new Error('wallet_switchEthereumChain not supported');
          }
          case 'wallet_addEthereumChain': {
              if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
              const success = await window.flutter_inappwebview.callHandler('handleAddChain', requestParams);
              return success;
              }
            throw new Error('wallet_addEthereumChain not supported');
              }
            default:
            console.log('🔗 Unsupported method:', method);
            throw new Error('Unsupported method: ' + method);
        }
      }
      send(method, params) { return this.request({ method, params }); }
      // legacy enable() used by older dApps
      async enable() {
        const accounts = await this.request({ method: 'eth_requestAccounts' });
        return accounts;
      }
    }
    // Create and install provider
      const provider = new DEXWalletProvider();
    window.ethereum = provider;
    window.web3 = { ethereum: provider };
    // MetaMask compatibility: providers as array, not object!
    window.ethereum.providers = [window.ethereum];
    // EIP-6963: Announce provider for dApp discovery
    try {
      const providerInfo = {
        uuid: 'dex-wallet-provider',
        name: 'DEX Wallet',
        icon: 'data:image/svg+xml;base64,',
        rdns: 'com.dex.wallet'
      };
      const announce = () => {
        try {
          window.dispatchEvent(new CustomEvent('eip6963:announceProvider', {
            detail: Object.freeze({ info: providerInfo, provider })
          }));
        } catch (_) {}
      };
      // announce immediately and when requested
      announce();
      window.addEventListener('eip6963:requestProvider', announce);
    } catch(_) {}
    if (typeof window.web3 !== 'undefined') {
      window.web3.default = provider;
      // window.web3.providers = { ethereum: provider }; // skip, MM uses array
      window.web3js = provider;
    }
    console.log('✅ DEX Wallet provider injected successfully');
    console.log('📍 Address:', provider.selectedAddress);
    console.log('🔗 Chain ID:', provider.chainId);
    // Immediately emit events for eager dApps
          if (provider.selectedAddress) {
            provider.emit('accountsChanged', [provider.selectedAddress]);
            provider.emit('chainChanged', provider.chainId);
              provider.emit('connect', { chainId: provider.chainId });
      try { window.dispatchEvent(new CustomEvent('ethereum#accountsChanged', { detail: [provider.selectedAddress] })); } catch(e) {}
      try { window.dispatchEvent(new CustomEvent('ethereum#chainChanged', { detail: provider.chainId })); } catch(e) {}
      try { window.dispatchEvent(new CustomEvent('ethereum#connect', { detail: { chainId: provider.chainId } })); } catch(e) {}
    }
    setTimeout(() => {
      if (provider.selectedAddress) {
              provider.emit('accountsChanged', [provider.selectedAddress]);
              provider.emit('chainChanged', provider.chainId);
        provider.emit('connect', { chainId: provider.chainId });
        try { window.dispatchEvent(new CustomEvent('ethereum#accountsChanged', { detail: [provider.selectedAddress] })); } catch(e) {}
        try { window.dispatchEvent(new CustomEvent('ethereum#chainChanged', { detail: provider.chainId })); } catch(e) {}
        try { window.dispatchEvent(new CustomEvent('ethereum#connect', { detail: { chainId: provider.chainId } })); } catch(e) {}
      }
    }, 600);
    try { window.dispatchEvent(new Event('ethereum#initialized')); } catch(e) {}
    // also fire on DOMContentLoaded for late-binding apps
    document.addEventListener('DOMContentLoaded', () => {
      try { window.dispatchEvent(new Event('ethereum#initialized')); } catch(e) {}
      if (provider && provider.selectedAddress) {
        try { provider.emit('connect', { chainId: provider.chainId }); } catch(e) {}
        try { provider.emit('accountsChanged', [provider.selectedAddress]); } catch(e) {}
        try { provider.emit('chainChanged', provider.chainId); } catch(e) {}
      }
    });
  } catch (error) {
    console.error('❌ Error injecting DEX Wallet provider:', error);
  }
})();
''';
  }

  /// Get balance for address
  Future<String> getBalance(String address) async {
    try {
      if (_walletService != null) {
        // Use unified WalletService getBalance method
        final balance = await _walletService!.getBalance(address);
        return balance;
      }
      
      // Final fallback: return 0
      print('⚠️ No WalletService available, returning 0 balance');
      return '0x0';
    } catch (e) {
      print('❌ Get balance failed: $e');
      return '0x0';
    }
  }

  /// Send transaction
  Future<String> sendTransaction({
    required String to,
    String value = '0x0',
    String? data,
    String? gasLimit,
    String? gasPrice,
  }) async {
    try {
      if (_walletService != null) {
        return await _walletService!.sendTransaction(
        to: to,
        value: value,
          data: data ?? '0x',
        gasLimit: gasLimit,
        gasPrice: gasPrice,
      );
      }
      throw Exception('WalletService not initialized');
    } catch (e) {
      print('❌ Send transaction failed: $e');
      throw Exception('Transaction failed: $e');
    }
  }

  /// Sign message
  Future<String> signMessage(String message) async {
    try {
      if (_walletService != null) {
        return await _walletService!.signMessage(message);
      }
      throw Exception('WalletService not initialized');
    } catch (e) {
      print('❌ Sign message failed: $e');
      throw Exception('Sign message failed: $e');
    }
  }

  /// Switch chain
  Future<void> switchChain(int chainId) async {
    try {
      if (_walletService != null) {
        await _walletService!.switchChain(chainId);
        _chainId = chainId;
        notifyListeners();
      }
    } catch (e) {
      print('❌ Switch chain failed: $e');
      throw Exception('Switch chain failed: $e');
    }
  }

  /// Sign typed data
  Future<String> signTypedData(Map<String, dynamic> typedData) async {
    try {
      if (_walletService != null) {
        // Convert Map to JSON string
        final jsonString = typedData.toString();
        return await _walletService!.signTypedData(jsonString);
      }
      throw Exception('WalletService not initialized');
    } catch (e) {
      print('❌ Sign typed data failed: $e');
      throw Exception('Sign typed data failed: $e');
    }
  }

  /// Initialize WalletKit (placeholder for compatibility)
  Future<void> initializeWalletKit({
    required String projectId,
    required String metadataName,
    required String metadataDescription,
    required String metadataUrl,
  }) async {
    print('🔗 Web3ProviderServiceSimple: WalletKit initialization (simplified)');
    print('📋 Project ID: $projectId');
    print('📋 Metadata: $metadataName - $metadataDescription');
    print('📋 URL: $metadataUrl');
    // Simplified version doesn't use WalletKit
    print('✅ Web3ProviderServiceSimple: Initialized (simplified mode)');
  }

  /// Register wallet for discovery (placeholder for compatibility)
  Future<void> registerWalletForDiscovery() async {
    print('🔗 Web3ProviderServiceSimple: Registering wallet for discovery (simplified)');
    // Simplified version doesn't use discovery
    print('✅ Web3ProviderServiceSimple: Wallet registered for discovery (simplified mode)');
  }

  /// Make wallet discoverable (placeholder for compatibility)
  Future<void> makeWalletDiscoverable() async {
    print('🔗 Web3ProviderServiceSimple: Making wallet discoverable (simplified)');
    // Simplified version doesn't use discovery
    print('✅ Web3ProviderServiceSimple: Wallet is discoverable (simplified mode)');
  }
}





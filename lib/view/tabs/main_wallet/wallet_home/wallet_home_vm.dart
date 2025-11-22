import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/base_vm.dart';
import '../../../../data/repos/wallet_repo.dart';
import '../../../../data/model/body/wallet_model.dart';
import '../../../../data/model/body/wallet_list_item_model.dart';
import '../../../../data/model/body/wallet_retrieval_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/wallet_service.dart';
import 'package:intl/intl.dart';

/// ViewModel for Wallet Home Screen
/// Handles navigation, API calls, and market data fetching.
class WalletHomeVM extends BaseVM {
  final WalletRepo _walletRepo = WalletRepo();
  final AuthService _authService = AuthService();
  bool _isGeneratingWallet = false;
  bool _hasExistingWallets = false;
  bool _isCheckingWallets = true;
  bool _hasInitialized = false;
  
  bool get isGeneratingWallet => _isGeneratingWallet;
  bool get hasExistingWallets => _hasExistingWallets;
  bool get isCheckingWallets => _isCheckingWallets;
  bool get hasInitialized => _hasInitialized;

  /// Initialize the ViewModel - check for existing wallets
  Future<void> initialize(BuildContext context) async {
    if (_hasInitialized) {
      print('🔄 WalletHomeVM - Already initialized, skipping...');
      return;
    }
    
    print('🚀 WalletHomeVM - Starting initialization...');
    _hasInitialized = true;
    
    try {
      await _checkExistingWallets(context);
      print('✅ WalletHomeVM - Initialization completed successfully');
    } catch (e) {
      print('❌ WalletHomeVM - Initialization failed: $e');
      _hasInitialized = false; // Reset flag so it can be retried
      rethrow;
    }
  }

  /// Reset the ViewModel (called after logout)
  void reset() {
    print('🔄 WalletHomeVM - Resetting...');
    _hasInitialized = false;
    _hasExistingWallets = false;
    _isCheckingWallets = false; // Reset to false so it can check again
    _isGeneratingWallet = false;
    notifyListeners();
  }

  /// Check if user has existing wallets
  Future<void> _checkExistingWallets(BuildContext context) async {
    if (_isCheckingWallets) {
      print('🔄 WalletHomeVM - Already checking wallets, skipping...');
      return;
    }
    
    try {
      print('🔍 Checking for existing wallets...');
      _isCheckingWallets = true;
      notifyListeners();
      
      // Use cached wallet list from WalletService
      final walletService = Provider.of<WalletService>(context, listen: false);
      
      // If wallet service is not initialized, initialize it first
      if (!walletService.hasInitialized) {
        print('🔄 Wallet service not initialized, initializing...');
        await walletService.initializeWalletData();
      }
      
      _hasExistingWallets = walletService.hasWallet;
      
      print('📋 Has existing wallets: $_hasExistingWallets');
      
    } catch (e) {
      print('❌ Error checking existing wallets: $e');
      // If there's an error accessing WalletService, assume no wallets
      _hasExistingWallets = false;
    } finally {
      _isCheckingWallets = false;
      notifyListeners();
    }
  }

  /// Generate a new wallet
  Future<void> generateWallet(BuildContext context) async {
    if (_isGeneratingWallet) return;
    
    _isGeneratingWallet = true;
    notifyListeners();
    
    try {
      print('🔄 Starting wallet generation...');
      
      // Check if user is authenticated
      final isAuthenticated = await _authService.isAuthenticated();
      final token = await _authService.getAuthToken();
      
      print('🔐 Authentication check:');
      print('   - Is authenticated: $isAuthenticated');
      print('   - Token exists: ${token != null}');
      print('   - Token length: ${token?.length ?? 0}');
      print('   - Token preview: ${token?.substring(0, token.length > 20 ? 20 : token.length) ?? 'null'}...');
      
      if (!isAuthenticated) {
        print('❌ User not authenticated, showing error dialog');
        _showAuthenticationRequiredDialog(context);
        return;
      }
      
      print('✅ User is authenticated, checking PIN status');
      
      // Check if PIN is set
      final isPinSet = await _authService.isPinSet();
      print('🔐 PIN status check:');
      print('   - Is PIN set: $isPinSet');
      
      if (!isPinSet) {
        print('🔐 PIN not set, redirecting to create PIN first');
        _showPinRequiredDialog(context);
        return;
      }
      
      print('✅ PIN is set, proceeding with wallet generation');
      
      // Ensure token is set in DioClient
      await _authService.initializeAuthToken();
      
      // Get the user's PIN for wallet creation
      final userPin = await _authService.getPin();
      if (userPin == null) {
        print('❌ No PIN found for wallet creation');
        _showErrorDialog(context, 'PIN Required', 'Please set up your PIN first');
        return;
      }
      
      // Sync PIN to backend before creating wallet
      print('🔄 Syncing PIN to backend before wallet creation...');
      final pinSynced = await _authService.syncPinToBackend();
      if (!pinSynced) {
        print('⚠️ PIN sync failed, but proceeding with wallet creation');
      } else {
        print('✅ PIN synced to backend successfully');
      }
      
      final response = await _walletRepo.createWallet(
        walletType: "personal",
        walletPin: userPin,
      );
      
      print('📊 Wallet creation response: ${response.isSuccess}');
      print('📊 Response data: ${response.data}');
      print('📊 Response message: ${response.message}');
      
      if (response.isSuccess) {
        print('🎉 Wallet generated successfully!');
        
        // Parse wallet data from response
        final walletData = _extractWalletFromResponse(response.data);
        print('📊 Extracted wallet data: $walletData');
        
        if (walletData != null) {
          print('✅ Showing wallet success dialog');
          _showWalletSuccessDialog(context, walletData);
        } else {
          print('⚠️ Could not extract wallet data, showing generic success dialog');
          _showSuccessDialog(context, 'Wallet Generated Successfully!', response.data);
        }
      } else {
        print('❌ Wallet generation failed: ${response.message}');
        
        // Check if it's an authentication error
        if (response.message.toLowerCase().contains('invalid token') || 
            response.message.toLowerCase().contains('unauthorized') ||
            response.statusCode == 401) {
          print('🔐 Authentication error detected, clearing token and showing login dialog');
          await _authService.clearAuthToken();
          _showAuthenticationRequiredDialog(context);
        } 
        // Check if user already has a wallet (409 error)
        else if (response.message.toLowerCase().contains('already has a wallet') ||
                 response.statusCode == 409) {
          print('ℹ️ User already has a wallet, automatically redirecting to main wallet');
          // Automatically redirect to main wallet instead of showing dialog
          Navigator.pushReplacementNamed(context, "/mainContainer");
        } else {
          _showErrorDialog(context, 'Failed to Generate Wallet', response.message);
        }
      }
    } catch (e) {
      print('💥 Exception during wallet generation: $e');
      
      // Check if it's a 401 error in the exception
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        print('🔐 401 error in exception, clearing token and showing login dialog');
        await _authService.clearAuthToken();
        _showAuthenticationRequiredDialog(context);
      } 
      // Check if it's a 409 error (wallet already exists)
      else if (e.toString().contains('409') || e.toString().contains('already has a wallet')) {
        print('ℹ️ 409 error in exception, user already has a wallet, automatically redirecting');
        // Automatically redirect to main wallet instead of showing dialog
        Navigator.pushReplacementNamed(context, "/mainContainer");
      } else {
        _showErrorDialog(context, 'Error', 'An unexpected error occurred: $e');
      }
    } finally {
      _isGeneratingWallet = false;
      notifyListeners();
    }
  }



  /// Check authentication status
  Future<void> checkAuthStatus(BuildContext context) async {
    try {
      final isAuthenticated = await _authService.isAuthenticated();
      final token = await _authService.getAuthToken();
      
      if (isAuthenticated) {
        _showSuccessDialog(
          context, 
          'Authentication Status', 
          '✅ User is authenticated!\n\nToken: ${token?.substring(0, 20)}...'
        );
      } else {
        _showErrorDialog(
          context, 
          'Authentication Status', 
          '❌ User is not authenticated. Please log in again.'
        );
      }
    } catch (e) {
      _showErrorDialog(context, 'Error', 'An error occurred: $e');
    }
  }

  /// Extract wallet data from API response
  WalletModel? _extractWalletFromResponse(dynamic responseData) {
    try {
      print('🔍 Extracting wallet from response: $responseData');
      print('🔍 Response data type: ${responseData.runtimeType}');
      
      if (responseData is Map<String, dynamic>) {
        print('🔍 Response is Map, checking structure...');
        print('🔍 Response keys: ${responseData.keys}');
        
        // Check if response has the expected structure: { success, message, data: { wallet data } }
        if (responseData['data'] != null && responseData['data'] is Map<String, dynamic>) {
          final data = responseData['data'] as Map<String, dynamic>;
          print('🔍 Found data field: $data');
          return WalletModel.fromJson(data);
        } else {
          print('⚠️ No data field found or data is not Map');
          // Try to parse the entire response as wallet data
          print('🔍 Trying to parse entire response as wallet data...');
          return WalletModel.fromJson(responseData);
        }
      }
    } catch (e) {
      print('⚠️ Could not extract wallet from response: $e');
    }
    return null;
  }

  void _showWalletSuccessDialog(BuildContext context, WalletModel wallet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Wallet Generated Successfully!'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildWalletInfoRow('Wallet ID:', wallet.walletId),
              _buildWalletInfoRow('Address:', wallet.address),
              _buildWalletInfoRow('Type:', wallet.walletType),
              _buildWalletInfoRow('Standard:', wallet.standard),
              _buildWalletInfoRow('Networks:', wallet.compatibleNetworks.join(', ')),
              _buildWalletInfoRow('Created:', _formatDate(wallet.createdAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Refresh wallet service with new wallet data
              try {
                final walletService = Provider.of<WalletService>(context, listen: false);
                walletService.refreshWalletData();
              } catch (e) {
                print('⚠️ Could not access WalletService, using singleton directly: $e');
                final walletService = WalletService();
                walletService.refreshWalletData();
              }
              // Navigate to main wallet after successful wallet creation
              Navigator.pushReplacementNamed(context, "/mainContainer");
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _showSuccessDialog(BuildContext context, String title, dynamic data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text('Response: ${data.toString()}'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Refresh wallet service with new wallet data
              try {
                final walletService = Provider.of<WalletService>(context, listen: false);
                walletService.refreshWalletData();
              } catch (e) {
                print('⚠️ Could not access WalletService, using singleton directly: $e');
                final walletService = WalletService();
                walletService.refreshWalletData();
              }
              // Navigate to main wallet after successful wallet creation
              Navigator.pushReplacementNamed(context, "/mainContainer");
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show authentication required dialog with navigation options
  void _showAuthenticationRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Required'),
        content: const Text(
          'You need to be logged in to create a wallet.\n\n'
          'Please register or login first to get an authentication token.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login screen
              Navigator.pushNamed(context, "/login");
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to signup screen
              Navigator.pushNamed(context, "/signup");
            },
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }

  /// Show PIN required dialog
  void _showPinRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PIN Required'),
        content: const Text(
          'You need to create a PIN before creating a wallet.\n\n'
          'This PIN will be used to secure your wallet access.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to create PIN screen
              Navigator.pushNamed(context, "/create_pin");
            },
            child: const Text('Create PIN'),
          ),
        ],
      ),
    );
  }


  /// Get User's Wallet List
  Future<List<WalletListItemModel>> getWalletList() async {
    try {
      print('📋 Getting user wallet list...');
      
      final response = await _walletRepo.getWalletList();
      
      if (response.isSuccess) {
        print('✅ Wallet list retrieved successfully');
        
        // Parse wallet list from response
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          if (data['data'] != null && data['data'] is List) {
            final walletList = (data['data'] as List)
                .map((wallet) => WalletListItemModel.fromJson(wallet))
                .toList();
            print('📋 Parsed ${walletList.length} wallets');
            return walletList;
          }
        }
      } else {
        print('❌ Failed to get wallet list: ${response.message}');
      }
    } catch (e) {
      print('💥 Exception getting wallet list: $e');
    }
    return [];
  }

  /// Retrieve Wallet Data by Address
  Future<WalletRetrievalModel?> retrieveWalletData({
    required String address,
    required String walletPin,
  }) async {
    try {
      print('🔍 Retrieving wallet data for address: $address');
      
      final response = await _walletRepo.retrieveWallet(
        address: address,
        walletPin: walletPin,
      );
      
      if (response.isSuccess) {
        print('✅ Wallet data retrieved successfully');
        
        // Parse wallet data from response
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          if (data['data'] != null && data['data'] is Map<String, dynamic>) {
            final walletData = WalletRetrievalModel.fromJson(data['data']);
            print('🔍 Parsed wallet data for address: ${walletData.address}');
            return walletData;
          }
        }
      } else {
        print('❌ Failed to retrieve wallet data: ${response.message}');
      }
    } catch (e) {
      print('💥 Exception retrieving wallet data: $e');
      
      // Check if it's a timeout error
      if (e.toString().contains('receive timeout') || e.toString().contains('timeout')) {
        print('⏰ Timeout error detected - API is taking too long to respond');
        throw Exception('Request timed out. The server is taking too long to respond. Please try again later.');
      }
    }
    return null;
  }

  /// Show Wallet List Dialog
  Future<void> showWalletList(BuildContext context) async {
    try {
      print('📋 Showing wallet list...');
      
      // Get cached wallet list from WalletService
      List<WalletListItemModel> walletList;
      try {
        final walletService = Provider.of<WalletService>(context, listen: false);
        walletList = walletService.walletList;
      } catch (e) {
        print('⚠️ Could not access WalletService, using singleton directly: $e');
        final walletService = WalletService();
        walletList = walletService.walletList;
      }
      
      if (walletList.isEmpty) {
        _showErrorDialog(context, 'No Wallets Found', 'You haven\'t created any wallets yet.');
        return;
      }
      
      // Show wallet list dialog
      print('📋 Showing wallet list dialog with ${walletList.length} wallets');
      showDialog(
        context: context,
        builder: (context) => ChangeNotifierProvider.value(
          value: WalletService(),
          child: AlertDialog(
          title: const Text('My Wallets'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400, // Fixed height to ensure visibility
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: walletList.length,
              itemBuilder: (context, index) {
                final wallet = walletList[index];
                print('📋 Building wallet item: ${wallet.address}');
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.account_balance_wallet),
                    title: Text('${wallet.walletType.toUpperCase()} Wallet'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Address: ${wallet.address.substring(0, 10)}...'),
                        Text('Network: ${wallet.network}'),
                        Text('Created: ${_formatDate(wallet.createdAt)}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.visibility),
                      onPressed: () {
                        print('🔐 Wallet clicked: ${wallet.address}');
                        _showWalletDetails(context, wallet);
                      },
                    ),
                    onTap: () {
                      print('🔐 Wallet tapped: ${wallet.address}');
                      _showWalletDetails(context, wallet);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
        ),
      );
    } catch (e) {
      // Close loading dialog if it's open
      Navigator.pop(context);
      _showErrorDialog(context, 'Error', 'Failed to load wallet list: $e');
    }
  }

  /// Show Wallet Details Dialog
  Future<void> _showWalletDetails(BuildContext context, WalletListItemModel wallet) async {
    try {
      print('🔐 Wallet selected: ${wallet.address}');
      
      // First, ask user to enter PIN for this wallet
      final pinController = TextEditingController();
      bool isPinVisible = false;
      
      final pinResult = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Enter PIN'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Enter your PIN to access wallet:'),
                const SizedBox(height: 10),
                Text('${wallet.address.substring(0, 10)}...', 
                     style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                const SizedBox(height: 20),
                TextField(
                  controller: pinController,
                  obscureText: !isPinVisible,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: InputDecoration(
                    labelText: 'PIN',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(isPinVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => isPinVisible = !isPinVisible),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (pinController.text.length == 4) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text('Access Wallet'),
              ),
            ],
          ),
        ),
      );
      
      if (pinResult != true) {
        print('❌ User cancelled PIN entry');
        return;
      }
      
      final enteredPin = pinController.text;
      print('🔐 PIN entered: ${enteredPin.substring(0, 1)}***');
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Verifying PIN...',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
      
      // Retrieve wallet data with entered PIN
      final walletData = await retrieveWalletData(
        address: wallet.address,
        walletPin: enteredPin,
      );
      
      // Close loading dialog
      Navigator.pop(context);
      
      if (walletData == null) {
        _showErrorDialog(context, 'Error', 'Invalid PIN or failed to retrieve wallet details');
        return;
      }
      
      // Save private key from backend to unified WalletService
      if (walletData.privateKey.isNotEmpty) {
        try {
          print('💾 Saving private key from backend to WalletService...');
          final walletService = WalletService();
          final saved = await walletService.savePrivateKeyFromBackend(walletData.privateKey, walletData.address);
          if (saved) {
            print('✅ Private key saved and wallet initialized successfully');
            print('✅ Wallet now has credentials - transactions can be signed!');
            
            // Reload wallet from storage to ensure it's initialized
            final reloaded = await walletService.loadWalletFromStorage();
            if (reloaded) {
              print('✅ Wallet reloaded from storage with credentials');
            } else {
              print('⚠️ Wallet reload failed (non-critical)');
            }
          } else {
            print('⚠️ Failed to save private key');
          }
        } catch (e) {
          print('❌ Error saving private key: $e');
        }
      } else {
        print('⚠️ Private key is empty in wallet data');
      }
      
      // Set the selected wallet as main wallet in the service
      try {
        final walletService = Provider.of<WalletService>(context, listen: false);
        walletService.setMainWallet(walletData.address);
        print('✅ Set main wallet in service: ${walletData.address}');
      } catch (e) {
        print('⚠️ Could not access WalletService, using singleton directly: $e');
        // Fallback: use the singleton directly
        final walletService = WalletService();
        walletService.setMainWallet(walletData.address);
        print('✅ Set main wallet in service (fallback): ${walletData.address}');
      }
      
      // Navigate to main container with wallet index 0 (main wallet tab)
      print('🚀 Navigating to main container with wallet address: ${walletData.address}');
      Navigator.pushReplacementNamed(
        context, 
        "/mainContainer",
        arguments: 0, // Pass index for MainWalletScreen
      );
    } catch (e) {
      // Close loading dialog if it's open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      // Check if it's a timeout error
      if (e.toString().contains('receive timeout') || e.toString().contains('timeout')) {
        _showErrorDialog(
          context, 
          'Request Timeout', 
          'The server is taking too long to respond. This might be due to network issues or server overload. Please try again later.'
        );
      } else {
        _showErrorDialog(context, 'Error', 'Failed to retrieve wallet details: $e');
      }
    }
  }

  /// Example: Navigate to create wallet screen
  void onCreateWallet(BuildContext context) {
    Navigator.pushNamed(context, "/createWallet");
  }

  /// Example: Navigate to import wallet screen
  void onImportWallet(BuildContext context) {
    Navigator.pushNamed(context, "/importWallet");
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../util/color_resources.dart';
import '../../../../../util/size_extension.dart';
import '../../../../../helper/sb_helper.dart';
import '../../../../../widgets/app_button.dart';
import '../../../../../theme/theme_manager.dart';
import '../../../../../data/model/body/supported_chain_model.dart';
import '../../../../../config/blockchain_config.dart';
import 'send_vm.dart';
import 'qr_scanner_screen.dart';
import '../../main_wallet_vm.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  bool _initialized = false;
  bool _balanceUpdated = false;
  String? _lastChainId;

  @override
  void initState() {
    super.initState();
    // Initialize after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update balance when MainWalletVM changes - use post frame callback to avoid setState during build
    if (_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final vm = context.read<SendVM>();
        final mainWalletVM = context.read<MainWalletVM>();
        _updateSendVMWithRealBalance(vm, mainWalletVM);
      });
    }
  }

  void _initializeScreen() async {
    if (_initialized) return;
    _initialized = true;

    final vm = context.read<SendVM>();
    final mainWalletVM = context.read<MainWalletVM>();

    // Get chain data from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    SupportedChainModel? chain;
    
    if (args is Map<String, dynamic>) {
      // Convert Map to SupportedChainModel
      chain = SupportedChainModel(
        chainId: args['chainId'] as String? ?? 'ethereum',
        chainName: args['chainName'] as String? ?? 'Ethereum Sepolia',
        chainType: args['chainType'] as String? ?? 'evm',
        chainIdNumber: args['chainIdNumber'] as int? ?? 11155111,
        rpcUrl: args['rpcUrl'] as String? ?? BlockchainConfig.ethereumSepoliaRpc,
        blockExplorer: args['blockExplorer'] as String? ?? 'https://sepolia.etherscan.io',
        nativeCurrencyName: args['nativeCurrencyName'] as String? ?? 'Ethereum',
        nativeCurrencySymbol: args['nativeCurrencySymbol'] as String? ?? 'ETH',
        decimals: args['decimals'] as int? ?? 18,
        isActive: args['isActive'] as bool? ?? true,
        iconPath: args['iconPath'] as String? ?? 'assets/svgs/wallet_home/ethereum.svg',
        color: args['color'] as String? ?? '#627EEA',
      );
      print('🔍 SendScreen - Chain from route args: ${chain.chainName}');
    } else if (args is SupportedChainModel) {
      // Handle legacy SupportedChainModel format
      chain = args;
      print('🔍 SendScreen - Chain from route (legacy): ${chain.chainName}');
    } else {
      // If no chain provided, use Ethereum Sepolia as default
      print('⚠️ SendScreen - No chain provided, using default Ethereum Sepolia');
      chain = SupportedChainModel(
        chainId: "ethereum",
        chainName: "Ethereum Sepolia",
        chainType: "evm",
        chainIdNumber: 11155111,
        rpcUrl: BlockchainConfig.ethereumSepoliaRpc,
        blockExplorer: "https://sepolia.etherscan.io",
        nativeCurrencyName: "Ethereum",
        nativeCurrencySymbol: "ETH",
        decimals: 18,
        isActive: true,
        iconPath: "assets/svgs/wallet_home/ethereum.svg",
        color: "#627EEA",
      );
    }

    // Initialize VM with chain data
    if (vm.chain == null) {
      print('🔍 SendScreen - Initializing VM with chain: ${chain.chainName}');
      vm.initializeWithChain(chain);
    }
    
    // Wait for MainWalletVM to have a valid balance
    int attempts = 0;
    while (attempts < 10 && (mainWalletVM.totalBalance == "0.00 ETH" || mainWalletVM.totalBalance == "Loading...")) {
      await Future.delayed(const Duration(milliseconds: 200));
      attempts++;
      print('🔍 SendScreen - Waiting for MainWalletVM balance... attempt $attempts');
    }
    
    _updateSendVMWithRealBalance(vm, mainWalletVM);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SendVM>();
    final themeManager = Provider.of<ThemeManager>(context);

    // Get chain data from route arguments
    SupportedChainModel? chain = ModalRoute.of(context)?.settings.arguments as SupportedChainModel?;

    // If no chain provided, use Ethereum Sepolia as default
    if (chain == null) {
      chain = SupportedChainModel(
        chainId: "ethereum",
        chainName: "Ethereum Sepolia",
        chainType: "evm",
        chainIdNumber: 11155111,
        rpcUrl: BlockchainConfig.ethereumSepoliaRpc,
        blockExplorer: "https://sepolia.etherscan.io",
        nativeCurrencyName: "Ethereum",
        nativeCurrencySymbol: "ETH",
        decimals: 18,
        isActive: true,
        iconPath: "assets/svgs/wallet_home/ethereum.svg",
        color: "#627EEA",
      );
    }

    return Scaffold(
      backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeManager.currentTheme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Send ${chain.nativeCurrencySymbol}",
          style: TextStyle(
            color: themeManager.currentTheme.colorScheme.onSurface,
            fontSize: 5.sp,
            fontWeight: FontWeight.bold,
            fontFamily: "Rubik",
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            children: [
              // Wallet Balance Display
              if (vm.chain != null) _buildWalletBalanceCard(vm, themeManager),

              SB.h(2.h),

              // Chain Selector
              _buildChainSelector(vm, themeManager, context),

              SB.h(2.h),

              // Address Input Field
              _buildAddressInputField(vm, themeManager, context),

              SB.h(2.h),

              // Amount Input Field
              _buildInputField(
                label: "Amount",
                hintText: "0.00 ${chain.nativeCurrencySymbol}",
                controller: vm.cryptoAmountController,
                onChanged: vm.updateCryptoAmount,
                themeManager: themeManager,
              ),

              SB.h(2.h),

              // USD Amount Input Field
              _buildInputField(
                label: "USD Amount",
                hintText: "0.00 USD",
                controller: vm.usdAmountController,
                onChanged: vm.updateUsdAmount,
                themeManager: themeManager,
              ),

              SB.h(2.h),

              // Percentage Selection
              _buildPercentageSelection(vm, themeManager),

              SB.h(2.h),

              // Fee and Amount Section
              _buildFeeAndAmountSection(vm, themeManager),

              SB.h(4.h),

              // Send Button
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: AppButton(
                  text: "Review Transaction",
                  onTap: () => vm.reviewTransaction(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletBalanceCard(SendVM vm, ThemeManager themeManager) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeManager.currentTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: Color(int.parse(vm.chain!.color.replaceFirst('#', '0xFF'))),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    vm.chain!.nativeCurrencySymbol.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              SB.w(2.w),
              Text(
                "Wallet Balance",
                style: themeManager.currentTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SB.h(1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${vm.walletBalance} ${vm.chain!.nativeCurrencySymbol}",
                style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                "${((double.tryParse(vm.walletBalance) ?? 0.0) * vm.currentPrice).toStringAsFixed(2)}",
                style: themeManager.currentTheme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInputField(SendVM vm, ThemeManager themeManager, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Address",
              style: themeManager.currentTheme.textTheme.bodyMedium?.copyWith(
                fontSize: 3.5.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SB.w(2.w),
            // Address validation indicator
            if (vm.addressController.text.isNotEmpty)
              Icon(
                vm.isAddressValid ? Icons.check_circle : Icons.warning,
                color: vm.isAddressValid ? AppColors.primary : Colors.orange,
                size: 4.w,
              ),
          ],
        ),
        SB.h(1.h),
        GestureDetector(
          onTap: () => _openQRScanner(context, vm),
          child: TextField(
            controller: vm.addressController,
            onChanged: (value) {
              // Trigger validation update by calling a method that handles notifyListeners
              vm.updateAddressValidation();
            },
            style: themeManager.currentTheme.textTheme.bodyLarge?.copyWith(
              fontSize: 4.sp,
            ),
            decoration: InputDecoration(
              hintText: "Enter recipient address",
              hintStyle: themeManager.currentTheme.textTheme.bodyLarge?.copyWith(
                color: themeManager.currentTheme.hintColor,
                fontSize: 4.sp,
              ),
              filled: true,
              fillColor: themeManager.currentTheme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: vm.addressController.text.isNotEmpty
                      ? (vm.isAddressValid ? AppColors.primary : Colors.orange)
                      : (themeManager.currentTheme.dividerTheme.color ?? Colors.grey),
                  width: vm.addressController.text.isNotEmpty ? 2 : 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: vm.addressController.text.isNotEmpty
                      ? (vm.isAddressValid ? AppColors.primary : Colors.orange)
                      : (themeManager.currentTheme.dividerTheme.color ?? Colors.grey),
                  width: vm.addressController.text.isNotEmpty ? 2 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: vm.addressController.text.isNotEmpty
                      ? (vm.isAddressValid ? AppColors.primary : Colors.orange)
                      : AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.qr_code_scanner,
                  color: AppColors.primary,
                  size: 5.w,
                ),
                onPressed: () => _openQRScanner(context, vm),
              ),
              isDense: true,
            ),
          ),
        ),
        // Address validation message
        if (vm.addressController.text.isNotEmpty && !vm.isAddressValid)
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Text(
              "Please enter a valid Ethereum address (0x...)",
              style: TextStyle(
                color: Colors.orange,
                fontSize: 3.sp,
              ),
            ),
          ),
      ],
    );
  }

  void _openQRScanner(BuildContext context, SendVM vm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeManager()),
          ],
          child: QRScannerScreen(
            onQRCodeScanned: (address) {
              vm.setAddressFromQR(address);
              
              // Show validation feedback
              String cleanAddress = address.trim();
              bool isValid = _isValidEthereumAddress(cleanAddress);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isValid 
                      ? "Valid address scanned successfully!" 
                      : "Address scanned (please verify it's correct)",
                  ),
                  backgroundColor: isValid ? AppColors.primary : Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
        ),
      ),
    );
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

  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required Function(String) onChanged,
    required ThemeManager themeManager,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: themeManager.currentTheme.textTheme.bodyMedium?.copyWith(
            fontSize: 3.5.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SB.h(1.h),
        GestureDetector(
          onTap: onTap,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: themeManager.currentTheme.textTheme.bodyLarge?.copyWith(
              fontSize: 4.sp,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: themeManager.currentTheme.textTheme.bodyLarge?.copyWith(
                color: themeManager.currentTheme.hintColor,
                fontSize: 4.sp,
              ),
              filled: true,
              fillColor: themeManager.currentTheme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              suffixIcon: trailing,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPercentageSelection(SendVM vm, ThemeManager themeManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Percentage",
          style: themeManager.currentTheme.textTheme.bodyMedium?.copyWith(
            fontSize: 3.5.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SB.h(1.h),
        Row(
          children: ["25%", "50%", "75%", "100%"].map((percentage) {
            bool isSelected = vm.selectedPercentage == percentage;
            return Expanded(
              child: GestureDetector(
                onTap: () => vm.selectPercentage(percentage),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 1.w),
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primary 
                        : themeManager.currentTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.primary 
                          : (themeManager.currentTheme.dividerTheme.color ?? Colors.grey),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    percentage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected 
                          ? Colors.white 
                          : themeManager.currentTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                      fontSize: 3.5.sp,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFeeAndAmountSection(SendVM vm, ThemeManager themeManager) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeManager.currentTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Network Fee",
                style: themeManager.currentTheme.textTheme.bodyMedium?.copyWith(
                  fontSize: 3.5.sp,
                ),
              ),
              Text(
                "${vm.fee} ${vm.chain?.nativeCurrencySymbol ?? 'ETH'}",
                style: themeManager.currentTheme.textTheme.bodyMedium?.copyWith(
                  fontSize: 3.5.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SB.h(1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "You Will Get",
                style: themeManager.currentTheme.textTheme.bodyMedium?.copyWith(
                  fontSize: 3.5.sp,
                ),
              ),
              Text(
                "You Will Get ${vm.youWillGet} ${vm.chain?.nativeCurrencySymbol ?? 'ETH'}",
                style: themeManager.currentTheme.textTheme.bodyMedium?.copyWith(
                  fontSize: 3.5.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Update SendVM with real balance from MainWalletVM
  void _updateSendVMWithRealBalance(SendVM sendVM, MainWalletVM mainWalletVM) {
    // Reset balance update flag if chain has changed
    if (sendVM.chain != null && _lastChainId != sendVM.chain!.chainId) {
      _lastChainId = sendVM.chain!.chainId;
      _balanceUpdated = false;
      print('🔍 SendScreen - Chain changed to ${sendVM.chain!.chainName}, resetting balance update flag');
    }
    
    // Prevent infinite loop
    if (_balanceUpdated) {
      print('🔍 SendScreen - Balance already updated, skipping...');
      return;
    }
    
    // Extract ETH balance from the total balance string
    String balanceString = mainWalletVM.totalBalance;
    print('🔍 SendScreen - MainWalletVM balance: $balanceString');
    print('🔍 SendScreen - MainWalletVM isLoadingBalance: ${mainWalletVM.isLoadingBalance}');
    print('🔍 SendScreen - MainWalletVM isRefreshing: ${mainWalletVM.isRefreshing}');
    print('🔍 SendScreen - MainWalletVM cachedEthBalance: ${mainWalletVM.cachedEthBalance}');
    
    // Try to get the cached balance directly if totalBalance is still "0.00 ETH"
    if (balanceString == "0.00 ETH" || balanceString.isEmpty || balanceString == "Loading...") {
      // Use cached balance if available
      if (mainWalletVM.cachedEthBalance != null) {
        String ethBalance = mainWalletVM.cachedEthBalance!.toStringAsFixed(6);
        print('🔍 SendScreen - Using cached ETH balance: $ethBalance');
        sendVM.updateWalletBalance(ethBalance);
        _balanceUpdated = true;
        return;
      } else {
        print('🔍 SendScreen - No cached balance available, triggering refresh...');
        mainWalletVM.forceRefreshBalance();
        return;
      }
    }
    
    // Extract just the ETH amount (remove " ETH" suffix)
    String ethBalance = balanceString.replaceAll(' ETH', '').trim();
    print('🔍 SendScreen - Extracted ETH balance: $ethBalance');
    
    // Update SendVM with real balance
    sendVM.updateWalletBalance(ethBalance);
    _balanceUpdated = true;
    print('🔍 SendScreen - Updated SendVM balance to: $ethBalance');
  }

  Widget _buildChainSelector(SendVM vm, ThemeManager themeManager, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: themeManager.currentTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Network",
            style: themeManager.currentTheme.textTheme.titleMedium?.copyWith(
              fontSize: 4.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SB.h(1.h),
          DropdownButtonFormField<String>(
            value: vm.chain?.chainId ?? 'ethereum',
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              filled: true,
              fillColor: themeManager.currentTheme.colorScheme.surface,
            ),
            items: vm.getSupportedChains().map((chain) {
              return DropdownMenuItem<String>(
                value: chain.chainId,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 3.w,
                      backgroundColor: Color(int.parse(chain.color.replaceAll('#', '0xff'))),
                    ),
                    SB.w(2.w),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            chain.nativeCurrencySymbol,
                            style: themeManager.currentTheme.textTheme.titleSmall?.copyWith(
                              fontSize: 3.0.sp,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            chain.chainName,
                            style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                              fontSize: 2.0.sp,
                              height: 1.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? chainId) {
              if (chainId != null) {
                final selectedChain = vm.getSupportedChains().firstWhere(
                  (chain) => chain.chainId == chainId,
                );
                vm.switchChain(selectedChain);
              }
            },
          ),
        ],
      ),
    );
  }
}
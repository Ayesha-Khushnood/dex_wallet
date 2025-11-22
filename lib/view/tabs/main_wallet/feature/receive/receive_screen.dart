import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../../util/color_resources.dart';
import '../../../../../util/size_extension.dart';
import '../../../../../helper/sb_helper.dart';
import '../../../../../theme/theme_manager.dart';
import '../../../../../config/blockchain_config.dart';
import 'receive_vm.dart';
import '../receive_crypto/receive_crypto_vm.dart';
import '../../../../../data/model/body/supported_chain_model.dart';
import '../../../../../services/wallet_service.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFromArguments();
    });
  }

  void _initializeFromArguments() {
    final args = ModalRoute.of(context)?.settings.arguments;
    print('🔍 ReceiveScreen - Route arguments: $args');
    
    if (args != null && args is Map<String, dynamic>) {
      // Extract individual arguments
      final cryptoSymbol = args['cryptoSymbol'] as String?;
      final cryptoName = args['cryptoName'] as String?;
      final cryptoIcon = args['cryptoIcon'] as String?;
      final walletAddress = args['walletAddress'] as String?;
      
      print('🔍 ReceiveScreen - Crypto Symbol: $cryptoSymbol');
      print('🔍 ReceiveScreen - Crypto Name: $cryptoName');
      print('🔍 ReceiveScreen - Wallet Address: $walletAddress');
      
      if (cryptoSymbol != null && cryptoName != null && walletAddress != null) {
        // Create a temporary CryptoItem and SupportedChainModel from the arguments
        final cryptoItem = CryptoItem(
          name: cryptoName,
          symbol: cryptoSymbol,
          iconPath: cryptoIcon ?? 'assets/svgs/wallet_home/ethereum.svg',
          price: '0.00',
          change: '0.0%',
          holdings: '0',
          holdingsValue: '0.00',
          chain: SupportedChainModel(
            chainId: args['chainId'] as String? ?? 'ethereum',
            chainName: args['chainName'] as String? ?? 'Ethereum',
            chainType: args['chainType'] as String? ?? 'evm',
            chainIdNumber: args['chainIdNumber'] as int? ?? 1,
            rpcUrl: args['rpcUrl'] as String? ?? '',
            blockExplorer: args['blockExplorer'] as String? ?? '',
            nativeCurrencyName: args['nativeCurrencyName'] as String? ?? 'Ethereum',
            nativeCurrencySymbol: args['nativeCurrencySymbol'] as String? ?? 'ETH',
            decimals: args['decimals'] as int? ?? 18,
            isActive: args['isActive'] as bool? ?? true,
            iconPath: args['iconPath'] as String? ?? 'assets/svgs/wallet_home/ethereum.svg',
            color: args['color'] as String? ?? '#627EEA',
          ),
          walletAddress: walletAddress,
        );
        
        final vm = context.read<ReceiveVM>();
        vm.initializeReceive(cryptoItem: cryptoItem, chain: cryptoItem.chain!);
        print('✅ ReceiveScreen - Initialized with $cryptoSymbol');
      } else {
        print('❌ ReceiveScreen - Missing required arguments');
      }
    } else {
      // No arguments provided - initialize with default ETH data
      print('🔍 ReceiveScreen - No arguments, using default ETH data');
      _initializeWithDefaultData();
    }
  }

  void _initializeWithDefaultData() {
    // Get wallet service to get current wallet address
    final walletService = WalletService();
    final walletAddress = walletService.walletList.isNotEmpty 
        ? walletService.walletList.first.address 
        : '0x0000000000000000000000000000000000000000';
    
    // Create default ETH crypto item
    final cryptoItem = CryptoItem(
      name: 'Ethereum Sepolia',
      symbol: 'ETH',
      iconPath: 'assets/svgs/wallet_home/ethereum.svg',
      price: '0.00',
      change: '0.0%',
      holdings: '0',
      holdingsValue: '0.00',
      chain: SupportedChainModel(
        chainId: 'ethereum',
        chainName: 'Ethereum Sepolia',
        chainType: 'evm',
        chainIdNumber: 11155111,
        rpcUrl: BlockchainConfig.ethereumSepoliaRpc,
        blockExplorer: 'https://sepolia.etherscan.io',
        nativeCurrencyName: 'Ethereum',
        nativeCurrencySymbol: 'ETH',
        decimals: 18,
        isActive: true,
        iconPath: 'assets/svgs/wallet_home/ethereum.svg',
        color: '#627EEA',
      ),
      walletAddress: walletAddress,
    );
    
    final vm = context.read<ReceiveVM>();
    vm.initializeReceive(cryptoItem: cryptoItem, chain: cryptoItem.chain!);
    print('✅ ReceiveScreen - Initialized with default ETH data');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReceiveVM>();
    final themeManager = Provider.of<ThemeManager>(context);

    if (!vm.hasInitialized) {
      return Scaffold(
        backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: themeManager.currentTheme.colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Receive",
            style: TextStyle(
              color: themeManager.currentTheme.colorScheme.onSurface,
              fontSize: 5.sp,
              fontWeight: FontWeight.bold,
              fontFamily: "Rubik",
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Loading receive information...',
                style: themeManager.currentTheme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
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
          "Receive ${vm.cryptoSymbol}",
          style: TextStyle(
            color: themeManager.currentTheme.colorScheme.onSurface,
            fontSize: 5.sp,
            fontWeight: FontWeight.bold,
            fontFamily: "Rubik",
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: themeManager.currentTheme.colorScheme.onSurface),
            onPressed: () => vm.shareAddress(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            children: [
              // Crypto Info Header
              Container(
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
                child: Row(
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        vm.cryptoIcon,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SB.w(3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vm.cryptoName,
                            style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                              fontSize: 4.5.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            vm.chain?.chainName ?? 'Unknown Network',
                            style: themeManager.currentTheme.textTheme.bodyMedium?.copyWith(
                              fontSize: 3.5.sp,
                              color: themeManager.currentTheme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SB.h(3.h),

              // QR Code Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: themeManager.currentTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // QR Code with corner accents
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          QrImageView(
                            data: vm.walletAddress,
                            version: QrVersions.auto,
                            size: 60.w,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          // Corner accents
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 4.w,
                              height: 4.w,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 4.w,
                              height: 4.w,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              width: 4.w,
                              height: 4.w,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 4.w,
                              height: 4.w,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SB.h(3.h),

              // Address Title
              Text(
                "Your ${vm.cryptoSymbol} Address",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 5.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Rubik",
                ),
              ),

              SB.h(2.h),

              // Address Field
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: themeManager.currentTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        vm.walletAddress,
                        style: themeManager.currentTheme.textTheme.bodyMedium?.copyWith(
                          fontSize: 3.5.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SB.w(2.w),
                    GestureDetector(
                      onTap: () => vm.copyAddress(context),
                      child: Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.copy,
                          color: Colors.white,
                          size: 4.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SB.h(4.h),

              // Important Section
              Container(
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
                      "Important",
                      style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                        fontSize: 4.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SB.h(2.h),
                    _buildImportantPoint(
                      vm.getImportantMessage(),
                      themeManager,
                    ),
                    SB.h(1.5.h),
                    _buildImportantPoint(
                      vm.getConfirmationMessage(),
                      themeManager,
                    ),
                  ],
                ),
              ),

              SB.h(2.h),

              // View on Explorer Button
              if (vm.getBlockExplorerUrl().isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // You can implement opening the block explorer here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening ${vm.chain?.chainName} explorer...'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'View on ${vm.chain?.chainName} Explorer',
                      style: TextStyle(
                        fontSize: 4.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              SB.h(2.h), // Add some bottom spacing
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImportantPoint(String text, ThemeManager themeManager) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 0.5.h),
          width: 1.w,
          height: 1.w,
          decoration: BoxDecoration(
            color: themeManager.currentTheme.colorScheme.onSurface,
            shape: BoxShape.circle,
          ),
        ),
        SB.w(2.w),
        Expanded(
          child: Text(
            text,
            style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
              fontSize: 3.2.sp,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}


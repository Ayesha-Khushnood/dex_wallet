import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../util/color_resources.dart';
import '../../../../../../util/size_extension.dart';
import '../../../../../../helper/sb_helper.dart';
import '../../../../../../widgets/app_button.dart';
import '../../../../../../theme/theme_manager.dart';
import 'success_vm.dart';
import '../../../main_wallet_vm.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  bool _hasInitialized = false;

  /// Refresh main wallet balance when going back
  void _refreshMainWalletBalance() {
    try {
      // Try to get MainWalletVM from the widget tree
      final mainWalletVM = Provider.of<MainWalletVM>(context, listen: false);
      // Only refresh if not already refreshing
      if (!mainWalletVM.isRefreshing) {
        print('🔄 SuccessScreen - Refreshing main wallet balance...');
        mainWalletVM.forceRefreshBalance();
      } else {
        print('🔄 SuccessScreen - Balance already refreshing, skipping...');
      }
    } catch (e) {
      print('⚠️ SuccessScreen - Could not refresh balance: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SuccessVM>();
    final themeManager = Provider.of<ThemeManager>(context);

    // Get transaction data from route arguments
    final route = ModalRoute.of(context);
    print('🔍 SuccessScreen - Route: $route');
    print('🔍 SuccessScreen - Route settings: ${route?.settings}');
    print('🔍 SuccessScreen - Route arguments: ${route?.settings.arguments}');
    
    final transactionData = route?.settings.arguments as Map<String, dynamic>?;
    print('🔍 SuccessScreen - Transaction data: $transactionData');
    print('🔍 SuccessScreen - Transaction data type: ${transactionData.runtimeType}');

    // Initialize VM with transaction data if provided (only once)
    if (transactionData != null && !_hasInitialized) {
      print('🔍 SuccessScreen - Initializing VM with transaction data');
      print('🔍 SuccessScreen - Chain: ${transactionData['chain']}');
      print('🔍 SuccessScreen - Amount: ${transactionData['amount']}');
      print('🔍 SuccessScreen - To Address: ${transactionData['toAddress']}');
      print('🔍 SuccessScreen - From Address: ${transactionData['fromAddress']}');
      print('🔍 SuccessScreen - Transaction Hash: ${transactionData['transactionHash']}');
      print('🔍 SuccessScreen - USD Amount: ${transactionData['usdAmount']}');
      _hasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.initializeTransaction(transactionData);
      });
    } else if (transactionData == null) {
      print('❌ SuccessScreen - No transaction data provided');
    } else {
      print('🔍 SuccessScreen - Already initialized, skipping...');
    }

    return Scaffold(
      backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.primary,
            size: 24,
          ),
          onPressed: () {
            // Refresh balance when going back to main wallet
            _refreshMainWalletBalance();
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          vm.chain?.nativeCurrencySymbol ?? "Crypto",
          style: const TextStyle(
            color: AppColors.primary,
            fontFamily: "Rubik",
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Column(
            children: [
              SB.h(4.h),

              // Success Icon
              _buildSuccessIcon(themeManager),

              SB.h(3.h),

              // Success Message
              _buildSuccessMessage(themeManager),

              SB.h(2.h),

              // Amount Summary
              _buildAmountSummary(vm, themeManager),

              SB.h(3.h),

              // Transaction Details Card
              _buildTransactionDetailsCard(vm, context, themeManager),

              SB.h(3.h),

              // View on Explorer Button
              AppButton(
                text: "View on Explorer",
                onTap: () => vm.viewOnExplorer(context),
              ),

              SB.h(2.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon(ThemeManager themeManager) {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary,
          width: 3,
        ),
      ),
      child: Icon(
        Icons.check,
        color: AppColors.primary,
        size: 50,
      ),
    );
  }

  Widget _buildSuccessMessage(ThemeManager themeManager) {
    return Column(
      children: [
        Text(
          "Transaction",
          style: themeManager.currentTheme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        Text(
          "Sent Successfully",
          style: themeManager.currentTheme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSummary(SuccessVM vm, ThemeManager themeManager) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Amount",
            style: themeManager.currentTheme.textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            vm.amount,
            style: themeManager.currentTheme.textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetailsCard(SuccessVM vm, BuildContext context, ThemeManager themeManager) {
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Amount
          _buildDetailRow("Amount", vm.transactionAmount, themeManager),
          _buildDivider(themeManager),
          
          // Asset
          _buildDetailRow("Asset", vm.asset, themeManager),
          _buildDivider(themeManager),
          
          // From
          _buildAddressRow("From", vm.fromAddress, vm, context, themeManager),
          _buildDivider(themeManager),
          
          // To
          _buildAddressRow("To", vm.toAddress, vm, context, themeManager),
          _buildDivider(themeManager),
          
          // Transaction Hash
          _buildHashRow("Transaction Hash", vm.transactionHash, vm, context, themeManager),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeManager themeManager) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: themeManager.currentTheme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(String label, String address, SuccessVM vm, BuildContext context, ThemeManager themeManager) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    vm.formatAddress(address),
                    style: themeManager.currentTheme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SB.w(1.w),
                GestureDetector(
                  onTap: () => vm.copyAddress(address),
                  child: Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      // color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Icon(
                      Icons.copy,
                      color: AppColors.primary,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHashRow(String label, String hash, SuccessVM vm, BuildContext context, ThemeManager themeManager) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    vm.formatTransactionHash(),
                    style: themeManager.currentTheme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SB.w(1.w),
                GestureDetector(
                  onTap: () => vm.copyTransactionHash(),
                  child: Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(

                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Icon(
                      Icons.copy,
                      color: AppColors.primary,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeManager themeManager) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      height: 0.5,
      color: themeManager.currentTheme.dividerTheme.color,
    );
  }
}

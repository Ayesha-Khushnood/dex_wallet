import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../util/color_resources.dart';
import '../../../../../../util/size_extension.dart';
import '../../../../../../helper/sb_helper.dart';
import '../../../../../../widgets/app_button.dart';
import '../../../../../../theme/theme_manager.dart';
import 'review_vm.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool _hasInitialized = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReviewVM>();
    final themeManager = Provider.of<ThemeManager>(context);

    // Get transaction data from route arguments
    final route = ModalRoute.of(context);
    print('🔍 ReviewScreen - Route: $route');
    print('🔍 ReviewScreen - Route settings: ${route?.settings}');
    print('🔍 ReviewScreen - Route arguments: ${route?.settings.arguments}');
    
    final transactionData = route?.settings.arguments as Map<String, dynamic>?;
    print('🔍 ReviewScreen - Transaction data: $transactionData');
    print('🔍 ReviewScreen - Transaction data type: ${transactionData.runtimeType}');

    // Initialize VM with transaction data if provided (only once)
    if (transactionData != null && !_hasInitialized) {
      print('🔍 ReviewScreen - Initializing VM with transaction data');
      print('🔍 ReviewScreen - Chain: ${transactionData['chain']}');
      print('🔍 ReviewScreen - Amount: ${transactionData['amount']}');
      print('🔍 ReviewScreen - To Address: ${transactionData['toAddress']}');
      _hasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.initializeTransaction(transactionData);
      });
    } else if (transactionData == null) {
      print('❌ ReviewScreen - No transaction data provided');
    } else {
      print('🔍 ReviewScreen - Already initialized, skipping...');
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
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          vm.chain?.nativeCurrencySymbol ?? "ETH",
          style: const TextStyle(
            color: AppColors.primary,
            fontFamily: "Rubik",
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Column(
              children: [
                SB.h(2.h),

                // Transaction Details Card
                _buildTransactionDetailsCard(vm, context, themeManager),

                SB.h(2.h),

                // Fee Details Card
                _buildFeeDetailsCard(vm, themeManager),

                SB.h(3.h),

                // Error Display
                if (vm.error != null) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    margin: EdgeInsets.only(bottom: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red, size: 20),
                            SizedBox(width: 2.w),
                            Text(
                              "Transaction Error",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          vm.error!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                        if (vm.chain?.chainId == 'ethereum') ...[
                          SizedBox(height: 2.h),
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.blue, size: 18),
                                    SizedBox(width: 2.w),
                                    Text(
                                      "Need test ETH?",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  "Get free test ETH from Sepolia faucet:",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  "https://sepoliafaucet.com",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // Send Button
                AppButton(
                  text: vm.isLoading ? "Sending..." : "Send",
                  onTap: vm.isLoading ? null : () => vm.sendTransaction(context),
                ),

                SB.h(2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionDetailsCard(ReviewVM vm, BuildContext context, ThemeManager themeManager) {
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
          _buildDetailRow("Amount", vm.amount, themeManager),
          _buildDivider(themeManager),
          
          // Asset
          _buildDetailRow("Asset", vm.asset, themeManager),
          _buildDivider(themeManager),
          
          // From
          _buildAddressRow("From", vm.fromAddress, vm, context, themeManager),
          _buildDivider(themeManager),
          
          // To
          _buildAddressRow("To", vm.toAddress, vm, context, themeManager),
        ],
      ),
    );
  }

  Widget _buildFeeDetailsCard(ReviewVM vm, ThemeManager themeManager) {
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
          // Transaction Fee
          _buildDetailRow("Transaction Fee", vm.transactionFee, themeManager),
          _buildDivider(themeManager),
          
          // Max Total
          _buildDetailRow("Max Total", vm.maxTotal, themeManager),
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

  Widget _buildAddressRow(String label, String address, ReviewVM vm, BuildContext context, ThemeManager themeManager) {
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
                    address,
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

  Widget _buildDivider(ThemeManager themeManager) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      height: 0.5,
      color: themeManager.currentTheme.dividerTheme.color,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../../../util/color_resources.dart';
import '../../../../../util/size_extension.dart';
import '../../../../../helper/sb_helper.dart';
import '../../../../../theme/theme_manager.dart';
import 'history_vm.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger loading when screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<HistoryVM>();
      vm.loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryVM>();
    final themeManager = Provider.of<ThemeManager>(context);

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
        title: Text(
          "History",
          style: TextStyle(
            color: themeManager.currentTheme.colorScheme.onSurface,
            fontFamily: "Rubik",
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SB.h(1.h),

            // Search Bar
            _buildSearchBar(vm, themeManager),

            SB.h(3.h),

            // Transaction List
            Expanded(
              child: vm.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : vm.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: themeManager.currentTheme.colorScheme.error,
                              ),
                              SB.h(2.h),
                              Text(
                                vm.error!,
                                style: themeManager.currentTheme.textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              SB.h(2.h),
                              ElevatedButton(
                                onPressed: () => vm.refreshTransactions(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : vm.transactions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 48,
                                    color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                  SB.h(2.h),
                                  Text(
                                    'No transactions found',
                                    style: themeManager.currentTheme.textTheme.titleMedium?.copyWith(
                                      color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                  SB.h(1.h),
                                  Text(
                                    'Your transaction history will appear here',
                                    style: themeManager.currentTheme.textTheme.bodyMedium?.copyWith(
                                      color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () => vm.refreshTransactions(),
                              color: AppColors.primary,
                              child: ListView.builder(
                                itemCount: vm.transactions.length,
                                itemBuilder: (context, index) {
                                  final transaction = vm.transactions[index];
                                  return _buildTransactionItem(context, transaction, themeManager);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(HistoryVM vm, ThemeManager themeManager) {
    return TextField(
      controller: vm.searchController,
      style: themeManager.currentTheme.textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: "BTC",
        hintStyle: themeManager.currentTheme.textTheme.bodyLarge?.copyWith(
          color: themeManager.currentTheme.hintColor,
        ),
        filled: true,
        fillColor: themeManager.currentTheme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 5.w),
        isDense: true,
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, TransactionItem transaction, ThemeManager themeManager) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: themeManager.currentTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showTransactionDetails(context, transaction, themeManager),
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: [
            // Crypto Icon
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: themeManager.currentTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
                  width: 1,
                ),
              ),
              child: SvgPicture.asset(
                transaction.cryptoIcon,
                fit: BoxFit.contain,
                width: 6.w,
                height: 6.w,
              ),
            ),

            SB.w(2.5.w),

            // Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${transaction.amount} ETH',
                        style: themeManager.currentTheme.textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SB.w(1.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 0.8.w, vertical: 0.2.h),
                        decoration: BoxDecoration(
                          color: transaction.status == 'Success' 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          transaction.status,
                          style: TextStyle(
                            color: transaction.status == 'Success' ? Colors.green : Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SB.h(0.3.h),
                  Text(
                    transaction.date,
                    style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SB.h(0.2.h),
                  Text(
                    '${transaction.type} • ${transaction.hash.substring(0, 8)}...',
                    style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Transaction Type and Arrow
            Column(
              children: [
                Text(
                  transaction.type,
                  style: TextStyle(
                    color: transaction.typeColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SB.h(0.2.h),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, TransactionItem transaction, ThemeManager themeManager) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Transaction Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Hash', transaction.hash),
              _buildDetailRow('Type', transaction.type),
              _buildDetailRow('Amount', '${transaction.amount} ETH'),
              _buildDetailRow('From', transaction.fromAddress),
              _buildDetailRow('To', transaction.toAddress),
              _buildDetailRow('Status', transaction.status),
              _buildDetailRow('Block', transaction.blockNumber),
              _buildDetailRow('Date', transaction.date),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20.w,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

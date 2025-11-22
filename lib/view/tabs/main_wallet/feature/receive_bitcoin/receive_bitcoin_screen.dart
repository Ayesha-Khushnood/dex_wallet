import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../../util/color_resources.dart';
import '../../../../../util/size_extension.dart';
import '../../../../../helper/sb_helper.dart';
import '../../../../../theme/theme_manager.dart';
import 'receive_bitcoin_vm.dart';

class ReceiveBitcoinScreen extends StatelessWidget {
  const ReceiveBitcoinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReceiveBitcoinVM>();
    final themeManager = Provider.of<ThemeManager>(context);

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            children: [
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
                    // QR Code with orange corner accents
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          QrImageView(
                            data: vm.bitcoinAddress,
                            version: QrVersions.auto,
                            size: 60.w,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          // Orange corner accents
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

              // Your BTC Address Title
              Text(
                "Your BTC Address",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 5.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Rubik",
                ),
              ),

              SB.h(2.h),

              // Bitcoin Address Field
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
                        vm.bitcoinAddress,
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
                      "Send only BTC to this address. Sending any other coin or token to this address may result in the loss of your receiving",
                      themeManager,
                    ),
                    SB.h(1.5.h),
                    _buildImportantPoint(
                      "Coins will be receive after 1 network confirmations.",
                      themeManager,
                    ),
                  ],
                ),
              ),

              SB.h(2.h), // Add some bottom spacing instead of Spacer
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


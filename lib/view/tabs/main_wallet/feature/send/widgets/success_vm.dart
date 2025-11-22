import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../../../../../data/base_vm.dart';
import '../../../../../../data/model/body/supported_chain_model.dart';

class SuccessVM extends BaseVM {
  String _transactionHash = "";
  SupportedChainModel? _chain;
  String _amount = "0.00";
  String _toAddress = "";
  String _fromAddress = "";
  String _usdAmount = "0.00";

  // Getters
  String get transactionHash => _transactionHash;
  SupportedChainModel? get chain => _chain;
  String get amount => _amount;
  String get toAddress => _toAddress;
  String get fromAddress => _fromAddress;
  String get usdAmount => _usdAmount;

  /// Initialize transaction data
  void initializeTransaction(Map<String, dynamic> transactionData) {
    _transactionHash = transactionData['transactionHash'] ?? "";
    _chain = transactionData['chain'] as SupportedChainModel?;
    _amount = transactionData['amount'] ?? "0.00";
    _toAddress = transactionData['toAddress'] ?? "";
    _fromAddress = transactionData['fromAddress'] ?? "";
    _usdAmount = transactionData['usdAmount'] ?? "0.00";
    
    notifyListeners();
  }

  /// Copy address to clipboard
  void copyAddress(String address) {
    Clipboard.setData(ClipboardData(text: address));
    // You could show a snackbar here if needed
  }

  /// Copy transaction hash to clipboard
  void copyTransactionHash() {
    Clipboard.setData(ClipboardData(text: _transactionHash));
    // You could show a snackbar here if needed
  }

  /// View transaction on block explorer
  Future<void> viewOnExplorer(BuildContext context) async {
    if (_chain == null || _transactionHash.isEmpty) return;

    String explorerUrl = _chain!.blockExplorer;
    if (explorerUrl.endsWith('/')) {
      explorerUrl = explorerUrl.substring(0, explorerUrl.length - 1);
    }
    final url = "$explorerUrl/tx/$_transactionHash";
    print('🔗 Block explorer URL: $url');

    // Navigate to in-app browser route if available, else show snackbar with URL
    try {
      Navigator.pushNamed(context, '/browser', arguments: {
        'url': url,
        'title': 'Transaction',
      });
    } catch (e) {
      // Fallback: copy URL and notify user
      Clipboard.setData(ClipboardData(text: url));
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Explorer URL copied to clipboard')),
      );
    }
  }

  /// Format address for display
  String formatAddress(String address) {
    if (address.length <= 10) return address;
    return "${address.substring(0, 6)}...${address.substring(address.length - 4)}";
  }

  /// Format transaction hash for display
  String formatTransactionHash() {
    if (_transactionHash.length <= 10) return _transactionHash;
    return "${_transactionHash.substring(0, 6)}...${_transactionHash.substring(_transactionHash.length - 4)}";
  }

  /// Get asset name
  String get asset => _chain?.nativeCurrencySymbol ?? "ETH";

  /// Get transaction amount
  String get transactionAmount => _amount;
}
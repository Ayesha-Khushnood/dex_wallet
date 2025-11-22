import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../data/base_vm.dart';

class ReceiveBitcoinVM extends BaseVM {
  final String _bitcoinAddress = "3E53XjqK4CxRYUri45445P2Vh...";
  
  String get bitcoinAddress => _bitcoinAddress;

  void copyAddress(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _bitcoinAddress));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Address copied to clipboard"),
        backgroundColor: Colors.green,
      ),
    );
  }
}


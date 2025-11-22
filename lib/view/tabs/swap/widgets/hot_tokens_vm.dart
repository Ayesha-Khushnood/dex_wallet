import 'package:flutter/material.dart';

class HotTokensVm extends ChangeNotifier {
  final List<Map<String, String>> tokens = [
    {"name": "Bitcoin", "price": "99284.01", "last": "68908.00", "change": "+68.3%"},
    {"name": "Ethereum", "price": "4820.50", "last": "4720.00", "change": "+2.1%"},
    {"name": "Solana", "price": "150.20", "last": "140.00", "change": "+7.2%"},
  ];

  void refreshData() {
    // Future API call logic
    notifyListeners();
  }
}

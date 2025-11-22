import 'package:flutter/material.dart';

class SwapVm extends ChangeNotifier {
  String fromToken = "ETH";
  String toToken = "SOL";

  void updateFromToken(String token) {
    fromToken = token;
    notifyListeners();
  }

  void updateToToken(String token) {
    toToken = token;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';

class SwapTabVm extends ChangeNotifier {
  String inputValue = "0";

  void updateValue(String newValue) {
    inputValue = newValue;
    notifyListeners();
  }
}

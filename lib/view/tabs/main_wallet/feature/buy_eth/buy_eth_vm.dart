import '../../../../../data/base_vm.dart';
import 'package:flutter/material.dart';

class BuyEthVM extends BaseVM {
  final TextEditingController amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();
  
  String _amount = "1500.0";
  String _ethAmount = "0.053195";
  bool _isGooglePaySelected = true;

  BuyEthVM() {
    amountController.text = _amount;
  }

  String get amount => _amount;
  String get ethAmount => _ethAmount;
  bool get isGooglePaySelected => _isGooglePaySelected;

  void updateAmount(String newAmount) {
    _amount = newAmount;
    // Calculate ETH amount based on current ETH price (simplified)
    double usdAmount = double.tryParse(newAmount) ?? 0.0;
    double ethPrice = 28200.0; // Example ETH price
    _ethAmount = (usdAmount / ethPrice).toStringAsFixed(6);
    notifyListeners();
  }


  void toggleGooglePay() {
    _isGooglePaySelected = !_isGooglePaySelected;
    notifyListeners();
  }

  void buyWithGooglePay(BuildContext context) {
    if (_isGooglePaySelected) {
      // Handle buy with Google Pay
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Processing purchase with Google Pay...")),
      );
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    amountFocusNode.dispose();
    super.dispose();
  }
}

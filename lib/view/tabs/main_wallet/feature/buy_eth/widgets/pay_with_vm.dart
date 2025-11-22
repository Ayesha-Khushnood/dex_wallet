import '../../../../../../data/base_vm.dart';
import 'package:flutter/material.dart';

class PayWithVM extends BaseVM {
  String? _selectedPaymentMethod;

  String? get selectedPaymentMethod => _selectedPaymentMethod;

  void selectPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void confirmPayment(BuildContext context) {
    if (_selectedPaymentMethod != null) {
      // Handle payment confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment confirmed with $_selectedPaymentMethod")),
      );
      Navigator.pop(context); // Go back to buy screen
    }
  }
}

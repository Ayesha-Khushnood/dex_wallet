import 'package:flutter/material.dart';

class BottomNavVM extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  
  // Set the current index (no navigation needed)
  void setIndex(int index) {
    if (_currentIndex == index) return;
    
    _currentIndex = index;
    notifyListeners();
  }
  
  // Set the current index based on the route (for initial setup)
  void setCurrentIndexFromRoute(String routeName) {
    switch (routeName) {
      case '/mainWallet':
        _currentIndex = 0;
        break;
      case '/market':
        _currentIndex = 1;
        break;
      case '/explore':
        _currentIndex = 2;
        break;
      case '/swap':
        _currentIndex = 3;
        break;
      case '/settings':
        _currentIndex = 4;
        break;
      default:
        _currentIndex = 0;
    }
    notifyListeners();
  }
}

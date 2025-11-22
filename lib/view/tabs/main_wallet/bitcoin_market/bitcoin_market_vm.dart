import '../../../../data/base_vm.dart';

class BitcoinMarketVM extends BaseVM {
  String _selectedTimeframe = "24H";
  
  String get selectedTimeframe => _selectedTimeframe;
  String get btcPrice => "\$50,3k";
  String get btcChange => "+5.07%";
  String get btcChangeValue => "↗ 3.2%";
  String get totalValue => "\$232657931.00258";
  String get currentValue => "\$50,3k";
  String get marketCap => "\$144.16 B";
  String get volume24h => "\$14.79 B";

  List<String> get timeframes => ["24H", "7D", "1M", "6M", "1Y", "24H"];

  void selectTimeframe(String timeframe) {
    _selectedTimeframe = timeframe;
    notifyListeners();
  }
}

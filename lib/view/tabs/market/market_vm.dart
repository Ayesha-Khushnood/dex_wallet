import '../../../data/base_vm.dart';

class MarketVM extends BaseVM {
  List<CryptoItem> _cryptoList = [];

  List<CryptoItem> get cryptoList => _cryptoList;

  MarketVM() {
    _loadMarketData();
  }

  void _loadMarketData() {
    _cryptoList = [
      CryptoItem(
        name: "Bitcoin",
        icon: "assets/svgs/wallet_home/bitcoin.svg",
        price: "\$99,284.01",
        change: "+68.3%",
        isPositive: true,
        quantity: "1",
        totalValue: "\$68,908.00",
      ),
      CryptoItem(
        name: "Ethereum",
        icon: "assets/svgs/wallet_home/ethereum.svg",
        price: "\$99,284.01",
        change: "-5.2%",
        isPositive: false,
        quantity: "0.5",
        totalValue: "\$49,642.00",
      ),
      CryptoItem(
        name: "Solana",
        icon: "assets/svgs/wallet_home/solana.svg",
        price: "\$250.50",
        change: "+10.1%",
        isPositive: true,
        quantity: "20",
        totalValue: "\$5,010.00",
      ),
      CryptoItem(
        name: "BNB",
        icon: "assets/svgs/wallet_home/bnb.svg",
        price: "\$480.25",
        change: "+2.8%",
        isPositive: true,
        quantity: "3",
        totalValue: "\$1,440.75",
      ),
      CryptoItem(
        name: "Bitcoin",
        icon: "assets/svgs/wallet_home/bitcoin.svg",
        price: "\$99,284.01",
        change: "+68.3%",
        isPositive: true,
        quantity: "1",
        totalValue: "\$68,908.00",
      ),
      CryptoItem(
        name: "Ethereum",
        icon: "assets/svgs/wallet_home/ethereum.svg",
        price: "\$99,284.01",
        change: "-5.2%",
        isPositive: false,
        quantity: "0.5",
        totalValue: "\$49,642.00",
      ),
      CryptoItem(
        name: "Solana",
        icon: "assets/svgs/wallet_home/solana.svg",
        price: "\$250.50",
        change: "+10.1%",
        isPositive: true,
        quantity: "20",
        totalValue: "\$5,010.00",
      ),
      CryptoItem(
        name: "BNB",
        icon: "assets/svgs/wallet_home/bnb.svg",
        price: "\$480.25",
        change: "+2.8%",
        isPositive: true,
        quantity: "3",
        totalValue: "\$1,440.75",
      ),
      CryptoItem(
        name: "Bitcoin",
        icon: "assets/svgs/wallet_home/bitcoin.svg",
        price: "\$99,284.01",
        change: "+68.3%",
        isPositive: true,
        quantity: "1",
        totalValue: "\$68,908.00",
      ),
      CryptoItem(
        name: "Ethereum",
        icon: "assets/svgs/wallet_home/ethereum.svg",
        price: "\$99,284.01",
        change: "-5.2%",
        isPositive: false,
        quantity: "0.5",
        totalValue: "\$49,642.00",
      ),
      CryptoItem(
        name: "Solana",
        icon: "assets/svgs/wallet_home/solana.svg",
        price: "\$250.50",
        change: "+10.1%",
        isPositive: true,
        quantity: "20",
        totalValue: "\$5,010.00",
      ),
      CryptoItem(
        name: "BNB",
        icon: "assets/svgs/wallet_home/bnb.svg",
        price: "\$480.25",
        change: "+2.8%",
        isPositive: true,
        quantity: "3",
        totalValue: "\$1,440.75",
      ),
      CryptoItem(
        name: "BNB",
        icon: "assets/svgs/wallet_home/bnb.svg",
        price: "\$480.25",
        change: "+2.8%",
        isPositive: true,
        quantity: "3",
        totalValue: "\$1,440.75",
      ),
    ];
    // Don't notify listeners in constructor - only when data actually changes
  }

  void refreshMarketData() {
    _loadMarketData();
    notifyListeners(); // Only notify when data is actually refreshed
  }
}

class CryptoItem {
  final String name;
  final String icon;
  final String price;
  final String change;
  final bool isPositive;
  final String quantity;
  final String totalValue;

  CryptoItem({
    required this.name,
    required this.icon,
    required this.price,
    required this.change,
    required this.isPositive,
    required this.quantity,
    required this.totalValue,
  });
}

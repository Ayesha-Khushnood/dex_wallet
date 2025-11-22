class SupportedChainModel {
  final String chainId;
  final String chainName;
  final String chainType;
  final int chainIdNumber;
  final String rpcUrl;
  final String blockExplorer;
  final String nativeCurrencyName;
  final String nativeCurrencySymbol;
  final int decimals;
  final bool isActive;
  final String iconPath;
  final String color;

  SupportedChainModel({
    required this.chainId,
    required this.chainName,
    required this.chainType,
    required this.chainIdNumber,
    required this.rpcUrl,
    required this.blockExplorer,
    required this.nativeCurrencyName,
    required this.nativeCurrencySymbol,
    required this.decimals,
    required this.isActive,
    required this.iconPath,
    required this.color,
  });

  @override
  String toString() {
    return 'SupportedChainModel(chainId: $chainId, chainName: $chainName, symbol: $nativeCurrencySymbol)';
  }
}

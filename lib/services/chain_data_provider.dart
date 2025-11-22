import '../data/model/body/supported_chain_model.dart';
import '../config/blockchain_config.dart';

class ChainDataProvider {
  static List<SupportedChainModel> getSupportedChains() {
    return [
      SupportedChainModel(
        chainId: "ethereum",
        chainName: "Ethereum Sepolia",
        chainType: "evm",
        chainIdNumber: 11155111,
        rpcUrl: BlockchainConfig.ethereumSepoliaRpc,
        blockExplorer: "https://sepolia.etherscan.io",
        nativeCurrencyName: "Ethereum",
        nativeCurrencySymbol: "ETH",
        decimals: 18,
        isActive: true,
        iconPath: "assets/svgs/wallet_home/ethereum.svg",
        color: "#627EEA",
      ),
      SupportedChainModel(
        chainId: "bsc",
        chainName: "BSC Testnet",
        chainType: "evm",
        chainIdNumber: 97,
        rpcUrl: "https://data-seed-prebsc-1-s1.binance.org:8545/",
        blockExplorer: "https://testnet.bscscan.com",
        nativeCurrencyName: "BNB",
        nativeCurrencySymbol: "BNB",
        decimals: 18,
        isActive: true,
        iconPath: "assets/svgs/wallet_home/bitcoin.svg", // Use existing icon
        color: "#F3BA2F",
      ),
      SupportedChainModel(
        chainId: "polygon",
        chainName: "Polygon Mumbai",
        chainType: "evm",
        chainIdNumber: 80001,
        rpcUrl: BlockchainConfig.polygonMumbaiRpc,
        blockExplorer: "https://mumbai.polygonscan.com",
        nativeCurrencyName: "MATIC",
        nativeCurrencySymbol: "MATIC",
        decimals: 18,
        isActive: true,
        iconPath: "assets/svgs/wallet_home/ethereum.svg", // Use existing icon
        color: "#8247E5",
      ),
      SupportedChainModel(
        chainId: "arbitrum",
        chainName: "Arbitrum Sepolia",
        chainType: "evm",
        chainIdNumber: 421614,
        rpcUrl: BlockchainConfig.arbitrumSepoliaRpc,
        blockExplorer: "https://sepolia.arbiscan.io",
        nativeCurrencyName: "Ethereum",
        nativeCurrencySymbol: "ETH",
        decimals: 18,
        isActive: true,
        iconPath: "assets/svgs/wallet_home/ethereum.svg",
        color: "#28A0F0",
      ),
      SupportedChainModel(
        chainId: "optimism",
        chainName: "Optimism Sepolia",
        chainType: "evm",
        chainIdNumber: 11155420,
        rpcUrl: BlockchainConfig.optimismSepoliaRpc,
        blockExplorer: "https://sepolia-optimism.etherscan.io",
        nativeCurrencyName: "Ethereum",
        nativeCurrencySymbol: "ETH",
        decimals: 18,
        isActive: true,
        iconPath: "assets/svgs/wallet_home/ethereum.svg",
        color: "#FF0420",
      ),
    ];
  }
}

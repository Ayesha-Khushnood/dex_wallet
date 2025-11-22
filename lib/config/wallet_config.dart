// import 'dart:developer';
//
//
//
// class WalletConfig{
//   WalletConfig._();
//
//   static WalletNetworkType networkType = AppConstants.networkType;
//   static ChainType chainType = ChainType.ethereum;
//
//   static int getEthChainId(){
//     if(networkType == WalletNetworkType.testnet){
//       return 11155111;
//     }else{
//       return 1;
//     }
//   }
//
//   static String getEthRPC(){
//     log("Network Type: $networkType");
//     if(networkType == WalletNetworkType.testnet){
//       return "https://worldchain-sepolia.g.alchemy.com/v2/HFZOheuWQULbFxePYiy0i";
//     }else{
//       return "https://worldchain-mainnet.g.alchemy.com/v2/HFZOheuWQULbFxePYiy0i";
//     }
//   }
//
//   // ChainId helpers
//   static String getEip155ChainId(){
//     return 'eip155:${getEthChainId()}';
//   }
//
//   // Contract addresses per network (extend as needed)
//   static String getZakatContractAddress(){
//     if(networkType == WalletNetworkType.testnet){
//       return '0xfa2332C60c85bF4f2303604696ba3a58E5348fd2';
//     }else{
//       return '0xfa2332C60c85bF4f2303604696ba3a58E5348fd2';
//     }
//   }
//
//   static String getUsdtContractAddress(){
//     if(networkType == WalletNetworkType.testnet){
//       return '0x2D3a71430Bf19edf7B6Df82Ed921d02e40c39Fa8';
//     }else{
//       return '0xdAC17F958D2ee523a2206206994597C13D831ec7';
//     }
//   }
//
//   // Wallet app schemes and universal links for deep linking
//   static const Map<String, Map<String, String>> walletDeepLinks = {
//     'MetaMask': {
//       'scheme': 'metamask',
//       'universal': 'https://metamask.app.link',
//     },
//     'Coinbase Wallet': {
//       'scheme': 'cbwallet',
//       'universal': 'https://go.cb-w.com',
//     },
//     'Trust Wallet': {
//       'scheme': 'trust',
//       'universal': 'https://link.trustwallet.com',
//     },
//     'Binance Wallet': {
//       'scheme': 'binance',
//       'universal': 'https://www.binance.com',
//     },
//     'Phantom': {
//       'scheme': 'phantom',
//       'universal': 'https://phantom.app/ul',
//     },
//     'WalletConnect': {
//       'scheme': 'wc',
//       'universal': 'https://walletconnect.com/app',
//     },
//   };
//
// }
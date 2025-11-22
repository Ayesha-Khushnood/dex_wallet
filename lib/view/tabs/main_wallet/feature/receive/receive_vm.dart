import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../data/base_vm.dart';
import '../../../../../data/model/body/supported_chain_model.dart';
import '../receive_crypto/receive_crypto_vm.dart';

class ReceiveVM extends BaseVM {
  CryptoItem? _cryptoItem;
  SupportedChainModel? _chain;
  String _walletAddress = '';
  bool _hasInitialized = false;

  CryptoItem? get cryptoItem => _cryptoItem;
  SupportedChainModel? get chain => _chain;
  String get walletAddress => _walletAddress;
  String get cryptoName => _cryptoItem?.name ?? 'Crypto';
  String get cryptoSymbol => _cryptoItem?.symbol ?? 'CRYPTO';
  String get cryptoIcon => _cryptoItem?.iconPath ?? 'assets/svgs/wallet_home/ethereum.svg';
  bool get hasInitialized => _hasInitialized;

  void initializeReceive({
    required CryptoItem cryptoItem,
    required SupportedChainModel chain,
  }) {
    if (_hasInitialized) return;
    
    _cryptoItem = cryptoItem;
    _chain = chain;
    _walletAddress = cryptoItem.walletAddress;
    _hasInitialized = true;
    
    print('✅ ReceiveVM - Initialized for ${cryptoItem.symbol}');
    print('🔍 ReceiveVM - Wallet address: $_walletAddress');
    print('🔍 ReceiveVM - Chain: ${chain.chainName}');
    
    notifyListeners();
  }

  void copyAddress(BuildContext context) {
    if (_walletAddress.isEmpty) return;
    
    Clipboard.setData(ClipboardData(text: _walletAddress));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${_cryptoItem?.symbol ?? 'Address'} address copied to clipboard"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void shareAddress(BuildContext context) {
    if (_walletAddress.isEmpty) return;
    
    // You can implement sharing functionality here
    // For now, just copy to clipboard
    copyAddress(context);
  }

  String getFormattedAddress() {
    if (_walletAddress.length <= 20) return _walletAddress;
    return '${_walletAddress.substring(0, 10)}...${_walletAddress.substring(_walletAddress.length - 8)}';
  }

  String getBlockExplorerUrl() {
    if (_chain?.blockExplorer == null) return '';
    return _chain!.blockExplorer;
  }

  String getImportantMessage() {
    final symbol = _cryptoItem?.symbol ?? 'crypto';
    return 'Send only $symbol to this address. Sending any other coin or token to this address may result in the loss of your funds.';
  }

  String getConfirmationMessage() {
    final symbol = _cryptoItem?.symbol ?? 'crypto';
    return 'Coins will be received after 1 network confirmation.';
  }

  @override
  void dispose() {
    _hasInitialized = false;
    super.dispose();
  }
}


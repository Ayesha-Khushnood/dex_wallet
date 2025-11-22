class WalletRetrievalModel {
  final String address;
  final String privateKey;
  final String mnemonic;

  WalletRetrievalModel({
    required this.address,
    required this.privateKey,
    required this.mnemonic,
  });

  factory WalletRetrievalModel.fromJson(Map<String, dynamic> json) {
    return WalletRetrievalModel(
      address: json['address'] ?? '',
      privateKey: json['privateKey'] ?? '',
      mnemonic: json['mnemonic'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'privateKey': privateKey,
      'mnemonic': mnemonic,
    };
  }

  @override
  String toString() {
    return 'WalletRetrievalModel(address: $address, privateKey: ${privateKey.substring(0, 10)}..., mnemonic: ${mnemonic.substring(0, 20)}...)';
  }
}

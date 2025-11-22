class WalletModel {
  final String walletId;
  final String address;
  final String publicKey;
  final String checksumAddress;
  final String derivationPath;
  final String walletType;
  final String standard;
  final List<String> compatibleNetworks;
  final String createdAt;
  final String? walletPin; // PIN specific to this wallet

  WalletModel({
    required this.walletId,
    required this.address,
    required this.publicKey,
    required this.checksumAddress,
    required this.derivationPath,
    required this.walletType,
    required this.standard,
    required this.compatibleNetworks,
    required this.createdAt,
    this.walletPin, // Optional PIN field
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      walletId: json['walletId'] ?? '',
      address: json['address'] ?? '',
      publicKey: json['publicKey'] ?? '',
      checksumAddress: json['checksumAddress'] ?? '',
      derivationPath: json['derivationPath'] ?? '',
      walletType: json['walletType'] ?? '',
      standard: json['standard'] ?? '',
      compatibleNetworks: List<String>.from(json['compatibleNetworks'] ?? []),
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'walletId': walletId,
      'address': address,
      'publicKey': publicKey,
      'checksumAddress': checksumAddress,
      'derivationPath': derivationPath,
      'walletType': walletType,
      'standard': standard,
      'compatibleNetworks': compatibleNetworks,
      'createdAt': createdAt,
    };
  }

  @override
  String toString() {
    return 'WalletModel(walletId: $walletId, address: $address, walletType: $walletType, standard: $standard)';
  }
}

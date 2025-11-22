class WalletListItemModel {
  final String walletId;
  final String address;
  final String publicKey;
  final String walletType;
  final String network;
  final String createdAt;

  WalletListItemModel({
    required this.walletId,
    required this.address,
    required this.publicKey,
    required this.walletType,
    required this.network,
    required this.createdAt,
  });

  factory WalletListItemModel.fromJson(Map<String, dynamic> json) {
    return WalletListItemModel(
      walletId: json['id'] ?? '', // Server sends 'id', not 'walletId'
      address: json['address'] ?? '',
      publicKey: json['publicKey'] ?? '',
      walletType: json['walletType'] ?? '',
      network: json['standard'] ?? 'ethereum', // Server sends 'standard' field
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'walletId': walletId,
      'address': address,
      'publicKey': publicKey,
      'walletType': walletType,
      'network': network,
      'createdAt': createdAt,
    };
  }

  @override
  String toString() {
    return 'WalletListItemModel(walletId: $walletId, address: $address, walletType: $walletType, network: $network)';
  }
}

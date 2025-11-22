class TransactionModel {
  final String fromAddress;
  final String toAddress;
  final String amount;
  final String gasPrice;
  final int gasLimit;
  final String? data;
  final int nonce;
  final String? signedTransaction;
  final String? transactionHash;
  final String? status;
  final DateTime? timestamp;
  final String? blockNumber;
  final String? blockHash;

  TransactionModel({
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.gasPrice,
    required this.gasLimit,
    this.data,
    required this.nonce,
    this.signedTransaction,
    this.transactionHash,
    this.status,
    this.timestamp,
    this.blockNumber,
    this.blockHash,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      fromAddress: json['fromAddress'] ?? '',
      toAddress: json['toAddress'] ?? '',
      amount: json['amount'] ?? '0',
      gasPrice: json['gasPrice'] ?? '0',
      gasLimit: json['gasLimit'] ?? 21000,
      data: json['data'],
      nonce: json['nonce'] ?? 0,
      signedTransaction: json['signedTransaction'],
      transactionHash: json['transactionHash'],
      status: json['status'],
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : null,
      blockNumber: json['blockNumber'],
      blockHash: json['blockHash'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromAddress': fromAddress,
      'toAddress': toAddress,
      'amount': amount,
      'gasPrice': gasPrice,
      'gasLimit': gasLimit,
      'data': data,
      'nonce': nonce,
      'signedTransaction': signedTransaction,
      'transactionHash': transactionHash,
      'status': status,
      'timestamp': timestamp?.toIso8601String(),
      'blockNumber': blockNumber,
      'blockHash': blockHash,
    };
  }

  TransactionModel copyWith({
    String? fromAddress,
    String? toAddress,
    String? amount,
    String? gasPrice,
    int? gasLimit,
    String? data,
    int? nonce,
    String? signedTransaction,
    String? transactionHash,
    String? status,
    DateTime? timestamp,
    String? blockNumber,
    String? blockHash,
  }) {
    return TransactionModel(
      fromAddress: fromAddress ?? this.fromAddress,
      toAddress: toAddress ?? this.toAddress,
      amount: amount ?? this.amount,
      gasPrice: gasPrice ?? this.gasPrice,
      gasLimit: gasLimit ?? this.gasLimit,
      data: data ?? this.data,
      nonce: nonce ?? this.nonce,
      signedTransaction: signedTransaction ?? this.signedTransaction,
      transactionHash: transactionHash ?? this.transactionHash,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      blockNumber: blockNumber ?? this.blockNumber,
      blockHash: blockHash ?? this.blockHash,
    );
  }

  @override
  String toString() {
    return 'TransactionModel(fromAddress: $fromAddress, toAddress: $toAddress, amount: $amount, gasPrice: $gasPrice, gasLimit: $gasLimit, nonce: $nonce, transactionHash: $transactionHash, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel &&
        other.fromAddress == fromAddress &&
        other.toAddress == toAddress &&
        other.amount == amount &&
        other.gasPrice == gasPrice &&
        other.gasLimit == gasLimit &&
        other.nonce == nonce &&
        other.transactionHash == transactionHash;
  }

  @override
  int get hashCode {
    return fromAddress.hashCode ^
        toAddress.hashCode ^
        amount.hashCode ^
        gasPrice.hashCode ^
        gasLimit.hashCode ^
        nonce.hashCode ^
        transactionHash.hashCode;
  }
}

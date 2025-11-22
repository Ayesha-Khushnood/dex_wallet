class ActivityResponse {
  bool? success;
  Data? data;

  ActivityResponse({this.success, this.data});

  ActivityResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Payments>? payments;
  Pagination? pagination;
  Filters? filters;
  Summary? summary;

  Data({this.payments, this.pagination, this.filters, this.summary});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['payments'] != null) {
      payments = <Payments>[];
      json['payments'].forEach((v) {
        payments!.add(new Payments.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
    filters = json['filters'] != null
        ? new Filters.fromJson(json['filters'])
        : null;
    summary = json['summary'] != null
        ? new Summary.fromJson(json['summary'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.payments != null) {
      data['payments'] = this.payments!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.filters != null) {
      data['filters'] = this.filters!.toJson();
    }
    if (this.summary != null) {
      data['summary'] = this.summary!.toJson();
    }
    return data;
  }
}

class Payments {
  Map<dynamic, dynamic>? id;
  String? type;
  double? amountUsd;
  String? status;
  String? walletAddress;
  String? description;
  String? paymentMethod;
  String? createdAt;
  String? updatedAt;
  String? errorMessage;
  String? contractTransactionHash;
  String? txLink;
  String? tokensProcessedAt;

  Payments({
    this.id,
    this.type,
    this.amountUsd,
    this.status,
    this.walletAddress,
    this.description,
    this.paymentMethod,
    this.createdAt,
    this.updatedAt,
    this.errorMessage,
    this.contractTransactionHash,
    this.txLink,
    this.tokensProcessedAt,
  });

  Payments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    // Handle amountUsd as either int or double
    if (json['amountUsd'] != null) {
      if (json['amountUsd'] is int) {
        amountUsd = (json['amountUsd'] as int).toDouble();
      } else if (json['amountUsd'] is double) {
        amountUsd = json['amountUsd'];
      } else if (json['amountUsd'] is String) {
        amountUsd = double.tryParse(json['amountUsd']);
      }
    }
    status = json['status'];
    walletAddress = json['walletAddress'];
    description = json['description'];
    paymentMethod = json['paymentMethod'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    errorMessage = json['errorMessage'];
    contractTransactionHash = json['contractTransactionHash'];
    txLink = json['txLink'];
    tokensProcessedAt = json['tokensProcessedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.id != null) {
      data['id'] = this.id!;
    }
    data['type'] = this.type;
    data['amountUsd'] = this.amountUsd;
    data['status'] = this.status;
    data['walletAddress'] = this.walletAddress;
    data['description'] = this.description;
    data['paymentMethod'] = this.paymentMethod;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['errorMessage'] = this.errorMessage;
    data['contractTransactionHash'] = this.contractTransactionHash;
    data['txLink'] = this.txLink;
    data['tokensProcessedAt'] = this.tokensProcessedAt;
    return data;
  }
}

class Pagination {
  int? page;
  int? limit;
  int? total;
  int? pages;

  Pagination({this.page, this.limit, this.total, this.pages});

  Pagination.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
    pages = json['pages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['page'] = this.page;
    data['limit'] = this.limit;
    data['total'] = this.total;
    data['pages'] = this.pages;
    return data;
  }
}

class Filters {
  String? status;
  Map<dynamic, dynamic>? userId;

  Filters({this.status, this.userId});

  Filters.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.userId != null) {
      data['userId'] = this.userId!;
    }
    return data;
  }
}

class Summary {
  int? stripePayments;
  int? processTokensPayments;
  int? totalPayments;

  Summary({
    this.stripePayments,
    this.processTokensPayments,
    this.totalPayments,
  });

  Summary.fromJson(Map<String, dynamic> json) {
    stripePayments = json['stripePayments'];
    processTokensPayments = json['processTokensPayments'];
    totalPayments = json['totalPayments'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stripePayments'] = this.stripePayments;
    data['processTokensPayments'] = this.processTokensPayments;
    data['totalPayments'] = this.totalPayments;
    return data;
  }
}

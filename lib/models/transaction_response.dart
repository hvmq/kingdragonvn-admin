class TransactionResponse {
  final List<Transaction> transactions;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  TransactionResponse({
    required this.transactions,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      transactions: (json['transactions'] as List?)
              ?.map((t) => Transaction.fromJson(t))
              .toList() ??
          [],
      currentPage: int.tryParse(json['currentPage']?.toString() ?? '1') ?? 1,
      totalPages: int.tryParse(json['totalPages']?.toString() ?? '1') ?? 1,
      totalItems: int.tryParse(json['totalItems']?.toString() ?? '0') ?? 0,
    );
  }
}

class Transaction {
  final String id;
  final String type;
  final double amount;
  final String status;
  final TransactionUser user;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.user,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
      user:
          TransactionUser.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Transaction copyWith({
    String? id,
    String? type,
    double? amount,
    String? status,
    TransactionUser? user,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TransactionUser {
  final String id;
  final String username;
  final String phoneNumber;
  final String refId;

  TransactionUser({
    required this.id,
    required this.username,
    required this.phoneNumber,
    required this.refId,
  });

  factory TransactionUser.fromJson(Map<String, dynamic> json) {
    return TransactionUser(
      id: json['_id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      refId: json['refId']?.toString() ?? '',
    );
  }
}

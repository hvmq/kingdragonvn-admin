class BankAccountsResponse {
  final String message;
  final List<BankAccount> accounts;

  BankAccountsResponse({
    required this.message,
    required this.accounts,
  });

  factory BankAccountsResponse.fromJson(Map<String, dynamic> json) {
    return BankAccountsResponse(
      message: json['message']?.toString() ?? '',
      accounts: (json['accounts'] as List<dynamic>? ?? [])
          .map((e) => BankAccount.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BankAccount {
  final String id;
  final String bankCode;
  final String bankName;
  final String accountNumber;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BankAccount({
    required this.id,
    required this.bankCode,
    required this.bankName,
    required this.accountNumber,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['_id']?.toString() ?? '',
      bankCode: json['bankCode']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      isActive: json['isActive'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
} 
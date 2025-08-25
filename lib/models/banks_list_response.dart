class BanksListResponse {
  final String message;
  final List<BankInfo> banks;

  BanksListResponse({
    required this.message,
    required this.banks,
  });

  factory BanksListResponse.fromJson(Map<String, dynamic> json) {
    return BanksListResponse(
      message: json['message']?.toString() ?? '',
      banks: (json['banks'] as List<dynamic>? ?? [])
          .map((e) => BankInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BankInfo {
  final String bankName;
  final String bankCode;

  BankInfo({
    required this.bankName,
    required this.bankCode,
  });

  factory BankInfo.fromJson(Map<String, dynamic> json) {
    return BankInfo(
      bankName: json['bankName']?.toString() ?? '',
      bankCode: json['bankCode']?.toString() ?? '',
    );
  }
} 
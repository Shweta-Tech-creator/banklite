class Account {
  final String accountId;
  final String accountType; // 'Savings Account' or 'Current Account'
  final String accountNumber;
  final String maskedNumber;
  double balance;
  final String bankName;
  final String ifscCode;

  Account({
    required this.accountId,
    required this.accountType,
    required this.accountNumber,
    required this.maskedNumber,
    required this.balance,
    this.bankName = 'BankLite National Bank',
    this.ifscCode = 'BLTE0001234',
  });

  Account copyWith({
    String? accountId,
    String? accountType,
    String? accountNumber,
    String? maskedNumber,
    double? balance,
    String? bankName,
    String? ifscCode,
  }) {
    return Account(
      accountId: accountId ?? this.accountId,
      accountType: accountType ?? this.accountType,
      accountNumber: accountNumber ?? this.accountNumber,
      maskedNumber: maskedNumber ?? this.maskedNumber,
      balance: balance ?? this.balance,
      bankName: bankName ?? this.bankName,
      ifscCode: ifscCode ?? this.ifscCode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'accountType': accountType,
      'accountNumber': accountNumber,
      'maskedNumber': maskedNumber,
      'balance': balance,
      'bankName': bankName,
      'ifscCode': ifscCode,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map, {String? docId}) {
    return Account(
      accountId: docId ?? map['accountId'] ?? 'ACC_${DateTime.now().millisecondsSinceEpoch}',
      accountType: map['accountType'] ?? 'Savings Account',
      accountNumber: map['accountNumber'] ?? '892144028912',
      maskedNumber: map['maskedNumber'] ?? '•••• 8912',
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      bankName: map['bankName'] ?? 'BankLite National Bank',
      ifscCode: map['ifscCode'] ?? 'BLTE0001234',
    );
  }
}

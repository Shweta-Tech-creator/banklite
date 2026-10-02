class BillCategory {
  final String id;
  final String name;
  final String icon;
  final List<String> providers;
  final double defaultFee;

  BillCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.providers,
    this.defaultFee = 0.0,
  });
}

class BillPayment {
  final String paymentId;
  final String provider;
  final String billType; // 'Electricity', 'Mobile', 'Internet', 'Water', 'Gas'
  final String consumerNumber;
  final double amount;
  final double fee;
  final double totalAmount;
  final String status;
  final DateTime date;
  final String paymentAccount;

  BillPayment({
    required this.paymentId,
    required this.provider,
    required this.billType,
    required this.consumerNumber,
    required this.amount,
    required this.fee,
    required this.totalAmount,
    this.status = 'Successful',
    required this.date,
    this.paymentAccount = 'Savings Account',
  });

  Map<String, dynamic> toMap() {
    return {
      'paymentId': paymentId,
      'provider': provider,
      'billType': billType,
      'consumerNumber': consumerNumber,
      'amount': amount,
      'fee': fee,
      'totalAmount': totalAmount,
      'status': status,
      'date': date.toIso8601String(),
      'paymentAccount': paymentAccount,
    };
  }

  factory BillPayment.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parsedDate = DateTime.now();
    if (map['date'] != null && map['date'] is String) {
      parsedDate = DateTime.tryParse(map['date']) ?? DateTime.now();
    }

    return BillPayment(
      paymentId: docId ?? map['paymentId'] ?? 'BLBILL_${DateTime.now().millisecondsSinceEpoch}',
      provider: map['provider'] ?? '',
      billType: map['billType'] ?? 'General',
      consumerNumber: map['consumerNumber'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      fee: (map['fee'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'Successful',
      date: parsedDate,
      paymentAccount: map['paymentAccount'] ?? 'Savings Account',
    );
  }
}

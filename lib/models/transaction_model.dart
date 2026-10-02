enum TransactionType { credit, debit }

enum TransactionStatus { successful, pending, failed }

class TransactionItem {
  final String transactionId;
  final String title;
  final double amount;
  final String category; // 'Income', 'Shopping', 'Bills', 'Food', 'Travel', 'Transfer', etc.
  final DateTime date;
  final TransactionType type;
  final TransactionStatus status;
  final String paymentMethod;
  final String recipientOrSender;
  final String note;

  TransactionItem({
    required this.transactionId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    this.status = TransactionStatus.successful,
    required this.paymentMethod,
    this.recipientOrSender = '',
    this.note = '',
  });

  bool get isCredit => type == TransactionType.credit;
  bool get isDebit => type == TransactionType.debit;

  String get statusText {
    switch (status) {
      case TransactionStatus.successful:
        return 'Successful';
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.failed:
        return 'Failed';
    }
  }

  TransactionItem copyWith({
    String? transactionId,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    TransactionType? type,
    TransactionStatus? status,
    String? paymentMethod,
    String? recipientOrSender,
    String? note,
  }) {
    return TransactionItem(
      transactionId: transactionId ?? this.transactionId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      type: type ?? this.type,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      recipientOrSender: recipientOrSender ?? this.recipientOrSender,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'type': type == TransactionType.credit ? 'credit' : 'debit',
      'status': status == TransactionStatus.successful
          ? 'successful'
          : (status == TransactionStatus.pending ? 'pending' : 'failed'),
      'paymentMethod': paymentMethod,
      'recipientOrSender': recipientOrSender,
      'note': note,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map, {String? docId}) {
    TransactionType txType = TransactionType.debit;
    if (map['type'] == 'credit' || map['type'] == 'TransactionType.credit') {
      txType = TransactionType.credit;
    }

    TransactionStatus txStatus = TransactionStatus.successful;
    if (map['status'] == 'pending') {
      txStatus = TransactionStatus.pending;
    } else if (map['status'] == 'failed') {
      txStatus = TransactionStatus.failed;
    }

    DateTime parsedDate = DateTime.now();
    if (map['date'] != null) {
      if (map['date'] is String) {
        parsedDate = DateTime.tryParse(map['date']) ?? DateTime.now();
      }
    }

    return TransactionItem(
      transactionId: docId ?? map['transactionId'] ?? 'BLTXN_${DateTime.now().millisecondsSinceEpoch}',
      title: map['title'] ?? 'Transaction',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? 'General',
      date: parsedDate,
      type: txType,
      status: txStatus,
      paymentMethod: map['paymentMethod'] ?? 'Savings Account',
      recipientOrSender: map['recipientOrSender'] ?? '',
      note: map['note'] ?? '',
    );
  }
}

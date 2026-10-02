/// Model representing an official bank statement generation record
/// stored in Cloud Firestore under `/users/{uid}/statements/{statementId}`.
class AccountStatementRecord {
  final String statementId;
  final String accountId;
  final String period;
  final String format; // 'PDF' | 'Excel (CSV)'
  final DateTime generatedAt;
  final double totalCredits;
  final double totalDebits;
  final int entryCount;
  final String fileName;
  final String status; // 'Downloaded' | 'Emailed'
  final String? deliveredToEmail;

  AccountStatementRecord({
    required this.statementId,
    required this.accountId,
    required this.period,
    required this.format,
    required this.generatedAt,
    required this.totalCredits,
    required this.totalDebits,
    required this.entryCount,
    required this.fileName,
    this.status = 'Downloaded',
    this.deliveredToEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      'statementId': statementId,
      'accountId': accountId,
      'period': period,
      'format': format,
      'generatedAt': generatedAt.toIso8601String(),
      'totalCredits': totalCredits,
      'totalDebits': totalDebits,
      'entryCount': entryCount,
      'fileName': fileName,
      'status': status,
      if (deliveredToEmail != null) 'deliveredToEmail': deliveredToEmail,
    };
  }

  factory AccountStatementRecord.fromMap(Map<String, dynamic> map, {String? docId}) {
    return AccountStatementRecord(
      statementId: docId ?? map['statementId'] ?? '',
      accountId: map['accountId'] ?? '',
      period: map['period'] ?? 'Last 30 Days',
      format: map['format'] ?? 'PDF',
      generatedAt: map['generatedAt'] != null
          ? (DateTime.tryParse(map['generatedAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      totalCredits: (map['totalCredits'] as num?)?.toDouble() ?? 0.0,
      totalDebits: (map['totalDebits'] as num?)?.toDouble() ?? 0.0,
      entryCount: (map['entryCount'] as num?)?.toInt() ?? 0,
      fileName: map['fileName'] ?? '',
      status: map['status'] ?? 'Downloaded',
      deliveredToEmail: map['deliveredToEmail'] as String?,
    );
  }
}

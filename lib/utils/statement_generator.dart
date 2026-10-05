import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

class StatementGenerator {
  /// Generate a PDF e-Statement document with official styling and complete transaction ledger
  static Future<Uint8List> generatePdf({
    required UserModel user,
    required Account account,
    required List<TransactionItem> transactions,
    required String period,
    required double totalCredits,
    required double totalDebits,
  }) async {
    final pdf = pw.Document();

    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final shortDateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat('#,##,##0.00', 'en_IN');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'BANKLITE',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#0F172A'),
                        ),
                      ),
                      pw.Text(
                        'Digital Banking Corporation • RBI Licensed',
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColor.fromHex('#64748B'),
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#ECFDF5'),
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border.all(color: PdfColor.fromHex('#10B981')),
                    ),
                    child: pw.Text(
                      'OFFICIAL e-STATEMENT',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#059669'),
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColor.fromHex('#E2E8F0'), thickness: 1),
              pw.SizedBox(height: 8),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Divider(color: PdfColor.fromHex('#E2E8F0'), thickness: 0.5),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Page ${context.pageNumber} of ${context.pagesCount} • BankLite 256-bit Certified Document',
                    style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('#94A3B8')),
                  ),
                  pw.Text(
                    'Confidential & Proprietary',
                    style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('#94A3B8')),
                  ),
                ],
              ),
            ],
          );
        },
        build: (pw.Context context) => [
          // Account & Customer Details Card
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F8FAFC'),
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('ACCOUNT HOLDER', style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('#64748B'), fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text(user.name, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text(user.email, style: const pw.TextStyle(fontSize: 9)),
                      pw.Text(user.phone, style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('ACCOUNT DETAILS', style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('#64748B'), fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text('${account.accountType} (${account.maskedNumber})', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text('IFSC: ${account.ifscCode}', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text('Bank: ${account.bankName}', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('STATEMENT PERIOD', style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('#64748B'), fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text(period, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#059669'))),
                      pw.SizedBox(height: 2),
                      pw.Text('Generated: ${dateFormat.format(DateTime.now())}', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 14),

          // Financial Summary Metrics
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#ECFDF5'),
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: PdfColor.fromHex('#A7F3D0')),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('TOTAL INFLOW (+)', style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('#065F46'), fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text('+Rs ${currencyFormat.format(totalCredits)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#059669'))),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#FEF2F2'),
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: PdfColor.fromHex('#FECACA')),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('TOTAL OUTFLOW (-)', style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('#991B1B'), fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text('-Rs ${currencyFormat.format(totalDebits)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#DC2626'))),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#EFF6FF'),
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: PdfColor.fromHex('#BFDBFE')),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('AVAILABLE BALANCE', style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('#1E40AF'), fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text('Rs ${currencyFormat.format(account.balance)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1D4ED8'))),
                    ],
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 16),

          // Ledger Table Header
          pw.Text(
            'TRANSACTION LEDGER (${transactions.length} ENTRIES)',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0F172A')),
          ),
          pw.SizedBox(height: 6),

          // Ledger Table
          if (transactions.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 24),
              alignment: pw.Alignment.center,
              child: pw.Text('No transactions recorded for this selected period.', style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#64748B'))),
            )
          else
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColor.fromHex('#E2E8F0'), width: 0.5),
              headerStyle: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E293B')),
              headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#F1F5F9')),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              headers: ['Date', 'Txn Ref', 'Description / Recipient', 'Category', 'Type', 'Amount (INR)'],
              data: transactions.map((t) {
                final isCredit = t.type == TransactionType.credit;
                return [
                  shortDateFormat.format(t.date),
                  t.transactionId,
                  t.title,
                  t.category,
                  isCredit ? 'CREDIT' : 'DEBIT',
                  '${isCredit ? '+' : '-'}Rs ${currencyFormat.format(t.amount)}',
                ];
              }).toList(),
            ),

          pw.SizedBox(height: 20),

          // Bank Certification Seal
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1'), width: 0.5),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('BankLite Certified Electronic Statement', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Digitally generated by BankLite Core Banking Engine. Valid without physical stamp.', style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('#64748B'))),
                  ],
                ),
                pw.Text('STATUS: VERIFIED', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#059669'))),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// Generate a formatted Excel (.csv) ledger file with BOM for Microsoft Excel & Google Sheets
  static Uint8List generateExcelCsv({
    required UserModel user,
    required Account account,
    required List<TransactionItem> transactions,
    required String period,
    required double totalCredits,
    required double totalDebits,
  }) {
    final buffer = StringBuffer();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final currencyFormat = NumberFormat('#,##,##0.00', 'en_IN');

    // UTF-8 BOM so Excel opens with proper encoding
    buffer.write('\uFEFF');

    // Header info
    buffer.writeln('BankLite Digital Banking - Account Statement');
    buffer.writeln('Account Holder,${_escapeCsv(user.name)}');
    buffer.writeln('Email,${_escapeCsv(user.email)}');
    buffer.writeln('Account Type,${_escapeCsv(account.accountType)}');
    buffer.writeln('Account Number,${_escapeCsv(account.accountNumber)}');
    buffer.writeln('IFSC Code,${_escapeCsv(account.ifscCode)}');
    buffer.writeln('Bank,${_escapeCsv(account.bankName)}');
    buffer.writeln('Statement Period,${_escapeCsv(period)}');
    buffer.writeln('Generated On,${dateFormat.format(DateTime.now())}');
    buffer.writeln();

    // Summary
    buffer.writeln('--- FINANCIAL SUMMARY ---');
    buffer.writeln('Total Credits (Inflow),${currencyFormat.format(totalCredits)}');
    buffer.writeln('Total Debits (Outflow),${currencyFormat.format(totalDebits)}');
    buffer.writeln('Available Balance,${currencyFormat.format(account.balance)}');
    buffer.writeln('Total Transactions,${transactions.length}');
    buffer.writeln();

    // Ledger Columns
    buffer.writeln('Date,Transaction ID,Description,Category,Type,Amount (INR),Payment Method,Status');

    for (final t in transactions) {
      final isCredit = t.type == TransactionType.credit;
      final typeStr = isCredit ? 'CREDIT' : 'DEBIT';
      final formattedAmount = '${isCredit ? '' : '-'}${t.amount.toStringAsFixed(2)}';
      buffer.writeln(
        '${_escapeCsv(dateFormat.format(t.date))},'
        '${_escapeCsv(t.transactionId)},'
        '${_escapeCsv(t.title)},'
        '${_escapeCsv(t.category)},'
        '$typeStr,'
        '$formattedAmount,'
        '${_escapeCsv(t.paymentMethod)},'
        '${_escapeCsv(t.status.name.toUpperCase())}',
      );
    }

    return Uint8List.fromList(utf8.encode(buffer.toString()));
  }

  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Generate a professional official PDF E-Receipt for a transaction
  static Future<Uint8List> generateReceiptPdf({
    required TransactionItem transaction,
    String bankName = 'BankLite National Bank',
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final currencyFormat = NumberFormat('#,##,##0.00', 'en_IN');
    final isCredit = transaction.isCredit;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(22),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0'), width: 1.5),
              borderRadius: pw.BorderRadius.circular(16),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'BANKLITE',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#0B132B'),
                  ),
                ),
                pw.Text(
                  'OFFICIAL TRANSACTION E-RECEIPT',
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#64748B'),
                    letterSpacing: 1.2,
                  ),
                ),
                pw.SizedBox(height: 14),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#ECFDF5'),
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Text(
                    'PAYMENT SUCCESSFUL',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#059669'),
                    ),
                  ),
                ),
                pw.SizedBox(height: 14),
                pw.Text(
                  '${isCredit ? '+' : '-'}Rs ${currencyFormat.format(transaction.amount)}',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: isCredit ? PdfColor.fromHex('#059669') : PdfColor.fromHex('#0B132B'),
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  transaction.title,
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColor.fromHex('#475569'),
                  ),
                ),
                pw.SizedBox(height: 14),
                pw.Divider(color: PdfColor.fromHex('#E2E8F0'), thickness: 1),
                pw.SizedBox(height: 8),
                _buildPdfReceiptRow('Transaction Reference ID', transaction.transactionId),
                _buildPdfReceiptRow('Date & Time', dateFormat.format(transaction.date)),
                _buildPdfReceiptRow('Type', isCredit ? 'Credit (Deposit)' : 'Debit (Payment)'),
                _buildPdfReceiptRow('Category', transaction.category),
                _buildPdfReceiptRow('Payment Method', transaction.paymentMethod),
                if (transaction.recipientOrSender.isNotEmpty)
                  _buildPdfReceiptRow(isCredit ? 'Sender' : 'Recipient', transaction.recipientOrSender),
                if (transaction.note.isNotEmpty)
                  _buildPdfReceiptRow('Note / Remarks', transaction.note),
                pw.SizedBox(height: 8),
                pw.Divider(color: PdfColor.fromHex('#E2E8F0'), thickness: 1),
                pw.SizedBox(height: 14),
                pw.Text(
                  'Digitally certified & verified by BankLite Core Banking System',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfColor.fromHex('#94A3B8'),
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'This is an electronic receipt and requires no physical signature.',
                  style: pw.TextStyle(
                    fontSize: 7.5,
                    color: PdfColor.fromHex('#94A3B8'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfReceiptRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9.5,
              color: PdfColor.fromHex('#64748B'),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#0F172A'),
            ),
          ),
        ],
      ),
    );
  }
}

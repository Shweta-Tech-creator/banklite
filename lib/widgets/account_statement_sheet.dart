import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/banking_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../utils/file_downloader.dart';
import '../utils/statement_generator.dart';
import 'account_statement_icon.dart';

class AccountStatementSheet extends StatefulWidget {
  const AccountStatementSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AccountStatementSheet(),
    );
  }

  @override
  State<AccountStatementSheet> createState() => _AccountStatementSheetState();
}

class _AccountStatementSheetState extends State<AccountStatementSheet> {
  String _selectedPeriod = 'Last 30 Days';
  bool _isDownloadingPdf = false;
  bool _isDownloadingExcel = false;

  final List<String> _periods = [
    'Last 30 Days',
    'Last 3 Months',
    'Last 6 Months',
    'This Year',
  ];

  DateTime _getStartDateForPeriod(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'Last 30 Days':
        return now.subtract(const Duration(days: 30));
      case 'Last 3 Months':
        return DateTime(now.year, now.month - 3, now.day);
      case 'Last 6 Months':
        return DateTime(now.year, now.month - 6, now.day);
      case 'This Year':
        return DateTime(now.year, 1, 1);
      default:
        return now.subtract(const Duration(days: 30));
    }
  }

  Future<void> _downloadPdf() async {
    if (_isDownloadingPdf || _isDownloadingExcel) return;
    setState(() => _isDownloadingPdf = true);

    try {
      final banking = context.bankingRead;
      final startDate = _getStartDateForPeriod(_selectedPeriod);
      final periodTransactions = banking.transactions.where((t) => t.date.isAfter(startDate)).toList();

      double totalCredits = 0.0;
      double totalDebits = 0.0;
      for (final t in periodTransactions) {
        if (t.type == TransactionType.credit) {
          totalCredits += t.amount;
        } else {
          totalDebits += t.amount;
        }
      }

      final pdfBytes = await StatementGenerator.generatePdf(
        user: banking.user,
        account: banking.selectedAccount,
        transactions: periodTransactions,
        period: _selectedPeriod,
        totalCredits: totalCredits,
        totalDebits: totalDebits,
      );

      final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
      final safeAccNum = banking.selectedAccount.accountNumber.replaceAll(RegExp(r'\s+'), '');
      final fileName = 'BankLite_Statement_${safeAccNum}_$dateStr.pdf';

      FileDownloader.download(
        bytes: pdfBytes,
        fileName: fileName,
        mimeType: 'application/pdf',
      );

      // Record statement in Cloud Firestore under /users/{uid}/statements/
      await banking.recordStatementGenerated(
        format: 'PDF',
        period: _selectedPeriod,
        totalCredits: totalCredits,
        totalDebits: totalDebits,
        entryCount: periodTransactions.length,
        fileName: fileName,
        status: 'Downloaded',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Downloaded "$fileName" successfully.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloadingPdf = false);
      }
    }
  }

  Future<void> _downloadExcel() async {
    if (_isDownloadingPdf || _isDownloadingExcel) return;
    setState(() => _isDownloadingExcel = true);

    try {
      final banking = context.bankingRead;
      final startDate = _getStartDateForPeriod(_selectedPeriod);
      final periodTransactions = banking.transactions.where((t) => t.date.isAfter(startDate)).toList();

      double totalCredits = 0.0;
      double totalDebits = 0.0;
      for (final t in periodTransactions) {
        if (t.type == TransactionType.credit) {
          totalCredits += t.amount;
        } else {
          totalDebits += t.amount;
        }
      }

      final excelBytes = StatementGenerator.generateExcelCsv(
        user: banking.user,
        account: banking.selectedAccount,
        transactions: periodTransactions,
        period: _selectedPeriod,
        totalCredits: totalCredits,
        totalDebits: totalDebits,
      );

      final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
      final safeAccNum = banking.selectedAccount.accountNumber.replaceAll(RegExp(r'\s+'), '');
      final fileName = 'BankLite_Statement_${safeAccNum}_$dateStr.csv';

      FileDownloader.download(
        bytes: excelBytes,
        fileName: fileName,
        mimeType: 'text/csv;charset=utf-8',
      );

      // Record statement in Cloud Firestore under /users/{uid}/statements/
      await banking.recordStatementGenerated(
        format: 'Excel (CSV)',
        period: _selectedPeriod,
        totalCredits: totalCredits,
        totalDebits: totalDebits,
        entryCount: periodTransactions.length,
        fileName: fileName,
        status: 'Downloaded',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Downloaded "$fileName" for Excel successfully.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0284C7),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate Excel file: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloadingExcel = false);
      }
    }
  }

  void _handleEmailStatement(String userEmail) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.mark_email_read_rounded, color: Color(0xFF059669)),
            SizedBox(width: 8),
            Text('Email Statement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Your password-protected official e-Statement for $_selectedPeriod will be delivered to:\n\n$userEmail\n\nThe PDF password is your PAN or Date of Birth (DDMMYYYY).',
          style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final banking = context.bankingRead;
              final startDate = _getStartDateForPeriod(_selectedPeriod);
              final periodTransactions = banking.transactions.where((t) => t.date.isAfter(startDate)).toList();
              double totalCredits = 0.0;
              double totalDebits = 0.0;
              for (final t in periodTransactions) {
                if (t.type == TransactionType.credit) {
                  totalCredits += t.amount;
                } else {
                  totalDebits += t.amount;
                }
              }
              final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
              final safeAccNum = banking.selectedAccount.accountNumber.replaceAll(RegExp(r'\s+'), '');
              final fileName = 'BankLite_Statement_${safeAccNum}_$dateStr.pdf';

              // Record in Cloud Firestore
              banking.recordStatementGenerated(
                format: 'PDF',
                period: _selectedPeriod,
                totalCredits: totalCredits,
                totalDebits: totalDebits,
                entryCount: periodTransactions.length,
                fileName: fileName,
                status: 'Emailed',
                email: userEmail,
              );

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Official statement sent to $userEmail'),
                  backgroundColor: AppColors.primaryNavy,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final banking = context.banking;
    final selectedAcc = banking.selectedAccount;
    final user = banking.user;

    final startDate = _getStartDateForPeriod(_selectedPeriod);
    final periodTransactions = banking.transactions.where((t) => t.date.isAfter(startDate)).toList();

    double totalCredits = 0.0;
    double totalDebits = 0.0;
    for (final t in periodTransactions) {
      if (t.type == TransactionType.credit) {
        totalCredits += t.amount;
      } else {
        totalDebits += t.amount;
      }
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: const AccountStatementIcon(size: 26),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Statement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Official Certified e-Statement & Ledger',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          // Scrollable Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              children: [
                // Account Information Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: AppColors.luxuryCardGradient,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryNavy.withValues(alpha: 0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedAcc.accountType,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded, color: Color(0xFF34D399), size: 12),
                                SizedBox(width: 4),
                                Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    color: Color(0xFF34D399),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        selectedAcc.maskedNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Available Balance', style: TextStyle(color: Colors.white60, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(
                                CurrencyFormatter.format(selectedAcc.balance),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('IFSC Code', style: TextStyle(color: Colors.white60, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(
                                selectedAcc.ifscCode,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // DOWNLOAD ACTION BUTTONS (Prominently placed at the top)
                Row(
                  children: [
                    // Download PDF Button
                    Expanded(
                      child: InkWell(
                        onTap: _isDownloadingPdf ? null : _downloadPdf,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF43F5E).withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isDownloadingPdf)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              else ...[
                                const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                _isDownloadingPdf ? 'Creating...' : 'Download PDF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Download Excel Button
                    Expanded(
                      child: InkWell(
                        onTap: _isDownloadingExcel ? null : _downloadExcel,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isDownloadingExcel)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              else ...[
                                const Icon(Icons.table_view_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                _isDownloadingExcel ? 'Creating...' : 'Download Excel',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Select Statement Period
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Statement Period',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _handleEmailStatement(user.email),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        foregroundColor: AppColors.accentBlue,
                      ),
                      icon: const Icon(Icons.email_outlined, size: 14),
                      label: const Text('Email to Me', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _periods.map((period) {
                      final isSelected = _selectedPeriod == period;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(period),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedPeriod = period),
                          selectedColor: AppColors.primaryNavy,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected ? AppColors.primaryNavy : AppColors.cardBorder,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 18),

                // Period Summary Statistics
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Inflow (+)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text(
                              '+${CurrencyFormatter.format(totalCredits)}',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.successDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 32, color: AppColors.divider),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Outflow (-)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text(
                              '-${CurrencyFormatter.format(totalDebits)}',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 32, color: Colors.grey[300]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Entries', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            const SizedBox(height: 2),
                            Text(
                              '${periodTransactions.length}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Transaction Ledger Preview Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Statement Preview',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${periodTransactions.length} items',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (periodTransactions.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    alignment: Alignment.center,
                    child: const Text(
                      'No transactions recorded in this period',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  )
                else
                  ...periodTransactions.take(15).map((t) {
                    final isCredit = t.type == TransactionType.credit;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isCredit
                                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                  : const Color(0xFFEF4444).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                              size: 16,
                              color: isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${DateFormat('dd MMM yyyy').format(t.date)} • ${t.category}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${isCredit ? '+' : '-'}${CurrencyFormatter.format(t.amount)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

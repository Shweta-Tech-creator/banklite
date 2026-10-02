import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/receipt_dialog.dart';
import '../../widgets/responsive_wrapper.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final TransactionItem transaction;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  void _showDisputeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Transaction Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ref ID: ${transaction.transactionId}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accentBlue)),
            const SizedBox(height: 10),
            const Text(
              'Our 24/7 BankLite AI Support will verify this transaction record and provide resolution within 2 hours.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Support ticket raised! Ticket ID: #BL-SRV-9921'),
                  backgroundColor: AppColors.primaryNavy,
                ),
              );
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(120, 44)),
            child: const Text('Submit Ticket'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;

    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Transaction Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Share Receipt',
              onPressed: () => ReceiptDialog.show(context, transaction),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Top Amount Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Category Emblem
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: isCredit ? AppColors.successLight : AppColors.softBlueBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                          color: isCredit ? AppColors.successDark : AppColors.primaryNavy,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        transaction.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Amount
                      Text(
                        '${isCredit ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: isCredit ? AppColors.successDark : AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.successDark, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              transaction.statusText,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.successDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Comprehensive Breakdown Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transaction Information',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRow(
                        'Transaction ID',
                        transaction.transactionId,
                        isCopyable: true,
                        context: context,
                        isHighlighted: true,
                      ),
                      const Divider(height: 20),
                      _buildRow('Type', isCredit ? 'Credit' : 'Debit'),
                      const Divider(height: 20),
                      _buildRow('Category', transaction.category),
                      const Divider(height: 20),
                      _buildRow('Date', DateFormatter.formatDateOnly(transaction.date)),
                      const Divider(height: 20),
                      _buildRow('Time', DateFormatter.formatTimeOnly(transaction.date)),
                      const Divider(height: 20),
                      _buildRow('Payment Method', transaction.paymentMethod),
                      if (transaction.recipientOrSender.isNotEmpty) ...[
                        const Divider(height: 20),
                        _buildRow(isCredit ? 'Sender' : 'Recipient', transaction.recipientOrSender),
                      ],
                      if (transaction.note.isNotEmpty) ...[
                        const Divider(height: 20),
                        _buildRow('Note / Remarks', transaction.note),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                ElevatedButton.icon(
                  onPressed: () {
                    ReceiptDialog.show(context, transaction);
                  },
                  icon: const Icon(Icons.receipt_long, size: 18),
                  label: const Text('Download / Share E-Receipt'),
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: () => _showDisputeDialog(context),
                  icon: const Icon(Icons.support_agent_rounded, size: 18),
                  label: const Text('Report an Issue with Transaction'),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isCopyable = false,
    bool isHighlighted = false,
    BuildContext? context,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
                    color: isHighlighted ? AppColors.accentBlue : AppColors.textPrimary,
                  ),
                ),
              ),
              if (isCopyable && context != null) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$label copied')),
                    );
                  },
                  child: const Icon(Icons.copy_rounded, size: 14, color: AppColors.accentBlue),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

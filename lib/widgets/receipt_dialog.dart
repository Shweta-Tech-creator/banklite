import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import 'bank_logo_emblem.dart';

class ReceiptDialog extends StatelessWidget {
  final TransactionItem transaction;

  const ReceiptDialog({
    super.key,
    required this.transaction,
  });

  static void show(BuildContext context, TransactionItem transaction) {
    showDialog(
      context: context,
      builder: (context) => ReceiptDialog(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header logo & bank name
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const BankLogoEmblem(size: 38),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BankLite',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      Text(
                        'Official E-Receipt',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Success badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.successDark, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Payment Successful',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.successDark,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Amount
              Text(
                '${isCredit ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isCredit ? AppColors.successDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                transaction.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),
              const Divider(color: AppColors.cardBorder, thickness: 1),
              const SizedBox(height: 16),

              // Receipt Key-Value fields
              _buildReceiptRow('Transaction ID', transaction.transactionId, isCopyable: true, context: context),
              _buildReceiptRow('Date & Time', DateFormatter.formatFull(transaction.date)),
              _buildReceiptRow('Type', isCredit ? 'Credit (Deposit)' : 'Debit (Payment)'),
              _buildReceiptRow('Category', transaction.category),
              _buildReceiptRow('Payment Method', transaction.paymentMethod),
              if (transaction.recipientOrSender.isNotEmpty)
                _buildReceiptRow('Recipient / Entity', transaction.recipientOrSender),
              if (transaction.note.isNotEmpty)
                _buildReceiptRow('Note / Remarks', transaction.note),

              const SizedBox(height: 16),
              const Divider(color: AppColors.cardBorder, thickness: 1),
              const SizedBox(height: 16),

              // Footer Barcode / Ref Mockup
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code, color: AppColors.textSecondary, size: 28),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Digitally Verified by BankLite Core',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Ref: BL-REC-${transaction.transactionId}',
                          style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                          text: 'BankLite Receipt\nTxn ID: ${transaction.transactionId}\nAmount: ₹${transaction.amount}\nDate: ${DateFormatter.formatFull(transaction.date)}\nStatus: Successful',
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Receipt details copied to clipboard')),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('Copy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('E-Receipt saved / shared successfully')),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Share'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isCopyable = false, BuildContext? context}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isCopyable && context != null) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$label copied to clipboard')),
                      );
                    },
                    child: const Icon(Icons.copy, size: 12, color: AppColors.accentBlue),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

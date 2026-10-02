import 'package:flutter/material.dart';
import '../../models/account_model.dart';
import '../../models/beneficiary_model.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency_formatter.dart';

class TransferConfirmDialog extends StatelessWidget {
  final Account fromAccount;
  final Beneficiary beneficiary;
  final double amount;
  final String note;
  final VoidCallback onConfirm;

  const TransferConfirmDialog({
    super.key,
    required this.fromAccount,
    required this.beneficiary,
    required this.amount,
    required this.note,
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    required Account fromAccount,
    required Beneficiary beneficiary,
    required double amount,
    required String note,
    required VoidCallback onConfirm,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TransferConfirmDialog(
        fromAccount: fromAccount,
        beneficiary: beneficiary,
        amount: amount,
        note: note,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double fee = 0.0;
    final double total = amount + fee;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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
          const SizedBox(height: 18),

          // Title
          const Center(
            child: Text(
              'Confirm Money Transfer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Please review your transfer details carefully',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 22),

          // Transfer Summary Container
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                  'From Account',
                  '${fromAccount.accountType}\n${fromAccount.maskedNumber}',
                  icon: Icons.account_balance_wallet_outlined,
                ),
                const Divider(height: 20),
                _buildSummaryRow(
                  'To Beneficiary',
                  '${beneficiary.name}\n${beneficiary.bankName} (${beneficiary.maskedNumber})',
                  icon: Icons.person_outline,
                ),
                const Divider(height: 20),
                _buildSummaryRow(
                  'Transfer Amount',
                  CurrencyFormatter.format(amount),
                  isBold: true,
                  icon: Icons.currency_rupee,
                ),
                const Divider(height: 20),
                _buildSummaryRow(
                  'Transfer Fee',
                  '₹0.00 (Free Instant IMPS)',
                  icon: Icons.flash_on_outlined,
                  valueColor: AppColors.successDark,
                ),
                if (note.isNotEmpty) ...[
                  const Divider(height: 20),
                  _buildSummaryRow(
                    'Transfer Note',
                    note,
                    icon: Icons.note_outlined,
                  ),
                ],
                const Divider(height: 24, thickness: 1.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Debit',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(total),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                    onConfirm();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 18),
                      SizedBox(width: 6),
                      Text('Confirm Transfer'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
    IconData? icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
        ],
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

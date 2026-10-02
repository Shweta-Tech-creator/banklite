import 'package:flutter/material.dart';
import '../../models/account_model.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency_formatter.dart';

class BillConfirmDialog extends StatelessWidget {
  final String billType;
  final String provider;
  final String consumerNumber;
  final double amount;
  final double fee;
  final double totalAmount;
  final Account paymentAccount;
  final VoidCallback onConfirm;

  const BillConfirmDialog({
    super.key,
    required this.billType,
    required this.provider,
    required this.consumerNumber,
    required this.amount,
    required this.fee,
    required this.totalAmount,
    required this.paymentAccount,
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String billType,
    required String provider,
    required String consumerNumber,
    required double amount,
    required double fee,
    required double totalAmount,
    required Account paymentAccount,
    required VoidCallback onConfirm,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BillConfirmDialog(
        billType: billType,
        provider: provider,
        consumerNumber: consumerNumber,
        amount: amount,
        fee: fee,
        totalAmount: totalAmount,
        paymentAccount: paymentAccount,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

          const Center(
            child: Text(
              'Confirm Bill Payment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Verify utility provider details below',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Summary Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                _buildRow('Bill Category', billType),
                const Divider(height: 18),
                _buildRow('Provider', provider, isBold: true),
                const Divider(height: 18),
                _buildRow('Consumer / A/C No', consumerNumber),
                const Divider(height: 18),
                _buildRow('Bill Amount', CurrencyFormatter.format(amount)),
                const Divider(height: 18),
                _buildRow('Convenience Fee', CurrencyFormatter.format(fee)),
                const Divider(height: 18),
                _buildRow('Payment Method', '${paymentAccount.accountType} (${paymentAccount.maskedNumber})'),
                const Divider(height: 22, thickness: 1.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Payable',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(totalAmount),
                      style: const TextStyle(
                        fontSize: 19,
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

          // Action buttons
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
                  child: Text('Pay ${CurrencyFormatter.format(totalAmount)}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
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
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

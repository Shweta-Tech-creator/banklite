import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/receipt_dialog.dart';
import '../../widgets/responsive_wrapper.dart';
import '../transactions/transaction_details_screen.dart';

class TransferSuccessScreen extends StatefulWidget {
  final TransactionItem transaction;

  const TransferSuccessScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<TransferSuccessScreen> createState() => _TransferSuccessScreenState();
}

class _TransferSuccessScreenState extends State<TransferSuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txn = widget.transaction;

    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Transfer Receipt'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // Animated Success Checkmark Icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.successGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.successDark.withValues(alpha: 0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 52,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const Text(
                        'Transfer Successful',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${CurrencyFormatter.format(txn.amount)} transferred successfully.',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Transaction Summary Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.cardBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow('Transaction ID', txn.transactionId, isHighlighted: true),
                            const Divider(height: 22),
                            _buildDetailRow('Date & Time', DateFormatter.formatFull(txn.date)),
                            const Divider(height: 22),
                            _buildDetailRow('Recipient', txn.title.replaceAll('Transfer to ', '')),
                            const Divider(height: 22),
                            _buildDetailRow('Payment Source', txn.paymentMethod),
                            const Divider(height: 22),
                            _buildDetailRow('Status', 'Successful', statusColor: AppColors.successDark),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // E-Receipt quick banner
                      OutlinedButton.icon(
                        onPressed: () {
                          ReceiptDialog.show(context, txn);
                        },
                        icon: const Icon(Icons.receipt_outlined, size: 18),
                        label: const Text('Download / Share Official E-Receipt'),
                      ),

                      const SizedBox(height: 14),

                      // View Transaction Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TransactionDetailsScreen(transaction: txn),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryNavy,
                        ),
                        child: const Text('View Transaction Details'),
                      ),

                      const SizedBox(height: 12),

                      // Back to Dashboard Button
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text(
                          'Back to Dashboard',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlighted = false, Color? statusColor}) {
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
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
              color: statusColor ?? (isHighlighted ? AppColors.accentBlue : AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}

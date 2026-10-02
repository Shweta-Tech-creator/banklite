import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';

class TransactionTile extends StatelessWidget {
  final TransactionItem transaction;
  final VoidCallback onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'income':
      case 'salary':
        return Icons.arrow_downward_rounded;
      case 'bills':
      case 'electricity':
      case 'utilities':
        return Icons.receipt_long_outlined;
      case 'food':
        return Icons.restaurant_outlined;
      case 'travel':
      case 'transport':
        return Icons.directions_car_outlined;
      case 'entertainment':
        return Icons.movie_creation_outlined;
      case 'transfer':
        return Icons.send_rounded;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'shopping':
        return const Color(0xFF8B5CF6); // Purple
      case 'income':
      case 'salary':
        return AppColors.successDark; // Green
      case 'bills':
      case 'electricity':
        return const Color(0xFFF59E0B); // Amber
      case 'food':
        return const Color(0xFFEF4444); // Coral Red
      case 'travel':
        return const Color(0xFF0284C7); // Cyan Blue
      case 'entertainment':
        return const Color(0xFFEC4899); // Pink
      case 'transfer':
        return AppColors.accentBlue; // Bright Blue
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(transaction.category);
    final isCredit = transaction.isCredit;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Category Icon with glow
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getCategoryIcon(transaction.category),
                    color: catColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Title & Subtitle / Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        transaction.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              transaction.category,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: catColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              DateFormatter.formatShort(transaction.date),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Amount & Type Indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${isCredit ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isCredit ? AppColors.successDark : AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isCredit ? 'Received' : 'Paid',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isCredit ? AppColors.successDark : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../services/banking_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/responsive_wrapper.dart';

class BudgetInsightsScreen extends StatelessWidget {
  const BudgetInsightsScreen({super.key});

  void _showSetBudgetDialog(BuildContext context) {
    final banking = context.bankingRead;
    final budgetCtrl = TextEditingController(text: banking.budget.monthlyBudget.toStringAsFixed(0));
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Monthly Budget', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Define your target monthly spending limit:',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: budgetCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monthly Budget Amount',
                  prefixText: '₹ ',
                ),
                validator: (val) {
                  final parsed = double.tryParse(val ?? '');
                  if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final amt = double.parse(budgetCtrl.text.trim());
                banking.updateMonthlyBudget(amt);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Monthly budget updated!'), backgroundColor: AppColors.successDark),
                );
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 42)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'bills':
        return Icons.receipt_long;
      case 'travel':
        return Icons.directions_car;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return const Color(0xFFEF4444);
      case 'shopping':
        return const Color(0xFF8B5CF6);
      case 'bills':
        return const Color(0xFFF59E0B);
      case 'travel':
        return const Color(0xFF0284C7);
      default:
        return AppColors.accentBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final banking = context.banking;
    final budget = banking.budget;
    final usagePercent = budget.percentageUsed;
    final remaining = budget.remaining;
    final totalSpent = budget.totalSpent;
    final monthlyBudget = budget.monthlyBudget;
    final categorySpending = budget.categorySpending;

    Color progressColor = AppColors.successDark;
    if (usagePercent > 85) {
      progressColor = AppColors.error;
    } else if (usagePercent > 65) {
      progressColor = AppColors.warning;
    }

    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Budget & Insights'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.tune_rounded),
              tooltip: 'Adjust Budget',
              onPressed: () => _showSetBudgetDialog(context),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Monthly Budget Overview Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0F172A),
                        Color(0xFF1E293B),
                        Color(0xFF0F3460),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryNavy.withValues(alpha: 0.25),
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
                          const Flexible(
                            child: Text(
                              'Monthly Spending Budget',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: progressColor.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: progressColor.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              '${usagePercent.toStringAsFixed(0)}% Used',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        CurrencyFormatter.format(monthlyBudget),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (usagePercent / 100).clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Spent vs Remaining row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Spent',
                                  style: TextStyle(color: Colors.white60, fontSize: 12),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  CurrencyFormatter.format(totalSpent),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 36,
                            width: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Remaining',
                                  style: TextStyle(color: Colors.white60, fontSize: 12),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  CurrencyFormatter.format(remaining),
                                  style: const TextStyle(
                                    color: AppColors.electricCyan,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Category Breakdown Header
                const Text(
                  'Spending by Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 14),

                // Category Cards List
                ...categorySpending.entries.map((entry) {
                  final categoryName = entry.key;
                  final spent = entry.value;
                  final color = _getCategoryColor(categoryName);
                  final categoryPercent = totalSpent > 0 ? ((spent / totalSpent) * 100) : 0.0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                _getCategoryIcon(categoryName),
                                color: color,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    categoryName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${categoryPercent.toStringAsFixed(1)}% of total spent',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(spent),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (categoryPercent / 100).clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: AppColors.background,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/banking_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/account_statement_icon.dart';
import '../widgets/account_statement_sheet.dart';
import '../widgets/balance_card.dart';
import '../widgets/notifications_sheet.dart';
import '../widgets/qr_scanner_dialog.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/responsive_wrapper.dart';
import '../widgets/transaction_tile.dart';
import 'bills/pay_bills_screen.dart';
import 'transactions/transaction_details_screen.dart';
import 'transfer/transfer_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int tabIndex)? onNavigateToTab;

  const DashboardScreen({
    super.key,
    this.onNavigateToTab,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 22) {
      return 'Good Evening';
    } else {
      return 'Welcome Back';
    }
  }

  @override
  Widget build(BuildContext context) {
    final banking = context.banking;
    final user = banking.user;
    final recentTxns = banking.recentTransactions;
    final unreadCount = banking.unreadNotificationCount;
    final budget = banking.budget;

    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 14.0, bottom: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Bar: User Profile, Greeting & Notification Bell
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (onNavigateToTab != null) {
                              onNavigateToTab!(3); // Profile tab
                            }
                          },
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.primaryNavy,
                                child: Text(
                                  user.name.trim().split(RegExp(r'\s+')).where((n) => n.isNotEmpty).map((n) => n[0].toUpperCase()).take(2).join(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppColors.successDark,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_getGreeting()},',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Luxury Notification Bell with Badge
                    InkWell(
                      onTap: () => NotificationsSheet.show(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.cardBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.notifications_none_rounded,
                              size: 22,
                              color: AppColors.primaryNavy,
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                  ),
                                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                  child: Text(
                                    '$unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      height: 1,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Luxury Balance Card
                const BalanceCard(),

                const SizedBox(height: 18),

                // Monthly Budget Spending Pill Banner
                InkWell(
                  onTap: () {
                    if (onNavigateToTab != null) {
                      onNavigateToTab!(2); // Budget tab
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.softBlueBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accentBlue.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.pie_chart_rounded, size: 18, color: AppColors.accentBlue),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Flexible(
                                    child: Text(
                                      'Monthly Spending Goal',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryNavy,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${budget.percentageUsed.toStringAsFixed(0)}% Used',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accentBlue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (budget.percentageUsed / 100).clamp(0.0, 1.0),
                                  minHeight: 5,
                                  backgroundColor: Colors.white,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    budget.percentageUsed > 85 ? AppColors.error : AppColors.accentBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${CurrencyFormatter.format(budget.totalSpent)} of ${CurrencyFormatter.format(budget.monthlyBudget)} • ${CurrencyFormatter.format(budget.remaining)} left',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // Quick Actions Section
                const Text(
                  'Quick Services',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 12),

                // 4 Quick Action Cards Grid
                Row(
                  children: [
                    Expanded(
                      child: QuickActionButton(
                        label: 'Transfer\nMoney',
                        icon: Icons.send_rounded,
                        iconColor: AppColors.accentBlue,
                        backgroundColor: AppColors.softBlueBg,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const TransferScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: QuickActionButton(
                        label: 'Pay\nBills',
                        icon: Icons.receipt_long_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        backgroundColor: const Color(0xFFFFFBEB),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const PayBillsScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: QuickActionButton(
                        label: 'Scan &\nPay',
                        icon: Icons.qr_code_scanner_rounded,
                        iconColor: const Color(0xFF0284C7),
                        backgroundColor: const Color(0xFFE0F2FE),
                        onTap: () {
                          QrScannerDialog.show(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: QuickActionButton(
                        label: 'Account\nStatement',
                        customIcon: const AccountStatementIcon(size: 26),
                        iconColor: const Color(0xFF059669),
                        backgroundColor: const Color(0xFFECFDF5),
                        onTap: () {
                          AccountStatementSheet.show(context);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                // Recent Transactions Header with View All
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (onNavigateToTab != null) {
                          onNavigateToTab!(1); // Transactions tab
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('View All', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios_rounded, size: 12),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Recent Transactions List
                if (recentTxns.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'No transactions yet.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  ...recentTxns.map((txn) {
                    return TransactionTile(
                      transaction: txn,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TransactionDetailsScreen(transaction: txn),
                          ),
                        );
                      },
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

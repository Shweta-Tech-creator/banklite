import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/account_model.dart';
import '../services/banking_provider.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import 'bank_logo_emblem.dart';

class BalanceCard extends StatelessWidget {
  final VoidCallback? onTransferTap;
  final VoidCallback? onPayBillsTap;

  const BalanceCard({
    super.key,
    this.onTransferTap,
    this.onPayBillsTap,
  });

  @override
  Widget build(BuildContext context) {
    final banking = context.banking;
    final isVisible = banking.isBalanceVisible;
    final selectedAccount = banking.selectedAccount;
    final isSavings = selectedAccount.accountType.contains('Savings');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isSavings ? AppColors.luxuryCardGradient : AppColors.currentCardGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: (isSavings ? const Color(0xFF0F172A) : const Color(0xFF312E81)).withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Holographic and geometric decorative watermarks
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.electricCyan.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 80,
            bottom: -60,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Brand, EMV Chip & Contactless
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const BankLogoEmblem(size: 28),
                        const SizedBox(width: 10),
                        const Text(
                          'BankLite',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00D2FF), Color(0xFF0066FF)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'PLATINUM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Contactless antenna graphic
                    const Icon(
                      Icons.contactless,
                      color: Colors.white70,
                      size: 24,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // EMV Chip Graphic
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFDF00), Color(0xFFD4AF37), Color(0xFFAA771C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Container(
                              width: 24,
                              height: 16,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black26, width: 0.7),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Balance Label & Hide/Show toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        'Available Balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        banking.toggleBalanceVisibility();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isVisible ? 'Hide' : 'Reveal',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Animated Balance Amount
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    isVisible
                        ? CurrencyFormatter.format(selectedAccount.balance)
                        : '₹ •••••••••',
                    key: ValueKey(isVisible ? selectedAccount.balance : 'hidden'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Account Selection & Number Footer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Account type dropdown trigger
                      Flexible(
                        child: PopupMenuButton<Account>(
                          initialValue: selectedAccount,
                          tooltip: 'Switch account',
                          color: Colors.white,
                          elevation: 12,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          onSelected: (acc) {
                            banking.selectAccount(acc);
                          },
                          itemBuilder: (context) => banking.accounts.map((acc) {
                            final isSelected = acc.accountId == selectedAccount.accountId;
                            return PopupMenuItem<Account>(
                              value: acc,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: (isSelected ? AppColors.accentBlue : AppColors.textSecondary)
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      acc.accountType.contains('Savings')
                                          ? Icons.savings_outlined
                                          : Icons.business_outlined,
                                      color: isSelected ? AppColors.accentBlue : AppColors.textSecondary,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        acc.accountType,
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                          color: AppColors.textPrimary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        '${acc.maskedNumber} • ${CurrencyFormatter.format(acc.balance)}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isSelected) ...[
                                    const Spacer(),
                                    const Icon(Icons.check_circle, color: AppColors.accentBlue, size: 18),
                                  ],
                                ],
                              ),
                            );
                          }).toList(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  selectedAccount.accountType,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white70,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Masked Account Number with Quick Copy
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: selectedAccount.accountNumber));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Account number copied to clipboard'),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                selectedAccount.maskedNumber,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.copy_rounded,
                                color: Colors.white70,
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

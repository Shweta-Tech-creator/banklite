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
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isSavings ? const Color(0xFF070B19) : const Color(0xFF130A2A)).withValues(alpha: 0.45),
            blurRadius: 28,
            offset: const Offset(0, 14),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: (isSavings ? AppColors.accentBlue : AppColors.accentIndigo).withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          // 1. Top-Right Aurora Cyan Radial Light Bloom
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isSavings ? AppColors.electricCyan : const Color(0xFFC084FC)).withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 2. Bottom-Left Royal Violet Ambient Bloom
          Positioned(
            left: -20,
            bottom: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isSavings ? AppColors.accentIndigo : const Color(0xFFE879F9)).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. Decorative Geometric Vector Watermarks (Fine concentric arcs)
          Positioned.fill(
            child: CustomPaint(
              painter: _CardGeometricWatermarkPainter(
                strokeColor: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // 4. Main Card Foreground Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Header Row: Bank Logo, Name, Luxury Badge & Contactless
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const BankLogoEmblem(size: 32),
                        const SizedBox(width: 10),
                        const Text(
                          'BankLite',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Sleek Frosted Holographic Diamond Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.20),
                                Colors.white.withValues(alpha: 0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.diamond_outlined,
                                size: 11,
                                color: isSavings ? AppColors.electricCyan : const Color(0xFFE879F9),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isSavings ? 'PLATINUM' : 'BUSINESS',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Contactless antenna graphic
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.contactless_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Realistically Rendered Brushed Gold EMV Chip
                const _EmvChipWidget(),

                const SizedBox(height: 18),

                // Balance Label & Frosted Hide/Reveal Toggle Pill
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
                          letterSpacing: 0.2,
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 0.8,
                          ),
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

                // Hero Animated Balance Amount
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.15),
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
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      height: 1.15,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Floating Frosted Glass Account Selector & Number Footer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 1.0,
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
                          elevation: 16,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: (isSelected ? AppColors.accentBlue : AppColors.textSecondary)
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      acc.accountType.contains('Savings')
                                          ? Icons.savings_outlined
                                          : Icons.business_center_outlined,
                                      color: isSelected ? AppColors.accentBlue : AppColors.textSecondary,
                                      size: 17,
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
                                    const Icon(Icons.check_circle_rounded, color: AppColors.accentBlue, size: 18),
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
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white70,
                                size: 19,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Masked Account Number with Quick Copy
                      InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Clipboard.setData(ClipboardData(text: selectedAccount.accountNumber));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text('${selectedAccount.accountType} number copied'),
                                ],
                              ),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.primaryNavy,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                selectedAccount.maskedNumber,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(width: 5),
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

/// Realistic Brushed Gold EMV Smart Chip with Circuit Paths & Metallic Bevel
class _EmvChipWidget extends StatelessWidget {
  const _EmvChipWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 32,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFE58F),
            Color(0xFFE5B842),
            Color(0xFFC79524),
            Color(0xFFDFB64C),
            Color(0xFFFDE68A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: const Color(0xFFB48316).withValues(alpha: 0.6),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: const Color(0xFFFBBF24).withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Inner circuit engraving pattern
          Center(
            child: Container(
              width: 32,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: const Color(0xFF784D09).withValues(alpha: 0.45),
                  width: 0.7,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: const Color(0xFF784D09).withValues(alpha: 0.45),
                            width: 0.7,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9A690B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: const Color(0xFF784D09).withValues(alpha: 0.45),
                            width: 0.7,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Specular metallic glint
          Positioned(
            top: 2,
            left: 4,
            right: 4,
            height: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for card background subtle concentric watermark lines
class _CardGeometricWatermarkPainter extends CustomPainter {
  final Color strokeColor;

  _CardGeometricWatermarkPainter({required this.strokeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width * 0.85, size.height * 0.35);

    canvas.drawCircle(center, 70, paint);
    canvas.drawCircle(center, 120, paint);
    canvas.drawCircle(center, 170, paint);
  }

  @override
  bool shouldRepaint(covariant _CardGeometricWatermarkPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';

class AccountStatementIcon extends StatelessWidget {
  final double size;
  final Color primaryColor;
  final Color accentColor;

  const AccountStatementIcon({
    super.key,
    this.size = 26,
    this.primaryColor = const Color(0xFF059669),
    this.accentColor = const Color(0xFF10B981),
  });

  @override
  Widget build(BuildContext context) {
    final width = size;
    final height = size * 1.15;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main Document Sheet
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(width * 0.16),
              border: Border.all(
                color: primaryColor,
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.18),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.18,
              vertical: height * 0.14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Top Header line
                Container(
                  height: 2,
                  width: width * 0.45,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                // Ledger line 1
                Container(
                  height: 1.8,
                  width: width * 0.65,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                // Ledger line 2
                Container(
                  height: 1.8,
                  width: width * 0.5,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                // Ledger line 3 with dot
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 2.5,
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Container(
                        height: 1.8,
                        width: width * 0.28,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Little corner badge with Rupee symbol
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 1),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Text(
                '₹',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

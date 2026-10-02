import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 440,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > maxWidth + 40) {
          // Large screen (Desktop / Web Browser) - render centered mobile phone container
          return Container(
            color: const Color(0xFF070D18),
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentBlue.withValues(alpha: 0.15),
                      blurRadius: 40,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRect(
                  child: child,
                ),
              ),
            ),
          );
        }
        // Native mobile screen
        return child;
      },
    );
  }
}

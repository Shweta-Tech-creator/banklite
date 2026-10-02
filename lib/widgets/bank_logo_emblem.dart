import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable BankLite Signature Neoclassical Architectural Logo Emblem
/// Matches the exact visual identity formed during the Splash Screen sequence
class BankLogoEmblem extends StatelessWidget {
  final double size;
  final bool showGlowHalo;
  final double borderRadiusRatio;

  const BankLogoEmblem({
    super.key,
    this.size = 56.0,
    this.showGlowHalo = false,
    this.borderRadiusRatio = 0.28,
  });

  @override
  Widget build(BuildContext context) {
    final innerIconSize = size * 0.58;

    Widget coreEmblem = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A), // Obsidian Navy
            Color(0xFF003B73), // Deep Royal Navy
            Color(0xFF0066FF), // Electric Royal Blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.electricCyan.withValues(alpha: 0.75),
          width: size >= 48 ? 2.0 : 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlue.withValues(alpha: 0.4),
            blurRadius: size * 0.35,
            spreadRadius: 1,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(innerIconSize, innerIconSize * 0.95),
          painter: _BankArchitectureStaticPainter(),
        ),
      ),
    );

    if (showGlowHalo) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 1.35,
            height: size * 1.35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentBlue.withValues(alpha: 0.12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.electricCyan.withValues(alpha: 0.25),
                  blurRadius: size * 0.5,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          coreEmblem,
        ],
      );
    }

    return coreEmblem;
  }
}

/// Precise Neoclassical Architectural Bank Vector Drawing matching the splash screen
class _BankArchitectureStaticPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;

    // 1. Pediment / Triangular Roof
    final roofPath = Path();
    final apexX = w / 2;
    final apexY = h * 0.06;
    final leftX = w * 0.08;
    final rightX = w * 0.92;
    final roofBottomY = h * 0.32;

    roofPath.moveTo(apexX, apexY);
    roofPath.lineTo(leftX, roofBottomY);
    roofPath.lineTo(rightX, roofBottomY);
    roofPath.close();

    canvas.drawPath(roofPath, strokePaint);

    // Cyan Medallion Dot inside Pediment
    final dotPaint = Paint()..color = AppColors.electricCyan;
    canvas.drawCircle(Offset(w / 2, h * 0.22), w * 0.05, dotPaint);

    // 2. 4 Neoclassical Pillars
    final pillarTopY = h * 0.36;
    final pillarBottomY = h * 0.74;
    final columnWidth = w * 0.08;

    const columnPositions = [0.18, 0.39, 0.61, 0.82];

    for (final colXRatio in columnPositions) {
      final colCenterX = w * colXRatio;
      final colRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          colCenterX - (columnWidth / 2),
          pillarTopY,
          columnWidth,
          pillarBottomY - pillarTopY,
        ),
        Radius.circular(w * 0.03),
      );
      canvas.drawRRect(colRect, fillPaint);
    }

    // 3. Foundation Base Steps
    final step1Y = h * 0.78;
    final step2Y = h * 0.88;

    final step1Rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w / 2, step1Y), width: w * 0.88, height: h * 0.07),
      Radius.circular(w * 0.03),
    );
    final step2Rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w / 2, step2Y), width: w * 0.98, height: h * 0.08),
      Radius.circular(w * 0.035),
    );

    canvas.drawRRect(step1Rect, fillPaint);
    canvas.drawRRect(step2Rect, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

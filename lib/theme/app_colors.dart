import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette - Obsidian Navy & Deep Sapphire
  static const Color primaryNavy = Color(0xFF0A1128);
  static const Color primaryBlue = Color(0xFF001F54);
  static const Color accentBlue = Color(0xFF0066FF);
  static const Color electricCyan = Color(0xFF00D2FF);
  static const Color lightBlue = Color(0xFF38BDF8);
  static const Color softBlueBg = Color(0xFFEFF6FF);

  // Status & Feedback Colors
  static const Color success = Color(0xFF10B981);
  static const Color successDark = Color(0xFF059669);
  static const Color successLight = Color(0xFFECFDF5);

  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEF2F2);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFEFF6FF);

  // Neutral Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Luxury Platinum & Holographic Card Gradients
  static const LinearGradient luxuryCardGradient = LinearGradient(
    colors: [
      Color(0xFF0F172A),
      Color(0xFF1E293B),
      Color(0xFF0A2540),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient currentCardGradient = LinearGradient(
    colors: [
      Color(0xFF1E1B4B),
      Color(0xFF312E81),
      Color(0xFF4338CA),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0066FF), Color(0xFF003BB5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00D2FF), Color(0xFF0066FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = luxuryCardGradient;
}

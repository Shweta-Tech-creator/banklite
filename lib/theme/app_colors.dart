import 'package:flutter/material.dart';

/// BankLite Signature Design System & Color Palette
/// Neo-Luxe Sapphire & Glass: Contemporary, prestigious, and visually breathtaking.
class AppColors {
  // Primary Luxury Palette - Velvety Obsidian Navy & Deep Royal Sapphire
  static const Color primaryNavy = Color(0xFF0B132B); // Deepest obsidian sapphire
  static const Color primaryNavyLight = Color(0xFF1C2541);
  static const Color primaryBlue = Color(0xFF1E3A8A); // Royal Blue
  static const Color accentBlue = Color(0xFF2563EB); // Vibrant Royal Sapphire Blue
  static const Color accentIndigo = Color(0xFF4F46E5); // Modern Indigo
  static const Color electricCyan = Color(0xFF06B6D4); // Luminescent Aurora Cyan
  static const Color lightBlue = Color(0xFF38BDF8); // Sky Blue
  static const Color softBlueBg = Color(0xFFF0F5FF); // Whispering Ice Blue Tint
  static const Color softIndigoBg = Color(0xFFEEF2FF); // Soft Indigo Tint

  // Status & Feedback Colors (Balanced, Modern, Accessible)
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color successDark = Color(0xFF059669);
  static const Color successLight = Color(0xFFECFDF5);

  static const Color error = Color(0xFFF43F5E); // Elegant Rose Coral (premium)
  static const Color errorDark = Color(0xFFE11D48);
  static const Color errorLight = Color(0xFFFFF1F2);

  static const Color warning = Color(0xFFF59E0B); // Warm Golden Amber
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFFFBEB);

  static const Color info = Color(0xFF0284C7);
  static const Color infoLight = Color(0xFFF0F9FF);

  // Neutral Colors & Surfaces
  static const Color background = Color(0xFFF6F8FC); // Luminous warm pearl slate
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF8FAFC);
  static const Color cardBorder = Color(0xFFE8EDF5); // Ultra-delicate soft border
  static const Color cardBorderLight = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Rich Slate 900
  static const Color textSecondary = Color(0xFF475569); // Harmonious Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textWhite = Color(0xFFFFFFFF);

  // Luxury Card Gradients
  // 1. Savings Account - Obsidian Celestial Sapphire
  static const LinearGradient luxuryCardGradient = LinearGradient(
    colors: [
      Color(0xFF070B19),
      Color(0xFF0D1B3E),
      Color(0xFF162A56),
      Color(0xFF0B1736),
    ],
    stops: [0.0, 0.45, 0.8, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 2. Current Account - Royal Imperial Amethyst
  static const LinearGradient currentCardGradient = LinearGradient(
    colors: [
      Color(0xFF130A2A),
      Color(0xFF241247),
      Color(0xFF381864),
      Color(0xFF160A30),
    ],
    stops: [0.0, 0.45, 0.8, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Primary Buttons & Action Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0B132B), Color(0xFF1C2D5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient vibrantBlueGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = emeraldGradient;

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = luxuryCardGradient;
}

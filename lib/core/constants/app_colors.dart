import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Royal Blue, Luminous Yellow & Crisp White Palette
  static const Color primary = Color(0xFF1E40AF); // Royal Blue
  static const Color primaryDark = Color(0xFF172554); // Deep Navy Blue
  static const Color primaryLight = Color(0xFF3B82F6); // Bright Sapphire Blue
  static const Color primaryGradientStart = Color(0xFF1E3A8A); // Deep Royal
  static const Color primaryGradientEnd = Color(0xFF2563EB); // Vibrant Electric Blue
  static const Color primaryContainer = Color(0xFFDBEAFE); // Soft Powder Blue
  static const Color onPrimary = Colors.white;

  // Luminous Yellow & Warm Amber Accents
  static const Color accentYellow = Color(0xFFFACC15); // Luminous Warm Yellow
  static const Color yellowAccent = Color(0xFFFACC15);
  static const Color yellowAccentDark = Color(0xFFD97706); // Golden Amber
  static const Color yellowAccentLight = Color(0xFFFEF3C7); // Warm Soft Cream
  static const Color yellowGradientStart = Color(0xFFFACC15);
  static const Color yellowGradientEnd = Color(0xFFF59E0B);

  // Backward-compatible Gold Aliases pointing to Yellow Palette
  static const Color goldAccent = Color(0xFFFACC15);
  static const Color goldAccentDark = Color(0xFFD97706);
  static const Color goldAccentLight = Color(0xFFFEF3C7);
  static const Color goldGradientStart = Color(0xFFFACC15);
  static const Color goldGradientEnd = Color(0xFFF59E0B);

  // Mint / Cyan Accent (modern high-contrast accent)
  static const Color mintAccent = Color(0xFF0284C7); // Electric Sky
  static const Color mintLight = Color(0xFFE0F2FE);

  // Interactive Touch & Ripple Colors
  static const Color rippleBlue = Color(0x261E40AF); // ~15% Blue
  static const Color rippleYellow = Color(0x38FACC15); // ~22% Yellow
  static const Color rippleWhite = Color(0x3DFFFFFF); // ~24% White

  // Status Colors for Attendance & Badges
  static const Color present = Color(0xFF10B981); // Crisp Emerald
  static const Color presentLight = Color(0xFFECFDF5);
  static const Color absent = Color(0xFFEF4444); // Modern Red
  static const Color absentLight = Color(0xFFFEF2F2);
  static const Color late = Color(0xFFF59E0B); // Modern Amber
  static const Color lateLight = Color(0xFFFFFBEB);
  static const Color leave = Color(0xFF2563EB); // Modern Royal Blue
  static const Color leaveLight = Color(0xFFEFF6FF);
  static const Color pending = Color(0xFF8B5CF6); // Modern Purple / Accent
  static const Color pendingLight = Color(0xFFF5F3FF);

  // Background and Surfaces (Crisp Porcelain White & Clean Slate)
  static const Color background = Color(0xFFF8FAFC); // Slate 50 Porcelain
  static const Color backgroundElevated = Color(0xFFFFFFFF); // Pure White Elevated
  static const Color surface = Colors.white; // Crisp Pure White
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderSubtle = Color(0xFFF1F5F9); // Slate 100

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Deep Slate Navy
  static const Color textSecondary = Color(0xFF475569); // Medium Slate
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textLight = Color(0xFFCBD5E1); // Slate 300

  // Card Shadow definition (Blue-tinted soft shadows)
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF1E3A8A).withAlpha(10),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: const Color(0xFF0F172A).withAlpha(6),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: primary.withAlpha(50),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get yellowGlow => [
        BoxShadow(
          color: accentYellow.withAlpha(80),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  // Indicators
  static const Color online = Color(0xFF10B981);
  static const Color offline = Color(0xFF94A3B8);
}

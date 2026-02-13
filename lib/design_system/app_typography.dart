import 'package:flutter/material.dart';
import 'package:aube/design_system/app_colors.dart';

/// 📝 Deep Violet & Soft Cloud Design System - Typography
///
/// This file defines the typography system using Inter font family
/// with proper hierarchy and styling for the VisioTransact app.
class AppTypography {
  // ========================================
  // 📚 FONT FAMILY
  // ========================================

  /// Primary font family - Inter (fallback to SF Pro, then system default)
  static const String fontFamily = 'Inter';

  // Note: To use Inter font, add google_fonts package to pubspec.yaml
  // and use: GoogleFonts.inter() in TextStyle

  // ========================================
  // 🔤 FONT WEIGHTS
  // ========================================

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // ========================================
  // 📏 DISPLAY STYLES (Large Headers)
  // ========================================

  /// Display Large - 32px, Bold
  static TextStyle displayLarge({bool isDark = false}) => TextStyle(
    fontSize: 32,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.getTextPrimary(isDark),
  );

  /// Display Medium - 28px, Bold
  static TextStyle displayMedium({bool isDark = false}) => TextStyle(
    fontSize: 28,
    fontWeight: bold,
    height: 1.25,
    letterSpacing: -0.5,
    color: AppColors.getTextPrimary(isDark),
  );

  /// Display Small - 24px, SemiBold
  static TextStyle displaySmall({bool isDark = false}) => TextStyle(
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.3,
    letterSpacing: -0.25,
    color: AppColors.getTextPrimary(isDark),
  );

  // ========================================
  // 📰 HEADING STYLES
  // ========================================

  /// Heading 1 - 22px, SemiBold
  static TextStyle h1({bool isDark = false}) => TextStyle(
    fontSize: 22,
    fontWeight: semiBold,
    height: 1.3,
    letterSpacing: -0.25,
    color: AppColors.getTextPrimary(isDark),
  );

  /// Heading 2 - 20px, SemiBold
  static TextStyle h2({bool isDark = false}) => TextStyle(
    fontSize: 20,
    fontWeight: semiBold,
    height: 1.35,
    letterSpacing: -0.15,
    color: AppColors.getTextPrimary(isDark),
  );

  /// Heading 3 - 18px, SemiBold
  static TextStyle h3({bool isDark = false}) => TextStyle(
    fontSize: 18,
    fontWeight: semiBold,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.getTextPrimary(isDark),
  );

  /// Heading 4 - 16px, SemiBold
  static TextStyle h4({bool isDark = false}) => TextStyle(
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.getTextPrimary(isDark),
  );

  // ========================================
  // 📄 BODY STYLES
  // ========================================

  /// Body Large - 16px, Regular
  static TextStyle bodyLarge({bool isDark = false}) => TextStyle(
    fontSize: 16,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.getTextPrimary(isDark),
  );

  /// Body Medium - 14px, Regular
  static TextStyle bodyMedium({bool isDark = false}) => TextStyle(
    fontSize: 14,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.25,
    color: AppColors.getTextPrimary(isDark),
  );

  /// Body Small - 12px, Regular
  static TextStyle bodySmall({bool isDark = false}) => TextStyle(
    fontSize: 12,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.4,
    color: AppColors.getTextSecondary(isDark),
  );

  // ========================================
  // 🏷️ LABEL STYLES (Buttons, Tabs)
  // ========================================

  /// Label Large - 14px, SemiBold
  static TextStyle labelLarge({bool isDark = false}) => TextStyle(
    fontSize: 14,
    fontWeight: semiBold,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.getTextPrimary(isDark),
  );

  /// Label Medium - 12px, SemiBold
  static TextStyle labelMedium({bool isDark = false}) => TextStyle(
    fontSize: 12,
    fontWeight: semiBold,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.getTextPrimary(isDark),
  );

  /// Label Small - 11px, Medium
  static TextStyle labelSmall({bool isDark = false}) => TextStyle(
    fontSize: 11,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.getTextSecondary(isDark),
  );

  // ========================================
  // 💬 CAPTION STYLES
  // ========================================

  /// Caption - 12px, Regular, Secondary color
  static TextStyle caption({bool isDark = false}) => TextStyle(
    fontSize: 12,
    fontWeight: regular,
    height: 1.4,
    letterSpacing: 0.4,
    color: AppColors.getTextSecondary(isDark),
  );

  /// Overline - 10px, Medium, Uppercase
  static TextStyle overline({bool isDark = false}) => TextStyle(
    fontSize: 10,
    fontWeight: medium,
    height: 1.6,
    letterSpacing: 1.5,
    color: AppColors.getTextSecondary(isDark),
  );

  // ========================================
  // 🔢 NUMERIC STYLES (For amounts, statistics)
  // ========================================

  /// Amount Large - 28px, Bold (for balance display)
  static TextStyle amountLarge({bool isDark = false}) => TextStyle(
    fontSize: 28,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.getTextPrimary(isDark),
    fontFeatures: [FontFeature.tabularFigures()], // Monospaced numbers
  );

  /// Amount Medium - 20px, SemiBold
  static TextStyle amountMedium({bool isDark = false}) => TextStyle(
    fontSize: 20,
    fontWeight: semiBold,
    height: 1.3,
    letterSpacing: -0.25,
    color: AppColors.getTextPrimary(isDark),
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Amount Small - 16px, SemiBold
  static TextStyle amountSmall({bool isDark = false}) => TextStyle(
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.getTextPrimary(isDark),
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // ========================================
  // 🎨 SPECIAL STYLES
  // ========================================

  /// Button Text - 14px, SemiBold, White
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: semiBold,
    height: 1.4,
    letterSpacing: 0.75,
    color: Colors.white,
  );

  /// Link Text - 14px, SemiBold, Royal Violet
  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: semiBold,
    height: 1.5,
    letterSpacing: 0.1,
    color: AppColors.royalViolet,
    decoration: TextDecoration.underline,
  );

  /// Monospace - For device IDs, codes
  static TextStyle monospace({bool isDark = false}) => TextStyle(
    fontSize: 12,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0,
    fontFamily: 'monospace',
    color: AppColors.getTextSecondary(isDark),
  );

  // ========================================
  // 🔧 HELPER METHODS
  // ========================================

  /// Apply color to any TextStyle
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply weight to any TextStyle
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Apply size to any TextStyle
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}




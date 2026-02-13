import 'package:flutter/material.dart';

/// 🎨 Deep Violet & Soft Cloud Design System - Color Palette
///
/// This file defines the complete color system for VisioTransact,
/// following the premium fintech visual identity.
class AppColors {
  // ========================================
  // 🔵 PRIMARY COLORS (Brand)
  // ========================================

  /// Royal Violet - Main brand color
  static const Color royalViolet = Color(0xFF6200EE);

  /// Electric Violet - Gradient end color
  static const Color electricViolet = Color(0xA855F7);

  /// Primary Gradient - Used for buttons, FAB, active states
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [royalViolet, electricViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ========================================
  // 🔹 SECONDARY COLORS (Accents)
  // ========================================

  /// Soft Pink - For category icons and accents
  static const Color softPink = Color(0xFFF472B6);

  /// Light Blue - For category icons and accents
  static const Color lightBlue = Color(0xFF60A5FA);

  /// Accent colors list for rotating usage
  static const List<Color> accentColors = [softPink, lightBlue];

  // ========================================
  // ⚪ BACKGROUND COLORS (Light Mode)
  // ========================================

  /// Main background - Ultra light gray-white
  static const Color backgroundLight = Color(0xFFF8FAFC);

  /// Card background - Pure white
  static const Color cardLight = Color(0xFFFFFFFF);

  /// Surface color for elevated elements
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // ========================================
  // ⚫ BACKGROUND COLORS (Dark Mode)
  // ========================================

  /// Main background - Deep black
  static const Color backgroundDark = Color(0xFF121212);

  /// Card background - Elevated dark
  static const Color cardDark = Color(0xFF1E1E1E);

  /// Surface color for elevated elements
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // ========================================
  // ⚙️ NEUTRAL COLORS (Text & Icons)
  // ========================================

  /// Primary text - Blue-black (never pure black)
  static const Color textPrimary = Color(0xFF1E1B4B);

  /// Secondary text - Slate gray
  static const Color textSecondary = Color(0xFF94A3B8);

  /// Primary text for dark mode
  static const Color textPrimaryDark = Color(0xFFFFFFFF);

  /// Secondary text for dark mode
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  /// Disabled text
  static const Color textDisabled = Color(0xFFCBD5E1);

  /// Icon color (light mode)
  static const Color iconLight = Color(0xFF64748B);

  /// Icon color (dark mode)
  static const Color iconDark = Color(0xFFB0B0B0);

  // ========================================
  // 🎯 SEMANTIC COLORS
  // ========================================

  /// Success - Green
  static const Color success = Color(0xFF10B981);

  /// Warning - Amber
  static const Color warning = Color(0xFFF59E0B);

  /// Error - Red
  static const Color error = Color(0xFFEF4444);

  /// Info - Blue
  static const Color info = Color(0xFF3B82F6);

  // ========================================
  // 💰 TRANSACTION TYPE COLORS
  // ========================================

  /// Depot (Deposit) - Green gradient
  static const LinearGradient depotGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Retrait (Withdrawal) - Red gradient
  static const LinearGradient retraitGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Transfert (Transfer) - Blue gradient
  static const LinearGradient transfertGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ========================================
  // 🌈 CHART COLORS
  // ========================================

  /// Chart color palette for statistics
  static const List<Color> chartColors = [
    royalViolet,
    softPink,
    lightBlue,
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF06B6D4), // Cyan
  ];

  // ========================================
  // 🔲 BORDER & DIVIDER COLORS
  // ========================================

  /// Border color (light mode) - Very subtle
  static const Color borderLight = Color(0xFFE2E8F0);

  /// Border color (dark mode)
  static const Color borderDark = Color(0xFF374151);

  /// Divider color (light mode)
  static const Color dividerLight = Color(0xFFE2E8F0);

  /// Divider color (dark mode)
  static const Color dividerDark = Color(0xFF374151);

  // ========================================
  // 🎭 SHADOW COLORS
  // ========================================

  /// Shadow color for cards and elevated elements
  static const Color shadowLight = Color(0x0D000000); // 5% black

  /// Shadow color for dark mode
  static const Color shadowDark = Color(0x1A000000); // 10% black

  // ========================================
  // 🔧 HELPER METHODS
  // ========================================

  /// Get background color based on theme brightness
  static Color getBackground(bool isDark) {
    return isDark ? backgroundDark : backgroundLight;
  }

  /// Get card color based on theme brightness
  static Color getCard(bool isDark) {
    return isDark ? cardDark : cardLight;
  }

  /// Get primary text color based on theme brightness
  static Color getTextPrimary(bool isDark) {
    return isDark ? textPrimaryDark : textPrimary;
  }

  /// Get secondary text color based on theme brightness
  static Color getTextSecondary(bool isDark) {
    return isDark ? textSecondaryDark : textSecondary;
  }

  /// Get icon color based on theme brightness
  static Color getIcon(bool isDark) {
    return isDark ? iconDark : iconLight;
  }

  /// Get accent color by index (rotates through accent colors)
  static Color getAccentColor(int index) {
    return accentColors[index % accentColors.length];
  }

  /// Get chart color by index
  static Color getChartColor(int index) {
    return chartColors[index % chartColors.length];
  }
}




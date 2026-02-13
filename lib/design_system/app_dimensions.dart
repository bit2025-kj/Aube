import 'package:flutter/material.dart';
import 'package:aube/design_system/app_colors.dart';

/// 📐 Deep Violet & Soft Cloud Design System - Dimensions
///
/// This file defines spacing, sizing, border radius, elevation,
/// and shadow constants for consistent layouts.
class AppDimensions {
  // ========================================
  // 📏 SPACING (Padding & Margin)
  // ========================================

  /// Extra small spacing - 4px
  static const double spaceXS = 4.0;

  /// Small spacing - 8px
  static const double spaceS = 8.0;

  /// Medium spacing - 12px
  static const double spaceM = 12.0;

  /// Default spacing - 16px (minimum for airy layouts)
  static const double space = 16.0;

  /// Large spacing - 20px
  static const double spaceL = 20.0;

  /// Extra large spacing - 24px
  static const double spaceXL = 24.0;

  /// Extra extra large spacing - 32px
  static const double spaceXXL = 32.0;

  /// Huge spacing - 48px
  static const double spaceHuge = 48.0;

  // ========================================
  // 🔲 BORDER RADIUS
  // ========================================

  /// Small radius - 8px
  static const double radiusS = 8.0;

  /// Medium radius - 12px
  static const double radiusM = 12.0;

  /// Card radius - 16px
  static const double radiusCard = 16.0;

  /// Large radius - 20px
  static const double radiusL = 20.0;

  /// Button radius - 24px (per design spec)
  static const double radiusButton = 24.0;

  /// Extra large radius - 32px
  static const double radiusXL = 32.0;

  /// Full circle - 999px
  static const double radiusFull = 999.0;

  // BorderRadius objects for convenience
  static const BorderRadius borderRadiusS = BorderRadius.all(
    Radius.circular(radiusS),
  );
  static const BorderRadius borderRadiusM = BorderRadius.all(
    Radius.circular(radiusM),
  );
  static const BorderRadius borderRadiusCard = BorderRadius.all(
    Radius.circular(radiusCard),
  );
  static const BorderRadius borderRadiusL = BorderRadius.all(
    Radius.circular(radiusL),
  );
  static const BorderRadius borderRadiusButton = BorderRadius.all(
    Radius.circular(radiusButton),
  );
  static const BorderRadius borderRadiusXL = BorderRadius.all(
    Radius.circular(radiusXL),
  );
  static const BorderRadius borderRadiusFull = BorderRadius.all(
    Radius.circular(radiusFull),
  );

  // ========================================
  // 📦 ELEVATION (Always 0 - use shadows instead)
  // ========================================

  /// No elevation - use shadows for depth
  static const double elevation = 0.0;

  // ========================================
  // 🌑 SHADOWS (Soft, diffuse shadows)
  // ========================================

  /// Card shadow - Soft, subtle elevation
  /// BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 10))
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 20,
      offset: Offset(0, 10),
      spreadRadius: 0,
    ),
  ];

  /// Card shadow for dark mode
  static List<BoxShadow> get cardShadowDark => [
    BoxShadow(
      color: AppColors.shadowDark,
      blurRadius: 20,
      offset: Offset(0, 10),
      spreadRadius: 0,
    ),
  ];

  /// Small shadow - For buttons and small elements
  static List<BoxShadow> get shadowSmall => [
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 10,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Medium shadow - For cards
  static List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 20,
      offset: Offset(0, 10),
      spreadRadius: 0,
    ),
  ];

  /// Large shadow - For dialogs and modals
  static List<BoxShadow> get shadowLarge => [
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 30,
      offset: Offset(0, 15),
      spreadRadius: 0,
    ),
  ];

  /// Get shadow based on theme brightness
  static List<BoxShadow> getShadow(bool isDark, {String size = 'medium'}) {
    if (isDark) {
      return cardShadowDark;
    }

    switch (size) {
      case 'small':
        return shadowSmall;
      case 'large':
        return shadowLarge;
      case 'medium':
      default:
        return shadowMedium;
    }
  }

  // ========================================
  // 📱 COMPONENT SIZES
  // ========================================

  /// Icon size - Small
  static const double iconS = 16.0;

  /// Icon size - Medium
  static const double iconM = 20.0;

  /// Icon size - Default
  static const double icon = 24.0;

  /// Icon size - Large
  static const double iconL = 32.0;

  /// Icon size - Extra large
  static const double iconXL = 48.0;

  /// Button height - Default
  static const double buttonHeight = 48.0;

  /// Button height - Small
  static const double buttonHeightS = 36.0;

  /// Button height - Large
  static const double buttonHeightL = 56.0;

  /// Input field height
  static const double inputHeight = 48.0;

  /// FAB size - Default
  static const double fabSize = 56.0;

  /// FAB size - Large
  static const double fabSizeL = 64.0;

  /// Avatar size - Small
  static const double avatarS = 32.0;

  /// Avatar size - Medium
  static const double avatarM = 40.0;

  /// Avatar size - Large
  static const double avatarL = 56.0;

  /// Avatar size - Extra large
  static const double avatarXL = 80.0;

  /// Minimum touch target size (accessibility)
  static const double minTouchTarget = 48.0;

  // ========================================
  // 📐 LAYOUT CONSTRAINTS
  // ========================================

  /// Maximum content width for tablets/desktop
  static const double maxContentWidth = 600.0;

  /// Card maximum width
  static const double cardMaxWidth = 400.0;

  /// Dialog maximum width
  static const double dialogMaxWidth = 500.0;

  /// Bottom sheet maximum height ratio
  static const double bottomSheetMaxHeightRatio = 0.9;

  // ========================================
  // 🎨 BORDER WIDTHS
  // ========================================

  /// Thin border - 0.5px
  static const double borderThin = 0.5;

  /// Default border - 1px
  static const double border = 1.0;

  /// Thick border - 2px
  static const double borderThick = 2.0;

  /// Focus border - 3px
  static const double borderFocus = 3.0;

  // ========================================
  // 🔧 HELPER METHODS
  // ========================================

  /// Get horizontal padding
  static EdgeInsets get paddingH => EdgeInsets.symmetric(horizontal: space);

  /// Get vertical padding
  static EdgeInsets get paddingV => EdgeInsets.symmetric(vertical: space);

  /// Get all-around padding
  static EdgeInsets get paddingAll => EdgeInsets.all(space);

  /// Get custom padding
  static EdgeInsets padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    if (all != null) {
      return EdgeInsets.all(all);
    }

    return EdgeInsets.only(
      top: top ?? vertical ?? 0,
      bottom: bottom ?? vertical ?? 0,
      left: left ?? horizontal ?? 0,
      right: right ?? horizontal ?? 0,
    );
  }

  /// Get card decoration with shadow
  static BoxDecoration cardDecoration({
    required bool isDark,
    Color? color,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.getCard(isDark),
      borderRadius: borderRadius ?? borderRadiusCard,
      boxShadow: getShadow(isDark),
    );
  }

  /// Get button decoration with gradient
  static BoxDecoration buttonDecoration({
    Gradient? gradient,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      gradient: gradient ?? AppColors.primaryGradient,
      borderRadius: borderRadius ?? borderRadiusButton,
      boxShadow: shadowSmall,
    );
  }
}




import 'package:flutter/material.dart';
import 'package:aube/design_system/app_colors.dart';
import 'package:aube/design_system/app_dimensions.dart';

/// 🎨 Premium Card Widget
///
/// A card component with soft shadows (no borders),
/// following the Deep Violet design system.
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool isDark;
  final List<BoxShadow>? customShadow;

  const PremiumCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.gradient,
    this.borderRadius,
    this.onTap,
    this.isDark = false,
    this.customShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        isDark || Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null
            ? (color ?? AppColors.getCard(isDarkMode))
            : null,
        gradient: gradient,
        borderRadius: borderRadius ?? AppDimensions.borderRadiusCard,
        boxShadow: customShadow ?? AppDimensions.getShadow(isDarkMode),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? AppDimensions.borderRadiusCard,
          child: Padding(
            padding: padding ?? AppDimensions.paddingAll,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 🎨 Compact Premium Card (less padding)
class PremiumCardCompact extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final Color? color;
  final VoidCallback? onTap;
  final bool isDark;

  const PremiumCardCompact({
    Key? key,
    required this.child,
    this.margin,
    this.color,
    this.onTap,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: EdgeInsets.all(AppDimensions.spaceM),
      margin: margin,
      color: color,
      onTap: onTap,
      isDark: isDark,
      child: child,
    );
  }
}

/// 🎨 Gradient Card (with gradient background)
class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const GradientCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.gradient,
    this.borderRadius,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      gradient: gradient ?? AppColors.primaryGradient,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
      child: child,
    );
  }
}

/// 🎨 Transaction Type Card (with specific gradient)
class TransactionCard extends StatelessWidget {
  final Widget child;
  final String transactionType; // 'depot', 'retrait', 'transfert'
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final bool isDark;

  const TransactionCard({
    Key? key,
    required this.child,
    required this.transactionType,
    this.padding,
    this.margin,
    this.onTap,
    this.isDark = false,
  }) : super(key: key);

  Gradient _getGradient() {
    switch (transactionType.toLowerCase()) {
      case 'depot':
      case 'dépôt':
        return AppColors.depotGradient;
      case 'retrait':
        return AppColors.retraitGradient;
      case 'transfert':
        return AppColors.transfertGradient;
      default:
        return AppColors.primaryGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.getCard(isDark),
        borderRadius: AppDimensions.borderRadiusCard,
        boxShadow: AppDimensions.getShadow(isDark),
        border: Border.all(width: 2, color: Colors.transparent),
      ),
      child: Stack(
        children: [
          // Gradient accent on the left
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                gradient: _getGradient(),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusCard),
                  bottomLeft: Radius.circular(AppDimensions.radiusCard),
                ),
              ),
            ),
          ),
          // Content
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: AppDimensions.borderRadiusCard,
              child: Padding(
                padding: padding ?? EdgeInsets.all(AppDimensions.space),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎨 Stat Card (for statistics display)
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final Gradient? gradient;
  final bool isDark;

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.gradient,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Container(
              padding: EdgeInsets.all(AppDimensions.spaceS),
              decoration: BoxDecoration(
                gradient: gradient ?? AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Icon(icon, color: Colors.white, size: AppDimensions.iconM),
            ),
          if (icon != null) SizedBox(height: AppDimensions.spaceM),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          SizedBox(height: AppDimensions.spaceXS),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
        ],
      ),
    );
  }
}




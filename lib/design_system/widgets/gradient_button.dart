import 'package:flutter/material.dart';
import 'package:aube/design_system/app_colors.dart';
import 'package:aube/design_system/app_dimensions.dart';
import 'package:aube/design_system/app_typography.dart';

/// 🎨 Gradient Button Widget
///
/// A premium button with diagonal gradient background,
/// following the Deep Violet design system.
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final Color? outlineColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const GradientButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.gradient,
    this.width,
    this.height,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.outlineColor,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    return Container(
      width: width,
      height: height ?? AppDimensions.buttonHeight,
      decoration: isOutlined
          ? BoxDecoration(
              border: Border.all(
                color: outlineColor ?? AppColors.royalViolet,
                width: AppDimensions.borderThick,
              ),
              borderRadius: borderRadius ?? AppDimensions.borderRadiusButton,
            )
          : BoxDecoration(
              gradient: isDisabled
                  ? LinearGradient(
                      colors: [Colors.grey[400]!, Colors.grey[400]!],
                    )
                  : gradient ?? AppColors.primaryGradient,
              borderRadius: borderRadius ?? AppDimensions.borderRadiusButton,
              boxShadow: isDisabled ? [] : AppDimensions.shadowSmall,
            ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: borderRadius ?? AppDimensions.borderRadiusButton,
          child: Container(
            padding:
                padding ??
                EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceL,
                  vertical: AppDimensions.spaceM,
                ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOutlined ? AppColors.royalViolet : Colors.white,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color: isOutlined
                                ? (outlineColor ?? AppColors.royalViolet)
                                : Colors.white,
                            size: AppDimensions.iconM,
                          ),
                          SizedBox(width: AppDimensions.spaceS),
                        ],
                        Text(
                          text,
                          style: AppTypography.button.copyWith(
                            color: isOutlined
                                ? (outlineColor ?? AppColors.royalViolet)
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 🎨 Small Gradient Button (for quick actions)
class GradientButtonSmall extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient? gradient;

  const GradientButtonSmall({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      gradient: gradient,
      height: AppDimensions.buttonHeightS,
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.space,
        vertical: AppDimensions.spaceS,
      ),
    );
  }
}

/// 🎨 Icon Gradient Button (circular)
class GradientIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final double? size;
  final Color? iconColor;

  const GradientIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.gradient,
    this.size,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double buttonSize = size ?? AppDimensions.fabSize;

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: AppDimensions.shadowSmall,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: CircleBorder(),
          child: Center(
            child: Icon(
              icon,
              color: iconColor ?? Colors.white,
              size: buttonSize * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}




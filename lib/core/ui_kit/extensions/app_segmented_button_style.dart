import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_border_radius.dart';

/// Segmented button style tokens for the dark Waily theme.
///
/// Consumed by `WailySegmentedButton` to render the Figma `Segmented btn`
/// component-set. Default state uses a translucent white track (12% alpha);
/// active state uses solid primary with dark surfaceVariant text.
@immutable
class AppSegmentedButtonStyle extends ThemeExtension<AppSegmentedButtonStyle> {
  const AppSegmentedButtonStyle._({
    required this.height,
    required this.borderRadius,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.itemSpacing,
    required this.iconSize,
    required this.defaultBackgroundColor,
    required this.activeBackgroundColor,
    required this.disabledBackgroundColor,
    required this.defaultLabelColor,
    required this.activeLabelColor,
    required this.disabledLabelColor,
    required this.iconColor,
    required this.disabledIconColor,
  });

  /// Container height. Figma: 48.
  final double height;

  /// Container corner radius. Figma: 12.
  final double borderRadius;

  /// Horizontal inner padding. Figma: 16.
  final double horizontalPadding;

  /// Vertical inner padding. Figma: 14.
  final double verticalPadding;

  /// Spacing between label and trailing icon. Figma: 8.
  final double itemSpacing;

  /// Trailing close icon canvas. Figma: 20x20.
  final double iconSize;

  /// Default background — Figma renders white at 12% opacity.
  final Color defaultBackgroundColor;

  /// Active background. Figma: AppColors.primary (#D4E1FF).
  final Color activeBackgroundColor;

  /// Background when disabled.
  final Color disabledBackgroundColor;

  /// Default label color. Figma: white.
  final Color defaultLabelColor;

  /// Active label color. Figma: AppColors.surfaceVariant (#252B38).
  final Color activeLabelColor;

  /// Disabled label color.
  final Color disabledLabelColor;

  /// Trailing icon color. Figma: white in both default and active states.
  final Color iconColor;

  /// Trailing icon color when disabled.
  final Color disabledIconColor;

  factory AppSegmentedButtonStyle.dark() => AppSegmentedButtonStyle._(
    height: 48,
    borderRadius: AppBorderRadius.m,
    horizontalPadding: 16,
    verticalPadding: 14,
    itemSpacing: 8,
    iconSize: 20,
    defaultBackgroundColor: AppColors.white.withValues(alpha: 0.12),
    activeBackgroundColor: AppColors.primary,
    disabledBackgroundColor: AppColors.white.withValues(alpha: 0.06),
    defaultLabelColor: AppColors.white,
    activeLabelColor: AppColors.surfaceVariant,
    disabledLabelColor: AppColors.textDisabled,
    iconColor: AppColors.white,
    disabledIconColor: AppColors.textDisabled,
  );

  @override
  AppSegmentedButtonStyle copyWith({
    double? height,
    double? borderRadius,
    double? horizontalPadding,
    double? verticalPadding,
    double? itemSpacing,
    double? iconSize,
    Color? defaultBackgroundColor,
    Color? activeBackgroundColor,
    Color? disabledBackgroundColor,
    Color? defaultLabelColor,
    Color? activeLabelColor,
    Color? disabledLabelColor,
    Color? iconColor,
    Color? disabledIconColor,
  }) => AppSegmentedButtonStyle._(
    height: height ?? this.height,
    borderRadius: borderRadius ?? this.borderRadius,
    horizontalPadding: horizontalPadding ?? this.horizontalPadding,
    verticalPadding: verticalPadding ?? this.verticalPadding,
    itemSpacing: itemSpacing ?? this.itemSpacing,
    iconSize: iconSize ?? this.iconSize,
    defaultBackgroundColor:
        defaultBackgroundColor ?? this.defaultBackgroundColor,
    activeBackgroundColor:
        activeBackgroundColor ?? this.activeBackgroundColor,
    disabledBackgroundColor:
        disabledBackgroundColor ?? this.disabledBackgroundColor,
    defaultLabelColor: defaultLabelColor ?? this.defaultLabelColor,
    activeLabelColor: activeLabelColor ?? this.activeLabelColor,
    disabledLabelColor: disabledLabelColor ?? this.disabledLabelColor,
    iconColor: iconColor ?? this.iconColor,
    disabledIconColor: disabledIconColor ?? this.disabledIconColor,
  );

  @override
  AppSegmentedButtonStyle lerp(
    ThemeExtension<AppSegmentedButtonStyle>? other,
    double t,
  ) {
    if (other is! AppSegmentedButtonStyle) return this;
    return AppSegmentedButtonStyle._(
      height: t < 0.5 ? height : other.height,
      borderRadius: t < 0.5 ? borderRadius : other.borderRadius,
      horizontalPadding: t < 0.5 ? horizontalPadding : other.horizontalPadding,
      verticalPadding: t < 0.5 ? verticalPadding : other.verticalPadding,
      itemSpacing: t < 0.5 ? itemSpacing : other.itemSpacing,
      iconSize: t < 0.5 ? iconSize : other.iconSize,
      defaultBackgroundColor:
          Color.lerp(
            defaultBackgroundColor,
            other.defaultBackgroundColor,
            t,
          ) ??
          defaultBackgroundColor,
      activeBackgroundColor:
          Color.lerp(activeBackgroundColor, other.activeBackgroundColor, t) ??
          activeBackgroundColor,
      disabledBackgroundColor:
          Color.lerp(
            disabledBackgroundColor,
            other.disabledBackgroundColor,
            t,
          ) ??
          disabledBackgroundColor,
      defaultLabelColor:
          Color.lerp(defaultLabelColor, other.defaultLabelColor, t) ??
          defaultLabelColor,
      activeLabelColor:
          Color.lerp(activeLabelColor, other.activeLabelColor, t) ??
          activeLabelColor,
      disabledLabelColor:
          Color.lerp(disabledLabelColor, other.disabledLabelColor, t) ??
          disabledLabelColor,
      iconColor: Color.lerp(iconColor, other.iconColor, t) ?? iconColor,
      disabledIconColor:
          Color.lerp(disabledIconColor, other.disabledIconColor, t) ??
          disabledIconColor,
    );
  }
}

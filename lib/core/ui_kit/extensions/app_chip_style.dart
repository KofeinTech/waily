import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_border_radius.dart';
import '../theme/app_spacing.dart';

/// Chip style tokens for the dark Waily theme.
///
/// Consumed by `WailyChip` to render the Figma `Chip` component-set: a pill
/// with a label, optional value text, and a trailing close icon. Variants:
/// `Type` ∈ {Default, 2 items} × `Color` ∈ {Dark, Light}.
@immutable
class AppChipStyle extends ThemeExtension<AppChipStyle> {
  const AppChipStyle._({
    required this.height,
    required this.borderRadius,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.itemSpacing,
    required this.iconSize,
    required this.darkBackgroundColor,
    required this.lightBackgroundColor,
    required this.disabledBackgroundColor,
    required this.labelColor,
    required this.valueColor,
    required this.iconColor,
    required this.disabledLabelColor,
    required this.disabledIconColor,
  });

  /// Container height. Figma: 36.
  final double height;

  /// Container corner radius. Figma: 8.
  final double borderRadius;

  /// Horizontal inner padding. Figma: 12.
  final double horizontalPadding;

  /// Vertical inner padding. Figma: 6.
  final double verticalPadding;

  /// Spacing between label, value, and close icon. Figma: 6.
  final double itemSpacing;

  /// Close icon canvas. Figma: 24x24.
  final double iconSize;

  /// Background for `Color=Dark` (Figma `surface` / #1D2534).
  final Color darkBackgroundColor;

  /// Background for `Color=Light` (Figma `borderStrong` / #3D475E).
  final Color lightBackgroundColor;

  /// Background in synthesized Disabled state.
  final Color disabledBackgroundColor;

  /// Label text color (s14w500). Figma: white.
  final Color labelColor;

  /// Value text color (s14w400). Figma: white.
  final Color valueColor;

  /// Close icon color. Figma: white.
  final Color iconColor;

  /// Label/value color in disabled state.
  final Color disabledLabelColor;

  /// Icon color in disabled state.
  final Color disabledIconColor;

  factory AppChipStyle.dark() => const AppChipStyle._(
    height: 36,
    borderRadius: AppBorderRadius.s,
    horizontalPadding: AppSpacing.sm,
    verticalPadding: 6,
    itemSpacing: 6,
    iconSize: 24,
    darkBackgroundColor: AppColors.surface,
    lightBackgroundColor: AppColors.borderStrong,
    disabledBackgroundColor: AppColors.surface,
    labelColor: AppColors.white,
    valueColor: AppColors.white,
    iconColor: AppColors.white,
    disabledLabelColor: AppColors.textDisabled,
    disabledIconColor: AppColors.textDisabled,
  );

  @override
  AppChipStyle copyWith({
    double? height,
    double? borderRadius,
    double? horizontalPadding,
    double? verticalPadding,
    double? itemSpacing,
    double? iconSize,
    Color? darkBackgroundColor,
    Color? lightBackgroundColor,
    Color? disabledBackgroundColor,
    Color? labelColor,
    Color? valueColor,
    Color? iconColor,
    Color? disabledLabelColor,
    Color? disabledIconColor,
  }) => AppChipStyle._(
    height: height ?? this.height,
    borderRadius: borderRadius ?? this.borderRadius,
    horizontalPadding: horizontalPadding ?? this.horizontalPadding,
    verticalPadding: verticalPadding ?? this.verticalPadding,
    itemSpacing: itemSpacing ?? this.itemSpacing,
    iconSize: iconSize ?? this.iconSize,
    darkBackgroundColor: darkBackgroundColor ?? this.darkBackgroundColor,
    lightBackgroundColor: lightBackgroundColor ?? this.lightBackgroundColor,
    disabledBackgroundColor:
        disabledBackgroundColor ?? this.disabledBackgroundColor,
    labelColor: labelColor ?? this.labelColor,
    valueColor: valueColor ?? this.valueColor,
    iconColor: iconColor ?? this.iconColor,
    disabledLabelColor: disabledLabelColor ?? this.disabledLabelColor,
    disabledIconColor: disabledIconColor ?? this.disabledIconColor,
  );

  @override
  AppChipStyle lerp(ThemeExtension<AppChipStyle>? other, double t) {
    if (other is! AppChipStyle) return this;
    return AppChipStyle._(
      height: t < 0.5 ? height : other.height,
      borderRadius: t < 0.5 ? borderRadius : other.borderRadius,
      horizontalPadding: t < 0.5 ? horizontalPadding : other.horizontalPadding,
      verticalPadding: t < 0.5 ? verticalPadding : other.verticalPadding,
      itemSpacing: t < 0.5 ? itemSpacing : other.itemSpacing,
      iconSize: t < 0.5 ? iconSize : other.iconSize,
      darkBackgroundColor:
          Color.lerp(darkBackgroundColor, other.darkBackgroundColor, t) ??
          darkBackgroundColor,
      lightBackgroundColor:
          Color.lerp(lightBackgroundColor, other.lightBackgroundColor, t) ??
          lightBackgroundColor,
      disabledBackgroundColor:
          Color.lerp(
            disabledBackgroundColor,
            other.disabledBackgroundColor,
            t,
          ) ??
          disabledBackgroundColor,
      labelColor: Color.lerp(labelColor, other.labelColor, t) ?? labelColor,
      valueColor: Color.lerp(valueColor, other.valueColor, t) ?? valueColor,
      iconColor: Color.lerp(iconColor, other.iconColor, t) ?? iconColor,
      disabledLabelColor:
          Color.lerp(disabledLabelColor, other.disabledLabelColor, t) ??
          disabledLabelColor,
      disabledIconColor:
          Color.lerp(disabledIconColor, other.disabledIconColor, t) ??
          disabledIconColor,
    );
  }
}

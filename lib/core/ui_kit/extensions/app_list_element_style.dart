import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// List element style tokens for the dark Waily theme.
///
/// Consumed by `WailyListElement` to render the Figma `List element`
/// component-set: `Type` ∈ {Default, 2 text}.
@immutable
class AppListElementStyle extends ThemeExtension<AppListElementStyle> {
  const AppListElementStyle._({
    required this.height,
    required this.verticalPadding,
    required this.itemSpacing,
    required this.iconSize,
    required this.labelColor,
    required this.valueColor,
    required this.iconColor,
    required this.disabledLabelColor,
    required this.disabledValueColor,
    required this.disabledIconColor,
  });

  /// Row height. Figma: 56.
  final double height;

  /// Vertical padding inside the row. Figma: 16.
  final double verticalPadding;

  /// Spacing between value and arrow. Figma: itemSpacing of inner Right
  /// side text element, ~6 visually.
  final double itemSpacing;

  /// Trailing arrow icon canvas. Figma: 24x24.
  final double iconSize;

  /// Label (left text) color. Figma: white, s16w500.
  final Color labelColor;

  /// Right side info text color. Figma: AppColors.textSecondary, s14w500.
  final Color valueColor;

  /// Trailing arrow color.
  final Color iconColor;

  final Color disabledLabelColor;
  final Color disabledValueColor;
  final Color disabledIconColor;

  factory AppListElementStyle.dark() => const AppListElementStyle._(
    height: 56,
    verticalPadding: 16,
    itemSpacing: 6,
    iconSize: 24,
    labelColor: AppColors.white,
    valueColor: AppColors.textSecondary,
    iconColor: AppColors.white,
    disabledLabelColor: AppColors.textDisabled,
    disabledValueColor: AppColors.textDisabled,
    disabledIconColor: AppColors.textDisabled,
  );

  @override
  AppListElementStyle copyWith({
    double? height,
    double? verticalPadding,
    double? itemSpacing,
    double? iconSize,
    Color? labelColor,
    Color? valueColor,
    Color? iconColor,
    Color? disabledLabelColor,
    Color? disabledValueColor,
    Color? disabledIconColor,
  }) => AppListElementStyle._(
    height: height ?? this.height,
    verticalPadding: verticalPadding ?? this.verticalPadding,
    itemSpacing: itemSpacing ?? this.itemSpacing,
    iconSize: iconSize ?? this.iconSize,
    labelColor: labelColor ?? this.labelColor,
    valueColor: valueColor ?? this.valueColor,
    iconColor: iconColor ?? this.iconColor,
    disabledLabelColor: disabledLabelColor ?? this.disabledLabelColor,
    disabledValueColor: disabledValueColor ?? this.disabledValueColor,
    disabledIconColor: disabledIconColor ?? this.disabledIconColor,
  );

  @override
  AppListElementStyle lerp(
    ThemeExtension<AppListElementStyle>? other,
    double t,
  ) {
    if (other is! AppListElementStyle) return this;
    return AppListElementStyle._(
      height: t < 0.5 ? height : other.height,
      verticalPadding: t < 0.5 ? verticalPadding : other.verticalPadding,
      itemSpacing: t < 0.5 ? itemSpacing : other.itemSpacing,
      iconSize: t < 0.5 ? iconSize : other.iconSize,
      labelColor: Color.lerp(labelColor, other.labelColor, t) ?? labelColor,
      valueColor: Color.lerp(valueColor, other.valueColor, t) ?? valueColor,
      iconColor: Color.lerp(iconColor, other.iconColor, t) ?? iconColor,
      disabledLabelColor:
          Color.lerp(disabledLabelColor, other.disabledLabelColor, t) ??
          disabledLabelColor,
      disabledValueColor:
          Color.lerp(disabledValueColor, other.disabledValueColor, t) ??
          disabledValueColor,
      disabledIconColor:
          Color.lerp(disabledIconColor, other.disabledIconColor, t) ??
          disabledIconColor,
    );
  }
}

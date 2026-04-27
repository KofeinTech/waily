import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_border_radius.dart';

/// Menu item container style tokens for the dark Waily theme.
///
/// Consumed by `WailyMenuItemContainer` to render the Figma `Menu Item Container`
/// component-set: `State` ∈ {Default, Active}.
@immutable
class AppMenuItemContainerStyle
    extends ThemeExtension<AppMenuItemContainerStyle> {
  const AppMenuItemContainerStyle._({
    required this.height,
    required this.borderRadius,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.itemSpacing,
    required this.iconSize,
    required this.defaultBackgroundColor,
    required this.activeBackgroundColor,
    required this.disabledBackgroundColor,
    required this.iconColor,
    required this.disabledIconColor,
    required this.labelColor,
    required this.disabledLabelColor,
  });

  /// Item height. Figma: 40.
  final double height;

  /// Active state corner radius. Figma: 8.
  final double borderRadius;

  /// Horizontal padding. Figma: 12.
  final double horizontalPadding;

  /// Vertical padding. Figma: 8.
  final double verticalPadding;

  /// Spacing between icon and label (Active state). Figma: 4.
  final double itemSpacing;

  /// Icon canvas. Figma: 24x24.
  final double iconSize;

  /// Default background — Figma: transparent.
  final Color defaultBackgroundColor;

  /// Active background. Figma: AppColors.borderStrong (#3D475E).
  final Color activeBackgroundColor;

  /// Background while disabled.
  final Color disabledBackgroundColor;

  /// Icon color.
  final Color iconColor;

  /// Icon color when disabled.
  final Color disabledIconColor;

  /// Label color (Active state).
  final Color labelColor;

  /// Label color when disabled.
  final Color disabledLabelColor;

  factory AppMenuItemContainerStyle.dark() => const AppMenuItemContainerStyle._(
    height: 40,
    borderRadius: AppBorderRadius.s,
    horizontalPadding: 12,
    verticalPadding: 8,
    itemSpacing: 4,
    iconSize: 24,
    defaultBackgroundColor: Color(0x00000000),
    activeBackgroundColor: AppColors.borderStrong,
    disabledBackgroundColor: Color(0x00000000),
    iconColor: AppColors.white,
    disabledIconColor: AppColors.textDisabled,
    labelColor: AppColors.white,
    disabledLabelColor: AppColors.textDisabled,
  );

  @override
  AppMenuItemContainerStyle copyWith({
    double? height,
    double? borderRadius,
    double? horizontalPadding,
    double? verticalPadding,
    double? itemSpacing,
    double? iconSize,
    Color? defaultBackgroundColor,
    Color? activeBackgroundColor,
    Color? disabledBackgroundColor,
    Color? iconColor,
    Color? disabledIconColor,
    Color? labelColor,
    Color? disabledLabelColor,
  }) => AppMenuItemContainerStyle._(
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
    iconColor: iconColor ?? this.iconColor,
    disabledIconColor: disabledIconColor ?? this.disabledIconColor,
    labelColor: labelColor ?? this.labelColor,
    disabledLabelColor: disabledLabelColor ?? this.disabledLabelColor,
  );

  @override
  AppMenuItemContainerStyle lerp(
    ThemeExtension<AppMenuItemContainerStyle>? other,
    double t,
  ) {
    if (other is! AppMenuItemContainerStyle) return this;
    return AppMenuItemContainerStyle._(
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
      iconColor: Color.lerp(iconColor, other.iconColor, t) ?? iconColor,
      disabledIconColor:
          Color.lerp(disabledIconColor, other.disabledIconColor, t) ??
          disabledIconColor,
      labelColor: Color.lerp(labelColor, other.labelColor, t) ?? labelColor,
      disabledLabelColor:
          Color.lerp(disabledLabelColor, other.disabledLabelColor, t) ??
          disabledLabelColor,
    );
  }
}

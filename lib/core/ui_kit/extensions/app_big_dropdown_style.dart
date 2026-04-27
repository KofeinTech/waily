import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Big dropdown style tokens for the dark Waily theme.
///
/// Consumed by `WailyBigDropdown` to render the Figma `Big Dropdown`
/// component-set. The container is a translucent white card; the trigger
/// shows a title, optional subtitle, and a trailing chevron.
@immutable
class AppBigDropdownStyle extends ThemeExtension<AppBigDropdownStyle> {
  const AppBigDropdownStyle._({
    required this.height,
    required this.borderRadius,
    required this.padding,
    required this.titleSubtitleSpacing,
    required this.iconSize,
    required this.backgroundColor,
    required this.disabledBackgroundColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.disabledTitleColor,
    required this.disabledSubtitleColor,
    required this.iconColor,
    required this.disabledIconColor,
  });

  /// Container height. Figma: 70.
  final double height;

  /// Container corner radius. Figma: 14.
  final double borderRadius;

  /// Inner inset. Figma: 12.
  final double padding;

  /// Vertical gap between title and subtitle. Figma: 6.
  final double titleSubtitleSpacing;

  /// Trailing chevron canvas. Figma: 24x24.
  final double iconSize;

  /// Container background — Figma renders white at 4% opacity.
  final Color backgroundColor;

  /// Container background while disabled.
  final Color disabledBackgroundColor;

  /// Title color. Figma: white.
  final Color titleColor;

  /// Subtitle color. Figma: AppColors.textSecondary (#9EA3AE).
  final Color subtitleColor;

  /// Title color when disabled.
  final Color disabledTitleColor;

  /// Subtitle color when disabled.
  final Color disabledSubtitleColor;

  /// Trailing chevron color.
  final Color iconColor;

  /// Trailing chevron color when disabled.
  final Color disabledIconColor;

  factory AppBigDropdownStyle.dark() => AppBigDropdownStyle._(
    height: 70,
    borderRadius: 14,
    padding: 12,
    titleSubtitleSpacing: 6,
    iconSize: 24,
    backgroundColor: AppColors.white.withValues(alpha: 0.04),
    disabledBackgroundColor: AppColors.white.withValues(alpha: 0.02),
    titleColor: AppColors.white,
    subtitleColor: AppColors.textSecondary,
    disabledTitleColor: AppColors.textDisabled,
    disabledSubtitleColor: AppColors.textDisabled,
    iconColor: AppColors.white,
    disabledIconColor: AppColors.textDisabled,
  );

  @override
  AppBigDropdownStyle copyWith({
    double? height,
    double? borderRadius,
    double? padding,
    double? titleSubtitleSpacing,
    double? iconSize,
    Color? backgroundColor,
    Color? disabledBackgroundColor,
    Color? titleColor,
    Color? subtitleColor,
    Color? disabledTitleColor,
    Color? disabledSubtitleColor,
    Color? iconColor,
    Color? disabledIconColor,
  }) => AppBigDropdownStyle._(
    height: height ?? this.height,
    borderRadius: borderRadius ?? this.borderRadius,
    padding: padding ?? this.padding,
    titleSubtitleSpacing: titleSubtitleSpacing ?? this.titleSubtitleSpacing,
    iconSize: iconSize ?? this.iconSize,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    disabledBackgroundColor:
        disabledBackgroundColor ?? this.disabledBackgroundColor,
    titleColor: titleColor ?? this.titleColor,
    subtitleColor: subtitleColor ?? this.subtitleColor,
    disabledTitleColor: disabledTitleColor ?? this.disabledTitleColor,
    disabledSubtitleColor:
        disabledSubtitleColor ?? this.disabledSubtitleColor,
    iconColor: iconColor ?? this.iconColor,
    disabledIconColor: disabledIconColor ?? this.disabledIconColor,
  );

  @override
  AppBigDropdownStyle lerp(
    ThemeExtension<AppBigDropdownStyle>? other,
    double t,
  ) {
    if (other is! AppBigDropdownStyle) return this;
    return AppBigDropdownStyle._(
      height: t < 0.5 ? height : other.height,
      borderRadius: t < 0.5 ? borderRadius : other.borderRadius,
      padding: t < 0.5 ? padding : other.padding,
      titleSubtitleSpacing: t < 0.5
          ? titleSubtitleSpacing
          : other.titleSubtitleSpacing,
      iconSize: t < 0.5 ? iconSize : other.iconSize,
      backgroundColor:
          Color.lerp(backgroundColor, other.backgroundColor, t) ??
          backgroundColor,
      disabledBackgroundColor:
          Color.lerp(
            disabledBackgroundColor,
            other.disabledBackgroundColor,
            t,
          ) ??
          disabledBackgroundColor,
      titleColor: Color.lerp(titleColor, other.titleColor, t) ?? titleColor,
      subtitleColor:
          Color.lerp(subtitleColor, other.subtitleColor, t) ?? subtitleColor,
      disabledTitleColor:
          Color.lerp(disabledTitleColor, other.disabledTitleColor, t) ??
          disabledTitleColor,
      disabledSubtitleColor:
          Color.lerp(disabledSubtitleColor, other.disabledSubtitleColor, t) ??
          disabledSubtitleColor,
      iconColor: Color.lerp(iconColor, other.iconColor, t) ?? iconColor,
      disabledIconColor:
          Color.lerp(disabledIconColor, other.disabledIconColor, t) ??
          disabledIconColor,
    );
  }
}

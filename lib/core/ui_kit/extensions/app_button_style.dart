// lib/core/ui_kit/extensions/app_button_style.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../theme/app_border_radius.dart';

/// Button style tokens for the dark Waily theme.
///
/// Consumed by [WailyButton] to build button visuals without Material defaults.
///
/// Variants follow the Figma `Button` component-set:
/// `Type` ∈ {Primary, Secondary} × `Size` ∈ {Default, Big} ×
/// `State` ∈ {Default, Pressed, Disabled, Loading}.
@immutable
class AppButtonStyle extends ThemeExtension<AppButtonStyle> {
  const AppButtonStyle._({
    required this.primaryBackground,
    required this.primaryForeground,
    required this.secondaryBackground,
    required this.secondaryForeground,
    required this.disabledBackground,
    required this.disabledForeground,
    required this.borderRadiusDefault,
    required this.borderRadiusBig,
    required this.paddingDefault,
    required this.paddingBig,
    required this.heightDefault,
    required this.heightBig,
    required this.textStyleDefault,
    required this.textStyleBig,
  });

  final Color primaryBackground;
  final Color primaryForeground;
  final Color secondaryBackground;
  final Color secondaryForeground;
  final Color disabledBackground;
  final Color disabledForeground;
  final double borderRadiusDefault;
  final double borderRadiusBig;
  final EdgeInsets paddingDefault;
  final EdgeInsets paddingBig;
  final double heightDefault;
  final double heightBig;
  final TextStyle textStyleDefault;
  final TextStyle textStyleBig;

  factory AppButtonStyle.dark() => AppButtonStyle._(
    // Primary fill: Figma Button / Type=Primary, State=Default => #D4E1FF.
    primaryBackground: AppColors.primary,
    // Primary label color sits on light blue surface — use surface dark.
    primaryForeground: AppColors.surfaceVariant,
    // Secondary fill: Figma Button / Type=Secondary, State=Default => #FFFFFF.
    secondaryBackground: AppColors.white,
    secondaryForeground: AppColors.surfaceVariant,
    // Disabled fill: Figma Button / State=Disabled => #9EA3AE (textSecondary).
    disabledBackground: AppColors.textSecondary,
    disabledForeground: AppColors.textPlaceholder,
    borderRadiusDefault: AppBorderRadius.m, // 12 (Figma Default)
    borderRadiusBig: AppBorderRadius.l, // 16 (plan hint for Big)
    paddingDefault: const EdgeInsets.symmetric(
      vertical: AppSpacing.m, // 16
      horizontal: AppSpacing.ml, // 20
    ),
    paddingBig: const EdgeInsets.symmetric(
      vertical: AppSpacing.ml, // 20
      horizontal: AppSpacing.l, // 24
    ),
    heightDefault: 52, // Figma Default size height
    heightBig: 64, // plan hint for Big
    textStyleDefault: AppTypography.s16w500(),
    textStyleBig: AppTypography.s18w500(),
  );

  @override
  AppButtonStyle copyWith({
    Color? primaryBackground,
    Color? primaryForeground,
    Color? secondaryBackground,
    Color? secondaryForeground,
    Color? disabledBackground,
    Color? disabledForeground,
    double? borderRadiusDefault,
    double? borderRadiusBig,
    EdgeInsets? paddingDefault,
    EdgeInsets? paddingBig,
    double? heightDefault,
    double? heightBig,
    TextStyle? textStyleDefault,
    TextStyle? textStyleBig,
  }) => AppButtonStyle._(
    primaryBackground: primaryBackground ?? this.primaryBackground,
    primaryForeground: primaryForeground ?? this.primaryForeground,
    secondaryBackground: secondaryBackground ?? this.secondaryBackground,
    secondaryForeground: secondaryForeground ?? this.secondaryForeground,
    disabledBackground: disabledBackground ?? this.disabledBackground,
    disabledForeground: disabledForeground ?? this.disabledForeground,
    borderRadiusDefault: borderRadiusDefault ?? this.borderRadiusDefault,
    borderRadiusBig: borderRadiusBig ?? this.borderRadiusBig,
    paddingDefault: paddingDefault ?? this.paddingDefault,
    paddingBig: paddingBig ?? this.paddingBig,
    heightDefault: heightDefault ?? this.heightDefault,
    heightBig: heightBig ?? this.heightBig,
    textStyleDefault: textStyleDefault ?? this.textStyleDefault,
    textStyleBig: textStyleBig ?? this.textStyleBig,
  );

  @override
  AppButtonStyle lerp(ThemeExtension<AppButtonStyle>? other, double t) {
    if (other is! AppButtonStyle) return this;
    return AppButtonStyle._(
      primaryBackground:
          Color.lerp(primaryBackground, other.primaryBackground, t) ??
          primaryBackground,
      primaryForeground:
          Color.lerp(primaryForeground, other.primaryForeground, t) ??
          primaryForeground,
      secondaryBackground:
          Color.lerp(secondaryBackground, other.secondaryBackground, t) ??
          secondaryBackground,
      secondaryForeground:
          Color.lerp(secondaryForeground, other.secondaryForeground, t) ??
          secondaryForeground,
      disabledBackground:
          Color.lerp(disabledBackground, other.disabledBackground, t) ??
          disabledBackground,
      disabledForeground:
          Color.lerp(disabledForeground, other.disabledForeground, t) ??
          disabledForeground,
      borderRadiusDefault: t < 0.5
          ? borderRadiusDefault
          : other.borderRadiusDefault,
      borderRadiusBig: t < 0.5 ? borderRadiusBig : other.borderRadiusBig,
      paddingDefault:
          EdgeInsets.lerp(paddingDefault, other.paddingDefault, t) ??
          paddingDefault,
      paddingBig:
          EdgeInsets.lerp(paddingBig, other.paddingBig, t) ?? paddingBig,
      heightDefault: t < 0.5 ? heightDefault : other.heightDefault,
      heightBig: t < 0.5 ? heightBig : other.heightBig,
      textStyleDefault:
          TextStyle.lerp(textStyleDefault, other.textStyleDefault, t) ??
          textStyleDefault,
      textStyleBig:
          TextStyle.lerp(textStyleBig, other.textStyleBig, t) ?? textStyleBig,
    );
  }
}

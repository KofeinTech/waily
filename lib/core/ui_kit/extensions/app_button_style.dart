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
/// `Type` ∈ {Primary, Secondary} × `Size` ∈ {Default, Small} ×
/// `State` ∈ {Default, Pressed, Disabled, Loading}.
@immutable
class AppButtonStyle extends ThemeExtension<AppButtonStyle> {
  const AppButtonStyle._({
    required this.primaryBackground,
    required this.primaryPressedBackground,
    required this.primaryForeground,
    required this.secondaryBackground,
    required this.secondaryPressedBackground,
    required this.secondaryForeground,
    required this.disabledBackground,
    required this.disabledForeground,
    required this.borderRadiusDefault,
    required this.borderRadiusSmall,
    required this.paddingDefault,
    required this.paddingSmall,
    required this.heightDefault,
    required this.heightSmall,
    required this.textStyleDefault,
    required this.textStyleSmall,
  });

  final Color primaryBackground;
  final Color primaryPressedBackground;
  final Color primaryForeground;
  final Color secondaryBackground;
  final Color secondaryPressedBackground;
  final Color secondaryForeground;
  final Color disabledBackground;
  final Color disabledForeground;
  final double borderRadiusDefault;
  final double borderRadiusSmall;
  final EdgeInsets paddingDefault;
  final EdgeInsets paddingSmall;
  final double heightDefault;
  final double heightSmall;
  final TextStyle textStyleDefault;
  final TextStyle textStyleSmall;

  factory AppButtonStyle.dark() => AppButtonStyle._(
    // Primary fill: Figma Button / Type=Primary, State=Default => #D4E1FF.
    primaryBackground: AppColors.primary,
    // Primary pressed: Figma Button / Type=Primary, State=Pressed => #E5EDFF.
    primaryPressedBackground: AppColors.primaryLowest,
    // Primary label color sits on light blue surface — use surface dark.
    primaryForeground: AppColors.surfaceVariant,
    // Secondary fill: Figma Button / Type=Secondary, State=Default => #FFFFFF.
    secondaryBackground: AppColors.white,
    // Secondary pressed: Figma shows the same #FFFFFF for State=Pressed.
    secondaryPressedBackground: AppColors.white,
    secondaryForeground: AppColors.surfaceVariant,
    // Disabled fill: Figma Button / State=Disabled => #9EA3AE (textSecondary).
    disabledBackground: AppColors.textSecondary,
    disabledForeground: AppColors.textPlaceholder,
    borderRadiusDefault: AppBorderRadius.m, // 12 (Figma Default)
    borderRadiusSmall: AppBorderRadius.s, // 8 (Figma Small)
    paddingDefault: const EdgeInsets.symmetric(
      vertical: AppSpacing.m, // 16
      horizontal: AppSpacing.ml, // 20
    ),
    paddingSmall: const EdgeInsets.symmetric(
      vertical: AppSpacing.sm, // 12
      horizontal: AppSpacing.m, // 16
    ),
    heightDefault: 52, // Figma Default size height
    heightSmall: 42, // Figma Small size height
    textStyleDefault: AppTypography.s16w500(),
    textStyleSmall: AppTypography.s14w500(),
  );

  @override
  AppButtonStyle copyWith({
    Color? primaryBackground,
    Color? primaryPressedBackground,
    Color? primaryForeground,
    Color? secondaryBackground,
    Color? secondaryPressedBackground,
    Color? secondaryForeground,
    Color? disabledBackground,
    Color? disabledForeground,
    double? borderRadiusDefault,
    double? borderRadiusSmall,
    EdgeInsets? paddingDefault,
    EdgeInsets? paddingSmall,
    double? heightDefault,
    double? heightSmall,
    TextStyle? textStyleDefault,
    TextStyle? textStyleSmall,
  }) => AppButtonStyle._(
    primaryBackground: primaryBackground ?? this.primaryBackground,
    primaryPressedBackground:
        primaryPressedBackground ?? this.primaryPressedBackground,
    primaryForeground: primaryForeground ?? this.primaryForeground,
    secondaryBackground: secondaryBackground ?? this.secondaryBackground,
    secondaryPressedBackground:
        secondaryPressedBackground ?? this.secondaryPressedBackground,
    secondaryForeground: secondaryForeground ?? this.secondaryForeground,
    disabledBackground: disabledBackground ?? this.disabledBackground,
    disabledForeground: disabledForeground ?? this.disabledForeground,
    borderRadiusDefault: borderRadiusDefault ?? this.borderRadiusDefault,
    borderRadiusSmall: borderRadiusSmall ?? this.borderRadiusSmall,
    paddingDefault: paddingDefault ?? this.paddingDefault,
    paddingSmall: paddingSmall ?? this.paddingSmall,
    heightDefault: heightDefault ?? this.heightDefault,
    heightSmall: heightSmall ?? this.heightSmall,
    textStyleDefault: textStyleDefault ?? this.textStyleDefault,
    textStyleSmall: textStyleSmall ?? this.textStyleSmall,
  );

  @override
  AppButtonStyle lerp(ThemeExtension<AppButtonStyle>? other, double t) {
    if (other is! AppButtonStyle) return this;
    return AppButtonStyle._(
      primaryBackground:
          Color.lerp(primaryBackground, other.primaryBackground, t) ??
          primaryBackground,
      primaryPressedBackground:
          Color.lerp(
            primaryPressedBackground,
            other.primaryPressedBackground,
            t,
          ) ??
          primaryPressedBackground,
      primaryForeground:
          Color.lerp(primaryForeground, other.primaryForeground, t) ??
          primaryForeground,
      secondaryBackground:
          Color.lerp(secondaryBackground, other.secondaryBackground, t) ??
          secondaryBackground,
      secondaryPressedBackground:
          Color.lerp(
            secondaryPressedBackground,
            other.secondaryPressedBackground,
            t,
          ) ??
          secondaryPressedBackground,
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
      borderRadiusSmall: t < 0.5 ? borderRadiusSmall : other.borderRadiusSmall,
      paddingDefault:
          EdgeInsets.lerp(paddingDefault, other.paddingDefault, t) ??
          paddingDefault,
      paddingSmall:
          EdgeInsets.lerp(paddingSmall, other.paddingSmall, t) ?? paddingSmall,
      heightDefault: t < 0.5 ? heightDefault : other.heightDefault,
      heightSmall: t < 0.5 ? heightSmall : other.heightSmall,
      textStyleDefault:
          TextStyle.lerp(textStyleDefault, other.textStyleDefault, t) ??
          textStyleDefault,
      textStyleSmall:
          TextStyle.lerp(textStyleSmall, other.textStyleSmall, t) ??
          textStyleSmall,
    );
  }
}

// lib/core/ui_kit/extensions/app_button_style.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../theme/app_border_radius.dart';

/// Button style tokens for the dark Waily theme.
///
/// Consumed by [WailyButton] to build [ButtonStyle] without Material defaults.
@immutable
class AppButtonStyle extends ThemeExtension<AppButtonStyle> {
  const AppButtonStyle._({
    required this.primaryBackground,
    required this.primaryForeground,
    required this.secondaryBackground,
    required this.secondaryForeground,
    required this.outlinedBorderColor,
    required this.outlinedForeground,
    required this.disabledBackground,
    required this.disabledForeground,
    required this.borderRadius,
    required this.padding,
    required this.textStyle,
  });

  final Color primaryBackground;
  final Color primaryForeground;
  final Color secondaryBackground;
  final Color secondaryForeground;
  final Color outlinedBorderColor;
  final Color outlinedForeground;
  final Color disabledBackground;
  final Color disabledForeground;
  final double borderRadius;
  final EdgeInsets padding;
  final TextStyle textStyle;

  factory AppButtonStyle.dark() => AppButtonStyle._(
    primaryBackground: AppColors.primarySubtle,
    primaryForeground: AppColors.surfaceVariant,
    secondaryBackground: AppColors.surface,
    secondaryForeground: AppColors.textPrimary,
    outlinedBorderColor: AppColors.primarySubtle,
    outlinedForeground: AppColors.primarySubtle,
    disabledBackground: AppColors.textSecondary,
    disabledForeground: AppColors.surfaceVariant,
    borderRadius: AppBorderRadius.m,
    padding: const EdgeInsets.symmetric(
      vertical: AppSpacing.m,
      horizontal: AppSpacing.ml,
    ),
    textStyle: AppTypography.s16w500(),
  );

  @override
  AppButtonStyle copyWith({
    Color? primaryBackground,
    Color? primaryForeground,
    Color? secondaryBackground,
    Color? secondaryForeground,
    Color? outlinedBorderColor,
    Color? outlinedForeground,
    Color? disabledBackground,
    Color? disabledForeground,
    double? borderRadius,
    EdgeInsets? padding,
    TextStyle? textStyle,
  }) => AppButtonStyle._(
    primaryBackground: primaryBackground ?? this.primaryBackground,
    primaryForeground: primaryForeground ?? this.primaryForeground,
    secondaryBackground: secondaryBackground ?? this.secondaryBackground,
    secondaryForeground: secondaryForeground ?? this.secondaryForeground,
    outlinedBorderColor: outlinedBorderColor ?? this.outlinedBorderColor,
    outlinedForeground: outlinedForeground ?? this.outlinedForeground,
    disabledBackground: disabledBackground ?? this.disabledBackground,
    disabledForeground: disabledForeground ?? this.disabledForeground,
    borderRadius: borderRadius ?? this.borderRadius,
    padding: padding ?? this.padding,
    textStyle: textStyle ?? this.textStyle,
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
      outlinedBorderColor:
          Color.lerp(outlinedBorderColor, other.outlinedBorderColor, t) ??
          outlinedBorderColor,
      outlinedForeground:
          Color.lerp(outlinedForeground, other.outlinedForeground, t) ??
          outlinedForeground,
      disabledBackground:
          Color.lerp(disabledBackground, other.disabledBackground, t) ??
          disabledBackground,
      disabledForeground:
          Color.lerp(disabledForeground, other.disabledForeground, t) ??
          disabledForeground,
      borderRadius: t < 0.5 ? borderRadius : other.borderRadius,
      padding: EdgeInsets.lerp(padding, other.padding, t) ?? padding,
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t) ?? textStyle,
    );
  }
}

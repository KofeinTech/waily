import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_border_radius.dart';

/// Option style tokens for the dark Waily theme.
///
/// Consumed by `WailyOption` to render the Figma `Option` component-set:
/// `State` ∈ {Default, Selected} plus a synthesized Disabled state.
@immutable
class AppOptionStyle extends ThemeExtension<AppOptionStyle> {
  const AppOptionStyle._({
    required this.height,
    required this.borderRadius,
    required this.padding,
    required this.titleDescriptionSpacing,
    required this.defaultBackgroundColor,
    required this.selectedBackgroundColor,
    required this.disabledBackgroundColor,
    required this.defaultTitleColor,
    required this.selectedTitleColor,
    required this.disabledTitleColor,
    required this.defaultDescriptionColor,
    required this.selectedDescriptionColor,
    required this.disabledDescriptionColor,
  });

  /// Card height. Figma: 70.
  final double height;

  /// Card corner radius. Figma: 12.
  final double borderRadius;

  /// Inner inset. Figma: 12.
  final double padding;

  /// Vertical gap between title and description. Figma: 6.
  final double titleDescriptionSpacing;

  /// Default state background. Figma: transparent.
  final Color defaultBackgroundColor;

  /// Selected state background. Figma: AppColors.primary (#D4E1FF).
  final Color selectedBackgroundColor;

  /// Disabled state background.
  final Color disabledBackgroundColor;

  /// Default title color. Figma: white.
  final Color defaultTitleColor;

  /// Selected title color. Figma: AppColors.background (#020815).
  final Color selectedTitleColor;

  /// Disabled title color.
  final Color disabledTitleColor;

  /// Default description color. Figma: AppColors.textSecondary (#9EA3AE).
  final Color defaultDescriptionColor;

  /// Selected description color. Figma: AppColors.textDisabled (#555A66).
  final Color selectedDescriptionColor;

  /// Disabled description color.
  final Color disabledDescriptionColor;

  factory AppOptionStyle.dark() => const AppOptionStyle._(
    height: 70,
    borderRadius: AppBorderRadius.m,
    padding: 12,
    titleDescriptionSpacing: 6,
    defaultBackgroundColor: Color(0x00000000),
    selectedBackgroundColor: AppColors.primary,
    disabledBackgroundColor: AppColors.surface,
    defaultTitleColor: AppColors.white,
    selectedTitleColor: AppColors.background,
    disabledTitleColor: AppColors.textDisabled,
    defaultDescriptionColor: AppColors.textSecondary,
    selectedDescriptionColor: AppColors.textDisabled,
    disabledDescriptionColor: AppColors.textDisabled,
  );

  @override
  AppOptionStyle copyWith({
    double? height,
    double? borderRadius,
    double? padding,
    double? titleDescriptionSpacing,
    Color? defaultBackgroundColor,
    Color? selectedBackgroundColor,
    Color? disabledBackgroundColor,
    Color? defaultTitleColor,
    Color? selectedTitleColor,
    Color? disabledTitleColor,
    Color? defaultDescriptionColor,
    Color? selectedDescriptionColor,
    Color? disabledDescriptionColor,
  }) => AppOptionStyle._(
    height: height ?? this.height,
    borderRadius: borderRadius ?? this.borderRadius,
    padding: padding ?? this.padding,
    titleDescriptionSpacing:
        titleDescriptionSpacing ?? this.titleDescriptionSpacing,
    defaultBackgroundColor:
        defaultBackgroundColor ?? this.defaultBackgroundColor,
    selectedBackgroundColor:
        selectedBackgroundColor ?? this.selectedBackgroundColor,
    disabledBackgroundColor:
        disabledBackgroundColor ?? this.disabledBackgroundColor,
    defaultTitleColor: defaultTitleColor ?? this.defaultTitleColor,
    selectedTitleColor: selectedTitleColor ?? this.selectedTitleColor,
    disabledTitleColor: disabledTitleColor ?? this.disabledTitleColor,
    defaultDescriptionColor:
        defaultDescriptionColor ?? this.defaultDescriptionColor,
    selectedDescriptionColor:
        selectedDescriptionColor ?? this.selectedDescriptionColor,
    disabledDescriptionColor:
        disabledDescriptionColor ?? this.disabledDescriptionColor,
  );

  @override
  AppOptionStyle lerp(ThemeExtension<AppOptionStyle>? other, double t) {
    if (other is! AppOptionStyle) return this;
    return AppOptionStyle._(
      height: t < 0.5 ? height : other.height,
      borderRadius: t < 0.5 ? borderRadius : other.borderRadius,
      padding: t < 0.5 ? padding : other.padding,
      titleDescriptionSpacing: t < 0.5
          ? titleDescriptionSpacing
          : other.titleDescriptionSpacing,
      defaultBackgroundColor:
          Color.lerp(
            defaultBackgroundColor,
            other.defaultBackgroundColor,
            t,
          ) ??
          defaultBackgroundColor,
      selectedBackgroundColor:
          Color.lerp(
            selectedBackgroundColor,
            other.selectedBackgroundColor,
            t,
          ) ??
          selectedBackgroundColor,
      disabledBackgroundColor:
          Color.lerp(
            disabledBackgroundColor,
            other.disabledBackgroundColor,
            t,
          ) ??
          disabledBackgroundColor,
      defaultTitleColor:
          Color.lerp(defaultTitleColor, other.defaultTitleColor, t) ??
          defaultTitleColor,
      selectedTitleColor:
          Color.lerp(selectedTitleColor, other.selectedTitleColor, t) ??
          selectedTitleColor,
      disabledTitleColor:
          Color.lerp(disabledTitleColor, other.disabledTitleColor, t) ??
          disabledTitleColor,
      defaultDescriptionColor:
          Color.lerp(
            defaultDescriptionColor,
            other.defaultDescriptionColor,
            t,
          ) ??
          defaultDescriptionColor,
      selectedDescriptionColor:
          Color.lerp(
            selectedDescriptionColor,
            other.selectedDescriptionColor,
            t,
          ) ??
          selectedDescriptionColor,
      disabledDescriptionColor:
          Color.lerp(
            disabledDescriptionColor,
            other.disabledDescriptionColor,
            t,
          ) ??
          disabledDescriptionColor,
    );
  }
}

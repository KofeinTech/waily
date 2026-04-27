import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_border_radius.dart';

/// Picker card style tokens for the dark Waily theme.
///
/// Consumed by `WailyPickerCard` to render the Figma `Picker Card`
/// component-set: `State` ∈ {Default, Active, Active with Input}.
@immutable
class AppPickerCardStyle extends ThemeExtension<AppPickerCardStyle> {
  const AppPickerCardStyle._({
    required this.borderRadius,
    required this.padding,
    required this.itemSpacing,
    required this.checkboxSize,
    required this.defaultBackgroundColor,
    required this.activeBackgroundColor,
    required this.disabledBackgroundColor,
    required this.defaultTitleColor,
    required this.activeTitleColor,
    required this.disabledTitleColor,
    required this.defaultSubtitleColor,
    required this.activeSubtitleColor,
    required this.disabledSubtitleColor,
  });

  /// Card corner radius. Figma: 16.
  final double borderRadius;

  /// Inner padding. Figma: 16.
  final double padding;

  /// Vertical gap between title and subtitle. Figma: 4.
  final double itemSpacing;

  /// Trailing checkbox canvas. Figma: 24x24.
  final double checkboxSize;

  /// Default background — Figma: white at 4% opacity.
  final Color defaultBackgroundColor;

  /// Active background — Figma: AppColors.primary (#D4E1FF).
  final Color activeBackgroundColor;

  /// Disabled background.
  final Color disabledBackgroundColor;

  /// Default title color. Figma: white.
  final Color defaultTitleColor;

  /// Active title color. Figma: AppColors.surfaceVariant (#252B38).
  final Color activeTitleColor;

  /// Disabled title color.
  final Color disabledTitleColor;

  /// Default subtitle color. Figma: AppColors.textSecondary.
  final Color defaultSubtitleColor;

  /// Active subtitle color. Figma: AppColors.textDisabled (#555A66).
  final Color activeSubtitleColor;

  /// Disabled subtitle color.
  final Color disabledSubtitleColor;

  factory AppPickerCardStyle.dark() => AppPickerCardStyle._(
    borderRadius: AppBorderRadius.l,
    padding: 16,
    itemSpacing: 4,
    checkboxSize: 24,
    defaultBackgroundColor: AppColors.white.withValues(alpha: 0.04),
    activeBackgroundColor: AppColors.primary,
    disabledBackgroundColor: AppColors.white.withValues(alpha: 0.02),
    defaultTitleColor: AppColors.white,
    activeTitleColor: AppColors.surfaceVariant,
    disabledTitleColor: AppColors.textDisabled,
    defaultSubtitleColor: AppColors.textSecondary,
    activeSubtitleColor: AppColors.textDisabled,
    disabledSubtitleColor: AppColors.textDisabled,
  );

  @override
  AppPickerCardStyle copyWith({
    double? borderRadius,
    double? padding,
    double? itemSpacing,
    double? checkboxSize,
    Color? defaultBackgroundColor,
    Color? activeBackgroundColor,
    Color? disabledBackgroundColor,
    Color? defaultTitleColor,
    Color? activeTitleColor,
    Color? disabledTitleColor,
    Color? defaultSubtitleColor,
    Color? activeSubtitleColor,
    Color? disabledSubtitleColor,
  }) => AppPickerCardStyle._(
    borderRadius: borderRadius ?? this.borderRadius,
    padding: padding ?? this.padding,
    itemSpacing: itemSpacing ?? this.itemSpacing,
    checkboxSize: checkboxSize ?? this.checkboxSize,
    defaultBackgroundColor:
        defaultBackgroundColor ?? this.defaultBackgroundColor,
    activeBackgroundColor:
        activeBackgroundColor ?? this.activeBackgroundColor,
    disabledBackgroundColor:
        disabledBackgroundColor ?? this.disabledBackgroundColor,
    defaultTitleColor: defaultTitleColor ?? this.defaultTitleColor,
    activeTitleColor: activeTitleColor ?? this.activeTitleColor,
    disabledTitleColor: disabledTitleColor ?? this.disabledTitleColor,
    defaultSubtitleColor: defaultSubtitleColor ?? this.defaultSubtitleColor,
    activeSubtitleColor: activeSubtitleColor ?? this.activeSubtitleColor,
    disabledSubtitleColor:
        disabledSubtitleColor ?? this.disabledSubtitleColor,
  );

  @override
  AppPickerCardStyle lerp(
    ThemeExtension<AppPickerCardStyle>? other,
    double t,
  ) {
    if (other is! AppPickerCardStyle) return this;
    return AppPickerCardStyle._(
      borderRadius: t < 0.5 ? borderRadius : other.borderRadius,
      padding: t < 0.5 ? padding : other.padding,
      itemSpacing: t < 0.5 ? itemSpacing : other.itemSpacing,
      checkboxSize: t < 0.5 ? checkboxSize : other.checkboxSize,
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
      defaultTitleColor:
          Color.lerp(defaultTitleColor, other.defaultTitleColor, t) ??
          defaultTitleColor,
      activeTitleColor:
          Color.lerp(activeTitleColor, other.activeTitleColor, t) ??
          activeTitleColor,
      disabledTitleColor:
          Color.lerp(disabledTitleColor, other.disabledTitleColor, t) ??
          disabledTitleColor,
      defaultSubtitleColor:
          Color.lerp(defaultSubtitleColor, other.defaultSubtitleColor, t) ??
          defaultSubtitleColor,
      activeSubtitleColor:
          Color.lerp(activeSubtitleColor, other.activeSubtitleColor, t) ??
          activeSubtitleColor,
      disabledSubtitleColor:
          Color.lerp(
            disabledSubtitleColor,
            other.disabledSubtitleColor,
            t,
          ) ??
          disabledSubtitleColor,
    );
  }
}
